from pathlib import Path

from fastapi import APIRouter, HTTPException, Request
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates


BASE_DIR = Path(__file__).resolve().parent.parent
templates = Jinja2Templates(directory=BASE_DIR / "templates")
router = APIRouter()

PAGINAS = {
    "escolhausuario",
    "loginaluno",
    "loginresponsavel",
    "telaadmin",
    "telaaluno",
    "telaresponsavel",
    "pedidoaluno",
    "carrinho",
    "pagamento",
    "alertapagamento",
    "alunosdevendo",
    "loginadmin",
    "adicionarsaldo",
}


@router.get("/", response_class=HTMLResponse)
async def inicio(request: Request):
    return templates.TemplateResponse(
        request=request,
        name="escolhausuario.html",
    )


@router.get("/{nome_pagina}", response_class=HTMLResponse)
async def exibir_pagina(request: Request, nome_pagina: str):
    pagina_sem_extensao = nome_pagina.removesuffix(".html")

    if pagina_sem_extensao not in PAGINAS:
        raise HTTPException(status_code=404, detail="Página não encontrada")

    return templates.TemplateResponse(
        request=request,
        name=f"{pagina_sem_extensao}.html",
    )
