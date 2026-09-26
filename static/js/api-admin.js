(function () {
    "use strict";

    async function requisitar(url, opcoes = {}) {
        const configuracao = { ...opcoes };
        configuracao.headers = { Accept: "application/json", ...(opcoes.headers || {}) };

        if (configuracao.body && typeof configuracao.body !== "string") {
            configuracao.headers["Content-Type"] = "application/json";
            configuracao.body = JSON.stringify(configuracao.body);
        }

        let resposta;
        try {
            resposta = await fetch(url, configuracao);
        } catch (_) {
            throw new Error("Não foi possível acessar a API. Confira se o FastAPI está em execução.");
        }

        const tipo = resposta.headers.get("content-type") || "";
        const dados = tipo.includes("application/json") ? await resposta.json() : null;

        if (!resposta.ok) {
            const erro = new Error(dados?.detail || "Não foi possível concluir a operação.");
            erro.integracaoPendente = [404, 405, 501, 503].includes(resposta.status);
            throw erro;
        }

        return dados;
    }

    function informar(elemento, texto, erro = false) {
        if (!elemento) return;
        elemento.textContent = texto;
        elemento.className = "mensagem-gestao " + (erro ? "erro" : "sucesso");
        elemento.hidden = !texto;
    }

    function informarPendente(elemento) {
        informar(elemento, "Esta tela está pronta, mas aguarda a criação do endpoint no FastAPI e sua conexão com o banco.", true);
    }

    function lista(dados, chave) {
        if (Array.isArray(dados)) return dados;
        return Array.isArray(dados?.[chave]) ? dados[chave] : [];
    }

    function criar(tag, texto, classe = "") {
        const elemento = document.createElement(tag);
        elemento.textContent = texto ?? "";
        if (classe) elemento.className = classe;
        return elemento;
    }

    window.NexusApi = { requisitar, informar, informarPendente, lista, criar };
}());
