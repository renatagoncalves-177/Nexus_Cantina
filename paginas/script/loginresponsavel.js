const form = document.getElementById("formLogin");
const matricula = document.getElementById("matricula");
const email = document.getElementById("email");
const senha = document.getElementById("senha");
const mensagem = document.getElementById("mensagem");

form.addEventListener("submit", function(event) {
    event.preventDefault();

const valorMatricula = matricula.value.trim();
const valorEmail = email.value.trim();
const valorSenha = senha.value.trim();

mensagem.className = "mensagem";
mensagem.textContent = "";

if (valorMatricula === "" || valorEmail === "" ||valorSenha === "") {
    mensagem.classList.add("erro");
    mensagem.textContent = "Preencha todos os campos.";
    return;
}

if (valorMatricula.length < 3) {
    mensagem.classList.add("erro");
    mensagem.textContent = "Digite uma matrícula válida.";
    return;
}

if (!valorEmail.includes("@") || !valorEmail.includes(".")) {
    mensagem.classList.add("erro");
    mensagem.textContent = "Digite um e-mail válido.";
    return;
}

mensagem.classList.add("sucesso");
mensagem.textContent = "Login realizado com sucesso!";

setTimeout(function() {
    window.location.href = "telaresponsavel.html";
}, 700);
});