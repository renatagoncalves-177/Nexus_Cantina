(function () {
    "use strict";

    const destinos = {
        aluno: { inicio: "telaaluno.html", login: "loginaluno.html" },
        responsavel: { inicio: "telaresponsavel.html", login: "loginresponsavel.html" },
        admin: { inicio: "telaadmin.html", login: "loginadmin.html" },
    };

    async function atualizarNavegacao() {
        try {
            const resposta = await fetch("/api/auth/me", { cache: "no-store" });
            if (!resposta.ok) return;
            const usuario = await resposta.json();
            const destino = destinos[usuario.tipo];
            if (!destino) return;

            const permitidos = (document.body.dataset.perfis || "")
                .split(",")
                .map(tipo => tipo.trim())
                .filter(Boolean);
            if (permitidos.length && !permitidos.includes(usuario.tipo)) {
                window.location.replace(destino.inicio);
                return;
            }

            document.querySelectorAll("[data-inicio-perfil]").forEach(link => {
                link.href = destino.inicio;
            });
            document.querySelectorAll("[data-logout]").forEach(link => {
                link.href = destino.login;
            });
        } catch (_) {
            /* O backend continua protegendo as rotas se a consulta falhar. */
        }
    }

    window.addEventListener("pageshow", atualizarNavegacao);
    window.addEventListener("focus", atualizarNavegacao);
    atualizarNavegacao();
}());
