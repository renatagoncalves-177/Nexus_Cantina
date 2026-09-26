# Nexus Cantina

Aplicação escolar com FastAPI, SQLAlchemy, HTML, CSS e JavaScript. A versão atual usa SQLite local para desenvolvimento, com usuários, produtos, pedidos e saldos persistidos.

## Iniciar

No PowerShell, dentro da pasta do projeto:

```powershell
python -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
.\.venv\Scripts\python.exe -m scripts.inicializar_banco
.\.venv\Scripts\python.exe -m uvicorn main:app --reload
```

Se o ambiente virtual já existir, pule o primeiro comando. Abra http://127.0.0.1:8000. Não abra os HTMLs por arquivo nem pelo Live Server.

Sem DATABASE_URL, o projeto usa nexus_dev.db na raiz. O inicializador cria um backup antes de reaplicar o seed em um banco existente. O seed não apaga registros nem repõe saldos e estoques já utilizados. Banco e backups são ignorados pelo Git.

Em outro computador, copie .env.example para .env e configure uma SECRET_KEY aleatória para preservar as sessões entre reinicializações. Não publique .env.

## Contas de desenvolvimento

- Administrador: admin ou admin@nexuscantina.com.
- Alunos: aluno01 até aluno50.
- Responsáveis: responsavel01@teste.example até responsavel50@teste.example.
- Senha inicial comum do seed: 12345678.

São dados fictícios exclusivamente para teste. As senhas ficam em hash Argon2id no banco. Há exatamente um administrador, cinquenta responsáveis e cinquenta alunos no seed. Cada aluno começa com R$ 50,00 e tem um responsável exclusivo. Sete séries são distribuídas em grupos de sete ou oito alunos.

O banco é a fonte dos logins. As antigas contas em memória não substituem as contas do banco, mesmo que uma configuração antiga ainda ative ENABLE_TEST_USERS.

## Fluxos disponíveis

- Login, sessão, logout e navegação por perfil, com autorização também nos endpoints.
- Cardápio com 38 produtos, seis categorias e filtragem de produtos indisponíveis.
- Administrador: cadastro e edição de produtos, estoque, preço, ativação, alunos, responsáveis, vínculos, fila de pedidos e recebimentos.
- Para editar produto, selecione sua linha na lista; o formulário existente recebe os dados. Categoria e caminho de imagem são solicitados em diálogos, preservando a estrutura visual.
- Para cadastrar um responsável, use a opção correspondente no seletor da tela de vínculos.
- Para recarregar, acesse Adicionar saldo na área do responsável ou a página adicionarsaldo.html.
- Saldo, gastos e pedidos são consultados no banco. O navegador guarda apenas o carrinho e referências para navegação.
- Compra com confirmação, limite negativo de R$ 250,00 e registro de movimentações.
- Edição atômica e cancelamento com estorno enquanto o pedido não estiver concluído.
- Um pedido não cancelado por aluno, dia e intervalo. Cancelamento libera o intervalo; conclusão mantém o bloqueio até o próximo dia.
- Cantina avança pedidos de pendente para pronto e depois concluído.
- Aviso de e-mail do pagamento aparece apenas ao clicar em Continuar. E-mails e pagamentos externos continuam sendo simulações; nenhum serviço de envio ou cobrança real foi contratado.

## Transações e concorrência

Execute um único worker para manter a fila FIFO pela chegada ao servidor. As tentativas recebem horário UTC e a resposta mostra milissegundos; empates seguem a ordem de entrada na fila. O dia escolar usa o horário de São Paulo (UTC-3).

SQLite usa BEGIN IMMEDIATE antes de consultar/alterar os pedidos; estoque também é descontado com atualização condicional. Falhas revertem pedido, itens, estoque e saldo. Chaves de operação evitam débito ou recarga duplicados em reenvios.

A fila em memória não fornece ordenação global entre vários workers ou servidores. Uma implantação distribuída exige uma fila compartilhada. Esta entrega é uma aplicação local de desenvolvimento, não uma implantação de produção.

## Banco e imagens

database/schema.sql e database/seed.sql são SQLite. Não execute esses arquivos diretamente no MySQL. Os modelos usam SQLAlchemy, mas uma migração do banco anterior MySQL requer revisão e conversão próprias; não foi executada nesta entrega.

O campo imagem_url contém os caminhos solicitados. As imagens finais estão sendo produzidas pela equipe no Figma; os cards conservam os ícones existentes enquanto esses arquivos não são entregues. Nenhuma imagem foi inventada pela IA.

[Layouts no Figma](https://www.figma.com/design/POPGJzsNhTX5LGz7EpR7d4/Hackaton?node-id=0-1&p=f&t=rFzy5CDQpAEaMaPl-0)

## Testes

```powershell
.\.venv\Scripts\python.exe -m pip install -r requirements-dev.txt
.\.venv\Scripts\python.exe -B -m pytest -q -p no:cacheprovider
```

A suíte usa bancos temporários. Cobre os 101 logins, permissões, cadastros, vínculos, compra, idempotência, concorrência, rollback, saldo, edição, cancelamento e conclusão. Os cinco testes agrupados passaram durante a implementação. Também foi verificada no navegador a compra completa, desde o login até o pedido pendente. A rodada ampliada de testes foi encerrada a pedido da equipe.

## Estrutura

- main.py: aplicativo, sessão, fila de escritas e registro de rotas.
- database/: conexão, schema e seed.
- models/: usuários, produtos, pedidos, itens e movimentações.
- routers/: autenticação, páginas, produtos, pedidos e gestão.
- services/: senhas e autorização.
- static/js/: integração das telas.
- templates/ e static/css/: visual existente.
- tests/: testes de integração isolados.
- documentacao-ia/REGISTRO_IA.md: histórico do uso de IA.

## Backup da reorganização anterior

A reorganização anterior foi registrada com o backup Nexus_Cantina_backup_antes_pagamento_2026-09-26_015624.zip na Área de Trabalho. Os novos backups do banco ficam em backups/.
