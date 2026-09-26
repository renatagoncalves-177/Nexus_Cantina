 const form = document.getElementById("formLogin");
        const matricula = document.getElementById("matricula");
        const senha = document.getElementById("senha");
        const mensagem = document.getElementById("mensagem");

        form.addEventListener("submit", function(event) {
            event.preventDefault();

            const valorMatricula = matricula.value.trim();
            const valorSenha = senha.value.trim();

            mensagem.className = "mensagem";
            mensagem.textContent = "";

            if (valorMatricula === "" || valorSenha === "") {
                mensagem.classList.add("erro");
                mensagem.textContent = "Preencha a matrícula e a senha.";
                return;
            }

            if (valorMatricula.length < 3) {
                mensagem.classList.add("erro");
                mensagem.textContent = "Digite uma matrícula válida.";
                return;
            }

            mensagem.classList.add("sucesso");
            mensagem.textContent = "Login realizado com sucesso!";

            setTimeout(function() {
                window.location.href = "telaaluno.html";
            }, 700);
        });