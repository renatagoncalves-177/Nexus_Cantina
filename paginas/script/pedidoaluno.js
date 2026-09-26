    const lista = document.getElementById("listaProdutos");

    function renderizarProdutos() {
        lista.innerHTML = "";

        produtos.forEach(produto => {
            const card = document.createElement("div");

            card.className = "produto";

            card.innerHTML = `
                <div class="imagem">${produto.emoji}</div>

                <div class="conteudo">
                    <h3>${produto.nome}</h3>
                    <p>${produto.descricao}</p>

                    <div class="rodape-produto">
                        <span class="preco">
                            R$ ${produto.preco.toFixed(2).replace(".", ",")}
                        </span>

                        ${
                            produto.estoque > 0
                            ? `<button onclick="adicionarCarrinho(${produto.id})">Adicionar</button>`
                            : `<span class="esgotado">Esgotado</span>`
                        }
                    </div>
                </div>
            `;

            lista.appendChild(card);
        });
    }

    function adicionarCarrinho(id) {
        const produto = produtos.find(p => p.id === id);

        if (!produto || produto.estoque <= 0) {
            return;
        }

        let carrinho = JSON.parse(localStorage.getItem("carrinho")) || [];

        const existente = carrinho.find(item => item.id === id);

        if (existente) {
            existente.quantidade++;
        } else {
            carrinho.push({
                id: produto.id,
                nome: produto.nome,
                preco: produto.preco,
                quantidade: 1,
                emoji: produto.emoji
            });
        }

        localStorage.setItem("carrinho", JSON.stringify(carrinho));

        const mensagem = document.getElementById("mensagem");

        mensagem.classList.add("visivel");

        setTimeout(() => {
            mensagem.classList.remove("visivel");
        }, 1800);
    }

    renderizarProdutos();