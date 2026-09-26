from pydantic import BaseModel, ConfigDict, Field, field_validator

from models.usuario import TipoUsuario


class LoginEntrada(BaseModel):
    identificador: str = Field(min_length=3, max_length=160)
    senha: str = Field(min_length=1, max_length=128)
    tipo: TipoUsuario

    @field_validator("identificador")
    @classmethod
    def limpar_identificador(cls, valor: str) -> str:
        return valor.strip()


class UsuarioAutenticado(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    nome: str
    tipo: TipoUsuario
