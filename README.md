# Nexus_Cantina

Projeto web da Nexus Cantina estruturado para usar FastAPI e templates HTML.

## Estrutura

```text
Nexus_Cantina/
├── main.py
├── database/
│   ├── database.py
│   └── schema.sql
├── models/
│   └── usuario.py
├── schemas/
│   └── auth.py
├── routers/
│   ├── auth.py
│   └── paginas.py
├── services/
│   └── auth.py
├── scripts/
│   ├── criar_usuario.py
│   └── criar_usuarios_teste.py
├── templates/
│   ├── pagamento.html
│   ├── alertapagamento.html
│   └── demais páginas HTML
└── static/
    ├── css/
    └── js/
```

## Executar com FastAPI

1. Crie o banco MySQL executando `database/schema.sql`.
2. Copie `.env.example` para `.env` e informe sua conexão e uma chave secreta.
3. Crie e ative o ambiente virtual, instale as dependências e inicie o FastAPI.
   Neste computador, o `.venv` já foi criado e as dependências já estão
   instaladas; em outro computador, execute todos os comandos:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install -r requirements.txt
uvicorn main:app --reload
```

Depois abra [http://localhost:8000](http://localhost:8000).

O login deve ser testado pelo FastAPI, e não abrindo os HTMLs diretamente.
Para criar o primeiro usuário com senha protegida por Argon2, execute:

```bash
python scripts/criar_usuario.py
```

### Contas básicas de teste

Depois que o MySQL e o arquivo `.env` estiverem configurados, crie ou redefina
as três contas de desenvolvimento com:

```powershell
python scripts/criar_usuarios_teste.py --confirmar
```

| Perfil | Identificador |
| --- | --- |
| Aluno | Matrícula `aluno01` |
| Responsável | `resp01@teste.com` |
| Administrador | `admin01@teste.com` |

A senha comum é `1234`. Ela pode ser alterada pela variável
`NEXUS_TEST_PASSWORD` no `.env`. Essas contas são apenas para desenvolvimento
e não são criadas automaticamente.

Enquanto o banco não estiver pronto, o `.env` local pode usar
`ENABLE_TEST_USERS=true`. Nesse modo, as mesmas três contas autenticam em
memória, sem gravar nada. Quando o banco estiver integrado, altere para
`ENABLE_TEST_USERS=false` e execute o script acima para criar as contas no
banco, se elas ainda forem necessárias.

O login precisa ser aberto pelo FastAPI em
[http://127.0.0.1:8000](http://127.0.0.1:8000). O Live Server na porta `5500`
serve apenas arquivos estáticos e não possui a rota `/api/auth/login`.

O navegador mantém uma única sessão ativa para o endereço local. Se outro
perfil entrar em uma segunda aba, as abas antigas passam a encaminhar para a
área do perfil mais recente. Nas telas compartilhadas, como produtos,
carrinho e pagamento, os links de início e saída também se adaptam ao perfil
da sessão.

O aluno entra com matrícula e senha. Responsáveis e administradores entram com
e-mail e senha. A sessão fica em um cookie assinado, `HttpOnly`, com duração de
oito horas. As páginas internas verificam o perfil antes de serem exibidas.

Ao preencher um e-mail válido nas telas de responsável e administrador, o
navegador mostra um alerta que simula o envio de uma mensagem. Nenhum e-mail
real é enviado nesta etapa.

## Fluxo do pagamento

As regras abaixo continuam definidas no frontend, mas a confirmação está
temporariamente desabilitada até saldo e pedidos serem conectados ao banco.

1. O aluno adiciona produtos ao carrinho.
2. No carrinho, escolhe o primeiro ou o segundo intervalo.
3. A tela de pagamento mostra o resumo do pedido.
4. Ao clicar em **Confirmar pedido**, aparece a pergunta **Tem certeza?**.
5. Depois da confirmação, a tela de pedido realizado é exibida.

Enquanto o pedido ainda não estiver concluído, o aluno pode alterá-lo ou
cancelá-lo. Nesses casos, o saldo é devolvido e o intervalo é liberado. Depois
que a cantina marcar o pedido como concluído, ele não poderá mais ser alterado
ou cancelado, e o intervalo continuará bloqueado até o dia seguinte.

O saldo pode ficar negativo até o limite de `R$ 250,00`. A revisão do pedido
avisa quando o saldo ficará negativo ou chegar exatamente ao limite e impede
uma confirmação que ultrapasse esse valor.

Por enquanto, esse bloqueio fica salvo no `localStorage` do navegador. Quando
o banco de dados estiver conectado, a mesma regra também deverá ser validada
no backend para funcionar entre aparelhos diferentes.

## Etapa atual da integração

- Os três logins já consultam a tabela `usuarios`.
- As senhas são comparadas por hash; senhas originais não ficam no banco.
- As áreas de aluno, responsável e administrador exigem a sessão e o perfil
  correspondentes.
- Os dados fictícios iniciais foram removidos.
- Produtos, pedidos, alunos vinculados, saldos e recargas ainda exibem estados
  vazios até que suas APIs sejam conectadas ao banco.
- O SQL já separa produtos de itens do pedido, registra movimentações de saldo
  e representa pedidos pendentes, prontos, concluídos ou cancelados.

## Telas que dependem do banco

Os logins já possuem backend, mas só autenticam depois que o banco, o `.env` e
ao menos um usuário estiverem configurados. As telas abaixo estão montadas e
aguardam os respectivos endpoints:

| Área | Telas | Dados necessários |
| --- | --- | --- |
| Login | `loginaluno`, `loginresponsavel`, `loginadmin` | usuários, perfis e senhas em hash |
| Aluno | `telaaluno`, `pedidoaluno`, `carrinho`, `pagamento`, `alertapagamento` | saldo, produtos, estoque, pedidos e itens |
| Responsável | `telaresponsavel`, `adicionarsaldo` | alunos vinculados, saldo e movimentações |
| Cantina | `telaadmin`, `alunosdevendo` | fila de pedidos, saldos e recebimentos |
| Novos cadastros | `gerenciaralunos`, `gerenciarprodutos`, `vincularaluno` | alunos, produtos e vínculos |
| Consulta | `detalhepedido` | pedido, itens, aluno e situação |

As quatro telas novas já fazem chamadas isoladas para `/api/alunos`,
`/api/produtos`, `/api/responsaveis`, `/api/vinculos` e `/api/pedidos/{id}`.
Enquanto esses endpoints não existirem, elas exibem um aviso de integração
pendente e não usam dados fictícios. Assim, o futuro backend pode ser ligado
sem refazer o HTML.

As imagens e os demais elementos visuais continuam sendo produzidos pela
equipe no Figma. Nenhuma imagem nova foi criada pela IA nesta etapa.

## Backup da reorganização anterior

Antes desta reorganização foi criado um ZIP completo na Área de Trabalho:

```text
Nexus_Cantina_backup_antes_pagamento_2026-09-26_015624.zip
```
