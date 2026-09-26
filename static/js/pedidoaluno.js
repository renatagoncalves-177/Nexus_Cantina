(function () {
    "use strict";

    const lista = document.getElementById("listaProdutos");
    const produtos = [];

    function lerCarrinho() {
        try {
            const dados = JSON.parse(localStorage.getItem("carrinho") || "[]");
            return Array.isArray(dados) ? dados : [];
        } catch (_) {
            localStorage.removeItem("carrinho");
            return [];
        }
    }

    function adicionarCarrinho(produto) {
        if (!produto || produto.estoque <= 0) return;
        const carrinho = lerCarrinho();
        const existente = carrinho.find(item => item.id === produto.id);

        if (existente) existente.quantidade = Number(existente.quantidade || 0) + 1;
        else carrinho.push({
            id: produto.id,
            nome: produto.nome,
            preco: produto.preco,
            quantidade: 1,
            emoji: produto.emoji
        });

        localStorage.setItem("carrinho", JSON.stringify(carrinho));
        const mensagem = document.getElementById("mensagem");
        mensagem.classList.add("visivel");
        window.setTimeout(() => mensagem.classList.remove("visivel"), 1800);
    }

    function criarCard(produto) {
        const card = document.createElement("article");
        card.className = "produto";
        const imagem = document.createElement("div");
        imagem.className = "imagem";
        imagem.textContent = produto.emoji || "🍽️";
        const conteudo = document.createElement("div");
        conteudo.className = "conteudo";
        const nome = document.createElement("h3");
        nome.textContent = produto.nome;
        const descricao = document.createElement("p");
        descricao.textContent = produto.descricao || "";
        const rodape = document.createElement("div");
        rodape.className = "rodape-produto";
        const preco = document.createElement("span");
        preco.className = "preco";
        preco.textContent = Number(produto.preco).toLocaleString("pt-BR", { style: "currency", currency: "BRL" });
        rodape.append(preco);

        if (produto.estoque > 0) {
            const botao = document.createElement("button");
            botao.type = "button";
            botao.textContent = "Adicionar";
            botao.addEventListener("click", () => adicionarCarrinho(produto));
            rodape.append(botao);
        } else {
            const esgotado = document.createElement("span");
            esgotado.className = "esgotado";
            esgotado.textContent = "Esgotado";
            rodape.append(esgotado);
        }

        conteudo.append(nome, descricao, rodape);
        card.append(imagem, conteudo);
        return card;
    }

    function renderizarProdutos() {
        lista.replaceChildren();
        if (!produtos.length) {
            const estado = document.createElement("section");
            estado.className = "estado-vazio";
            estado.setAttribute("aria-live", "polite");
            const titulo = document.createElement("h2");
            titulo.textContent = "Cardápio ainda não carregado";
            const texto = document.createElement("p");
            texto.textContent = "Os produtos aparecerão aqui quando essa parte do banco for integrada.";
            estado.append(titulo, texto);
            lista.append(estado);
            return;
        }
        produtos.forEach(produto => lista.append(criarCard(produto)));
    }

    renderizarProdutos();
}());
