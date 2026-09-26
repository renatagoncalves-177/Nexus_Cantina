import os
import secrets
import asyncio
from datetime import datetime, timezone
from pathlib import Path

from fastapi import FastAPI
from fastapi.responses import JSONResponse
from starlette.exceptions import HTTPException
from sqlalchemy.exc import IntegrityError, OperationalError
from fastapi.staticfiles import StaticFiles
from dotenv import load_dotenv
from starlette.middleware.sessions import SessionMiddleware

BASE_DIR = Path(__file__).resolve().parent
load_dotenv(BASE_DIR / ".env")

from routers.auth import router as auth_router  # noqa: E402
from routers.paginas import router as paginas_router  # noqa: E402
from routers.produtos import router as produtos_router  # noqa: E402
from routers.alunos import router as alunos_router
from routers.pedidos import router as pedidos_router


CHAVE_SESSAO = os.getenv("SECRET_KEY") or secrets.token_urlsafe(32)
COOKIE_SEGURO = os.getenv("COOKIE_SECURE", "false").lower() == "true"

app = FastAPI(title="Nexus Cantina")


@app.middleware("http")
async def ordenar_escritas(request, call_next):
    # Uma instância/worker: FIFO pela chegada ao servidor; empates em ms seguem a fila.
    if request.method in {"POST", "PUT", "PATCH", "DELETE"} and request.url.path.startswith("/api/"):
        if not hasattr(app.state, "fila"):
            app.state.fila = asyncio.Lock()
        request.state.recebido_em = datetime.now(timezone.utc)
        async with app.state.fila:
            response = await call_next(request)
    else:
        response = await call_next(request)
    if not request.url.path.startswith("/static/"):
        response.headers["Cache-Control"] = "no-store"
    return response


@app.exception_handler(HTTPException)
async def erro_http(request, exc):
    return JSONResponse(status_code=exc.status_code, content={"status": "error", "message": str(exc.detail)}, headers=exc.headers)


@app.exception_handler(IntegrityError)
async def conflito(request, exc):
    return JSONResponse(status_code=409, content={"status": "error", "message": "Registro duplicado ou vínculo inválido. Atualize a página."})


@app.exception_handler(OperationalError)
async def banco_indisponivel(request, exc):
    return JSONResponse(status_code=503, content={"status": "error", "message": "Banco indisponível ou não inicializado. Execute python -m scripts.inicializar_banco e confira a conexão."})
app.add_middleware(
    SessionMiddleware,
    secret_key=CHAVE_SESSAO,
    session_cookie="nexus_session",
    max_age=8 * 60 * 60,
    same_site="lax",
    https_only=COOKIE_SEGURO,
)

app.mount(
    "/static",
    StaticFiles(directory=BASE_DIR / "static"),
    name="static",
)

app.include_router(auth_router)
app.include_router(produtos_router)
app.include_router(alunos_router)
app.include_router(pedidos_router)
app.include_router(paginas_router)
