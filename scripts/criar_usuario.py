"""Cria um usuário real solicitando os dados no terminal."""

import getpass
import sys
from pathlib import Path

from sqlalchemy import select
from dotenv import load_dotenv


RAIZ = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(RAIZ))
load_dotenv(RAIZ / ".env")

from database.database import SessionLocal  # noqa: E402
from models.usuario import Administrador, Estudante, Responsavel, TipoUsuario, Usuario  # noqa: E402
from services.auth import gerar_hash_senha  # noqa: E402


def pedir_tipo() -> TipoUsuario:
    opcoes = ", ".join(tipo.value for tipo in TipoUsuario)
    while True:
        valor = input(f"Tipo ({opcoes}): ").strip().lower()
        try:
            return TipoUsuario(valor)
        except ValueError:
            print("Tipo inválido.")


def main() -> None:
    if SessionLocal is None:
        raise SystemExit("Defina DATABASE_URL antes de executar este script.")

    nome = input("Nome completo: ").strip()
    tipo = pedir_tipo()
    identificador = input("Matrícula: " if tipo is TipoUsuario.ALUNO else "E-mail: ").strip().lower()
    senha = getpass.getpass("Senha: ")
    confirmacao = getpass.getpass("Confirme a senha: ")

    if not nome or len(identificador) < 3:
        raise SystemExit("Nome e identificador são obrigatórios.")
    if len(senha) < 8:
        raise SystemExit("A senha deve ter pelo menos 8 caracteres.")
    if senha != confirmacao:
        raise SystemExit("As senhas não coincidem.")

    email = None if tipo is TipoUsuario.ALUNO else identificador
    matricula = identificador if tipo is TipoUsuario.ALUNO else None

    with SessionLocal() as db:
        campo = Usuario.matricula if tipo is TipoUsuario.ALUNO else Usuario.email
        existente = db.scalar(select(Usuario).where(campo == identificador))
        if existente:
            raise SystemExit("Já existe um usuário com esse identificador.")

        usuario = Usuario(
            nome=nome,
            email=email,
            matricula=matricula,
            senha_hash=gerar_hash_senha(senha),
            tipo=tipo,
        )
        db.add(usuario)
        db.flush()
        perfil = {
            TipoUsuario.ALUNO: Estudante,
            TipoUsuario.RESPONSAVEL: Responsavel,
            TipoUsuario.ADMIN: Administrador,
        }[tipo]
        db.add(perfil(usuario_id=usuario.id))
        db.commit()
        print(f"Usuário {usuario.nome} criado com sucesso.")


if __name__ == "__main__":
    main()
