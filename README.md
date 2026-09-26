# Nexus_Cantina

Projeto web da Nexus Cantina estruturado para usar FastAPI e templates HTML.

## Estrutura

```text
Nexus_Cantina/
├── main.py
├── database/
│   └── database.py
├── models/
│   └── usuario.py
├── schemas/
│   └── usuario.py
├── routers/
│   └── paginas.py
├── templates/
│   ├── pagamento.html
│   ├── alertapagamento.html
│   └── demais páginas HTML
└── static/
    ├── css/
    └── js/
```

## Executar com FastAPI

Instale o Python e, dentro da pasta do projeto, execute:

```bash
pip install -r requirements.txt
uvicorn main:app --reload
```

Depois abra [http://localhost:8000](http://localhost:8000).

## Fluxo do pagamento

1. O aluno adiciona produtos ao carrinho.
2. No carrinho, escolhe o primeiro ou o segundo intervalo.
3. A tela de pagamento mostra o resumo do pedido.
4. Ao clicar em **Confirmar pedido**, aparece a pergunta **Tem certeza?**.
5. Depois da confirmação, a tela de pedido realizado é exibida.

Um intervalo confirmado fica bloqueado até o fim do dia. O aluno ainda pode
comprar para o outro intervalo. No dia seguinte, os dois intervalos ficam
disponíveis novamente.

Por enquanto, esse bloqueio fica salvo no `localStorage` do navegador. Quando
o banco de dados estiver conectado, a mesma regra também deverá ser validada
no backend para funcionar entre aparelhos diferentes.

## Backup

Antes desta reorganização foi criado um ZIP completo na Área de Trabalho:

```text
Nexus_Cantina_backup_antes_pagamento_2026-09-26_015624.zip
```
