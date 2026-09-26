(function () {
    "use strict";
    const G = window.NexusGestao;
    const card = document.querySelector(".confirmacao-card");
    const intervaloElemento = document.getElementById("intervaloConfirmado");
    const totalElemento = document.getElementById("totalConfirmado");
    const saldoElemento = document.getElementById("saldoConfirmado");
    const aviso = document.getElementById("avisoPedido");
    const alterar = document.getElementById("alterarPedido");
    const cancelar = document.getElementById("cancelarPedido");
    let pedido = null;

    function lerPedido() {
        try { return JSON.parse(localStorage.getItem("ultimoPedido") || "null"); }
        catch (_) { return null; }
    }

    function liberarIntervalo(atual) {
        let registros;
        try {
            const dados = JSON.parse(localStorage.getItem("intervalosConfirmados") || "{}");
            registros = dados && typeof dados === "object" && !Array.isArray(dados) ? dados : {};
        }
        catch (_) { registros = {}; }
        const intervalos = Array.isArray(registros[atual.data]) ? registros[atual.data] : [];
        registros[atual.data] = intervalos.filter((item) => item !== atual.intervalo);
        if (!registros[atual.data].length) delete registros[atual.data];
        localStorage.setItem("intervalosConfirmados", JSON.stringify(registros));
    }

    function saldoAtual() {
        if (!pedido.alunoId) return null;
        const aluno = G.ler().alunos.find((item) => item.id === pedido.alunoId);
        return aluno ? aluno.saldo : null;
    }

    function renderizar() {
        pedido = lerPedido();
        if (!pedido) {
            document.getElementById("tituloPedido").textContent = "Pedido não encontrado";
            document.getElementById("mensagemPedido").textContent = "Volte ao cardápio para iniciar um pedido.";
            aviso.textContent = "Nenhuma confirmação foi encontrada neste navegador.";
            alterar.hidden = cancelar.hidden = true;
            return;
        }

        const status = pedido.status === "entregue" ? "concluido" : (pedido.status || "pendente");
        intervaloElemento.textContent = pedido.intervalo || "Não informado";
        const total = Number.isSafeInteger(pedido.totalCentavos)
            ? pedido.totalCentavos
            : Math.round(Number(pedido.total || 0) * 100);
        totalElemento.textContent = G.moeda(total);
        const saldo = status === "cancelado" ? saldoAtual() : pedido.saldoAposPedido;
        saldoElemento.textContent = Number.isSafeInteger(saldo) ? G.moeda(saldo) : "—";

        if (status === "cancelado") {
            card.classList.add("cancelado");
            document.getElementById("iconePedido").textContent = "×";
            document.getElementById("statusPedido").textContent = "PEDIDO CANCELADO";
            document.getElementById("tituloPedido").textContent = pedido.canceladoParaAlteracao ? "Pedido aberto para alteração" : "Pedido cancelado";
            document.getElementById("mensagemPedido").textContent = pedido.canceladoParaAlteracao
                ? "Os itens voltaram para o carrinho e o saldo foi devolvido."
                : "O intervalo foi liberado e o saldo utilizado foi devolvido.";
            aviso.textContent = pedido.canceladoParaAlteracao ? "Continue a alteração no carrinho." : "Este pedido não será preparado.";
            alterar.hidden = cancelar.hidden = true;
            return;
        }

        if (status === "concluido") {
            document.getElementById("statusPedido").textContent = "PEDIDO CONCLUÍDO";
            aviso.textContent = "O pedido já foi concluído e não pode mais ser alterado ou cancelado. Este intervalo ficará indisponível até amanhã.";
            alterar.hidden = cancelar.hidden = true;
            return;
        }

        alterar.hidden = cancelar.hidden = false;
        aviso.textContent = "Você pode alterar ou cancelar este pedido enquanto ele não estiver concluído.";
        if (pedido.saldoAposPedido === G.LIMITE_NEGATIVO) {
            aviso.textContent += " Atenção: seu saldo chegou ao limite negativo de R$ 250,00.";
        }
    }

    function prepararCancelamento(motivo) {
        G.importarUltimoPedido();
        const atualizado = G.cancelarPedido(pedido.id, motivo);
        liberarIntervalo(atualizado);
        return atualizado;
    }

    alterar.addEventListener("click", () => {
        try {
            const atualizado = prepararCancelamento("alterar");
            localStorage.setItem("carrinho", JSON.stringify(atualizado.itens));
            localStorage.setItem("intervaloPedido", atualizado.intervalo);
            window.location.href = "carrinho.html";
        } catch (erro) {
            aviso.textContent = erro.message;
        }
    });

    cancelar.addEventListener("click", () => {
        if (!window.confirm("Tem certeza que deseja cancelar este pedido?")) return;
        try {
            prepararCancelamento("cancelar");
            renderizar();
        } catch (erro) {
            aviso.textContent = erro.message;
        }
    });

    window.addEventListener("storage", renderizar);
    window.addEventListener("pageshow", renderizar);
    renderizar();
}());
