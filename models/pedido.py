from datetime import date, datetime, timezone
from decimal import Decimal

from sqlalchemy import CheckConstraint, Date, DateTime, ForeignKey, Numeric, String, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column

from database.database import Base


class Pedido(Base):
    __tablename__ = "pedidos"
    __table_args__ = (
        UniqueConstraint("estudante_id", "data_pedido", "intervalo_ativo"),
        CheckConstraint("total >= 0"),
        CheckConstraint("status IN ('pendente', 'pronto', 'concluido', 'cancelado')"),
    )
    id: Mapped[int] = mapped_column(primary_key=True)
    estudante_id: Mapped[int] = mapped_column(ForeignKey("estudantes.usuario_id"))
    data_pedido: Mapped[date] = mapped_column(Date)
    intervalo: Mapped[str] = mapped_column(String(30))
    intervalo_ativo: Mapped[str | None] = mapped_column(String(30))
    status: Mapped[str] = mapped_column(String(20), default="pendente")
    total: Mapped[Decimal] = mapped_column(Numeric(10, 2))
    criado_em: Mapped[datetime] = mapped_column(DateTime)
    chave: Mapped[str] = mapped_column(String(80), unique=True)


class ItemPedido(Base):
    __tablename__ = "itens_pedido"
    __table_args__ = (UniqueConstraint("pedido_id", "produto_id"), CheckConstraint("quantidade > 0"))
    id: Mapped[int] = mapped_column(primary_key=True)
    pedido_id: Mapped[int] = mapped_column(ForeignKey("pedidos.id"))
    produto_id: Mapped[int] = mapped_column(ForeignKey("produtos.id"))
    nome: Mapped[str] = mapped_column(String(120))
    quantidade: Mapped[int]
    preco: Mapped[Decimal] = mapped_column(Numeric(10, 2))


class Movimentacao(Base):
    __tablename__ = "movimentacoes_saldo"
    id: Mapped[int] = mapped_column(primary_key=True)
    estudante_id: Mapped[int] = mapped_column(ForeignKey("estudantes.usuario_id"))
    pedido_id: Mapped[int | None] = mapped_column(ForeignKey("pedidos.id"))
    tipo: Mapped[str] = mapped_column(String(20))
    valor: Mapped[Decimal] = mapped_column(Numeric(10, 2))
    saldo_apos: Mapped[Decimal] = mapped_column(Numeric(10, 2))
    criado_em: Mapped[datetime] = mapped_column(DateTime, default=lambda: datetime.now(timezone.utc).replace(tzinfo=None))
    chave: Mapped[str] = mapped_column(String(100), unique=True)
