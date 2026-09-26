let carrinho = JSON.parse(localStorage.getItem("carrinho")) || [];

const areaCarrinho = document.getElementById("carrinho");
const resumo = document.getElementById("resumo");
const totalElemento = document.getElementById("total");
const seletorIntervalo = document.getElementById("intervalo");

function obterChaveHoje() {
    const hoje = new Date();
    const ano = hoje.getFullYear();
    const mes = String(hoje.getMonth() + 1).padStart(2, "0");
    const dia = String(hoje.getDate()).padStart(2, "0");

    return `${ano}-${mes}-${dia}`;
}

function lerIntervalosConfirmados() {
    try {
        return JSON.parse(localStorage.getItem("intervalosConfirmados")) || {};
    } catch (_erro) {
        return {};
    }
}

function atualizarIntervalosDisponiveis() {
    const registros = lerIntervalosConfirmados();
    const intervalosHoje = registros[obterChaveHoje()] || [];

    Array.from(seletorIntervalo.options).forEach((opcao) => {
        if (!opcao.value) {
            return;
        }

        const rotuloOriginal = opcao.dataset.rotulo || opcao.textContent;
        const bloqueado = intervalosHoje.includes(opcao.value);

        opcao.dataset.rotulo = rotuloOriginal;
        opcao.disabled = bloqueado;
        opcao.textContent = bloqueado
            ? `${rotuloOriginal} — pedido já feito hoje`
            : rotuloOriginal;
    });
}

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

    carrinho.forEach((item) => {
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
    const item = carrinho.find((produto) => produto.id === id);

    if (!item) {
        return;
    }

    item.quantidade += valor;

    if (item.quantidade <= 0) {
        carrinho = carrinho.filter((produto) => produto.id !== id);
    }

    localStorage.setItem("carrinho", JSON.stringify(carrinho));
    renderizar();
}

function atualizarTotal() {
    const total = carrinho.reduce((soma, item) => {
        return soma + item.preco * item.quantidade;
    }, 0);

    totalElemento.textContent = `R$ ${total.toFixed(2).replace(".", ",")}`;
    localStorage.setItem("totalPedido", total);
}

function continuarPagamento() {
    const intervalo = seletorIntervalo.value;

    if (!intervalo) {
        alert("Escolha um intervalo disponível para retirada.");
        return;
    }

    const registros = lerIntervalosConfirmados();
    const intervalosHoje = registros[obterChaveHoje()] || [];

    if (intervalosHoje.includes(intervalo)) {
        alert("Você já fez um pedido para este intervalo hoje.");
        atualizarIntervalosDisponiveis();
        return;
    }

    localStorage.setItem("intervaloPedido", intervalo);
    window.location.href = "pagamento.html";
}

atualizarIntervalosDisponiveis();
renderizar();
