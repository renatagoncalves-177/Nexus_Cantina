(function () {
    "use strict";
    const G = window.NexusGestao;
    if (!G.exigirAdmin()) return;
    const busca = document.getElementById("buscaAluno");
    const turma = document.getElementById("filtroTurma");
    const situacao = document.getElementById("filtroDivida");
    const mensagem = document.getElementById("mensagemAlunos");
    const dialog = document.getElementById("dialogRecebimento");
    const valor = document.getElementById("valorRecebido");
    const erroDialog = document.getElementById("erroRecebimento");
    const confirmar = document.getElementById("confirmarRecebimento");
    let selecionado = null;
    function abrir(aluno) {
        selecionado = { alunoId: aluno.id, id: G.id() };
        document.getElementById("alunoRecebimento").textContent = aluno.nome + " • Matrícula " + aluno.id + ". Em aberto: " + G.moeda(aluno.divida) + ".";
        valor.value = (aluno.divida / 100).toFixed(2);
        valor.max = valor.value;
        erroDialog.hidden = true;
        confirmar.disabled = false;
        dialog.showModal();
        valor.focus();
    }
    function renderizar() {
        try {
            const dados = G.ler();
            const alunos = dados.alunos;
            const selecionada = turma.value;
            turma.replaceChildren(new Option("Todas as turmas", ""));
            [...new Set(alunos.map(a => a.turma))].sort().forEach(t => turma.append(new Option(t, t)));
            turma.value = selecionada;
            document.getElementById("totalEmAberto").textContent = G.moeda(alunos.reduce((s,a) => s + a.divida, 0));
            document.getElementById("quantidadeDevedores").textContent = alunos.filter(a => a.divida > 0).length;
            document.getElementById("quantidadeAlunos").textContent = alunos.length;
            const filtrados = alunos.filter(a => G.normalizar(a.nome + " " + a.id).includes(G.normalizar(busca.value.trim())) &&
                (!turma.value || a.turma === turma.value) && (situacao.value === "todos" || (situacao.value === "pendentes" ? a.divida > 0 : a.divida === 0)));
            const lista = document.getElementById("listaAlunos");
            lista.replaceChildren();
            for (const aluno of filtrados) {
                const tr = document.createElement("tr");
                const nome = document.createElement("td");
                nome.append(G.elemento("strong", aluno.nome), G.elemento("small", aluno.id));
                const estado = document.createElement("td");
                estado.append(G.elemento("span", aluno.divida > 0 ? "Com pendência" : "Em dia", "badge " + (aluno.divida > 0 ? "devedor" : "regular")));
                const acao = document.createElement("td");
                if (aluno.divida > 0) {
                    const b = G.elemento("button", "Registrar recebimento", "btn pequeno secundario");
                    b.type = "button";
                    b.setAttribute("aria-label", "Registrar recebimento de " + aluno.nome);
                    b.addEventListener("click", () => abrir(aluno));
                    acao.append(b);
                } else acao.append(G.elemento("span", "Sem pendência", "ajuda"));
                tr.append(nome, G.elemento("td", aluno.turma), G.elemento("td", G.moeda(aluno.divida)), estado, acao);
                lista.append(tr);
            }
            document.getElementById("contagemAlunos").textContent = filtrados.length + " aluno(s) encontrado(s)";
            document.getElementById("vazioAlunos").hidden = filtrados.length > 0;
            const historico = document.getElementById("historicoRecebimentos");
            historico.replaceChildren();
            if (!dados.recebimentos.length) historico.append(G.elemento("p", "Nenhum recebimento registrado ainda.", "ajuda"));
            dados.recebimentos.slice(0, 8).forEach(r => {
                const aluno = alunos.find(a => a.id === r.alunoId);
                const linha = G.elemento("div", "", "resumo-linha");
                linha.append(G.elemento("span", aluno.nome + " • " + new Date(r.data).toLocaleString("pt-BR")), G.elemento("strong", G.moeda(r.valor)));
                historico.append(linha);
            });
        } catch (erro) { G.aviso(mensagem, erro.message, true); }
    }
    [busca, turma, situacao].forEach(el => el.addEventListener("input", renderizar));
    document.getElementById("limparFiltrosAlunos").addEventListener("click", () => {
        busca.value = turma.value = "";
        situacao.value = "todos";
        renderizar();
    });
    document.getElementById("cancelarRecebimento").addEventListener("click", () => dialog.close());
    dialog.addEventListener("close", () => { selecionado = null; });
    document.getElementById("formRecebimento").addEventListener("submit", event => {
        event.preventDefault();
        if (!selecionado || confirmar.disabled || !G.exigirAdmin()) return;
        confirmar.disabled = true;
        try {
            const total = G.centavos(valor.value);
            G.receber(selecionado.alunoId, total, selecionado.id);
            G.aviso(mensagem, "Recebimento de teste de " + G.moeda(total) + " registrado.");
            dialog.close();
            renderizar();
        } catch (erro) {
            G.aviso(erroDialog, erro.message, true);
            confirmar.disabled = false;
        }
    });
    window.addEventListener("storage", renderizar);
    window.addEventListener("pageshow", () => { if (G.exigirAdmin()) renderizar(); });
    renderizar();
}());
