(function () {
    "use strict";
    const destinos = document.querySelectorAll("[data-nome-usuario]");
    if (!destinos.length) return;

    async function atualizarNome() {
        try {
            const resposta = await fetch("/api/auth/me", { cache: "no-store" });
            if (!resposta.ok) return;
            const usuario = await resposta.json();
            destinos.forEach((elemento) => { elemento.textContent = usuario.nome; });
            const r = await fetch("/api/alunos/me", { cache: "no-store" });
            if (!r.ok) return;
            const aluno = await r.json();
            const moeda = valor => Number(valor).toLocaleString("pt-BR", { style: "currency", currency: "BRL" });
            const saldo = document.getElementById("saldoDisponivel");
            if (saldo) saldo.textContent = moeda(aluno.saldo);
            const gastos = document.querySelector(".card.gasto h2");
            if (gastos) gastos.textContent = moeda(aluno.gastos);
            const descricao = document.querySelector("section.responsavel p:last-child");
            if (descricao) descricao.textContent = "Aluno vinculado: " + aluno.nome + " — " + aluno.matricula;
            const recarga = document.querySelector("section.saldo .card");
            if (recarga) {
                recarga.querySelector("p").textContent = "Adicionar saldo para " + aluno.nome;
                recarga.setAttribute("role", "link");
                recarga.tabIndex = 0;
                recarga.onclick = () => { location.href = "adicionarsaldo.html?aluno=" + aluno.id; };
                recarga.onkeydown = e => { if (e.key === "Enter") recarga.click(); };
            }
            const pedidosR = await fetch("/api/pedidos");
            if (pedidosR.ok) {
                const pedidos = await pedidosR.json();
                const aberto = pedidos.filter(p => !["concluido", "cancelado"].includes(p.status)).at(-1);
                const link = document.querySelector("section.pedido a");
                if (link && aberto) {
                    link.href = "alertapagamento.html?id=" + aberto.id;
                    link.textContent = "Acompanhar pedido";
                }
            }
        } catch (_) {
            /* A proteção da rota continua sendo responsabilidade do backend. */
        }
    }

    window.addEventListener("pageshow", atualizarNome);
    window.addEventListener("focus", atualizarNome);
    atualizarNome();
}());
