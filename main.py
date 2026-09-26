import os
import secrets
from pathlib import Path

from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from dotenv import load_dotenv
from starlette.middleware.sessions import SessionMiddleware

BASE_DIR = Path(__file__).resolve().parent
load_dotenv(BASE_DIR / ".env")

from routers.auth import router as auth_router  # noqa: E402
from routers.paginas import router as paginas_router  # noqa: E402


CHAVE_SESSAO = os.getenv("SECRET_KEY") or secrets.token_urlsafe(32)
COOKIE_SEGURO = os.getenv("COOKIE_SECURE", "false").lower() == "true"

app = FastAPI(title="Nexus Cantina")
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
app.include_router(paginas_router)
