(function () {
    "use strict";

    const lista = document.getElementById("listaProdutos");

    // ------------------------------------------------------------------
    // Carrinho (localStorage)
    // ------------------------------------------------------------------

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

        if (existente) {
            existente.quantidade = Number(existente.quantidade || 0) + 1;
        } else {
            carrinho.push({
                id: produto.id,
                nome: produto.nome,
                preco: produto.preco,
                quantidade: 1,
                emoji: produto.emoji || "🍽️"
            });
        }

        localStorage.setItem("carrinho", JSON.stringify(carrinho));
        const mensagem = document.getElementById("mensagem");
        mensagem.classList.add("visivel");
        window.setTimeout(() => mensagem.classList.remove("visivel"), 1800);
    }

    // ------------------------------------------------------------------
    // Criação de cards mantendo as classes CSS existentes
    // ------------------------------------------------------------------

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
        preco.textContent = Number(produto.preco).toLocaleString("pt-BR", {
            style: "currency",
            currency: "BRL"
        });
        rodape.append(preco);

        // A API já filtra estoque > 0, mas verificamos por segurança
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

    // ------------------------------------------------------------------
    // Renderização
    // ------------------------------------------------------------------

    function renderizarProdutos(produtos) {
        lista.replaceChildren();

        // Filtra qualquer produto com estoque <= 0 recebido da API
        const disponiveis = produtos.filter(p => p.estoque > 0);

        if (!disponiveis.length) {
            const estado = document.createElement("section");
            estado.className = "estado-vazio";
            estado.setAttribute("aria-live", "polite");
            const titulo = document.createElement("h2");
            titulo.textContent = "Cardápio indisponível no momento";
            const texto = document.createElement("p");
            texto.textContent = "Nenhum produto está disponível agora. Tente novamente em breve.";
            estado.append(titulo, texto);
            lista.append(estado);
            return;
        }

        disponiveis.forEach(produto => lista.append(criarCard(produto)));
    }

    function exibirErro(mensagem) {
        lista.replaceChildren();
        const estado = document.createElement("section");
        estado.className = "estado-vazio";
        estado.setAttribute("aria-live", "polite");
        const titulo = document.createElement("h2");
        titulo.textContent = "Não foi possível carregar o cardápio";
        const texto = document.createElement("p");
        texto.textContent = mensagem || "Verifique sua conexão e atualize a página.";
        estado.append(titulo, texto);
        lista.append(estado);
    }

    // ------------------------------------------------------------------
    // Busca os produtos na API — omite automaticamente estoque <= 0
    // ------------------------------------------------------------------

    async function carregarProdutos() {
        try {
            const resposta = await fetch("/api/produtos/", {
                credentials: "same-origin"
            });

            if (!resposta.ok) {
                throw new Error(`Erro ${resposta.status}: ${resposta.statusText}`);
            }

            const produtos = await resposta.json();

            if (!Array.isArray(produtos)) {
                throw new Error("Resposta inesperada do servidor.");
            }

            renderizarProdutos(produtos);
        } catch (erro) {
            console.error("[pedidoaluno] Falha ao carregar produtos:", erro);
            exibirErro(
                "Não foi possível carregar o cardápio agora. " +
                "Verifique se o servidor está rodando."
            );
        }
    }

    carregarProdutos();
}());
