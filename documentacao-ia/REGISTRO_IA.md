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

## 26 de setembro de 2026 — quatro telas de gestão e saldo

- `templates/loginadmin.html` e `static/js/loginadmin.js`: a IA criou o
  formulário de acesso administrativo de demonstração, com validação,
  mensagens e opção de mostrar a senha. Não é autenticação real.
- `templates/telaadmin.html` e `static/js/telaadmin.js`: a IA completou o
  painel com indicadores, filtros e atualização do preparo e da entrega de
  pedidos de teste, incluindo a leitura do último pedido local quando existe.
- `templates/alunosdevendo.html` e `static/js/alunosdevendo.js`: a IA
  completou a consulta de alunos, filtros, confirmação de recebimentos
  simulados parciais ou totais e histórico.
- `templates/adicionarsaldo.html` e `static/js/adicionarsaldo.js`: a IA criou
  a revisão da recarga simulada, confirmação, cancelamento e histórico,
  aproveitando o valor informado pelo responsável.
- `static/js/gestao-dados.js`: a IA concentrou os dados fictícios, cálculos
  em centavos, armazenamento local, prevenção de repetição da mesma operação
  e sessão de demonstração. Nenhuma operação cobra dinheiro real.
- `static/css/gestao.css`: a IA criou os estilos compartilhados e responsivos
  das quatro telas, seguindo as cores do projeto.
- `static/js/saldo-demo.js`: a IA adicionou a exibição do mesmo saldo de
  demonstração nas áreas do aluno e do responsável.
- `templates/telaaluno.html` e `templates/telaresponsavel.html`: a IA conectou
  a exibição do saldo local. Na tela do responsável, ajustou o formulário
  para abrir a revisão da recarga. As alterações recentes da equipe no
  formulário e no visual foram consideradas, sem substituir seus estilos.
- `templates/escolhausuario.html`: a IA passou a entrada administrativa
  pelo formulário de login de demonstração.
- `routers/paginas.py`: a IA registrou as duas páginas novas na lista de
  páginas permitidas, mantendo a compatibilidade com os links `.html`.
- `README.md`: a IA documentou as telas, a navegação e os limites da
  demonstração local. As imagens continuam sendo produzidas pela equipe
  no Figma; a IA não criou imagens nesta etapa.
- `documentacao-ia/REGISTRO_IA.md`: a IA registrou esta etapa. As quatro telas
  foram preparadas fora da pasta do projeto e testadas juntas no navegador
  antes da integração, incluindo navegação, filtros, confirmações,
  cancelamento, persistência e layouts móveis. Também foram verificadas as
  26 rotas de páginas no FastAPI e seus links e recursos locais. Os arquivos
  do banco, modelos e schemas não foram alterados nesta etapa.
- Os dados de demonstração e o armazenamento no navegador são temporários.
  Eles deverão ser removidos quando o banco interno em Python for conectado.

## 26 de setembro de 2026 — alteração, cancelamento e limite negativo

- `templates/pagamento.html`, `static/js/pagamento.js` e
  `static/css/pagamento.css`: a IA incluiu o saldo antes e depois do pedido,
  permitiu saldo negativo até R$ 250,00 e adicionou os avisos do limite.
- `templates/alertapagamento.html`, `static/js/alertapagamento.js` e
  `static/css/alertapagamento.css`: a IA adicionou as opções para alterar ou
  cancelar um pedido ainda não concluído. Essas ações devolvem o saldo; a
  alteração devolve os itens ao carrinho e ambas liberam o intervalo.
- `static/js/carrinho.js`: a IA manteve selecionado o intervalo do pedido
  quando o aluno volta ao carrinho para alterá-lo.
- `templates/telaadmin.html`, `static/js/telaadmin.js` e
  `static/css/gestao.css`: a IA trocou o estado final para **Concluído** e
  adicionou a exibição de pedidos cancelados. Somente pedidos ainda não
  concluídos podem ser alterados ou cancelados pelo aluno.
- `static/js/gestao-dados.js`: a IA registrou débito e estorno do pedido,
  aplicou o limite negativo e sincronizou o estado final com o último pedido
  deste navegador. Nenhum novo aluno ou pedido fictício foi acrescentado.
- `README.md`: a IA documentou as duas regras. Elas ainda usam o armazenamento
  local da demonstração e deverão ser validadas novamente no backend quando o
  banco em Python for conectado.

## 26 de setembro de 2026 — primeira integração do login com o banco

- `database/database.py`, `.env.example`, `requirements.txt` e `main.py`: a
  IA corrigiu a conexão, adicionou as dependências do MySQL, carregamento das
  variáveis de ambiente e sessão assinada em cookie `HttpOnly`.
- `database/schema.sql`: a IA reorganizou o SQL com uma tabela única de
  usuários, senha em hash, perfis, vínculos entre responsável e estudante,
  produtos, pedidos, itens e movimentações de saldo. Também incluiu o limite
  de saldo negativo de R$ 250,00 e removeu os triggers conflitantes.
- `models/usuario.py`, `schemas/auth.py`, `services/auth.py` e
  `routers/auth.py`: a IA criou o modelo, a validação, a conferência de senha
  com Argon2 e as rotas de login, sessão atual e logout. O antigo
  `schemas/usuario.py` foi removido porque ficou sem uso.
- `scripts/criar_usuario.py`: a IA adicionou um comando interativo para criar
  alunos, responsáveis ou administradores sem salvar a senha original.
- `routers/paginas.py`: a IA protegeu as páginas internas conforme o perfil
  autenticado.
- `templates/loginaluno.html`, `templates/loginresponsavel.html`,
  `templates/loginadmin.html`, `static/css/login.css` e `static/js/login.js`:
  a IA padronizou os formulários, nomes, validação, acessibilidade, estado de
  carregamento e mensagens. Os arquivos duplicados de CSS e JavaScript dos
  logins de aluno e responsável foram removidos.
- `static/js/login.js`: ao confirmar um e-mail válido de responsável ou
  administrador, a IA adicionou o alerta solicitado. A mensagem informa que
  o envio é apenas uma simulação; nenhum e-mail real é enviado.
- `static/js/logout.js`, `static/js/usuario-atual.js` e as páginas internas:
  a IA conectou o logout, exibiu o nome da sessão e retirou nomes, saldos,
  pedidos e credenciais fictícias. As áreas ainda não ligadas ao banco agora
  mostram estados vazios ou avisos de integração pendente.
- `static/js/gestao-dados.js`, `static/js/pagamento.js`,
  `static/js/alertapagamento.js`, `static/js/adicionarsaldo.js` e
  `static/js/saldo-demo.js`: a IA removeu os alunos e pedidos fictícios e o
  identificador fixo usado no saldo. `saldo-demo.js` foi removido. A
  confirmação de pedidos e a recarga ficam desabilitadas até suas APIs serem
  conectadas ao banco.
- `static/js/pedidoaluno.js` e `static/css/pedidoaluno.css`: a IA corrigiu o
  erro da variável `produtos` inexistente e adicionou um estado vazio para o
  cardápio ainda não integrado.
- `static/css/telaresponsavel.css`: a IA corrigiu a rolagem horizontal e a
  organização do cabeçalho no celular.
- `README.md` e `documentacao-ia/REGISTRO_IA.md`: a IA documentou a instalação,
  a criação do primeiro usuário e os limites desta primeira etapa.
- A autenticação foi testada com um banco SQLite temporário, sem adicionar
  usuários ao projeto. Passaram os três perfis, hash Argon2, cookie de sessão,
  logout, proteção de páginas, mensagens de erro, alertas simulados e layouts
  de desktop e celular.

## 26 de setembro de 2026 — telas preparadas para as próximas APIs

- `templates/gerenciaralunos.html` e `static/js/gerenciaralunos.js`: a IA
  adicionou o cadastro e a listagem de alunos preparados para `GET` e `POST`
  em `/api/alunos`, sem inserir registros fictícios.
- `templates/gerenciarprodutos.html` e `static/js/gerenciarprodutos.js`: a IA
  adicionou o cadastro e a listagem de produtos preparados para
  `/api/produtos`, incluindo preço, estoque e disponibilidade.
- `templates/vincularaluno.html` e `static/js/vincularaluno.js`: a IA criou a
  tela de vínculos preparada para alunos, responsáveis e `/api/vinculos`.
- `templates/detalhepedido.html` e `static/js/detalhepedido.js`: a IA criou a
  consulta de um pedido e a atualização de sua situação, preparadas para
  `/api/pedidos/{id}`.
- `static/js/api-admin.js`: a IA isolou as requisições dessas quatro telas e
  tratou endpoints ainda ausentes como integração pendente.
- `templates/telaadmin.html` e `static/css/gestao.css`: a IA adicionou os
  acessos para as novas telas e estilos responsivos compartilhados.
- `routers/paginas.py`: a IA registrou as quatro páginas e restringiu o acesso
  ao perfil administrador.
- `scripts/criar_usuarios_teste.py` e `.env.example`: a IA adicionou um comando
  explícito e idempotente para criar um aluno, um responsável e um
  administrador de teste somente no banco configurado. Nada é criado
  automaticamente e a senha pode ser definida pelo ambiente.
- `README.md`: a IA documentou as telas dependentes do banco, os endpoints
  planejados, o ambiente virtual e as contas de teste.
- `.venv/`: a IA criou o ambiente virtual local e instalou somente as
  dependências declaradas em `requirements.txt`. A pasta permanece ignorada
  pelo Git.
- Nenhum endpoint de alunos, produtos, vínculos ou pedidos foi implementado e
  nenhuma tabela ou lógica de negócio do banco foi alterada nesta etapa.

## 26 de setembro de 2026 — acesso local antes do banco

- `services/usuarios_teste.py`: a IA adicionou três contas locais controladas
  por `ENABLE_TEST_USERS`, sem salvar usuários no navegador ou criar um banco.
- `database/database.py` e `routers/auth.py`: a IA permitiu que login, sessão
  atual e páginas protegidas funcionem no modo de teste quando o banco ainda
  não estiver configurado. A autenticação pelo banco continua sendo usada
  normalmente quando esse modo não corresponde ao acesso informado.
- `.env`: a IA habilitou o modo apenas neste computador. O arquivo continua
  ignorado pelo Git.
- `.env.example`: a IA documentou a chave de ativação, desabilitada por padrão
  para novos ambientes.
- `scripts/criar_usuarios_teste.py`: a IA alinhou a futura carga no banco com
  as mesmas contas locais: `aluno01`, `resp01@teste.com` e
  `admin01@teste.com`, todas com a senha temporária `1234`.
- `templates/loginaluno.html`: a IA retirou o teclado exclusivamente numérico,
  pois a matrícula de teste também contém letras.
- `static/js/login.js`: a IA incluiu uma orientação clara quando alguém tenta
  autenticar pelo Live Server em vez do FastAPI.
- `README.md`: a IA registrou os acessos, a porta correta e como desabilitar o
  modo de teste quando o banco estiver pronto.
- Os três perfis foram testados por HTTP: login, cookie de sessão, rota
  `/api/auth/me` e abertura das respectivas páginas protegidas retornaram com
  sucesso. Nenhuma conta foi gravada em um banco real.

## 26 de setembro de 2026 — correção do acesso aberto como arquivo

- `static/js/login.js`: após a equipe identificar o erro `Failed to fetch`, a
  IA confirmou que o HTML estava aberto por `file:///`. As três telas de login
  agora redirecionam automaticamente para a mesma página em
  `http://127.0.0.1:8000`, onde o backend e a sessão estão disponíveis.
- `static/js/login.js`: a IA também substituiu a mensagem técnica de falha de
  rede por uma orientação para iniciar o FastAPI na porta 8000.
- Nenhuma credencial, regra de negócio ou estrutura do banco foi alterada
  nesta correção.

## 26 de setembro de 2026 — revisão de navegação e estabilidade

- `routers/paginas.py`: a IA corrigiu o redirecionamento de uma página de
  outro perfil. Um usuário já autenticado agora volta para sua própria área,
  em vez de cair no formulário de login do perfil incorreto.
- `static/js/navegacao-perfil.js`: a IA adicionou navegação consciente da
  sessão. Início e saída apontam para aluno, responsável ou administrador
  conforme o perfil atual. Abas antigas também são encaminhadas ao trocar de
  perfil em outra aba.
- `templates/pedidoaluno.html`, `templates/carrinho.html`,
  `templates/pagamento.html` e `templates/alertapagamento.html`: a IA marcou
  as páginas compartilhadas, corrigiu o destino de início e adicionou os
  scripts de navegação. O logout que faltava no cardápio também foi ligado.
- `templates/telaaluno.html`, `templates/telaresponsavel.html`,
  `templates/telaadmin.html`, `templates/alunosdevendo.html`,
  `templates/adicionarsaldo.html`, `templates/gerenciaralunos.html`,
  `templates/gerenciarprodutos.html`, `templates/vincularaluno.html` e
  `templates/detalhepedido.html`: a IA declarou os perfis permitidos no HTML
  e ativou a verificação de abas antigas.
- `static/js/logout.js`: a IA passou a consultar a sessão antes de sair, para
  sempre retornar ao login do perfil correto.
- `templates/carrinho.html` e `static/js/carrinho.js`: a IA substituiu o link
  com `href="#"` por um botão real, removeu eventos inline, tratou dados
  locais ausentes ou inválidos e passou a criar os itens com a API do DOM.
- `static/js/pagamento.js`, `static/js/alertapagamento.js` e
  `static/js/pedidoaluno.js`: a IA adicionou leitura segura do armazenamento,
  validação dos dados e criação de conteúdo sem interpolar valores do
  navegador em HTML.
- `static/js/usuario-atual.js`: a IA passou a atualizar o nome ao restaurar ou
  focar uma aba, evitando dados visuais de uma sessão anterior.
- `static/css/pedidoaluno.css`, `static/css/carrinho.css` e
  `static/css/pagamento.css`: a IA corrigiu cabeçalhos estreitos, quebra da
  navegação em telas pequenas e indicação da seção atual.
- `README.md`: a IA documentou que existe uma sessão por navegador e como a
  navegação se comporta ao trocar de perfil.
- A revisão verificou as 17 páginas Jinja, todos os arquivos Python e os 17
  arquivos JavaScript, referências locais, IDs duplicados, IDs usados pelos
  scripts, permissões, logins e redirecionamentos por perfil. Nenhum endpoint
  de negócio ou banco de dados foi adicionado nesta correção.

## 26 de setembro de 2026 — consolidação antes do commit

- A IA confirmou que a falha mais recente de login ocorreu porque o FastAPI
  local estava parado. O servidor foi reiniciado em `127.0.0.1:8000` e o
  acesso `aluno01` com senha `1234` voltou a abrir `telaaluno.html` com status
  HTTP 200.
- Os acessos de aluno, responsável e administrador foram novamente verificados
  pelo backend, incluindo suas páginas iniciais e o redirecionamento para a
  área correta quando uma rota pertence a outro perfil.
- A inspeção visual que seria feita no navegador foi interrompida a pedido da
  equipe; ela não produziu alterações adicionais no projeto.
- `.env` e `.venv/` permanecem apenas no computador local e ignorados pelo
  Git. `.env.example` registra as opções necessárias sem incluir a chave local
  de sessão.
- Todo o restante do progresso descrito neste registro foi preparado para um
  único commit de consolidação, sem adicionar o banco de dados de negócio.
