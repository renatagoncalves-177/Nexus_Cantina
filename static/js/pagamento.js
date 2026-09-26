function lerCarrinhoPagamento() {
    try {
        const dados = JSON.parse(localStorage.getItem("carrinho") || "[]");
        if (!Array.isArray(dados)) return [];
        return dados.filter(item => item && typeof item.nome === "string" &&
            Number.isFinite(Number(item.preco)) && Number(item.preco) >= 0 &&
            Number.isInteger(Number(item.quantidade)) && Number(item.quantidade) > 0
        ).map(item => ({ ...item, preco: Number(item.preco), quantidade: Number(item.quantidade) }));
    } catch (_) {
        localStorage.removeItem("carrinho");
        return [];
    }
}

const carrinho = lerCarrinhoPagamento();
const intervalo = localStorage.getItem("intervaloPedido") || "";

const listaPedido = document.getElementById("listaPedido");
const intervaloElemento = document.getElementById("intervaloPedido");
const totalElemento = document.getElementById("totalPedido");
const aviso = document.getElementById("avisoPagamento");
const abrirConfirmacao = document.getElementById("abrirConfirmacao");
const modal = document.getElementById("modalConfirmacao");
const cancelarConfirmacao = document.getElementById("cancelarConfirmacao");
const confirmarCompra = document.getElementById("confirmarCompra");
const saldoAntesElemento = document.getElementById("saldoAntesPedido");
const saldoDepoisElemento = document.getElementById("saldoDepoisPedido");
const G = window.NexusGestao;
const ALUNO_ID = null;

function obterChaveHoje() {
    const hoje = new Date();
    const ano = hoje.getFullYear();
    const mes = String(hoje.getMonth() + 1).padStart(2, "0");
    const dia = String(hoje.getDate()).padStart(2, "0");

    return `${ano}-${mes}-${dia}`;
}

function lerIntervalosConfirmados() {
    try {
        const dados = JSON.parse(localStorage.getItem("intervalosConfirmados") || "{}");
        return dados && typeof dados === "object" && !Array.isArray(dados) ? dados : {};
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

function obterAluno() {
    return G.ler().alunos.find((aluno) => aluno.id === ALUNO_ID);
}

function atualizarSaldo() {
    if (!ALUNO_ID) {
        saldoAntesElemento.textContent = "—";
        saldoDepoisElemento.textContent = "—";
        bloquearConfirmacao("A confirmação de pedidos será habilitada quando saldo e pedidos forem conectados ao banco.");
        return;
    }
    const aluno = obterAluno();
    if (!aluno) {
        throw new Error("Aluno não encontrado.");
    }
    const saldoDepois = aluno.saldo - Math.round(calcularTotal() * 100);
    saldoAntesElemento.textContent = G.moeda(aluno.saldo);
    saldoDepoisElemento.textContent = G.moeda(saldoDepois);

    if (saldoDepois < G.LIMITE_NEGATIVO) {
        bloquearConfirmacao("Este pedido ultrapassa o limite de saldo negativo de R$ 250,00.");
        return;
    }
    if (saldoDepois === G.LIMITE_NEGATIVO) {
        aviso.textContent = "Atenção: este pedido fará o saldo chegar ao limite negativo de R$ 250,00.";
        aviso.className = "aviso visivel limite";
    } else if (saldoDepois < 0) {
        aviso.textContent = `Atenção: após este pedido, o saldo ficará em ${G.moeda(saldoDepois)}. O limite é -R$ 250,00.`;
        aviso.className = "aviso visivel limite";
    }
}

function renderizarPedido() {
    abrirConfirmacao.disabled = false;
    aviso.textContent = "";
    aviso.className = "aviso";
    intervaloElemento.textContent = intervalo || "Não informado";
    totalElemento.textContent = formatarMoeda(calcularTotal());
    listaPedido.replaceChildren();

    if (carrinho.length === 0) {
        const estado = document.createElement("div");
        estado.className = "estado-vazio";
        const texto = document.createElement("p");
        texto.textContent = "Seu carrinho está vazio.";
        const link = document.createElement("a");
        link.href = "pedidoaluno.html";
        link.textContent = "Escolher produtos";
        estado.append(texto, link);
        listaPedido.append(estado);
        bloquearConfirmacao("Adicione pelo menos um produto antes de confirmar.");
        return;
    }

    carrinho.forEach((item) => {
        const elemento = document.createElement("article");
        elemento.className = "item-pedido";
        const identificacao = document.createElement("div");
        identificacao.className = "item-identificacao";
        const emoji = document.createElement("span");
        emoji.className = "item-emoji";
        emoji.textContent = typeof item.emoji === "string" ? item.emoji : "🍽️";
        const descricao = document.createElement("div");
        const nome = document.createElement("h3");
        nome.textContent = item.nome;
        const quantidade = document.createElement("p");
        quantidade.textContent = `Quantidade: ${item.quantidade}`;
        descricao.append(nome, quantidade);
        identificacao.append(emoji, descricao);
        const subtotal = document.createElement("strong");
        subtotal.textContent = formatarMoeda(item.preco * item.quantidade);
        elemento.append(identificacao, subtotal);
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
        return;
    }

    try { atualizarSaldo(); }
    catch (erro) { bloquearConfirmacao(erro.message); }
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
    if (!ALUNO_ID) {
        fecharModal();
        bloquearConfirmacao("A confirmação de pedidos ainda não está conectada ao banco.");
        return;
    }
    if (intervaloJaUsadoHoje()) {
        fecharModal();
        bloquearConfirmacao(
            "Este intervalo acabou de ser utilizado. Escolha outro ou tente amanhã."
        );
        return;
    }

    const pedidoId = Date.now();
    const total = calcularTotal();
    let saldoAposPedido;
    try {
        const dados = G.debitarPedido(ALUNO_ID, pedidoId, Math.round(total * 100));
        saldoAposPedido = dados.alunos.find((aluno) => aluno.id === ALUNO_ID).saldo;
    } catch (erro) {
        fecharModal();
        bloquearConfirmacao(erro.message);
        return;
    }

    const registros = lerIntervalosConfirmados();
    const chaveHoje = obterChaveHoje();
    const intervalosHoje = registros[chaveHoje] || [];

    intervalosHoje.push(intervalo);
    registros[chaveHoje] = intervalosHoje;
    localStorage.setItem("intervalosConfirmados", JSON.stringify(registros));

    const pedido = {
        id: pedidoId,
        alunoId: ALUNO_ID,
        data: chaveHoje,
        intervalo,
        total,
        totalCentavos: Math.round(total * 100),
        itens: carrinho,
        status: "pendente",
        saldoAposPedido,
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
