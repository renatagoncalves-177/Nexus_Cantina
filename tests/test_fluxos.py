import asyncio
from pathlib import Path
import sqlite3
from uuid import uuid4

import httpx
import pytest
from sqlalchemy import create_engine, event
from sqlalchemy.orm import sessionmaker

from main import app
from database.database import get_db, get_db_opcional
from models.produto import Produto
from models.usuario import Estudante
from routers.pedidos import ESGOTADO

RAIZ = Path(__file__).resolve().parents[1]


@pytest.fixture
def anyio_backend():
    return "asyncio"


@pytest.fixture
def banco(tmp_path):
    caminho = tmp_path / "teste.db"
    with sqlite3.connect(caminho) as c:
        c.executescript((RAIZ / "database/seed.sql").read_text(encoding="utf-8"))
    engine = create_engine("sqlite:///" + caminho.as_posix(), connect_args={"check_same_thread": False, "timeout": 30})
    @event.listens_for(engine, "connect")
    def configurar(c, _):
        c.execute("PRAGMA foreign_keys=ON")
    fabrica = sessionmaker(engine, expire_on_commit=False, autoflush=False)
    def sessao():
        with fabrica() as db:
            yield db
    app.dependency_overrides[get_db] = sessao
    app.dependency_overrides[get_db_opcional] = sessao
    if hasattr(app.state, "fila"):
        del app.state.fila
    yield fabrica, caminho
    app.dependency_overrides.clear()
    engine.dispose()


def cliente():
    return httpx.AsyncClient(transport=httpx.ASGITransport(app=app), base_url="http://test")


async def login(c, identificador="aluno01", tipo="aluno", senha="12345678"):
    r = await c.post("/api/auth/login", json={"identificador": identificador, "tipo": tipo, "senha": senha})
    assert r.status_code == 200, r.text
    return r.json()


def compra(produto=1, quantidade=1, intervalo="Primeiro intervalo"):
    return {"intervalo": intervalo, "chave": str(uuid4()), "itens": [{"produto_id": produto, "quantidade": quantidade}]}


@pytest.mark.anyio
async def test_seed_logins_e_perfis(banco):
    _, caminho = banco
    with sqlite3.connect(caminho) as db:
        assert dict(db.execute("SELECT tipo, COUNT(*) FROM usuarios GROUP BY tipo")) == {"admin": 1, "aluno": 50, "responsavel": 50}
        assert db.execute("SELECT COUNT(*) FROM produtos").fetchone()[0] == 38
        assert db.execute("SELECT COUNT(*) FROM estudantes WHERE saldo=50 AND responsavel_id IS NOT NULL").fetchone()[0] == 50
        assert len(db.execute("SELECT serie FROM estudantes GROUP BY serie").fetchall()) == 7
        assert db.execute("SELECT COUNT(*) FROM produtos WHERE estoque=2").fetchone()[0] >= 3
        db.executescript((RAIZ / "database/seed.sql").read_text(encoding="utf-8"))
        assert db.execute("SELECT COUNT(*) FROM usuarios").fetchone()[0] == 101
    async with cliente() as c:
        for n in range(1, 51):
            await login(c, f"aluno{n:02}")
            assert (await c.get("/api/auth/me")).json()["tipo"] == "aluno"
            await login(c, f"responsavel{n:02}@teste.example", "responsavel")
            assert (await c.get("/api/alunos/me")).json()["id"] == 200 + n
        await login(c, "admin@nexuscantina.com", "admin")
        await login(c, "admin", "admin")
        assert (await c.post("/api/auth/login", json={"identificador": "admin", "tipo": "admin", "senha": "errada"})).status_code == 401
        assert (await c.post("/api/auth/logout")).status_code == 204
        assert (await c.get("/api/auth/me")).status_code == 401


@pytest.mark.anyio
async def test_permissoes_cadastros_e_paginas(banco):
    async with cliente() as c:
        assert (await c.get("/api/produtos")).status_code == 401
        await login(c)
        assert (await c.post("/api/produtos", json={"nome": "Teste", "preco": 5, "estoque": 3})).status_code == 403
        assert (await c.get("/api/responsaveis")).status_code == 403
        assert (await c.get("/telaadmin.html")).status_code == 303
        for p in ("telaaluno", "pedidoaluno", "carrinho", "pagamento", "alertapagamento"):
            assert (await c.get("/" + p + ".html")).status_code == 200
        await login(c, "responsavel01@teste.example", "responsavel")
        assert len((await c.get("/api/alunos")).json()) == 1
        assert (await c.post("/api/alunos/202/saldo", json={"valor": 5, "chave": str(uuid4())})).status_code == 403
        await login(c, "admin", "admin")
        for p in ("telaadmin", "alunosdevendo", "gerenciaralunos", "gerenciarprodutos", "vincularaluno", "detalhepedido"):
            assert (await c.get("/" + p + ".html")).status_code == 200
        dados = {"nome": "Produto de teste", "preco": 5, "estoque": 3, "categoria": "Bebidas"}
        r = await c.post("/api/produtos", json=dados)
        assert r.status_code == 201, r.text
        produto_id = r.json()["id"]
        assert (await c.put(f"/api/produtos/{produto_id}", json={**dados, "estoque": 0})).status_code == 200
        assert (await c.delete(f"/api/produtos/{produto_id}")).status_code == 204
        novo = {"nome": "Aluno Cadastro", "matricula": "novoteste", "senha": "12345678"}
        assert (await c.post("/api/alunos", json=novo)).status_code == 201
        assert (await c.post("/api/alunos", json=novo)).status_code == 409
        resp = await c.post("/api/responsaveis", json={"nome": "Novo Responsável", "email": "novo@teste.example", "senha": "12345678"})
        assert resp.status_code == 201
        assert (await c.post("/api/vinculos", json={"responsavel_id": resp.json()["id"], "aluno_id": 201})).status_code == 200
        assert (await c.post("/api/vinculos", json={"responsavel_id": resp.json()["id"], "aluno_id": 202})).status_code == 409


@pytest.mark.anyio
async def test_compra_cancelamento_idempotencia_e_edicao(banco):
    fabrica, _ = banco
    async with cliente() as c:
        await login(c)
        dados = compra()
        r = await c.post("/api/pedidos", json=dados)
        assert r.status_code == 201, r.text
        p = r.json()
        assert p["saldo"] == 43
        assert (await c.post("/api/pedidos", json=dados)).json()["id"] == p["id"]
        assert (await c.post("/api/pedidos", json=compra())).status_code == 409
        edicao = compra(2)
        r = await c.put(f'/api/pedidos/{p["id"]}', json=edicao)
        assert r.status_code == 200, r.text
        assert r.json()["saldo"] == 42
        assert (await c.put(f'/api/pedidos/{p["id"]}', json=edicao)).json()["saldo"] == 42
        falha = await c.put(f'/api/pedidos/{p["id"]}', json=compra(3, 100))
        assert falha.status_code == 400
        assert (await c.get("/api/alunos/me")).json()["saldo"] == 42
        for _ in range(2):
            r = await c.patch(f'/api/pedidos/{p["id"]}', json={"status": "cancelado"})
            assert r.status_code == 200, r.text
            assert r.json()["saldo"] == 50
        with fabrica() as db:
            assert db.get(Produto, 1).estoque == 2
            assert db.get(Produto, 2).estoque == 2
        assert (await c.post("/api/pedidos", json=compra())).status_code == 201


@pytest.mark.anyio
async def test_concorrencia_e_rollback(banco):
    fabrica, _ = banco
    clientes = [cliente() for _ in range(4)]
    try:
        for n, c in enumerate(clientes, 1):
            await login(c, f"aluno{n:02}")
        resultados = await asyncio.gather(*(c.post("/api/pedidos", json=compra()) for c in clientes))
        assert [r.status_code for r in resultados] == [201, 201, 400, 400]
        for r in resultados[2:]:
            assert r.json() == {"status": "error", "message": ESGOTADO}
        with fabrica() as db:
            assert db.get(Produto, 1).estoque == 0
            assert [float(db.get(Estudante, n).saldo) for n in range(201, 205)] == [43, 43, 50, 50]
        assert all(p["id"] != 1 for p in (await clientes[0].get("/api/produtos")).json())
        # O primeiro item disponível também deve voltar ao estoque ao falhar outro item.
        dados = compra(2)
        dados["itens"].append({"produto_id": 3, "quantidade": 100})
        assert (await clientes[2].post("/api/pedidos", json=dados)).status_code == 400
        with fabrica() as db:
            assert db.get(Produto, 2).estoque == 2
            assert db.get(Estudante, 203).saldo == 50
    finally:
        for c in clientes:
            await c.aclose()


@pytest.mark.anyio
async def test_limite_recarga_conclusao_e_isolamento(banco):
    fabrica, _ = banco
    with fabrica() as db:
        db.get(Produto, 1).preco = 300
        db.commit()
    async with cliente() as c, cliente() as admin:
        await login(c)
        await login(admin, "admin", "admin")
        r = await c.post("/api/pedidos", json=compra())
        assert r.status_code == 201, r.text
        p = r.json()
        assert p["saldo"] == -250
        assert (await c.post("/api/pedidos", json=compra(2, intervalo="Segundo intervalo"))).status_code == 400
        assert (await c.patch(f'/api/pedidos/{p["id"]}', json={"status": "pronto"})).status_code == 403
        for status in ("pronto", "concluido"):
            assert (await admin.patch(f'/api/pedidos/{p["id"]}', json={"status": status})).status_code == 200
        assert (await c.patch(f'/api/pedidos/{p["id"]}', json={"status": "cancelado"})).status_code == 409
        assert (await c.put(f'/api/pedidos/{p["id"]}', json=compra(2))).status_code == 409
        await login(c, "aluno02")
        assert (await c.get(f'/api/pedidos/{p["id"]}')).status_code == 403
        await login(c, "responsavel01@teste.example", "responsavel")
        dados = {"valor": 50, "chave": str(uuid4())}
        for _ in range(2):
            assert (await c.post("/api/alunos/201/saldo", json=dados)).json()["saldo"] == -200
        assert (await admin.post("/api/alunos/201/saldo", json={"valor": 201, "tipo": "recebimento", "chave": str(uuid4())})).status_code == 400
        assert (await admin.post("/api/alunos/201/saldo", json={"valor": 200, "tipo": "recebimento", "chave": str(uuid4())})).json()["saldo"] == 0
