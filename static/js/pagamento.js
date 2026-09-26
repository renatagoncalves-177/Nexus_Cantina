(function () {
    "use strict";
    const G = window.NexusGestao;
    const $ = id => document.getElementById(id);
    const abrir = $("abrirConfirmacao"), confirmar = $("confirmarCompra"), modal = $("modalConfirmacao");
    let carrinho = [], aluno = null;
    const intervalo = localStorage.getItem("intervaloPedido") || "";
    const edicao = localStorage.getItem("pedidoEdicao");
    let chave = localStorage.getItem("chaveCompra") || G.id();
    localStorage.setItem("chaveCompra", chave);
    const total = () => carrinho.reduce((s, i) => s + Math.round(i.preco * 100) * i.quantidade, 0);
    function erro(texto) {
        $("avisoPagamento").textContent = texto;
        $("avisoPagamento").className = "aviso visivel erro";
        abrir.disabled = true;
    }
    function fechar() {
        modal.hidden = true;
        document.body.classList.remove("modal-aberto");
        abrir.focus();
    }
    async function carregar() {
        abrir.disabled = true;
        try {
            const salvo = JSON.parse(localStorage.getItem("carrinho") || "[]");
            if (!Array.isArray(salvo) || !salvo.length) throw new Error("Seu carrinho está vazio.");
            const produtos = await Promise.all(salvo.map(item => G.requisitar("/api/produtos/" + encodeURIComponent(item.id))));
            aluno = await G.requisitar("/api/alunos/me");
            carrinho = salvo.map(item => {
                const p = produtos.find(p => p.id === Number(item.id));
                const quantidade = Number(item.quantidade);
                if (!p || !Number.isInteger(quantidade) || quantidade <= 0) throw new Error("Um item está indisponível. Volte ao cardápio e atualize o carrinho.");
                return { ...p, quantidade };
            });
            $("listaPedido").replaceChildren();
            for (const item of carrinho) {
                const artigo = G.elemento("article", "", "item-pedido");
                const identificacao = G.elemento("div", "", "item-identificacao");
                const descricao = G.elemento("div", "");
                descricao.append(G.elemento("h3", item.nome), G.elemento("p", "Quantidade: " + item.quantidade));
                identificacao.append(G.elemento("span", item.emoji || "🍽️", "item-emoji"), descricao);
                artigo.append(identificacao, G.elemento("strong", G.moeda(Math.round(item.preco * 100) * item.quantidade)));
                $("listaPedido").append(artigo);
            }
            let creditoEdicao = 0;
            if (edicao) {
                const pedido = await G.requisitar("/api/pedidos/" + encodeURIComponent(edicao));
                if (["concluido", "cancelado"].includes(pedido.status)) throw new Error("Este pedido não pode mais ser alterado.");
                creditoEdicao = Math.round(pedido.total * 100);
            }
            const depois = Math.round(aluno.saldo * 100) + creditoEdicao - total();
            $("intervaloPedido").textContent = intervalo;
            $("totalPedido").textContent = G.moeda(total());
            $("saldoAntesPedido").textContent = G.moeda(Math.round(aluno.saldo * 100));
            $("saldoDepoisPedido").textContent = G.moeda(depois);
            if (!intervalo) throw new Error("Volte ao carrinho e escolha o intervalo.");
            if (depois < G.LIMITE_NEGATIVO) throw new Error("Este pedido ultrapassa o limite negativo de R$ 250,00.");
            if (depois <= 0) {
                $("avisoPagamento").textContent = depois === G.LIMITE_NEGATIVO
                    ? "Atenção: seu saldo chegará ao limite negativo de R$ 250,00."
                    : "Saldo após a compra: " + G.moeda(depois) + ". Limite: -R$ 250,00.";
                $("avisoPagamento").className = "aviso visivel limite";
            }
            abrir.disabled = false;
        } catch (e) { erro(e.message); }
    }
    abrir.addEventListener("click", () => {
        modal.hidden = false; document.body.classList.add("modal-aberto"); confirmar.focus();
    });
    $("cancelarConfirmacao").addEventListener("click", fechar);
    modal.addEventListener("click", e => { if (e.target === modal) fechar(); });
    document.addEventListener("keydown", e => { if (e.key === "Escape" && !modal.hidden) fechar(); });
    confirmar.addEventListener("click", async () => {
        if (confirmar.disabled) return;
        confirmar.disabled = true;
        try {
            const pedido = await G.requisitar("/api/pedidos" + (edicao ? "/" + encodeURIComponent(edicao) : ""), {
                method: edicao ? "PUT" : "POST",
                body: JSON.stringify({ intervalo, chave, itens: carrinho.map(i => ({ produto_id: i.id, quantidade: i.quantidade })) })
            });
            localStorage.setItem("ultimoPedido", JSON.stringify({ id: pedido.id }));
            ["carrinho", "intervaloPedido", "totalPedido", "pedidoEdicao", "chaveCompra"].forEach(k => localStorage.removeItem(k));
            location.href = "alertapagamento.html?id=" + pedido.id;
        } catch (e) {
            fechar(); erro(e.message); confirmar.disabled = false;
        }
    });
    carregar();
}());
