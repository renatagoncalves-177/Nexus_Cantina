/* Dados de demonstração. A autorização e os valores reais devem vir do backend. */
(function () {
    "use strict";
    const CHAVE = "nexusGestaoDemo.v1";
    const SESSAO = "nexusAdminDemo";
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
            versao: 1,
            alunos: [
                { id: "2026001", nome: "Carlos Silva", turma: "1º A", saldo: 11000, divida: 0 },
                { id: "2026002", nome: "Ana Oliveira", turma: "2º B", saldo: 0, divida: 1850 },
                { id: "2026003", nome: "João Santos", turma: "1º A", saldo: 0, divida: 3200 },
                { id: "2026004", nome: "Luiza Costa", turma: "3º A", saldo: 2500, divida: 0 }
            ],
            pedidos: [
                { id: "DEMO-001", aluno: "Carlos Silva", data: hoje(), intervalo: "Primeiro intervalo", total: 850, descricao: "1 sanduíche • 1 suco", status: "pendente", exemplo: true },
                { id: "DEMO-002", aluno: "Ana Oliveira", data: hoje(), intervalo: "Segundo intervalo", total: 600, descricao: "1 salgado • 1 água", status: "pendente", exemplo: true },
                { id: "DEMO-003", aluno: "Luiza Costa", data: hoje(), intervalo: "Primeiro intervalo", total: 500, descricao: "1 pão de queijo • 1 suco", status: "pronto", exemplo: true }
            ],
            recargas: [], recebimentos: [], operacoes: []
        };
    }
    function validar(d) {
        if (!d || d.versao !== 1 || !["alunos", "pedidos", "recargas", "recebimentos", "operacoes"].every(k => Array.isArray(d[k])) ||
            !d.alunos.every(a => a && typeof a.id === "string" && typeof a.nome === "string" && Number.isSafeInteger(a.saldo) && a.saldo >= 0 && Number.isSafeInteger(a.divida) && a.divida >= 0)) {
            throw new Error("Os dados de demonstração estão inválidos. Não foi possível carregar esta tela.");
        }
        return d;
    }
    function ler() {
        try {
            const salvo = localStorage.getItem(CHAVE);
            return salvo ? validar(JSON.parse(salvo)) : inicial();
        } catch (_) {
            throw new Error("Não foi possível ler os dados de demonstração. Verifique o armazenamento do navegador.");
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
    function importarUltimoPedido() {
        let pedido;
        try { pedido = JSON.parse(localStorage.getItem("ultimoPedido") || "null"); } catch (_) { return; }
        if (!pedido || !pedido.id || !/^\d{4}-\d{2}-\d{2}$/.test(pedido.data) || !Array.isArray(pedido.itens) ||
            !Number.isFinite(pedido.total) || pedido.total <= 0 ||
            !["Primeiro intervalo", "Segundo intervalo"].includes(pedido.intervalo)) return;
        const chave = "local-" + String(pedido.id);
        const d = ler();
        if (d.pedidos.some(p => p.id === chave)) return;
        d.pedidos.unshift({
            id: chave, aluno: "Aluno não identificado", data: pedido.data,
            intervalo: pedido.intervalo, total: Math.round(pedido.total * 100),
            descricao: pedido.itens.map(item => String(item.quantidade) + " × " + String(item.nome)).join(" • "),
            status: "pendente", exemplo: false
        });
        gravar(d);
    }
    function avancarPedido(pedidoId, esperado) {
        const d = ler();
        const p = d.pedidos.find(item => item.id === pedidoId);
        if (!p || p.status !== esperado) throw new Error("Esse pedido foi atualizado. Confira a lista novamente.");
        const proximo = { pendente: "pronto", pronto: "entregue" }[esperado];
        if (!proximo) throw new Error("Esse pedido já foi entregue.");
        p.status = proximo;
        gravar(d);
    }
    function autenticado() {
        try {
            const s = JSON.parse(sessionStorage.getItem(SESSAO) || "null");
            return s?.tipo === "admin-demo" && Number.isFinite(s.expira) && s.expira > Date.now();
        } catch (_) { return false; }
    }
    function entrar(email, senha) {
        if (email.trim().toLowerCase() !== "admin@nexus.test" || senha !== "Cantina123!") throw new Error("E-mail ou senha de demonstração incorretos.");
        try { sessionStorage.setItem(SESSAO, JSON.stringify({ tipo: "admin-demo", expira: Date.now() + 8 * 60 * 60 * 1000 })); }
        catch (_) { throw new Error("Permita o armazenamento da sessão neste navegador para entrar."); }
    }
    function exigirAdmin() {
        if (!autenticado()) {
            window.location.replace("loginadmin.html");
            return false;
        }
        document.querySelector("[data-area-admin]")?.removeAttribute("hidden");
        document.querySelectorAll("[data-sair-admin]").forEach(el => el.addEventListener("click", () => {
            sessionStorage.removeItem(SESSAO);
        }));
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
    window.NexusGestao = { ler, recarregar, receber, importarUltimoPedido, avancarPedido, entrar, autenticado, exigirAdmin, aviso, elemento, normalizar, moeda, centavos, hoje, id };
}());
