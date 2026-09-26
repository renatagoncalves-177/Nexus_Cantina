from fastapi import HTTPException, Request
from sqlalchemy import select
from sqlalchemy.orm import Session
from models.usuario import Usuario, Estudante


def usuario_atual(request: Request, db: Session, *perfis: str) -> Usuario:
    usuario = db.get(Usuario, request.session.get("usuario_id", 0))
    if not usuario or not usuario.ativo or request.session.get("modo_teste"):
        raise HTTPException(401, "Entre novamente com uma conta do banco.")
    if perfis and usuario.tipo.value not in perfis:
        raise HTTPException(403, "Seu perfil não tem permissão para esta operação.")
    return usuario


def aluno_acessivel(usuario: Usuario, db: Session, aluno_id: int | None = None) -> Estudante:
    if usuario.tipo.value == "aluno":
        if aluno_id and aluno_id != usuario.id:
            raise HTTPException(403, "Aluno não autorizado.")
        aluno_id = usuario.id
    elif usuario.tipo.value == "responsavel" and not aluno_id:
        aluno_id = db.scalar(select(Estudante.usuario_id).where(Estudante.responsavel_id == usuario.id))
    aluno = db.get(Estudante, aluno_id) if aluno_id else None
    if not aluno:
        raise HTTPException(404, "Aluno não encontrado ou sem vínculo.")
    if usuario.tipo.value == "responsavel" and aluno.responsavel_id != usuario.id:
        raise HTTPException(403, "Aluno não vinculado a este responsável.")
    return aluno
