"""Cadastros, vínculo individual, saldos e recebimentos."""
from decimal import Decimal
from fastapi import APIRouter, Depends, HTTPException, Request
from pydantic import BaseModel, Field, ConfigDict
from sqlalchemy import select, func
from sqlalchemy.orm import Session
from database.database import get_db
from models.usuario import Usuario, Estudante, Responsavel, TipoUsuario
from models.pedido import Movimentacao, Pedido
from services.auth import gerar_hash_senha
from services.permissoes import usuario_atual, aluno_acessivel
from routers.pedidos import iniciar_escrita, publico as pedido_publico

router = APIRouter(prefix="/api", tags=["gestão"])


class Cadastro(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True)
    nome: str = Field(min_length=2, max_length=120)
    matricula: str | None = Field(default=None, max_length=30)
    email: str | None = Field(default=None, max_length=160)
    senha: str = Field(min_length=8, max_length=128)
    serie: str | None = Field(default=None, max_length=30)
    turma: str | None = Field(default=None, max_length=30)


class Vinculo(BaseModel):
    responsavel_id: int = Field(gt=0)
    aluno_id: int = Field(gt=0)


class Recarga(BaseModel):
    valor: Decimal = Field(gt=0, le=500, decimal_places=2)
    chave: str = Field(min_length=8, max_length=80)
    tipo: str = "recarga"


def aluno_publico(a, db):
    u = db.get(Usuario, a.usuario_id)
    gastos = db.scalar(select(func.coalesce(func.sum(Pedido.total), 0)).where(
        Pedido.estudante_id == a.usuario_id, Pedido.status != "cancelado"))
    return {"id": a.usuario_id, "nome": u.nome, "email": u.email, "matricula": u.matricula,
            "serie": a.serie, "turma": a.turma, "saldo": float(a.saldo),
            "gastos": float(gastos), "ativo": u.ativo, "responsavel_id": a.responsavel_id}


@router.get("/alunos")
@router.get("/alunos/", include_in_schema=False)
def listar(request: Request, db: Session = Depends(get_db)):
    usuario = usuario_atual(request, db)
    consulta = select(Estudante)
    if usuario.tipo.value == "aluno":
        consulta = consulta.where(Estudante.usuario_id == usuario.id)
    elif usuario.tipo.value == "responsavel":
        consulta = consulta.where(Estudante.responsavel_id == usuario.id)
    return [aluno_publico(a, db) for a in db.scalars(consulta)]


@router.get("/alunos/me")
def meu_aluno(request: Request, db: Session = Depends(get_db)):
    return aluno_publico(aluno_acessivel(usuario_atual(request, db, "aluno", "responsavel"), db), db)


def cadastrar(dados, tipo, db):
    email = dados.email.lower() if dados.email else None
    matricula = dados.matricula.lower() if dados.matricula else None
    if tipo == TipoUsuario.ALUNO and not matricula:
        raise HTTPException(422, "Informe uma matrícula.")
    if tipo == TipoUsuario.RESPONSAVEL and (not email or "@" not in email):
        raise HTTPException(422, "Informe um e-mail válido.")
    if db.scalar(select(Usuario.id).where(Usuario.email == email)) if email else False:
        raise HTTPException(409, "E-mail já cadastrado.")
    if db.scalar(select(Usuario.id).where(Usuario.matricula == matricula)) if matricula else False:
        raise HTTPException(409, "Matrícula já cadastrada.")
    usuario = Usuario(nome=dados.nome, email=email, matricula=matricula,
                      senha_hash=gerar_hash_senha(dados.senha), tipo=tipo)
    db.add(usuario)
    db.flush()
    if tipo == TipoUsuario.ALUNO:
        db.add(Estudante(usuario_id=usuario.id, serie=dados.serie, turma=dados.turma))
    else:
        db.add(Responsavel(usuario_id=usuario.id))
    db.commit()
    return usuario


@router.post("/alunos", status_code=201)
def novo_aluno(dados: Cadastro, request: Request, db: Session = Depends(get_db)):
    usuario_atual(request, db, "admin")
    u = cadastrar(dados, TipoUsuario.ALUNO, db)
    return aluno_publico(db.get(Estudante, u.id), db)


@router.get("/responsaveis")
def responsaveis(request: Request, db: Session = Depends(get_db)):
    usuario_atual(request, db, "admin")
    return [{"id": u.id, "nome": u.nome, "email": u.email} for u in db.scalars(
        select(Usuario).where(Usuario.tipo == TipoUsuario.RESPONSAVEL))]


@router.post("/responsaveis", status_code=201)
def novo_responsavel(dados: Cadastro, request: Request, db: Session = Depends(get_db)):
    usuario_atual(request, db, "admin")
    u = cadastrar(dados, TipoUsuario.RESPONSAVEL, db)
    return {"id": u.id, "nome": u.nome, "email": u.email}


@router.get("/vinculos")
def vinculos(request: Request, db: Session = Depends(get_db)):
    usuario_atual(request, db, "admin")
    return [{"aluno_id": a.usuario_id, "responsavel_id": a.responsavel_id,
             "aluno_nome": db.get(Usuario, a.usuario_id).nome,
             "responsavel_nome": db.get(Usuario, a.responsavel_id).nome, "ativo": True}
            for a in db.scalars(select(Estudante).where(Estudante.responsavel_id.is_not(None)))]


@router.post("/vinculos")
def vincular(dados: Vinculo, request: Request, db: Session = Depends(get_db)):
    usuario_atual(request, db, "admin")
    a = db.get(Estudante, dados.aluno_id)
    if not a or not db.get(Responsavel, dados.responsavel_id):
        raise HTTPException(404, "Aluno ou responsável não encontrado.")
    outro = db.scalar(select(Estudante).where(Estudante.responsavel_id == dados.responsavel_id,
                                             Estudante.usuario_id != a.usuario_id))
    if outro:
        raise HTTPException(409, "Este responsável já está vinculado a outro aluno.")
    a.responsavel_id = dados.responsavel_id
    db.commit()
    return {"status": "ok"}


@router.post("/alunos/{aluno_id}/saldo")
def recarregar(aluno_id: int, dados: Recarga, request: Request, db: Session = Depends(get_db)):
    try:
        iniciar_escrita(db)
        usuario = usuario_atual(request, db, "admin", "responsavel")
        aluno = aluno_acessivel(usuario, db, aluno_id)
        aluno = db.scalar(select(Estudante).where(Estudante.usuario_id == aluno_id).with_for_update())
        anterior = db.scalar(select(Movimentacao).where(Movimentacao.chave == dados.chave))
        if anterior:
            if anterior.estudante_id != aluno_id or anterior.valor != dados.valor or anterior.tipo != dados.tipo:
                raise HTTPException(409, "Identificador de operação já utilizado.")
            return aluno_publico(aluno, db)
        if dados.tipo not in ("recarga", "recebimento"):
            raise HTTPException(422, "Tipo de movimentação inválido.")
        if dados.tipo == "recebimento":
            if usuario.tipo.value != "admin":
                raise HTTPException(403, "Recebimentos são exclusivos da cantina.")
            if dados.valor > max(-aluno.saldo, Decimal(0)):
                raise HTTPException(400, "O recebimento não pode ultrapassar a dívida.")
        aluno.saldo += dados.valor
        db.add(Movimentacao(estudante_id=aluno_id, tipo=dados.tipo, valor=dados.valor,
                           saldo_apos=aluno.saldo, chave=dados.chave))
        db.commit()
        return aluno_publico(aluno, db)
    except Exception:
        db.rollback()
        raise


@router.get("/gestao")
def gestao(request: Request, db: Session = Depends(get_db)):
    usuario = usuario_atual(request, db)
    alunos = listar(request, db)
    ids = [a["id"] for a in alunos]
    movimentos = db.scalars(select(Movimentacao).where(Movimentacao.estudante_id.in_(ids))
                            .order_by(Movimentacao.id.desc())).all()
    pedidos = [pedido_publico(p, db) for p in db.scalars(select(Pedido).where(Pedido.estudante_id.in_(ids))
               .order_by(Pedido.criado_em, Pedido.id))]
    return {
        "alunos": [{**a, "id": str(a["id"]), "saldo": round(a["saldo"] * 100),
                    "divida": max(0, -round(a["saldo"] * 100))} for a in alunos],
        "pedidos": [{**p, "aluno": p["aluno_nome"], "total": round(p["total"] * 100),
                    "descricao": " • ".join(str(i["quantidade"]) + " × " + i["nome"] for i in p["itens"])} for p in pedidos],
        "recargas": [{"alunoId": str(m.estudante_id), "valor": round(m.valor * 100), "data": m.criado_em.isoformat() + "Z"}
                    for m in movimentos if m.tipo == "recarga"],
        "recebimentos": [{"alunoId": str(m.estudante_id), "valor": round(m.valor * 100), "data": m.criado_em.isoformat() + "Z"}
                         for m in movimentos if m.tipo == "recebimento"],
    }
