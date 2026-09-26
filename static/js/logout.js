(function () {
    "use strict";
    document.querySelectorAll("[data-logout]").forEach((link) => {
        link.addEventListener("click", async (event) => {
            event.preventDefault();
            let destino = link.href;
            try {
                const sessao = await fetch("/api/auth/me", { cache: "no-store" });
                if (sessao.ok) {
                    const usuario = await sessao.json();
                    destino = {
                        aluno: "loginaluno.html",
                        responsavel: "loginresponsavel.html",
                        admin: "loginadmin.html",
                    }[usuario.tipo] || destino;
                }
                await fetch("/api/auth/logout", { method: "POST" });
            } finally {
                window.location.href = destino;
            }
        });
    });
}());
