(function () {
    "use strict";
    const Api = window.NexusApi;
    const formulario = document.getElementById("formProduto");
    const corpo = document.getElementById("listaProdutos");
    const vazio = document.getElementById("vazioProdutos");
    const mensagem = document.getElementById("mensagemProdutos");

    function moeda(valor) {
        return Number(valor || 0).toLocaleString("pt-BR", { style: "currency", currency: "BRL" });
    }

    function renderizar(produtos) {
        corpo.replaceChildren();
        produtos.forEach(produto => {
            const linha = document.createElement("tr");
            const identificacao = document.createElement("td");
            identificacao.append(Api.criar("strong", produto.nome), Api.criar("small", produto.descricao || "Sem descrição"));
            linha.append(
                identificacao,
                Api.criar("td", moeda(produto.preco)),
                Api.criar("td", String(produto.estoque ?? 0)),
                Api.criar("td", produto.ativo === false ? "Inativo" : "Ativo", "badge " + (produto.ativo === false ? "cancelado" : "regular"))
            );
            corpo.append(linha);
        });
        vazio.hidden = produtos.length > 0;
        document.getElementById("contagemProdutos").textContent = produtos.length + " produto(s) cadastrado(s)";
    }

    async function carregar() {
        try {
            const dados = await Api.requisitar("/api/produtos");
            renderizar(Api.lista(dados, "produtos"));
            Api.informar(mensagem, "");
        } catch (erro) {
            renderizar([]);
            erro.integracaoPendente ? Api.informarPendente(mensagem) : Api.informar(mensagem, erro.message, true);
        }
    }

    formulario.addEventListener("submit", async evento => {
        evento.preventDefault();
        const botao = formulario.querySelector("button[type='submit']");
        const dados = Object.fromEntries(new FormData(formulario));
        dados.preco = Number(String(dados.preco).replace(",", "."));
        dados.estoque = Number(dados.estoque);
        dados.ativo = formulario.elements.ativo.checked;
        botao.disabled = true;
        try {
            await Api.requisitar("/api/produtos", { method: "POST", body: dados });
            formulario.reset();
            formulario.elements.ativo.checked = true;
            Api.informar(mensagem, "Produto cadastrado com sucesso.");
            await carregar();
        } catch (erro) {
            erro.integracaoPendente ? Api.informarPendente(mensagem) : Api.informar(mensagem, erro.message, true);
        } finally {
            botao.disabled = false;
        }
    });

    document.getElementById("atualizarProdutos").addEventListener("click", carregar);
    carregar();
}());
