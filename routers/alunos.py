"""Router de alunos: listagem e cadastro via API."""

from decimal import Decimal

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, Field
from sqlalchemy import select
from sqlalchemy.orm import Session

from database.database import get_db
from models.usuario import Estudante, TipoUsuario, Usuario
from services.auth import gerar_hash_senha

router = APIRouter(prefix="/api/alunos", tags=["alunos"])


# ---------------------------------------------------------------------------
# Schemas
# ---------------------------------------------------------------------------

class AlunoPublico(BaseModel):
    id: int
    nome: str
    matricula: str | None = None
    email: str | None = None
    serie: str | None = None
    turma: str | None = None
    saldo: float
    ativo: bool

    class Config:
        from_attributes = True


class AlunoCadastro(BaseModel):
    nome: str = Field(min_length=2, max_length=120)
    matricula: str = Field(min_length=1, max_length=30)
    senha: str = Field(min_length=6, max_length=128)
    email: str | None = Field(default=None, max_length=160)
    serie: str | None = Field(default=None, max_length=30)
    turma: str | None = Field(default=None, max_length=30)


# ---------------------------------------------------------------------------
# Endpoints
# ---------------------------------------------------------------------------

@router.get("/", response_model=list[AlunoPublico])
def listar_alunos(db: Session = Depends(get_db)):
    """Lista todos os alunos ativos com seus dados de estudante."""
    registros = db.execute(
        select(Usuario, Estudante)
        .join(Estudante, Estudante.usuario_id == Usuario.id)
        .where(
            Usuario.tipo == TipoUsuario.ALUNO,
            Usuario.ativo.is_(True),
        )
        .order_by(Usuario.nome)
    ).all()

    return [
        AlunoPublico(
            id=u.id,
            nome=u.nome,
            matricula=u.matricula,
            email=u.email,
            serie=e.serie,
            turma=e.turma,
            saldo=float(e.saldo),
            ativo=u.ativo,
        )
        for u, e in registros
    ]


@router.post("/", response_model=AlunoPublico, status_code=status.HTTP_201_CREATED)
def cadastrar_aluno(dados: AlunoCadastro, db: Session = Depends(get_db)):
    """Cadastra um novo aluno com hash de senha."""
    # Verifica matrícula duplicada
    existente = db.scalar(
        select(Usuario).where(Usuario.matricula == dados.matricula.strip())
    )
    if existente:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=f"Já existe um usuário com a matrícula '{dados.matricula}'.",
        )

    novo_usuario = Usuario(
        nome=dados.nome.strip(),
        matricula=dados.matricula.strip(),
        email=dados.email.strip() if dados.email else None,
        senha_hash=gerar_hash_senha(dados.senha),
        tipo=TipoUsuario.ALUNO,
        ativo=True,
    )
    db.add(novo_usuario)
    db.flush()  # gera o ID sem fechar a transação

    novo_estudante = Estudante(
        usuario_id=novo_usuario.id,
        serie=dados.serie,
        turma=dados.turma,
        saldo=Decimal("0.00"),
    )
    db.add(novo_estudante)
    db.commit()
    db.refresh(novo_usuario)
    db.refresh(novo_estudante)

    return AlunoPublico(
        id=novo_usuario.id,
        nome=novo_usuario.nome,
        matricula=novo_usuario.matricula,
        email=novo_usuario.email,
        serie=novo_estudante.serie,
        turma=novo_estudante.turma,
        saldo=float(novo_estudante.saldo),
        ativo=novo_usuario.ativo,
    )
