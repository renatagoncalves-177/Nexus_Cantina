from fastapi import APIRouter, Depends, HTTPException, Request, Response, status
from sqlalchemy.orm import Session

from database.database import get_db_opcional
from models.usuario import Usuario
from schemas.auth import LoginEntrada, UsuarioAutenticado
from services.auth import autenticar_usuario
from services.usuarios_teste import autenticar_conta_teste, obter_conta_teste


router = APIRouter(prefix="/api/auth", tags=["autenticação"])


@router.post("/login", response_model=UsuarioAutenticado)
def login(
    dados: LoginEntrada,
    request: Request,
    db: Session | None = Depends(get_db_opcional),
):
    conta_teste = autenticar_conta_teste(dados.identificador, dados.senha, dados.tipo)
    if conta_teste is not None:
        request.session.clear()
        request.session.update(
            {
                "usuario_id": conta_teste.id,
                "nome": conta_teste.nome,
                "tipo": conta_teste.tipo.value,
                "modo_teste": True,
            }
        )
        return conta_teste.resposta()

    if db is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Conta de teste inválida. Confira o identificador, a senha e o perfil escolhido.",
        )

    usuario = autenticar_usuario(db, dados.identificador, dados.senha, dados.tipo)
    if usuario is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Identificador ou senha inválidos.",
        )

    request.session.clear()
    request.session.update(
        {
            "usuario_id": usuario.id,
            "nome": usuario.nome,
            "tipo": usuario.tipo.value,
        }
    )
    return usuario


@router.post("/logout", status_code=status.HTTP_204_NO_CONTENT)
def logout(request: Request) -> Response:
    request.session.clear()
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.get("/me", response_model=UsuarioAutenticado)
def usuario_atual(request: Request, db: Session | None = Depends(get_db_opcional)):
    usuario_id = request.session.get("usuario_id")
    if not usuario_id:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Sessão não autenticada.")

    if request.session.get("modo_teste"):
        conta_teste = obter_conta_teste(usuario_id)
        if conta_teste is not None:
            return conta_teste.resposta()
        request.session.clear()
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Sessão de teste inválida.")

    if db is None:
        request.session.clear()
        raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail="Banco de dados ainda não configurado.")

    usuario = db.get(Usuario, usuario_id)
    if usuario is None or not usuario.ativo:
        request.session.clear()
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Sessão inválida.")
    return usuario
