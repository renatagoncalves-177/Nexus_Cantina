(function () {
    "use strict";
    const destinos = document.querySelectorAll("[data-nome-usuario]");
    if (!destinos.length) return;

    async function atualizarNome() {
        try {
            const resposta = await fetch("/api/auth/me", { cache: "no-store" });
            if (!resposta.ok) return;
            const usuario = await resposta.json();
            destinos.forEach((elemento) => { elemento.textContent = usuario.nome; });
        } catch (_) {
            /* A proteção da rota continua sendo responsabilidade do backend. */
        }
    }

    window.addEventListener("pageshow", atualizarNome);
    window.addEventListener("focus", atualizarNome);
    atualizarNome();
}());
