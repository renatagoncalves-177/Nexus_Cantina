"""Cardápio e manutenção de produtos, com autorização no servidor."""
from decimal import Decimal
from fastapi import APIRouter, Depends, HTTPException, Request
from pydantic import BaseModel, Field, ConfigDict
from sqlalchemy import select
from sqlalchemy.orm import Session
from database.database import get_db
from models.produto import Produto
from services.permissoes import usuario_atual

router = APIRouter(prefix="/api/produtos", tags=["produtos"])
CATEGORIAS = {"Salgados Assados", "Salgados Fritos", "Doces & Sobremesas", "Bebidas", "Lanches Saudáveis", "Pratos do Dia"}


class ProdutoCadastro(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True)
    nome: str = Field(min_length=2, max_length=120)
    descricao: str = Field(default="", max_length=255)
    preco: Decimal = Field(gt=0, max_digits=10, decimal_places=2)
    estoque: int = Field(ge=0, le=1000000)
    categoria: str = "Salgados Assados"
    imagem_url: str | None = Field(default=None, max_length=255)
    ativo: bool = True
    emoji: str | None = Field(default=None, max_length=10)


def publico(p):
    return {"id": p.id, "nome": p.nome, "descricao": p.descricao,
            "preco": float(p.preco), "estoque": p.estoque, "ativo": p.ativo,
            "categoria": p.categoria, "imagem_url": p.imagem_url, "emoji": p.emoji}


@router.get("")
@router.get("/", include_in_schema=False)
def listar(request: Request, db: Session = Depends(get_db)):
    usuario = usuario_atual(request, db)
    consulta = select(Produto).order_by(Produto.categoria, Produto.id)
    if usuario.tipo.value != "admin":
        consulta = consulta.where(Produto.ativo.is_(True), Produto.estoque > 0)
    return [publico(p) for p in db.scalars(consulta)]


def validar(dados):
    if dados.categoria not in CATEGORIAS:
        raise HTTPException(422, "Categoria inválida.")
    if dados.imagem_url and not dados.imagem_url.startswith("/static/img/produtos/"):
        raise HTTPException(422, "Use uma imagem local de /static/img/produtos/.")


@router.get("/{produto_id}")
def detalhe(produto_id: int, request: Request, db: Session = Depends(get_db)):
    usuario = usuario_atual(request, db)
    produto = db.get(Produto, produto_id)
    if not produto or (not produto.ativo and usuario.tipo.value != "admin"):
        raise HTTPException(404, "Produto não disponível.")
    return publico(produto)


@router.post("", status_code=201)
@router.post("/", status_code=201, include_in_schema=False)
def cadastrar(dados: ProdutoCadastro, request: Request, db: Session = Depends(get_db)):
    usuario_atual(request, db, "admin")
    validar(dados)
    produto = Produto(**dados.model_dump())
    db.add(produto)
    db.commit()
    return publico(produto)


@router.put("/{produto_id}")
def editar(produto_id: int, dados: ProdutoCadastro, request: Request, db: Session = Depends(get_db)):
    usuario_atual(request, db, "admin")
    validar(dados)
    produto = db.get(Produto, produto_id)
    if not produto:
        raise HTTPException(404, "Produto não encontrado.")
    for chave, valor in dados.model_dump().items():
        setattr(produto, chave, valor)
    db.commit()
    return publico(produto)


@router.delete("/{produto_id}", status_code=204)
def desativar(produto_id: int, request: Request, db: Session = Depends(get_db)):
    usuario_atual(request, db, "admin")
    produto = db.get(Produto, produto_id)
    if not produto:
        raise HTTPException(404, "Produto não encontrado.")
    produto.ativo = False
    db.commit()
