"""Cria três contas previsíveis somente para testes locais."""

import argparse
import os
import sys
from pathlib import Path

from dotenv import load_dotenv
from sqlalchemy import select


RAIZ = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(RAIZ))
load_dotenv(RAIZ / ".env")

from database.database import SessionLocal  # noqa: E402
from models.usuario import Administrador, Estudante, Responsavel, TipoUsuario, Usuario  # noqa: E402
from services.auth import gerar_hash_senha  # noqa: E402


SENHA_TESTE = os.getenv("NEXUS_TEST_PASSWORD", "1234")
USUARIOS_TESTE = (
    {
        "nome": "Aluno de Teste",
        "tipo": TipoUsuario.ALUNO,
        "matricula": "aluno01",
        "email": None,
        "perfil": Estudante,
    },
    {
        "nome": "Responsável de Teste",
        "tipo": TipoUsuario.RESPONSAVEL,
        "matricula": None,
        "email": "resp01@teste.com",
        "perfil": Responsavel,
    },
    {
        "nome": "Administrador de Teste",
        "tipo": TipoUsuario.ADMIN,
        "matricula": None,
        "email": "admin01@teste.com",
        "perfil": Administrador,
    },
)


def criar_ou_atualizar(db, dados: dict) -> str:
    identificador = dados["matricula"] or dados["email"]
    campo = Usuario.matricula if dados["matricula"] else Usuario.email
    usuario = db.scalar(select(Usuario).where(campo == identificador))

    if usuario is None:
        usuario = Usuario(
            nome=dados["nome"],
            tipo=dados["tipo"],
            matricula=dados["matricula"],
            email=dados["email"],
            senha_hash=gerar_hash_senha(SENHA_TESTE),
        )
        db.add(usuario)
        db.flush()
        db.add(dados["perfil"](usuario_id=usuario.id))
        return "criado"

    if usuario.tipo != dados["tipo"]:
        raise RuntimeError(f"O identificador {identificador} já pertence a outro perfil.")

    usuario.nome = dados["nome"]
    usuario.senha_hash = gerar_hash_senha(SENHA_TESTE)
    usuario.ativo = True
    if db.get(dados["perfil"], usuario.id) is None:
        db.add(dados["perfil"](usuario_id=usuario.id))
    return "atualizado"


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--confirmar",
        action="store_true",
        help="confirma a criação ou redefinição das contas de teste",
    )
    argumentos = parser.parse_args()

    if not argumentos.confirmar:
        raise SystemExit("Use --confirmar para criar contas conhecidas somente no banco de desenvolvimento.")
    if SessionLocal is None:
        raise SystemExit("Defina DATABASE_URL no arquivo .env antes de executar este script.")

    with SessionLocal() as db:
        resultados = [(dados, criar_ou_atualizar(db, dados)) for dados in USUARIOS_TESTE]
        db.commit()

    print("Contas de teste prontas:")
    for dados, resultado in resultados:
        identificador = dados["matricula"] or dados["email"]
        print(f"- {dados['tipo'].value}: {identificador} ({resultado})")
    print(f"- senha comum: {SENHA_TESTE}")
    print("Não use essas contas em produção.")


if __name__ == "__main__":
    main()
