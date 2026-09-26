from pwdlib import PasswordHash
from sqlalchemy import select, or_
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
    filtro = Usuario.matricula == identificador if tipo is TipoUsuario.ALUNO else or_(Usuario.email == identificador, Usuario.matricula == identificador)

    usuario = db.scalar(
        select(Usuario).where(
            filtro,
            Usuario.tipo == tipo,
            Usuario.ativo.is_(True),
        )
    )

    if usuario is None:
        return None
    try:
        if not gerenciador_senhas.verify(senha, usuario.senha_hash):
            return None
    except Exception:
        return None
    return usuario
