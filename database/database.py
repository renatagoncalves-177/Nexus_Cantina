import os
from collections.abc import Generator

from fastapi import HTTPException, status
from sqlalchemy import create_engine
from sqlalchemy.orm import DeclarativeBase, Session, sessionmaker


DATABASE_URL = os.getenv("DATABASE_URL", "").strip()


class Base(DeclarativeBase):
    pass


def banco_configurado() -> bool:
    return bool(DATABASE_URL)


def _criar_engine():
    if not banco_configurado():
        return None

    argumentos_conexao = {}
    if DATABASE_URL.startswith("sqlite"):
        argumentos_conexao["check_same_thread"] = False

    return create_engine(
        DATABASE_URL,
        pool_pre_ping=True,
        connect_args=argumentos_conexao,
    )


engine = _criar_engine()
SessionLocal = (
    sessionmaker(bind=engine, autoflush=False, expire_on_commit=False)
    if engine is not None
    else None
)


def get_db() -> Generator[Session, None, None]:
    """Entrega uma sessão por requisição e garante seu fechamento."""
    if SessionLocal is None:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Banco de dados ainda não configurado.",
        )

    with SessionLocal() as sessao:
        yield sessao


def get_db_opcional() -> Generator[Session | None, None, None]:
    """Permite autenticação local de teste antes da configuração do banco."""
    if SessionLocal is None:
        yield None
        return

    with SessionLocal() as sessao:
        yield sessao
