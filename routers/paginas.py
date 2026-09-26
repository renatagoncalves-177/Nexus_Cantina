from pathlib import Path

from fastapi import APIRouter, HTTPException, Request, Depends
from sqlalchemy.orm import Session
from database.database import get_db_opcional
from models.usuario import Usuario
from fastapi.responses import HTMLResponse, RedirectResponse
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
    "gerenciaralunos",
    "gerenciarprodutos",
    "detalhepedido",
    "vincularaluno",
}

PAGINAS_PROTEGIDAS = {
    "telaaluno": {"aluno"},
    "pedidoaluno": {"aluno", "responsavel"},
    "carrinho": {"aluno", "responsavel"},
    "pagamento": {"aluno", "responsavel"},
    "alertapagamento": {"aluno", "responsavel"},
    "telaresponsavel": {"responsavel"},
    "adicionarsaldo": {"responsavel"},
    "telaadmin": {"admin"},
    "alunosdevendo": {"admin"},
    "gerenciaralunos": {"admin"},
    "gerenciarprodutos": {"admin"},
    "detalhepedido": {"admin"},
    "vincularaluno": {"admin"},
}

DESTINOS_POR_TIPO = {
    "aluno": "telaaluno.html",
    "responsavel": "telaresponsavel.html",
    "admin": "telaadmin.html",
}

LOGIN_POR_TIPO = {
    "aluno": "loginaluno.html",
    "responsavel": "loginresponsavel.html",
    "admin": "loginadmin.html",
}


@router.get("/", response_class=HTMLResponse)
async def inicio(request: Request, db: Session | None = Depends(get_db_opcional)):
    validar_sessao(request, db)
    destino = DESTINOS_POR_TIPO.get(request.session.get("tipo"))
    if destino:
        return RedirectResponse(url="/" + destino, status_code=303)
    return templates.TemplateResponse(
        request=request,
        name="escolhausuario.html",
    )


@router.get("/{nome_pagina}", response_class=HTMLResponse)
async def exibir_pagina(request: Request, nome_pagina: str, db: Session | None = Depends(get_db_opcional)):
    validar_sessao(request, db)
    pagina_sem_extensao = nome_pagina.removesuffix(".html")

    if pagina_sem_extensao not in PAGINAS:
        raise HTTPException(status_code=404, detail="Página não encontrada")

    tipo_usuario = request.session.get("tipo")
    permitido = PAGINAS_PROTEGIDAS.get(pagina_sem_extensao)
    if permitido and tipo_usuario not in permitido:
        if tipo_usuario in DESTINOS_POR_TIPO:
            return RedirectResponse(url=f"/{DESTINOS_POR_TIPO[tipo_usuario]}", status_code=303)
        if len(permitido) == 1:
            login = LOGIN_POR_TIPO[next(iter(permitido))]
        else:
            login = "escolhausuario.html"
        return RedirectResponse(url=f"/{login}", status_code=303)

    tipo_login = next(
        (tipo for tipo, pagina in LOGIN_POR_TIPO.items() if pagina.removesuffix(".html") == pagina_sem_extensao),
        None,
    )
    if tipo_login and tipo_usuario == tipo_login:
        return RedirectResponse(url=f"/{DESTINOS_POR_TIPO[tipo_login]}", status_code=303)

    return templates.TemplateResponse(
        request=request,
        name=f"{pagina_sem_extensao}.html",
    )


def validar_sessao(request, db):
    if not request.session.get("usuario_id"):
        return
    usuario = db.get(Usuario, request.session["usuario_id"]) if db is not None else None
    if not usuario or not usuario.ativo or request.session.get("modo_teste"):
        request.session.clear()
    else:
        request.session["tipo"] = usuario.tipo.value
