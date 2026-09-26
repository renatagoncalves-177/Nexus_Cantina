(function () {
    "use strict";
    const Api = window.NexusApi;
    const formulario = document.getElementById("formAluno");
    const corpo = document.getElementById("listaAlunos");
    const vazio = document.getElementById("vazioAlunos");
    const mensagem = document.getElementById("mensagemAlunos");

    function renderizar(alunos) {
        corpo.replaceChildren();
        alunos.forEach(aluno => {
            const linha = document.createElement("tr");
            const identificacao = document.createElement("td");
            identificacao.append(Api.criar("strong", aluno.nome), Api.criar("small", aluno.email || "E-mail não informado"));
            linha.append(
                identificacao,
                Api.criar("td", aluno.matricula),
                Api.criar("td", [aluno.serie, aluno.turma].filter(Boolean).join(" — ") || "Não informado"),
                Api.criar("td", aluno.ativo === false ? "Inativo" : "Ativo", "badge " + (aluno.ativo === false ? "cancelado" : "regular"))
            );
            corpo.append(linha);
        });
        vazio.hidden = alunos.length > 0;
        document.getElementById("contagemAlunos").textContent = alunos.length + " aluno(s) cadastrado(s)";
    }

    async function carregar() {
        try {
            const dados = await Api.requisitar("/api/alunos");
            renderizar(Api.lista(dados, "alunos"));
            Api.informar(mensagem, "");
        } catch (erro) {
            renderizar([]);
            erro.integracaoPendente ? Api.informarPendente(mensagem) : Api.informar(mensagem, erro.message, true);
        }
    }

    formulario.addEventListener("submit", async evento => {
        evento.preventDefault();
        const botao = formulario.querySelector("button[type='submit']");
        botao.disabled = true;
        try {
            const campos = new FormData(formulario);
            await Api.requisitar("/api/alunos", { method: "POST", body: Object.fromEntries(campos) });
            formulario.reset();
            Api.informar(mensagem, "Aluno cadastrado com sucesso.");
            await carregar();
        } catch (erro) {
            erro.integracaoPendente ? Api.informarPendente(mensagem) : Api.informar(mensagem, erro.message, true);
        } finally {
            botao.disabled = false;
        }
    });

    document.getElementById("atualizarAlunos").addEventListener("click", carregar);
    carregar();
}());
