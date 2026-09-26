(function () {
    "use strict";
    const Api = window.NexusApi;
    const formulario = document.getElementById("formProduto");
    const corpo = document.getElementById("listaProdutos");
    const vazio = document.getElementById("vazioProdutos");
    const mensagem = document.getElementById("mensagemProdutos");
    let editando = null;
    let produtoEdicao = null;

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
            linha.tabIndex = 0;
            linha.setAttribute("aria-label", "Editar " + produto.nome);
            const editar = () => {
                editando = produto.id;
                produtoEdicao = produto;
                for (const campo of ["nome", "descricao", "preco", "estoque"]) formulario.elements[campo].value = produto[campo] ?? "";
                formulario.elements.ativo.checked = produto.ativo;
                formulario.querySelector("button[type='submit']").textContent = "Salvar alterações";
                formulario.elements.nome.focus();
                Api.informar(mensagem, "Editando " + produto.nome + ". Salve as alterações ou atualize a lista para voltar ao cadastro.");
            };
            linha.addEventListener("click", editar);
            linha.addEventListener("keydown", e => { if (e.key === "Enter") editar(); });
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
            // Campos sem controles visuais são preservados na edição.
            if (produtoEdicao) {
                dados.categoria = produtoEdicao.categoria;
                dados.imagem_url = produtoEdicao.imagem_url;
                dados.emoji = produtoEdicao.emoji;
            }
            const categoria = prompt("Categoria: Salgados Assados, Salgados Fritos, Doces & Sobremesas, Bebidas, Lanches Saudáveis ou Pratos do Dia", dados.categoria || "Salgados Assados");
            if (categoria === null) return;
            dados.categoria = categoria;
            const imagem = prompt("Caminho da imagem em /static/img/produtos/ (opcional)", dados.imagem_url || "");
            if (imagem === null) return;
            dados.imagem_url = imagem || null;
            await Api.requisitar("/api/produtos" + (editando ? "/" + editando : ""), { method: editando ? "PUT" : "POST", body: dados });
            editando = produtoEdicao = null;
            botao.textContent = "Cadastrar produto";
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

    document.getElementById("atualizarProdutos").addEventListener("click", () => {
        editando = produtoEdicao = null;
        formulario.reset();
        formulario.querySelector("button[type='submit']").textContent = "Cadastrar produto";
        carregar();
    });
    carregar();
}());
