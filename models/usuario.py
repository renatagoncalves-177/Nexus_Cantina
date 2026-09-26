from datetime import datetime
from enum import Enum

from decimal import Decimal

from sqlalchemy import Boolean, CheckConstraint, DateTime, Enum as EnumBanco, ForeignKey, Numeric, String, func
from sqlalchemy.orm import Mapped, mapped_column

from database.database import Base


class TipoUsuario(str, Enum):
    ALUNO = "aluno"
    RESPONSAVEL = "responsavel"
    ADMIN = "admin"


class Usuario(Base):
    __tablename__ = "usuarios"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    nome: Mapped[str] = mapped_column(String(120))
    email: Mapped[str | None] = mapped_column(String(160), unique=True, index=True)
    matricula: Mapped[str | None] = mapped_column(String(30), unique=True, index=True)
    senha_hash: Mapped[str] = mapped_column(String(255))
    tipo: Mapped[TipoUsuario] = mapped_column(
        EnumBanco(
            TipoUsuario,
            values_callable=lambda tipos: [tipo.value for tipo in tipos],
            native_enum=False,
            length=20,
        ),
        index=True,
    )
    ativo: Mapped[bool] = mapped_column(Boolean, default=True)
    criado_em: Mapped[datetime] = mapped_column(DateTime, server_default=func.now())


class Estudante(Base):
    __tablename__ = "estudantes"
    __table_args__ = (CheckConstraint("saldo >= -250.00", name="chk_limite_saldo"),)

    usuario_id: Mapped[int] = mapped_column(ForeignKey("usuarios.id", ondelete="CASCADE"), primary_key=True)
    serie: Mapped[str | None] = mapped_column(String(30))
    turma: Mapped[str | None] = mapped_column(String(30))
    saldo: Mapped[Decimal] = mapped_column(Numeric(10, 2), default=Decimal("0.00"))


class Responsavel(Base):
    __tablename__ = "responsaveis"

    usuario_id: Mapped[int] = mapped_column(ForeignKey("usuarios.id", ondelete="CASCADE"), primary_key=True)


class Administrador(Base):
    __tablename__ = "administradores"

    usuario_id: Mapped[int] = mapped_column(ForeignKey("usuarios.id", ondelete="CASCADE"), primary_key=True)
