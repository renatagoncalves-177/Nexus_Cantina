const carrinho = JSON.parse(localStorage.getItem("carrinho")) || [];
const intervalo = localStorage.getItem("intervaloPedido") || "";

const listaPedido = document.getElementById("listaPedido");
const intervaloElemento = document.getElementById("intervaloPedido");
const totalElemento = document.getElementById("totalPedido");
const aviso = document.getElementById("avisoPagamento");
const abrirConfirmacao = document.getElementById("abrirConfirmacao");
const modal = document.getElementById("modalConfirmacao");
const cancelarConfirmacao = document.getElementById("cancelarConfirmacao");
const confirmarCompra = document.getElementById("confirmarCompra");

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

function intervaloJaUsadoHoje() {
    const registros = lerIntervalosConfirmados();
    const intervalosHoje = registros[obterChaveHoje()] || [];

    return intervalosHoje.includes(intervalo);
}

function calcularTotal() {
    return carrinho.reduce((total, item) => {
        return total + Number(item.preco) * Number(item.quantidade);
    }, 0);
}

function formatarMoeda(valor) {
    return valor.toLocaleString("pt-BR", {
        style: "currency",
        currency: "BRL"
    });
}

function bloquearConfirmacao(mensagem) {
    aviso.textContent = mensagem;
    aviso.classList.add("visivel", "erro");
    abrirConfirmacao.disabled = true;
}

function renderizarPedido() {
    intervaloElemento.textContent = intervalo || "Não informado";
    totalElemento.textContent = formatarMoeda(calcularTotal());
    listaPedido.innerHTML = "";

    if (carrinho.length === 0) {
        listaPedido.innerHTML = `
            <div class="estado-vazio">
                <p>Seu carrinho está vazio.</p>
                <a href="pedidoaluno.html">Escolher produtos</a>
            </div>
        `;
        bloquearConfirmacao("Adicione pelo menos um produto antes de confirmar.");
        return;
    }

    carrinho.forEach((item) => {
        const elemento = document.createElement("article");
        elemento.className = "item-pedido";
        elemento.innerHTML = `
            <div class="item-identificacao">
                <span class="item-emoji">${item.emoji || "🍽️"}</span>
                <div>
                    <h3>${item.nome}</h3>
                    <p>Quantidade: ${item.quantidade}</p>
                </div>
            </div>
            <strong>${formatarMoeda(Number(item.preco) * Number(item.quantidade))}</strong>
        `;
        listaPedido.appendChild(elemento);
    });

    if (!intervalo) {
        bloquearConfirmacao("Volte ao carrinho e escolha um intervalo para retirada.");
        return;
    }

    if (intervaloJaUsadoHoje()) {
        bloquearConfirmacao(
            `Você já fez um pedido para ${intervalo.toLowerCase()} hoje. ` +
            "Tente novamente amanhã ou escolha o outro intervalo."
        );
    }
}

function exibirModal() {
    if (abrirConfirmacao.disabled) {
        return;
    }

    modal.hidden = false;
    document.body.classList.add("modal-aberto");
    confirmarCompra.focus();
}

function fecharModal() {
    modal.hidden = true;
    document.body.classList.remove("modal-aberto");
    abrirConfirmacao.focus();
}

function registrarPedido() {
    if (intervaloJaUsadoHoje()) {
        fecharModal();
        bloquearConfirmacao(
            "Este intervalo acabou de ser utilizado. Escolha outro ou tente amanhã."
        );
        return;
    }

    const registros = lerIntervalosConfirmados();
    const chaveHoje = obterChaveHoje();
    const intervalosHoje = registros[chaveHoje] || [];

    intervalosHoje.push(intervalo);
    registros[chaveHoje] = intervalosHoje;
    localStorage.setItem("intervalosConfirmados", JSON.stringify(registros));

    const pedido = {
        id: Date.now(),
        data: chaveHoje,
        intervalo,
        total: calcularTotal(),
        itens: carrinho,
        confirmadoEm: new Date().toISOString()
    };

    localStorage.setItem("ultimoPedido", JSON.stringify(pedido));
    localStorage.removeItem("carrinho");
    localStorage.removeItem("totalPedido");
    localStorage.removeItem("intervaloPedido");

    window.location.href = "alertapagamento.html";
}

abrirConfirmacao.addEventListener("click", exibirModal);
cancelarConfirmacao.addEventListener("click", fecharModal);
confirmarCompra.addEventListener("click", registrarPedido);

modal.addEventListener("click", (event) => {
    if (event.target === modal) {
        fecharModal();
    }
});

document.addEventListener("keydown", (event) => {
    if (event.key === "Escape" && !modal.hidden) {
        fecharModal();
    }
});

renderizarPedido();
