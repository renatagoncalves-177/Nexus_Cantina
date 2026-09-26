(function () {
    "use strict";
    const Api = window.NexusApi;
    const formulario = document.getElementById("formVinculo");
    const responsavel = document.getElementById("responsavelId");
    const aluno = document.getElementById("alunoId");
    const corpo = document.getElementById("listaVinculos");
    const vazio = document.getElementById("vazioVinculos");
    const mensagem = document.getElementById("mensagemVinculos");

    function preencherSelect(select, itens, rotulo) {
        select.replaceChildren(new Option(rotulo, ""));
        itens.forEach(item => select.add(new Option(item.nome, item.id)));
    }

    function renderizar(vinculos) {
        corpo.replaceChildren();
        vinculos.forEach(vinculo => {
            const linha = document.createElement("tr");
            linha.append(
                Api.criar("td", vinculo.responsavel_nome || vinculo.responsavel?.nome || "Responsável"),
                Api.criar("td", vinculo.aluno_nome || vinculo.aluno?.nome || "Aluno"),
                Api.criar("td", vinculo.ativo === false ? "Inativo" : "Ativo", "badge " + (vinculo.ativo === false ? "cancelado" : "regular"))
            );
            corpo.append(linha);
        });
        vazio.hidden = vinculos.length > 0;
        document.getElementById("contagemVinculos").textContent = vinculos.length + " vínculo(s) cadastrado(s)";
    }

    async function carregar() {
        try {
            const [dadosResponsaveis, dadosAlunos, dadosVinculos] = await Promise.all([
                Api.requisitar("/api/responsaveis"),
                Api.requisitar("/api/alunos"),
                Api.requisitar("/api/vinculos")
            ]);
            preencherSelect(responsavel, Api.lista(dadosResponsaveis, "responsaveis"), "Selecione um responsável");
            responsavel.add(new Option("Cadastrar novo responsável…", "novo"));
            preencherSelect(aluno, Api.lista(dadosAlunos, "alunos"), "Selecione um aluno");
            renderizar(Api.lista(dadosVinculos, "vinculos"));
            Api.informar(mensagem, "");
        } catch (erro) {
            preencherSelect(responsavel, [], "Aguardando responsáveis");
            preencherSelect(aluno, [], "Aguardando alunos");
            renderizar([]);
            erro.integracaoPendente ? Api.informarPendente(mensagem) : Api.informar(mensagem, erro.message, true);
        }
    }

    responsavel.addEventListener("change", async () => {
        if (responsavel.value !== "novo") return;
        try {
            const nome = prompt("Nome completo do responsável:");
            if (!nome) { responsavel.value = ""; return; }
            const email = prompt("E-mail do responsável:");
            if (!email) { responsavel.value = ""; return; }
            const senha = prompt("Senha inicial de teste (mínimo de 8 caracteres):");
            if (!senha) { responsavel.value = ""; return; }
            const novo = await Api.requisitar("/api/responsaveis", { method: "POST", body: { nome, email, senha } });
            await carregar();
            responsavel.value = String(novo.id);
        } catch (erro) { Api.informar(mensagem, erro.message, true); responsavel.value = ""; }
    });
    formulario.addEventListener("submit", async evento => {
        evento.preventDefault();
        const botao = formulario.querySelector("button[type='submit']");
        botao.disabled = true;
        try {
            await Api.requisitar("/api/vinculos", { method: "POST", body: Object.fromEntries(new FormData(formulario)) });
            formulario.reset();
            Api.informar(mensagem, "Vínculo criado com sucesso.");
            await carregar();
        } catch (erro) {
            erro.integracaoPendente ? Api.informarPendente(mensagem) : Api.informar(mensagem, erro.message, true);
        } finally {
            botao.disabled = false;
        }
    });

    document.getElementById("atualizarVinculos").addEventListener("click", carregar);
    carregar();
}());
