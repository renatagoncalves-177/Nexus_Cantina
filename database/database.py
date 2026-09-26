import os


DATABASE_URL = os.getenv("DATABASE_URL", "")


def banco_configurado() -> bool:
    """Informa se a conexão do banco já foi configurada no ambiente."""

    return bool(DATABASE_URL)
