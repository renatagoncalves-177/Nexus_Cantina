(function () {
    "use strict";

    if (window.location.protocol === "file:") {
        const pagina = window.location.pathname.split("/").pop();
        window.location.replace(`http://127.0.0.1:8000/${pagina}`);
        return;
    }

    const form = document.getElementById("formLogin");
    const identificador = document.getElementById("identificador");
    const senha = document.getElementById("senha");
    const mensagem = document.getElementById("mensagemLogin");
    const botao = form.querySelector("[data-botao-login]");
    const mostrarSenha = form.querySelector("[data-mostrar-senha]");
    const textoOriginalBotao = botao.textContent;

    function exibirMensagem(texto, erro = true) {
        mensagem.textContent = texto;
        mensagem.hidden = false;
        mensagem.classList.toggle("erro", erro);
        mensagem.classList.toggle("sucesso", !erro);
    }

    mostrarSenha.addEventListener("click", () => {
        const senhaVisivel = senha.type === "password";
        senha.type = senhaVisivel ? "text" : "password";
        mostrarSenha.textContent = senhaVisivel ? "Ocultar" : "Mostrar";
        mostrarSenha.setAttribute("aria-pressed", String(senhaVisivel));
    });

    const campoEmail = form.querySelector("[data-alerta-email]");
    if (campoEmail) {
        let ultimoEmailAlertado = "";
        campoEmail.addEventListener("change", () => {
            const email = campoEmail.value.trim().toLowerCase();
            if (campoEmail.checkValidity() && email !== ultimoEmailAlertado) {
                window.alert(`Simulação: um e-mail foi enviado para ${email}. Nenhum e-mail real foi enviado.`);
                ultimoEmailAlertado = email;
            }
        });
    }

    form.addEventListener("submit", async (event) => {
        event.preventDefault();
        mensagem.hidden = true;
        if (!form.reportValidity()) return;

        botao.disabled = true;
        botao.textContent = "Entrando…";

        try {
            const resposta = await fetch("/api/auth/login", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({
                    identificador: identificador.value,
                    senha: senha.value,
                    tipo: form.dataset.tipo,
                }),
            });
            const dados = await resposta.json().catch(() => ({}));
            if (!resposta.ok) {
                if (resposta.status === 404) {
                    throw new Error("Abra o projeto pelo FastAPI em http://127.0.0.1:8000. O login não funciona pelo Live Server.");
                }
                throw new Error(dados.detail || "Não foi possível entrar agora.");
            }

            exibirMensagem(`Bem-vindo(a), ${dados.nome}.`, false);
            senha.value = "";
            window.location.href = form.dataset.destino;
        } catch (erro) {
            const mensagemErro = erro instanceof TypeError
                ? "O FastAPI não está ligado. Inicie o servidor na porta 8000 e tente novamente."
                : erro.message;
            exibirMensagem(mensagemErro || "Não foi possível conectar ao servidor.");
            senha.focus();
        } finally {
            botao.disabled = false;
            botao.textContent = textoOriginalBotao;
        }
    });
}());
