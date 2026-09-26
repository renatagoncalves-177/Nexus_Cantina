(function () {
    "use strict";
    const G = window.NexusGestao;
    const form = document.getElementById("formAdmin");
    const email = document.getElementById("emailAdmin");
    const senha = document.getElementById("senhaAdmin");
    const mensagem = document.getElementById("mensagemAdmin");
    const mostrar = document.getElementById("mostrarSenha");
    mostrar.addEventListener("click", () => {
        const visivel = senha.type === "password";
        senha.type = visivel ? "text" : "password";
        mostrar.textContent = visivel ? "Ocultar" : "Mostrar";
        mostrar.setAttribute("aria-pressed", String(visivel));
    });
    form.addEventListener("submit", event => {
        event.preventDefault();
        try {
            G.entrar(email.value, senha.value);
            senha.value = "";
            window.location.href = "telaadmin.html";
        } catch (erro) {
            G.aviso(mensagem, erro.message, true);
        }
    });
}());
