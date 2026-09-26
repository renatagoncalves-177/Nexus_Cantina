(function () {
    "use strict";
    const G = window.NexusGestao;
    const $ = id => document.getElementById(id);
    let pedido;
    async function carregar() {
        try {
            let id = new URLSearchParams(location.search).get("id");
            if (!id) {
                try { id = JSON.parse(localStorage.getItem("ultimoPedido") || "{}").id; } catch (_) {}
            }
            if (!id) {
                const pedidos = await G.requisitar("/api/pedidos");
                id = pedidos.at(-1)?.id;
            }
            if (!id) throw new Error("Nenhum pedido encontrado. Inicie um pedido no cardápio.");
            pedido = await G.requisitar("/api/pedidos/" + encodeURIComponent(id));
            $("intervaloConfirmado").textContent = pedido.intervalo;
            $("totalConfirmado").textContent = G.moeda(Math.round(pedido.total * 100));
            $("saldoConfirmado").textContent = G.moeda(Math.round(pedido.saldo * 100));
            const encerrado = ["concluido", "cancelado"].includes(pedido.status);
            $("alterarPedido").hidden = $("cancelarPedido").hidden = encerrado;
            $("statusPedido").textContent = "PEDIDO " + pedido.status.toUpperCase();
            $("avisoPedido").textContent = encerrado ? "Este pedido não pode mais ser alterado."
                : "Você pode alterar ou cancelar este pedido enquanto ele não estiver concluído.";
            if (pedido.status === "cancelado") {
                $("tituloPedido").textContent = "Pedido cancelado";
                $("mensagemPedido").textContent = "Seu saldo e o estoque foram devolvidos. O intervalo está disponível.";
                $("iconePedido").textContent = "×";
                document.querySelector(".confirmacao-card").classList.add("cancelado");
            }
            if (pedido.saldo === -250) $("avisoPedido").textContent += " Seu saldo chegou ao limite negativo de R$ 250,00.";
        } catch (e) {
            $("tituloPedido").textContent = "Não foi possível carregar o pedido";
            $("avisoPedido").textContent = e.message;
            $("alterarPedido").hidden = $("cancelarPedido").hidden = true;
        }
    }
    $("alterarPedido").addEventListener("click", () => {
        if (!pedido) return;
        localStorage.setItem("carrinho", JSON.stringify(pedido.itens));
        localStorage.setItem("intervaloPedido", pedido.intervalo);
        localStorage.setItem("pedidoEdicao", String(pedido.id));
        localStorage.removeItem("chaveCompra");
        location.href = "carrinho.html";
    });
    $("cancelarPedido").addEventListener("click", async () => {
        if (!pedido || !confirm("Tem certeza que deseja cancelar este pedido?")) return;
        $("cancelarPedido").disabled = true;
        try {
            await G.requisitar("/api/pedidos/" + pedido.id, { method: "PATCH", body: JSON.stringify({ status: "cancelado" }) });
            await carregar();
        } catch (e) { $("avisoPedido").textContent = e.message; }
        finally { $("cancelarPedido").disabled = false; }
    });
    $("continuarPedido").addEventListener("click", e => {
        e.preventDefault();
        $("continuarPedido").disabled = true;
        $("bannerEmail").textContent = "O e-mail foi enviado com sucesso! (Simulação: nenhum e-mail real foi enviado.)";
        $("bannerEmail").hidden = false;
        setTimeout(() => { location.href = "/"; }, 2000);
    });
    window.addEventListener("focus", carregar);
    carregar();
}());
