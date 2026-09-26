from pathlib import Path

from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles

from routers.paginas import router as paginas_router


BASE_DIR = Path(__file__).resolve().parent

app = FastAPI(title="Nexus Cantina")

app.mount(
    "/static",
    StaticFiles(directory=BASE_DIR / "static"),
    name="static",
)

app.include_router(paginas_router)
