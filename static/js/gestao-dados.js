/* Valores da API em reais; a camada de apresentação usa centavos. */
(function () {
    "use strict";
    let dados = { alunos: [], pedidos: [], recargas: [], recebimentos: [] };
    async function requisitar(url, opcoes = {}) {
        const resposta = await fetch(url, { ...opcoes, headers: { "Content-Type": "application/json", ...opcoes.headers } });
        const corpo = await resposta.json().catch(() => ({}));
        if (!resposta.ok) throw new Error(corpo.message || (typeof corpo.detail === "string" ? corpo.detail : "Confira os campos informados."));
        return corpo;
    }
    async function carregar() { dados = await requisitar("/api/gestao"); return dados; }
    const moeda = valor => (Number(valor) / 100).toLocaleString("pt-BR", { style: "currency", currency: "BRL" });
    const hoje = () => new Date().toLocaleDateString("sv-SE", { timeZone: "America/Sao_Paulo" });
    const id = () => crypto.randomUUID();
    function centavos(valor) {
        const texto = String(valor).trim().replace(",", ".");
        if (!/^\d+(\.\d{1,2})?$/.test(texto)) throw new Error("Informe um valor com até duas casas decimais.");
        const n = Math.round(Number(texto) * 100);
        if (!Number.isSafeInteger(n) || n <= 0) throw new Error("Informe um valor maior que zero.");
        return n;
    }
    async function movimentar(alunoId, valor, chave, tipo) {
        await requisitar("/api/alunos/" + encodeURIComponent(alunoId) + "/saldo", {
            method: "POST", body: JSON.stringify({ valor: valor / 100, chave, tipo })
        });
        return carregar();
    }
    async function avancarPedido(pedidoId, esperado) {
        await requisitar("/api/pedidos/" + pedidoId, {
            method: "PATCH", body: JSON.stringify({ status: esperado === "pendente" ? "pronto" : "concluido" })
        });
        return carregar();
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
    function exigirAdmin() { document.querySelector("[data-area-admin]")?.removeAttribute("hidden"); return true; }
    function normalizar(valor) { return String(valor).normalize("NFD").replace(/[\u0300-\u036f]/g, "").toLowerCase(); }
    window.NexusGestao = {
        requisitar, carregar, ler: () => dados, moeda, hoje, id, centavos, avancarPedido,
        recarregar: (aluno, valor, chave) => movimentar(aluno, valor, chave, "recarga"),
        receber: (aluno, valor, chave) => movimentar(aluno, valor, chave, "recebimento"),
        exigirAdmin, aviso, elemento, normalizar, LIMITE_NEGATIVO: -25000
    };
}());
