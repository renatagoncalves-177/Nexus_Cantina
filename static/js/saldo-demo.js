/* Saldo do mesmo aluno de demonstração usado na tela de recarga. */
(function () {
    const G = window.NexusGestao;
    function atualizar() {
        const saldo = document.getElementById("saldoDisponivel");
        try {
            const aluno = G.ler().alunos.find(a => a.id === "2026001");
            saldo.textContent = G.moeda(aluno.saldo);
        } catch (_) { saldo.textContent = "Indisponível"; }
    }
    window.addEventListener("storage", atualizar);
    window.addEventListener("pageshow", atualizar);
    atualizar();
}());
