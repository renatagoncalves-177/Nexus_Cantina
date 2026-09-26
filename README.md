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

## Telas de gestão e saldo (demonstração)

- `loginadmin.html`: entrada da cantina pela escolha de perfil. O próprio
  formulário mostra as credenciais públicas de teste.
- `telaadmin.html`: pedidos do dia, busca, filtros por intervalo e situação,
  atualização para pronto e entregue.
- `alunosdevendo.html`: consulta por nome, matrícula, turma e situação,
  confirmação de recebimentos parciais ou totais e histórico.
- `adicionarsaldo.html`: revisão e confirmação de recarga simulada, valores
  sugeridos e histórico. Recebe o valor preenchido na área do responsável.

Com FastAPI, acesse essas páginas por `/loginadmin.html`, por exemplo.
Com Live Server, abra `templates/escolhausuario.html` e navegue pelos links.
O saldo de demonstração de Carlos Silva é compartilhado entre a recarga e
as áreas do aluno e do responsável.

Os dados são fictícios, salvos somente neste navegador na chave
`nexusGestaoDemo.v1` do `localStorage`. A sessão administrativa de demonstração
usa `sessionStorage`. Isso não substitui autenticação nem autorização no
backend; não use dados reais. Recarregar e registrar recebimento não realiza
pagamentos. O painel pode importar o último pedido local do fluxo existente,
mas não sincroniza aparelhos nem altera as regras atuais de pagamento.
Banco de dados, usuários reais e integração financeira ficam para outra etapa.

As imagens e os demais elementos visuais continuam sendo produzidos pela
equipe no Figma. Nenhuma imagem nova foi criada pela IA nesta etapa.

## Backup da reorganização anterior

Antes desta reorganização foi criado um ZIP completo na Área de Trabalho:

```text
Nexus_Cantina_backup_antes_pagamento_2026-09-26_015624.zip
```
