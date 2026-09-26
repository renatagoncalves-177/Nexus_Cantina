(function () {
    "use strict";
    const G = window.NexusGestao;
    if (!G.exigirAdmin()) return;
    const lista = document.getElementById("listaPedidos");
    const busca = document.getElementById("buscaPedido");
    const intervalo = document.getElementById("filtroIntervalo");
    const status = document.getElementById("filtroStatus");
    const mensagem = document.getElementById("mensagemPainel");
    const rotulos = { pendente: "Aguardando preparo", pronto: "Pronto para retirada", concluido: "Concluído", cancelado: "Cancelado" };
    function renderizar() {
        try {
            const hoje = G.ler().pedidos.filter(p => p.data === G.hoje());
            document.getElementById("dataPainel").textContent = new Date().toLocaleDateString("pt-BR", { day: "2-digit", month: "long", year: "numeric" });
            document.getElementById("totalPedidos").textContent = hoje.length;
            document.getElementById("totalPendentes").textContent = hoje.filter(p => p.status === "pendente").length;
            document.getElementById("totalProntos").textContent = hoje.filter(p => p.status === "pronto").length;
            const filtrados = hoje.filter(p => G.normalizar(p.id + " " + p.aluno).includes(G.normalizar(busca.value.trim())) &&
                (!intervalo.value || intervalo.value === p.intervalo) && (!status.value || status.value === p.status));
            lista.replaceChildren();
            for (const pedido of filtrados) {
                const tr = document.createElement("tr");
                const identificacao = document.createElement("td");
                identificacao.append(G.elemento("strong", pedido.aluno), G.elemento("small", "Pedido " + pedido.id), G.elemento("small", pedido.descricao));
                identificacao.tabIndex = 0;
                identificacao.setAttribute("role", "link");
                identificacao.onclick = () => { location.href = "detalhepedido.html?id=" + pedido.id; };
                identificacao.onkeydown = e => { if (e.key === "Enter") identificacao.click(); };
                const situacao = document.createElement("td");
                situacao.append(G.elemento("span", rotulos[pedido.status], "badge " + pedido.status));
                const acao = document.createElement("td");
                if (["pendente", "pronto"].includes(pedido.status)) {
                    const botao = G.elemento("button", pedido.status === "pendente" ? "Marcar pronto" : "Marcar concluído", "btn pequeno secundario");
                    botao.type = "button";
                    botao.setAttribute("aria-label", botao.textContent + ": " + pedido.id);
                    botao.addEventListener("click", async () => {
                        if (!G.exigirAdmin()) return;
                        try {
                            botao.disabled = true;
                            await G.avancarPedido(pedido.id, pedido.status);
                            G.aviso(mensagem, "Pedido " + pedido.id + " atualizado.");
                        } catch (erro) { G.aviso(mensagem, erro.message, true); }
                        renderizar();
                    });
                    acao.append(botao);
                } else acao.append(G.elemento("span", pedido.status === "cancelado" ? "Sem ação" : "Concluído", "badge " + (pedido.status === "cancelado" ? "cancelado" : "regular")));
                tr.append(identificacao, G.elemento("td", pedido.intervalo), G.elemento("td", G.moeda(pedido.total)), situacao, acao);
                lista.append(tr);
            }
            document.getElementById("contagemPedidos").textContent = filtrados.length + " pedido(s) encontrado(s)";
            document.getElementById("vazioPedidos").hidden = filtrados.length > 0;
        } catch (erro) { G.aviso(mensagem, erro.message, true); }
    }
    async function atualizar() {
        if (!G.exigirAdmin()) return;
        try { await G.carregar(); } catch (erro) { G.aviso(mensagem, erro.message, true); }
        renderizar();
    }
    [busca, intervalo, status].forEach(el => el.addEventListener("input", renderizar));
    document.getElementById("atualizarPedidos").addEventListener("click", atualizar);
    document.getElementById("limparFiltrosPedidos").addEventListener("click", () => {
        busca.value = intervalo.value = status.value = "";
        renderizar();
    });
    window.addEventListener("storage", atualizar);
    window.addEventListener("pageshow", atualizar);
    atualizar();
}());
