-- =============================================================================
-- seed.sql — Nexus Cantina
-- Dados iniciais: 1 admin, 25 alunos, 25 responsáveis e 38 produtos.
--
-- Senha usada em todos os usuários: Nexus@2026
-- Hash Argon2id gerado com pwdlib (mesmo algoritmo do backend).
-- Para gerar um novo hash: python -c "from pwdlib import PasswordHash; ph = PasswordHash.recommended(); print(ph.hash('Nexus@2026'))"
--
-- ATENÇÃO: troque os hashes abaixo por valores reais antes de usar em produção.
-- O placeholder $argon2id$... é apenas demonstrativo; use scripts/criar_usuario.py
-- para inserir usuários reais com hash válido.
-- =============================================================================

USE nexus_cantina;

-- -----------------------------------------------------------------------------
-- Limpa os dados anteriores (ordem respeita FK)
-- -----------------------------------------------------------------------------
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE movimentacoes_saldo;
TRUNCATE TABLE itens_pedido;
TRUNCATE TABLE pedidos;
TRUNCATE TABLE responsavel_estudante;
TRUNCATE TABLE administradores;
TRUNCATE TABLE responsaveis;
TRUNCATE TABLE estudantes;
TRUNCATE TABLE produtos;
TRUNCATE TABLE usuarios;
SET FOREIGN_KEY_CHECKS = 1;

-- =============================================================================
-- ADMINISTRADOR
-- =============================================================================

INSERT INTO usuarios (nome, email, matricula, senha_hash, tipo, ativo) VALUES
('Administrador Nexus', 'admin@nexuscantina.edu.br', NULL,
 '$argon2id$v=19$m=65536,t=3,p=4$HASH_ADMIN_PLACEHOLDER',
 'admin', TRUE);

INSERT INTO administradores (usuario_id) VALUES (LAST_INSERT_ID());

-- =============================================================================
-- RESPONSÁVEIS (25)
-- =============================================================================

INSERT INTO usuarios (nome, email, matricula, senha_hash, tipo, ativo) VALUES
('Ana Beatriz Silva',      'ana.silva@email.com',      NULL, '$argon2id$v=19$m=65536,t=3,p=4$HASH_RESP_PLACEHOLDER', 'responsavel', TRUE),
('Carlos Eduardo Souza',   'carlos.souza@email.com',   NULL, '$argon2id$v=19$m=65536,t=3,p=4$HASH_RESP_PLACEHOLDER', 'responsavel', TRUE),
('Mariana Costa Lima',     'mariana.lima@email.com',   NULL, '$argon2id$v=19$m=65536,t=3,p=4$HASH_RESP_PLACEHOLDER', 'responsavel', TRUE),
('Roberto Alves Pereira',  'roberto.pereira@email.com',NULL, '$argon2id$v=19$m=65536,t=3,p=4$HASH_RESP_PLACEHOLDER', 'responsavel', TRUE),
('Fernanda Oliveira',      'fernanda.oliveira@email.com',NULL,'$argon2id$v=19$m=65536,t=3,p=4$HASH_RESP_PLACEHOLDER','responsavel', TRUE),
('José Antonio Martins',   'jose.martins@email.com',   NULL, '$argon2id$v=19$m=65536,t=3,p=4$HASH_RESP_PLACEHOLDER', 'responsavel', TRUE),
('Patrícia Gomes',         'patricia.gomes@email.com', NULL, '$argon2id$v=19$m=65536,t=3,p=4$HASH_RESP_PLACEHOLDER', 'responsavel', TRUE),
('Ricardo Nascimento',     'ricardo.nasc@email.com',   NULL, '$argon2id$v=19$m=65536,t=3,p=4$HASH_RESP_PLACEHOLDER', 'responsavel', TRUE),
('Luciana Ferreira',       'luciana.ferreira@email.com',NULL,'$argon2id$v=19$m=65536,t=3,p=4$HASH_RESP_PLACEHOLDER','responsavel', TRUE),
('Marcos Henrique Dias',   'marcos.dias@email.com',    NULL, '$argon2id$v=19$m=65536,t=3,p=4$HASH_RESP_PLACEHOLDER', 'responsavel', TRUE),
('Cristiane Rocha',        'cristiane.rocha@email.com',NULL, '$argon2id$v=19$m=65536,t=3,p=4$HASH_RESP_PLACEHOLDER', 'responsavel', TRUE),
('Alexandre Barbosa',      'alexandre.barb@email.com', NULL, '$argon2id$v=19$m=65536,t=3,p=4$HASH_RESP_PLACEHOLDER', 'responsavel', TRUE),
('Sandra Melo',            'sandra.melo@email.com',    NULL, '$argon2id$v=19$m=65536,t=3,p=4$HASH_RESP_PLACEHOLDER', 'responsavel', TRUE),
('Paulo Sérgio Teixeira',  'paulo.teixeira@email.com', NULL, '$argon2id$v=19$m=65536,t=3,p=4$HASH_RESP_PLACEHOLDER', 'responsavel', TRUE),
('Juliana Cardoso',        'juliana.cardoso@email.com',NULL, '$argon2id$v=19$m=65536,t=3,p=4$HASH_RESP_PLACEHOLDER', 'responsavel', TRUE),
('Marcelo Ribeiro',        'marcelo.ribeiro@email.com',NULL, '$argon2id$v=19$m=65536,t=3,p=4$HASH_RESP_PLACEHOLDER', 'responsavel', TRUE),
('Tatiana Araújo',         'tatiana.araujo@email.com', NULL, '$argon2id$v=19$m=65536,t=3,p=4$HASH_RESP_PLACEHOLDER', 'responsavel', TRUE),
('Rodrigo Monteiro',       'rodrigo.mont@email.com',   NULL, '$argon2id$v=19$m=65536,t=3,p=4$HASH_RESP_PLACEHOLDER', 'responsavel', TRUE),
('Adriana Pinto',          'adriana.pinto@email.com',  NULL, '$argon2id$v=19$m=65536,t=3,p=4$HASH_RESP_PLACEHOLDER', 'responsavel', TRUE),
('Leandro Castro',         'leandro.castro@email.com', NULL, '$argon2id$v=19$m=65536,t=3,p=4$HASH_RESP_PLACEHOLDER', 'responsavel', TRUE),
('Simone Freitas',         'simone.freitas@email.com', NULL, '$argon2id$v=19$m=65536,t=3,p=4$HASH_RESP_PLACEHOLDER', 'responsavel', TRUE),
('Fábio Correia',          'fabio.correia@email.com',  NULL, '$argon2id$v=19$m=65536,t=3,p=4$HASH_RESP_PLACEHOLDER', 'responsavel', TRUE),
('Renata Campos',          'renata.campos@email.com',  NULL, '$argon2id$v=19$m=65536,t=3,p=4$HASH_RESP_PLACEHOLDER', 'responsavel', TRUE),
('Wagner Nunes',           'wagner.nunes@email.com',   NULL, '$argon2id$v=19$m=65536,t=3,p=4$HASH_RESP_PLACEHOLDER', 'responsavel', TRUE),
('Eliane Moura',           'eliane.moura@email.com',   NULL, '$argon2id$v=19$m=65536,t=3,p=4$HASH_RESP_PLACEHOLDER', 'responsavel', TRUE);

-- Registra perfis de responsável
INSERT INTO responsaveis (usuario_id)
SELECT id FROM usuarios WHERE tipo = 'responsavel';

-- =============================================================================
-- ALUNOS (25)
-- =============================================================================

INSERT INTO usuarios (nome, email, matricula, senha_hash, tipo, ativo) VALUES
('Gabriel Silva',       NULL, '2026001', '$argon2id$v=19$m=65536,t=3,p=4$HASH_ALUNO_PLACEHOLDER', 'aluno', TRUE),
('Isabela Souza',       NULL, '2026002', '$argon2id$v=19$m=65536,t=3,p=4$HASH_ALUNO_PLACEHOLDER', 'aluno', TRUE),
('Pedro Costa',         NULL, '2026003', '$argon2id$v=19$m=65536,t=3,p=4$HASH_ALUNO_PLACEHOLDER', 'aluno', TRUE),
('Laura Lima',          NULL, '2026004', '$argon2id$v=19$m=65536,t=3,p=4$HASH_ALUNO_PLACEHOLDER', 'aluno', TRUE),
('Matheus Oliveira',    NULL, '2026005', '$argon2id$v=19$m=65536,t=3,p=4$HASH_ALUNO_PLACEHOLDER', 'aluno', TRUE),
('Beatriz Alves',       NULL, '2026006', '$argon2id$v=19$m=65536,t=3,p=4$HASH_ALUNO_PLACEHOLDER', 'aluno', TRUE),
('Lucas Pereira',       NULL, '2026007', '$argon2id$v=19$m=65536,t=3,p=4$HASH_ALUNO_PLACEHOLDER', 'aluno', TRUE),
('Valentina Gomes',     NULL, '2026008', '$argon2id$v=19$m=65536,t=3,p=4$HASH_ALUNO_PLACEHOLDER', 'aluno', TRUE),
('Enzo Martins',        NULL, '2026009', '$argon2id$v=19$m=65536,t=3,p=4$HASH_ALUNO_PLACEHOLDER', 'aluno', TRUE),
('Sofia Ferreira',      NULL, '2026010', '$argon2id$v=19$m=65536,t=3,p=4$HASH_ALUNO_PLACEHOLDER', 'aluno', TRUE),
('Miguel Nascimento',   NULL, '2026011', '$argon2id$v=19$m=65536,t=3,p=4$HASH_ALUNO_PLACEHOLDER', 'aluno', TRUE),
('Alice Dias',          NULL, '2026012', '$argon2id$v=19$m=65536,t=3,p=4$HASH_ALUNO_PLACEHOLDER', 'aluno', TRUE),
('Arthur Rocha',        NULL, '2026013', '$argon2id$v=19$m=65536,t=3,p=4$HASH_ALUNO_PLACEHOLDER', 'aluno', TRUE),
('Heloísa Barbosa',     NULL, '2026014', '$argon2id$v=19$m=65536,t=3,p=4$HASH_ALUNO_PLACEHOLDER', 'aluno', TRUE),
('Nicolas Melo',        NULL, '2026015', '$argon2id$v=19$m=65536,t=3,p=4$HASH_ALUNO_PLACEHOLDER', 'aluno', TRUE),
('Manuela Teixeira',    NULL, '2026016', '$argon2id$v=19$m=65536,t=3,p=4$HASH_ALUNO_PLACEHOLDER', 'aluno', TRUE),
('Davi Cardoso',        NULL, '2026017', '$argon2id$v=19$m=65536,t=3,p=4$HASH_ALUNO_PLACEHOLDER', 'aluno', TRUE),
('Lorena Ribeiro',      NULL, '2026018', '$argon2id$v=19$m=65536,t=3,p=4$HASH_ALUNO_PLACEHOLDER', 'aluno', TRUE),
('Samuel Araújo',       NULL, '2026019', '$argon2id$v=19$m=65536,t=3,p=4$HASH_ALUNO_PLACEHOLDER', 'aluno', TRUE),
('Lívia Monteiro',      NULL, '2026020', '$argon2id$v=19$m=65536,t=3,p=4$HASH_ALUNO_PLACEHOLDER', 'aluno', TRUE),
('Felipe Pinto',        NULL, '2026021', '$argon2id$v=19$m=65536,t=3,p=4$HASH_ALUNO_PLACEHOLDER', 'aluno', TRUE),
('Melissa Castro',      NULL, '2026022', '$argon2id$v=19$m=65536,t=3,p=4$HASH_ALUNO_PLACEHOLDER', 'aluno', TRUE),
('Rafael Freitas',      NULL, '2026023', '$argon2id$v=19$m=65536,t=3,p=4$HASH_ALUNO_PLACEHOLDER', 'aluno', TRUE),
('Camila Correia',      NULL, '2026024', '$argon2id$v=19$m=65536,t=3,p=4$HASH_ALUNO_PLACEHOLDER', 'aluno', TRUE),
('Gustavo Campos',      NULL, '2026025', '$argon2id$v=19$m=65536,t=3,p=4$HASH_ALUNO_PLACEHOLDER', 'aluno', TRUE);

-- Registra perfis de estudante com saldo inicial de R$ 20,00
INSERT INTO estudantes (usuario_id, serie, turma, saldo)
SELECT
    u.id,
    CASE (u.id % 3)
        WHEN 0 THEN '7º Ano'
        WHEN 1 THEN '8º Ano'
        ELSE '9º Ano'
    END,
    CASE (u.id % 4)
        WHEN 0 THEN 'A'
        WHEN 1 THEN 'B'
        WHEN 2 THEN 'C'
        ELSE 'D'
    END,
    20.00
FROM usuarios u
WHERE u.tipo = 'aluno';

-- =============================================================================
-- VÍNCULOS responsável → aluno (cada responsável vincula a um aluno)
-- =============================================================================

INSERT INTO responsavel_estudante (responsavel_id, estudante_id)
SELECT r.usuario_id, e.usuario_id
FROM responsaveis r
JOIN estudantes e ON e.usuario_id = (
    -- emparelha pelo índice de criação (responsável 1 ↔ aluno 1, etc.)
    SELECT u2.id
    FROM usuarios u2
    WHERE u2.tipo = 'aluno'
    ORDER BY u2.id
    LIMIT 1 OFFSET (
        (SELECT COUNT(*) FROM responsaveis r2 WHERE r2.usuario_id < r.usuario_id)
    )
);

-- =============================================================================
-- PRODUTOS (38)
-- =============================================================================

INSERT INTO produtos (nome, descricao, preco, quantidade_estoque, ativo, emoji) VALUES
-- Lanches
('Misto Quente',           'Pão de forma, queijo e presunto grelhados',                       5.00,  30, TRUE, '🥪'),
('Bauru',                  'Pão francês, rosbife, tomate, pepino e molho especial',            7.50,  20, TRUE, '🥖'),
('Cachorro-Quente',        'Pão, salsicha, purê, ervilha, vinagrete e mostarda',               6.00,  25, TRUE, '🌭'),
('Hambúrguer Simples',     'Pão de hambúrguer, carne bovina, alface e tomate',                 9.00,  20, TRUE, '🍔'),
('Pão na Chapa',           'Pão francês com manteiga grelhado',                                3.00,  40, TRUE, '🍞'),
('Wrap de Frango',         'Tortilha, frango desfiado, alface e molho',                        8.50,  15, TRUE, '🌯'),
-- Salgados e petiscos
('Coxinha de Frango',      'Massa crocante recheada com frango e catupiry',                    4.50,  50, TRUE, '🍗'),
('Pão de Queijo (2 un.)', 'Pão de queijo mineiro assado na hora',                             4.00,  60, TRUE, '🧆'),
('Enroladinho de Salsicha','Massa folhada enrolada em salsicha',                               3.50,  45, TRUE, '🌀'),
('Empada de Frango',       'Massa amanteigada recheada com frango',                            4.00,  30, TRUE, '🥧'),
('Quibe Assado',           'Quibe recheado com carne e hortelã, assado no forno',              4.50,  20, TRUE, '🟤'),
('Risole de Camarão',      'Massa frita recheada com camarão e catupiry',                      5.00,  15, TRUE, '🍤'),
-- Refeições
('Marmita do Dia',         'Arroz, feijão, proteína e salada conforme o cardápio',            12.00,  30, TRUE, '🍱'),
('Macarrão ao Molho',      'Espaguete com molho de tomate e carne moída',                      9.50,  20, TRUE, '🍝'),
('Arroz com Frango',       'Arroz temperado com frango grelhado e salada',                    10.50,  20, TRUE, '🍚'),
('Omelete',                'Omelete de três ovos com queijo e presunto',                        7.00,  15, TRUE, '🍳'),
-- Acompanhamentos
('Batata Palha (pote)',     'Batata palha crocante temperada',                                  3.00,  40, TRUE, '🥔'),
('Salada de Frutas',       'Mix de frutas frescas da temporada',                               5.50,  25, TRUE, '🍓'),
('Iogurte com Granola',    'Iogurte natural com granola e mel',                                6.00,  20, TRUE, '🥣'),
('Biscoito Recheado (pct)','Pacote individual de biscoito recheado',                           2.50,  80, TRUE, '🍪'),
-- Doces
('Brigadeiro',             'Brigadeiro tradicional de chocolate',                               2.00, 100, TRUE, '🍫'),
('Beijinho',               'Docinho de coco com açúcar cristal',                               2.00, 100, TRUE, '🥥'),
('Brownie',                'Brownie de chocolate com nozes',                                    5.00,  30, TRUE, '🟫'),
('Fatia de Bolo de Cenoura','Bolo de cenoura com cobertura de chocolate',                       4.50,  20, TRUE, '🎂'),
('Fatia de Bolo Formigueiro','Bolo de chocolate com granulado',                                4.00,  20, TRUE, '🍰'),
('Doce de Leite (pote)',   'Doce de leite cremoso com 100 g',                                  4.00,  25, TRUE, '🟡'),
('Pudim de Leite',         'Pudim tradicional com calda de caramelo',                           4.50,  18, TRUE, '🍮'),
-- Bebidas quentes
('Café (copo)',             'Café coado na hora',                                               2.00,  80, TRUE, '☕'),
('Chocolate Quente',       'Achocolatado quente com leite integral',                            4.50,  30, TRUE, '🍫'),
('Leite (copo 200 ml)',     'Leite integral gelado ou quente',                                  3.00,  40, TRUE, '🥛'),
-- Bebidas frias
('Suco de Laranja Natural','Suco de laranja espremido na hora (300 ml)',                        5.50,  25, TRUE, '🍊'),
('Suco de Uva (caixinha)', 'Suco de uva integral de 200 ml',                                   3.50,  50, TRUE, '🍇'),
('Água (500 ml)',           'Água mineral sem gás',                                             2.00, 100, TRUE, '💧'),
('Refrigerante (lata)',     'Refrigerante gelado — sabor conforme disponibilidade',              4.00,  40, TRUE, '🥤'),
('Isotônico (garrafa)',     'Bebida isotônica para hidratação (500 ml)',                         5.00,  20, TRUE, '🏃'),
-- Itens especiais / promoção
('Combo Lanche + Suco',    'Misto quente + suco de laranja com desconto',                      9.00,  15, TRUE, '🎁'),
('Combo Kids',             'Coxinha + pão de queijo + suco de uva (para crianças)',             9.00,  10, TRUE, '👶'),
('Salada Vegana',          'Mix de folhas, legumes e molho de limão (vegano)',                  8.00,  10, TRUE, '🥗');
