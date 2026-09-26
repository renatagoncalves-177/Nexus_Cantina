# Registro de uso de inteligência artificial

Este arquivo registra, em linguagem simples, quais partes do projeto foram
criadas ou alteradas com auxílio de inteligência artificial.

Sempre que uma IA criar ou modificar um arquivo do projeto, uma nova entrada
deve ser adicionada aqui. O objetivo é deixar claro para a equipe e para os
avaliadores onde a IA ajudou no desenvolvimento.

## 25 de setembro de 2026

- `database/schema.sql`: a primeira estrutura do banco de dados foi criada com
  auxílio de IA. Ela incluiu as tabelas e os relacionamentos pensados para
  responsáveis, alunos, produtos, pedidos, estoque e saldo. Depois disso, o
  arquivo pôde ser alterado pela própria equipe.
- `documentacao-ia/REGISTRO_IA.md`: criado com auxílio de IA para manter este
  histórico de forma simples e transparente.
- `AGENTS.md`: criado com auxílio de IA para lembrar as próximas ferramentas de
  IA de atualizarem este registro sempre que trabalharem nos arquivos.

## Modelo para as próximas entradas

Copie este modelo e preencha de forma simples:

```text
## Data

- `caminho/do/arquivo`: explique o que a IA criou ou alterou nesse arquivo.
```

## 26 de setembro de 2026

- `paginas/html/loginaluno.html`: a IA ajudou a criar e corrigir a tela de
  login do aluno. Também ajudou com a validação de matrícula e senha, o
  redirecionamento para a área do aluno e o caminho correto do arquivo CSS.
- `paginas/html/loginresponsavel.html`: a tela de login do responsável foi
  criada com auxílio de IA, incluindo o formulário e a validação feita com
  JavaScript.
- `paginas/html/telaaluno.html`: a IA ajudou a criar a página inicial do
  aluno, com saldo, gastos, menu e acesso à área de pedidos.
- `paginas/html/pedidoaluno.html`: a IA ajudou a criar o cardápio, os produtos
  de demonstração, a indicação de estoque e a função de adicionar itens ao
  carrinho.
- `paginas/html/carrinho.html`: a IA ajudou a criar o carrinho, os controles
  de quantidade, a remoção de produtos e o cálculo do valor total.
- `paginas/html/pagamento.html`: a IA ajudou a criar a etapa de pagamento
  simulado e a escolha entre o primeiro e o segundo intervalo.
- `paginas/styles/loginaluno.css`: o visual da página de login do aluno foi
  criado e ajustado com auxílio de IA.
- `paginas/styles/pagamento.css`: o visual da etapa de pagamento foi criado e
  organizado com auxílio de IA.
- `documentacao-ia/REGISTRO_IA.md`: esta seção foi adicionada pela IA depois
  da conferência da conversa “Aguardar imagens Figma” e dos arquivos que
  realmente estão na pasta `paginas`.

## 26 de setembro de 2026 — correções de caminhos e login

- `paginas/scripts/` e `paginas/script/`: a IA renomeou a pasta de scripts
  para o singular. Os arquivos `carrinho.js`, `loginaluno.js`,
  `loginresponsavel.js`, `pagamento.js` e `pedidoaluno.js` foram movidos para
  o novo caminho.
- `paginas/html/carrinho.html`, `paginas/html/loginaluno.html`,
  `paginas/html/loginresponsavel.html`, `paginas/html/pagamento.html` e
  `paginas/html/pedidoaluno.html`: a IA atualizou os caminhos dos arquivos
  JavaScript de `../scripts/` para `../script/`.
- `paginas/html/telaaluno.html`: a IA removeu a referência a
  `telaaluno.js`, pois esse arquivo não existe no projeto e a página não
  depende dele.
- `paginas/script/loginresponsavel.js`: a IA substituiu a mensagem exibida
  apenas no console pelo redirecionamento para `telaresponsavel.html` depois
  do login bem-sucedido.
- `paginas/html/telaresponsavel.html`: a IA corrigiu o caminho do CSS sem
  acento, ajustou o botão **Sair** para `loginresponsavel.html`, corrigiu o
  título da página e adicionou a tag final `</html>`.
- `README.md`: a IA documentou a estrutura atual do projeto e resumiu as
  correções realizadas.
- `documentacao-ia/REGISTRO_IA.md`: a IA adicionou esta entrada para registrar
  de forma transparente as alterações acima.

- `documentacao-ia/REGISTRO_IA.md`: a IA adicionou uma tela de escolha de usuário para definir qual login será acessado.

## 26 de setembro de 2026 — reorganização FastAPI e confirmação do pedido

- `main.py`: a IA corrigiu a configuração do FastAPI para carregar as rotas,
  os templates e os arquivos estáticos nas novas pastas.
- `database/database.py`, `models/usuario.py`, `schemas/usuario.py` e
  `routers/paginas.py`: a IA criou a estrutura base solicitada para o projeto
  FastAPI. A conexão real com o banco ainda não foi implementada.
- `templates/*.html`: a IA atualizou os caminhos das páginas, dos estilos e
  dos scripts para a estrutura `templates` e `static`.
- `templates/alunosdevendo.html` e `static/css/alunosdevendo.css`: a IA
  preservou os arquivos criados pela equipe durante a reorganização e ajustou
  seus caminhos para a nova estrutura.
- `templates/pagamento.html`: a IA criou a revisão do pedido e a confirmação
  com a mensagem “Tem certeza?” antes de concluir a compra.
- `templates/alertapagamento.html`: a IA criou a tela que informa que o pedido
  foi realizado e mostra o intervalo e o valor confirmados.
- `static/js/carrinho.js` e `static/js/pagamento.js`: a IA adicionou o bloqueio
  de uma segunda compra para o mesmo intervalo no mesmo dia. O bloqueio é
  liberado automaticamente no dia seguinte e, nesta primeira versão, fica
  salvo no navegador.
- `static/js/alertapagamento.js`, `static/css/pagamento.css` e
  `static/css/alertapagamento.css`: a IA criou o comportamento e o visual das
  novas telas do fluxo de confirmação.
- `requirements.txt` e `README.md`: a IA documentou as dependências, a nova
  estrutura, a execução do FastAPI e a regra temporária de intervalo.
- `documentacao-ia/REGISTRO_IA.md`: a IA adicionou esta entrada para registrar
  as alterações acima.
- `paginas/html/pagamento.html`: a IA adicionou um redirecionamento de
  compatibilidade para o caminho antigo continuar abrindo a nova tela.
- `templates/pagamento.html`, `templates/alertapagamento.html`,
  `static/js/pagamento.js`, `static/js/carrinho.js` e `routers/paginas.py`: a
  IA tornou o fluxo de pagamento compatível tanto com o FastAPI quanto com a
  abertura direta dos arquivos HTML durante o desenvolvimento.
- `templates/*.html` e `static/js/*.js`: a IA trocou as rotas absolutas por
  links relativos com `.html`, permitindo navegar normalmente pelo Live Server
  na porta 5500 sem perder a compatibilidade com o FastAPI.
- As imagens e demais elementos visuais do projeto estão sendo produzidos pela
  equipe no Figma. A IA não criou nem adicionou esses arquivos nesta etapa.
