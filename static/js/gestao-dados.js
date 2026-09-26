/* Operações locais temporárias. Os dados reais serão fornecidos pelo backend. */
(function () {
    "use strict";
    const CHAVE = "nexusGestaoLocal.v2";
    const LIMITE_NEGATIVO = -25000;
    const moeda = valor => (valor / 100).toLocaleString("pt-BR", { style: "currency", currency: "BRL" });
    const hoje = () => {
        const d = new Date();
        return [d.getFullYear(), String(d.getMonth() + 1).padStart(2, "0"), String(d.getDate()).padStart(2, "0")].join("-");
    };
    const id = () => globalThis.crypto?.randomUUID?.() || Date.now() + "-" + Math.random().toString(16).slice(2);
    const centavos = valor => {
        const texto = String(valor).trim().replace(",", ".");
        if (!/^\d+(\.\d{1,2})?$/.test(texto)) throw new Error("Informe um valor com até duas casas decimais.");
        const partes = texto.split(".");
        const numero = Number(partes[0]) * 100 + Number((partes[1] || "").padEnd(2, "0"));
        if (!Number.isSafeInteger(numero) || numero <= 0) throw new Error("Informe um valor maior que zero.");
        return numero;
    };
    function inicial() {
        return {
            versao: 2,
            alunos: [],
            pedidos: [],
            recargas: [], recebimentos: [], operacoes: []
        };
    }
    function validar(d) {
        if (!d || d.versao !== 2 || !["alunos", "pedidos", "recargas", "recebimentos", "operacoes"].every(k => Array.isArray(d[k])) ||
            !d.alunos.every(a => a && typeof a.id === "string" && typeof a.nome === "string" && Number.isSafeInteger(a.saldo) && a.saldo >= LIMITE_NEGATIVO && Number.isSafeInteger(a.divida) && a.divida >= 0)) {
            throw new Error("Os dados locais estão inválidos. Não foi possível carregar esta tela.");
        }
        return d;
    }
    function ler() {
        try {
            const salvo = localStorage.getItem(CHAVE);
            const dados = salvo ? validar(JSON.parse(salvo)) : inicial();
            dados.pedidos.forEach(pedido => {
                if (pedido.status === "entregue") pedido.status = "concluido";
            });
            return dados;
        } catch (_) {
            throw new Error("Não foi possível ler os dados locais. Verifique o armazenamento do navegador.");
        }
    }
    function gravar(d) {
        validar(d);
        try { localStorage.setItem(CHAVE, JSON.stringify(d)); }
        catch (_) { throw new Error("Não foi possível salvar. Libere o armazenamento do navegador e tente novamente."); }
    }
    function alterar(operacao, modificar) {
        const d = ler();
        if (d.operacoes.includes(operacao)) return d;
        modificar(d);
        d.operacoes.push(operacao);
        gravar(d);
        return d;
    }
    function recarregar(alunoId, valor, operacao) {
        if (!Number.isSafeInteger(valor) || valor < 100 || valor > 50000) throw new Error("Escolha um valor entre R$ 1,00 e R$ 500,00.");
        return alterar(operacao, d => {
            const aluno = d.alunos.find(a => a.id === alunoId);
            if (!aluno) throw new Error("Aluno não encontrado.");
            aluno.saldo += valor;
            d.recargas.unshift({ id: operacao, alunoId, valor, data: new Date().toISOString() });
        });
    }
    function receber(alunoId, valor, operacao) {
        return alterar(operacao, d => {
            const aluno = d.alunos.find(a => a.id === alunoId);
            if (!aluno || !Number.isSafeInteger(valor) || valor <= 0 || valor > aluno.divida) throw new Error("O valor deve ser maior que zero e não pode ultrapassar a pendência atual.");
            aluno.divida -= valor;
            d.recebimentos.unshift({ id: operacao, alunoId, valor, data: new Date().toISOString() });
        });
    }
    function debitarPedido(alunoId, pedidoId, valor) {
        if (!Number.isSafeInteger(valor) || valor <= 0) throw new Error("O total do pedido é inválido.");
        return alterar("pedido-debito-" + pedidoId, d => {
            const aluno = d.alunos.find(a => a.id === alunoId);
            if (!aluno) throw new Error("Aluno não encontrado.");
            if (aluno.saldo - valor < LIMITE_NEGATIVO) {
                throw new Error("Este pedido ultrapassa o limite de saldo negativo de R$ 250,00.");
            }
            aluno.saldo -= valor;
        });
    }
    function importarUltimoPedido() {
        let pedido;
        try { pedido = JSON.parse(localStorage.getItem("ultimoPedido") || "null"); } catch (_) { return; }
        if (!pedido || !pedido.id || !/^\d{4}-\d{2}-\d{2}$/.test(pedido.data) || !Array.isArray(pedido.itens) ||
            !Number.isFinite(pedido.total) || pedido.total <= 0 ||
            !["Primeiro intervalo", "Segundo intervalo"].includes(pedido.intervalo)) return;
        const chave = "local-" + String(pedido.id);
        const d = ler();
        if (d.pedidos.some(p => p.id === chave)) return;
        const statusPedido = ["pendente", "pronto", "concluido", "cancelado"].includes(pedido.status)
            ? pedido.status
            : "pendente";
        d.pedidos.unshift({
            id: chave, aluno: "Aluno não identificado", data: pedido.data,
            intervalo: pedido.intervalo, total: Math.round(pedido.total * 100),
            descricao: pedido.itens.map(item => String(item.quantidade) + " × " + String(item.nome)).join(" • "),
            status: statusPedido, exemplo: false
        });
        gravar(d);
    }
    function avancarPedido(pedidoId, esperado) {
        const d = ler();
        const p = d.pedidos.find(item => item.id === pedidoId);
        if (!p || p.status !== esperado) throw new Error("Esse pedido foi atualizado. Confira a lista novamente.");
        const proximo = { pendente: "pronto", pronto: "concluido" }[esperado];
        if (!proximo) throw new Error("Esse pedido já foi concluído ou cancelado.");
        p.status = proximo;
        gravar(d);
        if (pedidoId.startsWith("local-")) {
            try {
                const ultimo = JSON.parse(localStorage.getItem("ultimoPedido") || "null");
                if (ultimo && "local-" + String(ultimo.id) === pedidoId) {
                    ultimo.status = proximo;
                    localStorage.setItem("ultimoPedido", JSON.stringify(ultimo));
                }
            } catch (_) { /* O painel continua atualizado mesmo sem o resumo local. */ }
        }
    }
    function cancelarPedido(pedidoId, motivo) {
        let ultimo;
        try { ultimo = JSON.parse(localStorage.getItem("ultimoPedido") || "null"); }
        catch (_) { throw new Error("Não foi possível ler o pedido."); }
        if (!ultimo || String(ultimo.id) !== String(pedidoId)) throw new Error("Pedido não encontrado.");
        const chave = "local-" + String(pedidoId);
        const d = ler();
        const pedidoPainel = d.pedidos.find(p => p.id === chave);
        const statusAtual = pedidoPainel?.status || ultimo.status || "pendente";
        if (["concluido", "entregue"].includes(statusAtual)) {
            throw new Error("Este pedido já foi concluído e não pode mais ser alterado ou cancelado.");
        }
        if (statusAtual !== "cancelado") {
            const operacaoDebito = "pedido-debito-" + pedidoId;
            const operacaoEstorno = "pedido-estorno-" + pedidoId;
            if (d.operacoes.includes(operacaoDebito) && !d.operacoes.includes(operacaoEstorno)) {
                const aluno = d.alunos.find(a => a.id === ultimo.alunoId);
                const total = Number.isSafeInteger(ultimo.totalCentavos)
                    ? ultimo.totalCentavos
                    : Math.round(Number(ultimo.total) * 100);
                if (!aluno || !Number.isSafeInteger(total) || total <= 0) throw new Error("Não foi possível estornar o saldo deste pedido.");
                aluno.saldo += total;
                d.operacoes.push(operacaoEstorno);
            }
            if (pedidoPainel) pedidoPainel.status = "cancelado";
            ultimo.status = "cancelado";
            ultimo.canceladoParaAlteracao = motivo === "alterar";
            ultimo.canceladoEm = new Date().toISOString();
            gravar(d);
            localStorage.setItem("ultimoPedido", JSON.stringify(ultimo));
        }
        return ultimo;
    }
    function exigirAdmin() {
        document.querySelector("[data-area-admin]")?.removeAttribute("hidden");
        return true;
    }
    function aviso(el, texto, erro = false) {
        el.textContent = texto;
        el.className = "mensagem-gestao " + (erro ? "erro" : "sucesso");
        el.hidden = !texto;
    }
    function elemento(tag, texto, classe = "") {
        const el = document.createElement(tag);
        el.textContent = texto;
        if (classe) el.className = classe;
        return el;
    }
    function normalizar(valor) { return String(valor).normalize("NFD").replace(/[\u0300-\u036f]/g, "").toLowerCase(); }
    window.NexusGestao = { ler, recarregar, receber, debitarPedido, importarUltimoPedido, avancarPedido, cancelarPedido, exigirAdmin, aviso, elemento, normalizar, moeda, centavos, hoje, id, LIMITE_NEGATIVO };
}());
