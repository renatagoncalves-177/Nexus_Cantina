const intervaloElemento = document.getElementById("intervaloConfirmado");
const totalElemento = document.getElementById("totalConfirmado");

function formatarMoeda(valor) {
    return Number(valor || 0).toLocaleString("pt-BR", {
        style: "currency",
        currency: "BRL"
    });
}

try {
    const pedido = JSON.parse(localStorage.getItem("ultimoPedido"));

    if (pedido) {
        intervaloElemento.textContent = pedido.intervalo;
        totalElemento.textContent = formatarMoeda(pedido.total);
    }
} catch (_erro) {
    intervaloElemento.textContent = "Não informado";
    totalElemento.textContent = formatarMoeda(0);
}
