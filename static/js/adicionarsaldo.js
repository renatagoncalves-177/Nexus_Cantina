(function () {
    "use strict";
    const G = window.NexusGestao;
    let ALUNO = new URLSearchParams(window.location.search).get("aluno");
    const valor = document.getElementById("valorRecarga");
    const mensagem = document.getElementById("mensagemRecarga");
    const dialog = document.getElementById("dialogRecarga");
    const erroDialog = document.getElementById("erroRecarga");
    const confirmar = document.getElementById("confirmarRecarga");
    let revisao = null;
    const sugerido = new URLSearchParams(window.location.search).get("valor");
    if (sugerido) {
        try {
            const total = G.centavos(sugerido);
            if (total >= 100 && total <= 50000) valor.value = (total / 100).toFixed(2);
            else G.aviso(mensagem, "Escolha um valor entre R$ 1,00 e R$ 500,00.", true);
        } catch (erro) { G.aviso(mensagem, erro.message, true); }
    }
    function renderizar() {
        try {
            const dados = G.ler();
            const aluno = dados.alunos.find(a => a.id === ALUNO);
            if (!aluno) throw new Error("Nenhum aluno vinculado foi encontrado. Solicite o vínculo à cantina.");
            let adicionar = 0;
            try { adicionar = G.centavos(valor.value); } catch (_) { /* Campo ainda vazio. */ }
            if (adicionar < 100 || adicionar > 50000) adicionar = 0;
            document.getElementById("saldoAtual").textContent = G.moeda(aluno.saldo);
            document.getElementById("valorResumo").textContent = G.moeda(adicionar);
            document.getElementById("saldoDepois").textContent = G.moeda(aluno.saldo + adicionar);
            document.querySelectorAll("[data-valor]").forEach(b => b.setAttribute("aria-pressed", String(Number(b.dataset.valor) * 100 === adicionar)));
            const historico = document.getElementById("historicoRecargas");
            historico.replaceChildren();
            const recargas = dados.recargas.filter(r => r.alunoId === ALUNO).slice(0, 5);
            if (!recargas.length) historico.append(G.elemento("p", "Nenhuma recarga registrada ainda.", "ajuda"));
            recargas.forEach(r => {
                const linha = G.elemento("div", "", "resumo-linha");
                linha.append(G.elemento("span", new Date(r.data).toLocaleString("pt-BR")), G.elemento("strong", "+ " + G.moeda(r.valor)));
                historico.append(linha);
            });
            document.getElementById("revisarRecarga").disabled = false;
        } catch (erro) {
            document.getElementById("revisarRecarga").disabled = true;
            G.aviso(mensagem, erro.message, true);
        }
    }
    document.querySelectorAll("[data-valor]").forEach(b => b.addEventListener("click", () => {
        valor.value = b.dataset.valor;
        renderizar();
    }));
    valor.addEventListener("input", renderizar);
    document.getElementById("formRecarga").addEventListener("submit", event => {
        event.preventDefault();
        try {
            const total = G.centavos(valor.value);
            if (total < 100 || total > 50000) throw new Error("Escolha um valor entre R$ 1,00 e R$ 500,00.");
            const aluno = G.ler().alunos.find(a => a.id === ALUNO);
            if (!aluno) throw new Error("Nenhum aluno foi selecionado.");
            revisao = { valor: total, id: G.id() };
            document.getElementById("revisaoRecarga").textContent = "Adicionar " + G.moeda(total) + " ao saldo de " + aluno.nome + ".";
            erroDialog.hidden = true;
            confirmar.disabled = false;
            dialog.showModal();
            document.getElementById("cancelarRecarga").focus();
        } catch (erro) { G.aviso(mensagem, erro.message, true); }
    });
    document.getElementById("cancelarRecarga").addEventListener("click", () => dialog.close());
    dialog.addEventListener("close", () => { revisao = null; });
    confirmar.addEventListener("click", async () => {
        if (!revisao || confirmar.disabled) return;
        confirmar.disabled = true;
        try {
            const dados = await G.recarregar(ALUNO, revisao.valor, revisao.id);
            const novoSaldo = dados.alunos.find(a => a.id === ALUNO).saldo;
            G.aviso(mensagem, "Recarga de " + G.moeda(revisao.valor) + " registrada. Saldo disponível: " + G.moeda(novoSaldo) + ".");
            valor.value = "";
            dialog.close();
            renderizar();
        } catch (erro) {
            G.aviso(erroDialog, erro.message, true);
            confirmar.disabled = false;
        }
    });
    async function carregar() {
        try {
            const dados = await G.carregar();
            ALUNO = ALUNO || dados.alunos[0]?.id;
            const aluno = dados.alunos.find(a => a.id === ALUNO);
            if (aluno) {
                document.querySelector(".aluno-resumo strong").textContent = aluno.nome;
                document.querySelector(".aluno-resumo p").textContent = "Matrícula: " + aluno.matricula;
            }
            renderizar();
        } catch (erro) { G.aviso(mensagem, erro.message, true); }
    }
    window.addEventListener("focus", carregar);
    carregar();
}());
