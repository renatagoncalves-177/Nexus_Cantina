"""Inicializa uma base SQLite de desenvolvimento sem apagar dados existentes."""
from pathlib import Path
import sqlite3
from dotenv import load_dotenv

RAIZ = Path(__file__).resolve().parents[1]
load_dotenv(RAIZ / ".env")
from database.database import engine


def main():
    if engine.dialect.name != "sqlite":
        raise SystemExit("Este seed é SQLite. Para MySQL use uma base separada e migração revisada; nenhum dado foi alterado.")
    caminho = Path(engine.url.database).resolve()
    if caminho.exists() and caminho.stat().st_size:
        pasta = RAIZ / "backups"
        pasta.mkdir(exist_ok=True)
        from datetime import datetime
        destino = pasta / ("nexus-" + datetime.now().strftime("%Y%m%d-%H%M%S-%f") + ".db")
        with sqlite3.connect(caminho) as origem, sqlite3.connect(destino) as copia:
            origem.backup(copia)
        print("Backup do banco salvo em", destino)
    with sqlite3.connect(caminho) as conexao:
        try:
            conexao.executescript((RAIZ / "database/seed.sql").read_text(encoding="utf-8"))
        except Exception:
            conexao.rollback()
            raise
        print("Usuários:", conexao.execute("SELECT tipo, COUNT(*) FROM usuarios GROUP BY tipo").fetchall())
        print("Produtos:", conexao.execute("SELECT COUNT(*) FROM produtos").fetchone()[0])
    print("Banco pronto. Execute python -m uvicorn main:app --reload (um worker).")


if __name__ == "__main__":
    main()
