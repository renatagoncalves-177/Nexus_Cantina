function lerCarrinho() {
    try {
        const dados = JSON.parse(localStorage.getItem("carrinho") || "[]");
        if (!Array.isArray(dados)) return [];
        return dados.filter(item =>
            item && ["string", "number"].includes(typeof item.id) &&
            typeof item.nome === "string" && Number.isFinite(Number(item.preco)) &&
            Number(item.preco) >= 0 && Number.isInteger(Number(item.quantidade)) &&
            Number(item.quantidade) > 0
        ).map(item => ({
            id: item.id,
            nome: item.nome,
            preco: Number(item.preco),
            quantidade: Number(item.quantidade),
            emoji: typeof item.emoji === "string" ? item.emoji : "🍽️"
        }));
    } catch (_) {
        localStorage.removeItem("carrinho");
        return [];
    }
}

let carrinho = lerCarrinho();

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

let intervalosServidor = {};
function lerIntervalosConfirmados() { return intervalosServidor; }

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

    const intervaloSalvo = localStorage.getItem("intervaloPedido");
    const opcaoSalva = Array.from(seletorIntervalo.options).find((opcao) => opcao.value === intervaloSalvo);
    if (opcaoSalva && !opcaoSalva.disabled) seletorIntervalo.value = intervaloSalvo;
}

function renderizar() {
    areaCarrinho.replaceChildren();

    if (carrinho.length === 0) {
        const vazio = document.createElement("div");
        vazio.className = "vazio";
        const texto = document.createElement("p");
        texto.textContent = "Seu carrinho está vazio.";
        const link = document.createElement("a");
        link.href = "pedidoaluno.html";
        link.textContent = "Ver produtos";
        vazio.append(texto, link);
        areaCarrinho.append(vazio);

        resumo.style.display = "none";
        return;
    }

    resumo.style.display = "block";

    carrinho.forEach((item) => {
        const elemento = document.createElement("div");
        elemento.className = "item";
        const info = document.createElement("div");
        info.className = "info";
        const emoji = document.createElement("div");
        emoji.className = "emoji";
        emoji.textContent = item.emoji;
        const descricao = document.createElement("div");
        const nome = document.createElement("h3");
        nome.textContent = item.nome;
        const preco = document.createElement("p");
        preco.textContent = `R$ ${item.preco.toFixed(2).replace(".", ",")}`;
        descricao.append(nome, preco);
        info.append(emoji, descricao);

        const quantidade = document.createElement("div");
        quantidade.className = "quantidade";
        const diminuir = document.createElement("button");
        diminuir.type = "button";
        diminuir.textContent = "−";
        diminuir.setAttribute("aria-label", `Diminuir quantidade de ${item.nome}`);
        diminuir.addEventListener("click", () => alterarQuantidade(item.id, -1));
        const totalItem = document.createElement("strong");
        totalItem.textContent = String(item.quantidade);
        const aumentar = document.createElement("button");
        aumentar.type = "button";
        aumentar.textContent = "+";
        aumentar.setAttribute("aria-label", `Aumentar quantidade de ${item.nome}`);
        aumentar.addEventListener("click", () => alterarQuantidade(item.id, 1));
        quantidade.append(diminuir, totalItem, aumentar);
        elemento.append(info, quantidade);

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

async function carregarIntervalos() {
    try {
        const resposta = await fetch("/api/pedidos", { cache: "no-store" });
        if (!resposta.ok) return;
        const pedidos = await resposta.json();
        const hoje = obterChaveHoje();
        const edicao = localStorage.getItem("pedidoEdicao");
        intervalosServidor = { [hoje]: pedidos.filter(p => p.data === hoje && p.status !== "cancelado" && String(p.id) !== edicao).map(p => p.intervalo) };
        atualizarIntervalosDisponiveis();
    } catch (_) { /* A validação final ocorre na transação do servidor. */ }
}
carregarIntervalos();
renderizar();
document.getElementById("continuarPagamento").addEventListener("click", continuarPagamento);
