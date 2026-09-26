"""Contas locais e explícitas para uso antes da integração com o banco."""

import hmac
import os
from dataclasses import dataclass

from models.usuario import TipoUsuario


def _variavel_ativa(nome: str) -> bool:
    return os.getenv(nome, "false").strip().lower() in {"1", "true", "sim", "yes"}


MODO_TESTE_ATIVO = _variavel_ativa("ENABLE_TEST_USERS")
SENHA_TESTE = os.getenv("NEXUS_TEST_PASSWORD", "1234")


@dataclass(frozen=True)
class ContaTeste:
    id: int
    nome: str
    tipo: TipoUsuario
    identificador: str

    def resposta(self) -> dict:
        return {"id": self.id, "nome": self.nome, "tipo": self.tipo}


CONTAS_TESTE = (
    ContaTeste(-1, "Aluno de Teste", TipoUsuario.ALUNO, "aluno01"),
    ContaTeste(-2, "Responsável de Teste", TipoUsuario.RESPONSAVEL, "resp01@teste.com"),
    ContaTeste(-3, "Administrador de Teste", TipoUsuario.ADMIN, "admin01@teste.com"),
)


def autenticar_conta_teste(identificador: str, senha: str, tipo: TipoUsuario) -> ContaTeste | None:
    if not MODO_TESTE_ATIVO or not hmac.compare_digest(senha, SENHA_TESTE):
        return None

    identificador_normalizado = identificador.strip().lower()
    return next(
        (
            conta
            for conta in CONTAS_TESTE
            if conta.tipo == tipo and conta.identificador.lower() == identificador_normalizado
        ),
        None,
    )


def obter_conta_teste(usuario_id: int) -> ContaTeste | None:
    if not MODO_TESTE_ATIVO:
        return None
    return next((conta for conta in CONTAS_TESTE if conta.id == usuario_id), None)
