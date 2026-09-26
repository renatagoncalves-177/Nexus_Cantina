(function () {
    "use strict";
    const Api = window.NexusApi;
    const busca = document.getElementById("formBuscarPedido");
    const mensagem = document.getElementById("mensagemPedido");
    const conteudo = document.getElementById("conteudoPedido");
    const itens = document.getElementById("itensPedido");
    const idInicial = new URLSearchParams(location.search).get("id") || "";

    function preencher(pedido) {
        document.getElementById("pedidoNumero").textContent = pedido.id || pedido.numero || "—";
        document.getElementById("pedidoAluno").textContent = pedido.aluno_nome || pedido.aluno?.nome || "—";
        document.getElementById("pedidoIntervalo").textContent = pedido.intervalo || "—";
        document.getElementById("pedidoStatus").value = pedido.status || "pendente";
        const total = Number(pedido.total || 0).toLocaleString("pt-BR", { style: "currency", currency: "BRL" });
        document.getElementById("pedidoTotal").textContent = total;
        itens.replaceChildren();
        Api.lista(pedido.itens, "itens").forEach(item => {
            const linha = document.createElement("tr");
            linha.append(
                Api.criar("td", item.nome || item.produto?.nome || "Produto"),
                Api.criar("td", String(item.quantidade ?? 0)),
                Api.criar("td", Number(item.subtotal || 0).toLocaleString("pt-BR", { style: "currency", currency: "BRL" }))
            );
            itens.append(linha);
        });
        conteudo.hidden = false;
    }

    async function carregar(id) {
        if (!id) {
            conteudo.hidden = true;
            Api.informar(mensagem, "Informe o número de um pedido.", true);
            return;
        }
        document.getElementById("buscarPedidoId").value = id;
        try {
            preencher(await Api.requisitar("/api/pedidos/" + encodeURIComponent(id)));
            Api.informar(mensagem, "");
        } catch (erro) {
            conteudo.hidden = true;
            erro.integracaoPendente ? Api.informarPendente(mensagem) : Api.informar(mensagem, erro.message, true);
        }
    }

    busca.addEventListener("submit", evento => {
        evento.preventDefault();
        const id = document.getElementById("buscarPedidoId").value.trim();
        history.replaceState(null, "", id ? "detalhepedido.html?id=" + encodeURIComponent(id) : "detalhepedido.html");
        carregar(id);
    });

    document.getElementById("formStatusPedido").addEventListener("submit", async evento => {
        evento.preventDefault();
        const id = document.getElementById("pedidoNumero").textContent;
        const botao = evento.currentTarget.querySelector("button");
        botao.disabled = true;
        try {
            await Api.requisitar("/api/pedidos/" + encodeURIComponent(id), {
                method: "PATCH",
                body: { status: document.getElementById("pedidoStatus").value }
            });
            Api.informar(mensagem, "Situação do pedido atualizada.");
            await carregar(id);
        } catch (erro) {
            erro.integracaoPendente ? Api.informarPendente(mensagem) : Api.informar(mensagem, erro.message, true);
        } finally {
            botao.disabled = false;
        }
    });

    carregar(idInicial);
}());
