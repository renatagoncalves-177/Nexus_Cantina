from pwdlib import PasswordHash
from sqlalchemy import select
from sqlalchemy.orm import Session

from models.usuario import TipoUsuario, Usuario


gerenciador_senhas = PasswordHash.recommended()


def gerar_hash_senha(senha: str) -> str:
    return gerenciador_senhas.hash(senha)


def autenticar_usuario(
    db: Session,
    identificador: str,
    senha: str,
    tipo: TipoUsuario,
) -> Usuario | None:
    identificador = identificador.strip().lower()
    campo = Usuario.matricula if tipo is TipoUsuario.ALUNO else Usuario.email

    usuario = db.scalar(
        select(Usuario).where(
            campo == identificador,
            Usuario.tipo == tipo,
            Usuario.ativo.is_(True),
        )
    )

    if usuario is None or not gerenciador_senhas.verify(senha, usuario.senha_hash):
        return None
    return usuario
