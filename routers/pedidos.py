"""Pedidos persistidos: estoque, saldo e estornos na mesma transação."""
from datetime import datetime, timezone, timedelta
from decimal import Decimal
from typing import Literal
from fastapi import APIRouter, Depends, HTTPException, Request
from pydantic import BaseModel, Field
from sqlalchemy import select, text, delete, update
from sqlalchemy.orm import Session
from database.database import get_db
from models.pedido import Pedido, ItemPedido, Movimentacao
from models.produto import Produto
from models.usuario import Usuario, Estudante
from services.permissoes import usuario_atual, aluno_acessivel

router = APIRouter(prefix="/api/pedidos", tags=["pedidos"])
ESGOTADO = "Que pena! O item esgotou segundos atrás. Seu saldo não foi alterado."


class ItemEntrada(BaseModel):
    produto_id: int = Field(gt=0)
    quantidade: int = Field(gt=0, le=1000)


class PedidoEntrada(BaseModel):
    intervalo: Literal["Primeiro intervalo", "Segundo intervalo"]
    itens: list[ItemEntrada] = Field(min_length=1, max_length=100)
    aluno_id: int | None = None
    chave: str = Field(min_length=8, max_length=80)


class StatusEntrada(BaseModel):
    status: Literal["pendente", "pronto", "concluido", "cancelado"]


def iniciar_escrita(db):
    # Antes de qualquer SELECT: SQLite não implementa FOR UPDATE.
    if db.bind.dialect.name == "sqlite":
        db.execute(text("BEGIN IMMEDIATE"))


def publico(p, db):
    aluno = db.get(Estudante, p.estudante_id)
    itens = db.scalars(select(ItemPedido).where(ItemPedido.pedido_id == p.id)).all()
    return {"id": p.id, "alunoId": p.estudante_id,
            "aluno_nome": db.get(Usuario, p.estudante_id).nome,
            "data": p.data_pedido.isoformat(), "intervalo": p.intervalo,
            "status": p.status, "total": float(p.total), "saldo": float(aluno.saldo),
            "timestamp": p.criado_em.isoformat(timespec="milliseconds") + "Z",
            "itens": [{"id": i.produto_id, "produto_id": i.produto_id, "nome": i.nome,
                       "quantidade": i.quantidade, "preco": float(i.preco),
                       "subtotal": float(i.preco * i.quantidade)} for i in itens]}


def carregar(pedido_id, usuario, db):
    p = db.scalar(select(Pedido).where(Pedido.id == pedido_id).with_for_update())
    if not p:
        raise HTTPException(404, "Pedido não encontrado.")
    aluno_acessivel(usuario, db, p.estudante_id)
    return p


def comprar_itens(p, itens, aluno, db):
    quantidades = {}
    for i in itens:
        quantidades[i.produto_id] = quantidades.get(i.produto_id, 0) + i.quantidade
    total = Decimal("0.00")
    for produto_id, quantidade in sorted(quantidades.items()):
        produto = db.scalar(select(Produto).where(Produto.id == produto_id).with_for_update())
        if not produto or not produto.ativo:
            raise HTTPException(400, "Um produto não está mais disponível. Atualize o carrinho.")
        alteracao = db.execute(update(Produto).where(Produto.id == produto_id, Produto.estoque >= quantidade)
                              .values(estoque=Produto.estoque - quantidade))
        if alteracao.rowcount != 1:
            raise HTTPException(400, ESGOTADO)
        total += produto.preco * quantidade
        db.add(ItemPedido(pedido_id=p.id, produto_id=produto_id, nome=produto.nome,
                          quantidade=quantidade, preco=produto.preco))
    if aluno.saldo - total < Decimal("-250.00"):
        raise HTTPException(400, "Este pedido ultrapassa o limite de saldo negativo de R$ 250,00.")
    aluno.saldo -= total
    p.total = total
    db.add(Movimentacao(estudante_id=aluno.usuario_id, pedido_id=p.id, tipo="compra", valor=-total,
                       saldo_apos=aluno.saldo, chave="compra:" + p.chave))


@router.post("", status_code=201)
def criar(dados: PedidoEntrada, request: Request, db: Session = Depends(get_db)):
    try:
        iniciar_escrita(db)
        usuario = usuario_atual(request, db, "aluno", "responsavel")
        aluno = aluno_acessivel(usuario, db, dados.aluno_id)
        aluno = db.scalar(select(Estudante).where(Estudante.usuario_id == aluno.usuario_id).with_for_update())
        existente = db.scalar(select(Pedido).where(Pedido.chave == dados.chave))
        if existente:
            if existente.estudante_id != aluno.usuario_id:
                raise HTTPException(409, "Identificador da operação já utilizado.")
            return publico(existente, db)
        agora = getattr(request.state, "recebido_em", datetime.now(timezone.utc)).replace(tzinfo=None)
        hoje = (agora - timedelta(hours=3)).date()
        usado = db.scalar(select(Pedido.id).where(Pedido.estudante_id == aluno.usuario_id,
                          Pedido.data_pedido == hoje, Pedido.intervalo_ativo == dados.intervalo))
        if usado:
            raise HTTPException(409, "Você já tem um pedido para este intervalo hoje. Altere ou cancele o pedido existente.")
        p = Pedido(estudante_id=aluno.usuario_id, data_pedido=hoje, intervalo=dados.intervalo,
                   intervalo_ativo=dados.intervalo, total=0, criado_em=agora, chave=dados.chave)
        db.add(p)
        db.flush()
        comprar_itens(p, dados.itens, aluno, db)
        db.commit()
        return publico(p, db)
    except Exception:
        db.rollback()
        raise


@router.get("")
def listar(request: Request, db: Session = Depends(get_db)):
    usuario = usuario_atual(request, db)
    consulta = select(Pedido).order_by(Pedido.criado_em, Pedido.id)
    if usuario.tipo.value != "admin":
        consulta = consulta.where(Pedido.estudante_id == aluno_acessivel(usuario, db).usuario_id)
    return [publico(p, db) for p in db.scalars(consulta)]


@router.get("/{pedido_id}")
def detalhe(pedido_id: int, request: Request, db: Session = Depends(get_db)):
    return publico(carregar(pedido_id, usuario_atual(request, db), db), db)


def estornar(p, db, chave):
    aluno = db.scalar(select(Estudante).where(Estudante.usuario_id == p.estudante_id).with_for_update())
    for item in db.scalars(select(ItemPedido).where(ItemPedido.pedido_id == p.id).order_by(ItemPedido.produto_id)):
        db.execute(update(Produto).where(Produto.id == item.produto_id).values(estoque=Produto.estoque + item.quantidade))
    aluno.saldo += p.total
    db.add(Movimentacao(estudante_id=p.estudante_id, pedido_id=p.id, tipo="estorno", valor=p.total,
                       saldo_apos=aluno.saldo, chave=chave))
    return aluno


@router.patch("/{pedido_id}")
def status(pedido_id: int, dados: StatusEntrada, request: Request, db: Session = Depends(get_db)):
    try:
        iniciar_escrita(db)
        usuario = usuario_atual(request, db)
        p = carregar(pedido_id, usuario, db)
        if usuario.tipo.value != "admin" and dados.status != "cancelado":
            raise HTTPException(403, "Somente a cantina pode avançar o pedido.")
        if p.status == dados.status:
            return publico(p, db)
        if p.status in ("concluido", "cancelado"):
            raise HTTPException(409, "Pedido concluído ou cancelado não pode ser alterado.")
        if dados.status == "cancelado":
            estornar(p, db, "cancelamento:" + str(p.id))
            p.intervalo_ativo = None
        elif (p.status, dados.status) not in (("pendente", "pronto"), ("pronto", "concluido")):
            raise HTTPException(409, "Transição inválida. Marque pronto antes de concluir.")
        p.status = dados.status
        db.commit()
        return publico(p, db)
    except Exception:
        db.rollback()
        raise


@router.put("/{pedido_id}")
def alterar(pedido_id: int, dados: PedidoEntrada, request: Request, db: Session = Depends(get_db)):
    try:
        iniciar_escrita(db)
        usuario = usuario_atual(request, db, "aluno", "responsavel")
        p = carregar(pedido_id, usuario, db)
        if p.status in ("concluido", "cancelado"):
            raise HTTPException(409, "Este pedido não pode mais ser alterado.")
        if db.scalar(select(Movimentacao.id).where(Movimentacao.chave == "compra:" + dados.chave)):
            return publico(p, db)
        outro = db.scalar(select(Pedido.id).where(Pedido.estudante_id == p.estudante_id,
            Pedido.data_pedido == p.data_pedido, Pedido.intervalo_ativo == dados.intervalo, Pedido.id != p.id))
        if outro:
            raise HTTPException(409, "Já existe um pedido neste intervalo.")
        aluno = estornar(p, db, "edicao:" + dados.chave)
        db.execute(delete(ItemPedido).where(ItemPedido.pedido_id == p.id))
        p.chave = dados.chave
        p.intervalo = p.intervalo_ativo = dados.intervalo
        p.status = "pendente"
        comprar_itens(p, dados.itens, aluno, db)
        db.commit()
        return publico(p, db)
    except Exception:
        db.rollback()
        raise
