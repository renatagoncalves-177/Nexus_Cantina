# Nexus_Cantina
Sistema web da Nexus Cantina, com telas para alunos e responsáveis.

## Estrutura principal

```text
paginas/
├── html/
├── script/
└── styles/
```

## Correções realizadas

- A pasta de JavaScript foi padronizada como `paginas/script`.
- Os arquivos HTML agora usam caminhos no formato `../script/arquivo.js`.
- O login do responsável redireciona para `telaresponsavel.html` após a
  validação bem-sucedida.
- A tela do responsável usa o arquivo
  `../styles/telaresponsavel.css`, sem acento no nome.
- O botão **Sair** da tela do responsável retorna para
  `loginresponsavel.html`.
- A referência inexistente a `telaaluno.js` foi removida de
  `telaaluno.html`.

## Execução

Abra um dos arquivos de login no navegador:

- `paginas/html/loginaluno.html`
- `paginas/html/loginresponsavel.html`
