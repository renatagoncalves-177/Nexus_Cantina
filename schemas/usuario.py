from pydantic import BaseModel


class UsuarioResposta(BaseModel):
    id: int
    nome: str
    tipo: str
