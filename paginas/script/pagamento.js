  let carrinho = JSON.parse(localStorage.getItem("carrinho")) || [];

    const areaCarrinho = document.getElementById("carrinho");
    const resumo = document.getElementById("resumo");
    const totalElemento = document.getElementById("total");

    function renderizar() {
        areaCarrinho.innerHTML = "";

        if (carrinho.length === 0) {
            areaCarrinho.innerHTML = `
                <div class="vazio">
                    <p>Seu carrinho está vazio.</p>
                    <a href="pedidoaluno.html">Ver produtos</a>
                </div>
            `;

            resumo.style.display = "none";
            return;
        }

        resumo.style.display = "block";

        carrinho.forEach(item => {
            const elemento = document.createElement("div");

            elemento.className = "item";

            elemento.innerHTML = `
                <div class="info">
                    <div class="emoji">${item.emoji}</div>

                    <div>
                        <h3>${item.nome}</h3>
                        <p>R$ ${item.preco.toFixed(2).replace(".", ",")}</p>
                    </div>
                </div>

                <div class="quantidade">
                    <button onclick="alterarQuantidade(${item.id}, -1)">−</button>
                    <strong>${item.quantidade}</strong>
                    <button onclick="alterarQuantidade(${item.id}, 1)">+</button>
                </div>
            `;

            areaCarrinho.appendChild(elemento);
        });

        atualizarTotal();
    }

    function alterarQuantidade(id, valor) {
        const item = carrinho.find(produto => produto.id === id);

        if (!item) {
            return;
        }

        item.quantidade += valor;

        if (item.quantidade <= 0) {
            carrinho = carrinho.filter(produto => produto.id !== id);
        }

        localStorage.setItem("carrinho", JSON.stringify(carrinho));

        renderizar();
    }

    function atualizarTotal() {
        const total = carrinho.reduce((soma, item) => {
            return soma + item.preco * item.quantidade;
        }, 0);

        totalElemento.textContent =
            "R$ " + total.toFixed(2).replace(".", ",");

        localStorage.setItem("totalPedido", total);
    }

    function continuarPagamento() {
        const intervalo = document.getElementById("intervalo").value;

        if (intervalo === "") {
            alert("Escolha o intervalo para retirada.");
            return;
        }

        localStorage.setItem("intervaloPedido", intervalo);

        window.location.href = "pagamento.html";
    }

    renderizar();