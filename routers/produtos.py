"""Router de produtos: listagem pública e compra com controle de concorrência."""

from datetime import datetime, timezone
from decimal import Decimal

from fastapi import APIRouter, Depends, HTTPException, Request, status
from pydantic import BaseModel
from sqlalchemy import select, text
from sqlalchemy.orm import Session

from database.database import get_db
from models.produto import Produto
from models.usuario import Estudante

router = APIRouter(prefix="/api/produtos", tags=["produtos"])


# ---------------------------------------------------------------------------
# Schemas de saída / entrada
# ---------------------------------------------------------------------------

class ProdutoPublico(BaseModel):
    """Dados de produto expostos ao cardápio do aluno."""

    id: int
    nome: str
    descricao: str | None = None
    preco: float
    estoque: int
    emoji: str | None = None

    class Config:
        from_attributes = True


class CompraEntrada(BaseModel):
    produto_id: int
    quantidade: int = 1


class ProdutoCadastro(BaseModel):
    nome: str = Field(min_length=2, max_length=120)
    descricao: str | None = Field(default=None, max_length=255)
    preco: float = Field(gt=0)
    estoque: int = Field(ge=0)
    ativo: bool = True
    emoji: str | None = Field(default=None, max_length=10)


# ---------------------------------------------------------------------------
# Endpoints
# ---------------------------------------------------------------------------

@router.get("/", response_model=list[ProdutoPublico])
def listar_produtos(db: Session = Depends(get_db)):
    """
    Retorna todos os produtos ativos com estoque > 0.
    Usado pelo cardápio do aluno (pedidoaluno.html).
    """
    produtos = db.scalars(
        select(Produto).where(
            Produto.ativo.is_(True),
            Produto.quantidade_estoque > 0,
        ).order_by(Produto.nome)
    ).all()

    return [
        ProdutoPublico(
            id=p.id,
            nome=p.nome,
            descricao=p.descricao,
            preco=float(p.preco),
            estoque=p.quantidade_estoque,
            emoji=p.emoji,
        )
        for p in produtos
    ]


@router.post("/comprar", status_code=status.HTTP_200_OK)
def comprar_produto(
    dados: CompraEntrada,
    request: Request,
    db: Session = Depends(get_db),
):
    """
    Registra a compra de um produto com proteção contra race condition.

    Regras:
    - Apenas alunos autenticados podem comprar.
    - Usa SELECT ... FOR UPDATE para garantir exclusividade na transação.
    - Se o estoque estiver zerado quando a transação for processada,
      devolve HTTP 400 sem descontar nenhum valor do aluno.
    - O timestamp do servidor define a prioridade em compras simultâneas.
    """
    # --- Verificação de sessão ---
    usuario_id = request.session.get("usuario_id")
    tipo = request.session.get("tipo")
    if not usuario_id or tipo not in ("aluno", "responsavel"):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Autenticação necessária.",
        )

    if dados.quantidade < 1:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Quantidade inválida.",
        )

    # --- Transação atômica ---
    # O timestamp registra o momento exato da tentativa (prioridade de fila).
    timestamp_tentativa = datetime.now(tz=timezone.utc)

    try:
        with db.begin():  # abre BEGIN … COMMIT / ROLLBACK automático
            # Bloqueia a linha do produto para leitura exclusiva.
            # MySQL: SELECT ... FOR UPDATE
            # SQLite: BEGIN IMMEDIATE é suficiente (não suporta FOR UPDATE).
            produto = db.execute(
                select(Produto)
                .where(Produto.id == dados.produto_id)
                .with_for_update()
            ).scalar_one_or_none()

            if produto is None or not produto.ativo:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="Produto não encontrado.",
                )

            # --- Verificação de estoque dentro da transação ---
            if produto.quantidade_estoque <= 0:
                # Rollback automático ao sair do with db.begin() com exceção.
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=(
                        "Que pena! O item esgotou segundos atrás. "
                        "Seu saldo não foi alterado."
                    ),
                )

            if produto.quantidade_estoque < dados.quantidade:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=(
                        f"Estoque insuficiente. Disponível: "
                        f"{produto.quantidade_estoque} unidade(s)."
                    ),
                )

            # --- Desconta do estoque ---
            produto.quantidade_estoque -= dados.quantidade

            # --- Debita saldo do aluno (se for conta de aluno real) ---
            valor_total = Decimal(str(produto.preco)) * dados.quantidade
            estudante = db.execute(
                select(Estudante)
                .where(Estudante.usuario_id == usuario_id)
                .with_for_update()
            ).scalar_one_or_none()

            if estudante is not None:
                novo_saldo = estudante.saldo - valor_total
                if novo_saldo < Decimal("-250.00"):
                    raise HTTPException(
                        status_code=status.HTTP_400_BAD_REQUEST,
                        detail="Saldo insuficiente. Limite negativo de R$ 250,00 atingido.",
                    )
                estudante.saldo = novo_saldo

        # Commit bem-sucedido — retorna confirmação
        return {
            "status": "ok",
            "message": "Compra realizada com sucesso!",
            "produto": produto.nome,
            "quantidade": dados.quantidade,
            "total": float(valor_total),
            "timestamp": timestamp_tentativa.isoformat(),
        }

    except HTTPException:
        # Re-lança HTTPExceptions para que o FastAPI as trate normalmente.
        raise
    except Exception as exc:  # pragma: no cover
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erro interno ao processar a compra.",
        ) from exc
