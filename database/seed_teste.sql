-- =============================================================================
-- seed_teste.sql — Nexus Cantina
-- Dados mínimos para TESTE DE SOFTWARE.
--
-- Logins prontos para usar:
--
--  TIPO          | IDENTIFICADOR              | SENHA
-- ---------------+----------------------------+--------------
--  admin         | admin@nexuscantina.edu.br  | Admin@Nexus26
--  responsavel   | resp01@teste.com           | Resp01@2026
--  responsavel   | resp02@teste.com           | Resp02@2026
--  aluno         | 2026001                    | Aluno01@2026
--  aluno         | 2026002                    | Aluno02@2026
--
-- Execute APÓS rodar schema.sql:
--   mysql -u root -p nexus_cantina < database/seed_teste.sql
-- =============================================================================

USE nexus_cantina;

-- -----------------------------------------------------------------------------
-- Limpa dados anteriores (ordem respeita FK)
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
-- ADMINISTRADOR (1)
-- Senha: Admin@Nexus26
-- =============================================================================

INSERT INTO usuarios (nome, email, matricula, senha_hash, tipo, ativo) VALUES (
    'Administrador Nexus',
    'admin@nexuscantina.edu.br',
    NULL,
    '$argon2id$v=19$m=65536,t=3,p=4$M5rJrRmSV+MSbjkagCO9pg$qZatz19sjRhF5CMj8boroxfOdZTCjG3LakJkUAoj0S8',
    'admin',
    TRUE
);
INSERT INTO administradores (usuario_id) VALUES (LAST_INSERT_ID());

-- =============================================================================
-- RESPONSÁVEIS (2)
-- =============================================================================

-- Responsável 1  — senha: Resp01@2026
INSERT INTO usuarios (nome, email, matricula, senha_hash, tipo, ativo) VALUES (
    'Ana Beatriz Silva',
    'resp01@teste.com',
    NULL,
    '$argon2id$v=19$m=65536,t=3,p=4$s9EHMtFM7QxXLYXyOCvcAA$lidOqtNG3rYEXpcSaZbI8gXz3Bvvoq+Jaqw+bDzLesM',
    'responsavel',
    TRUE
);
SET @resp1_id = LAST_INSERT_ID();
INSERT INTO responsaveis (usuario_id) VALUES (@resp1_id);

-- Responsável 2  — senha: Resp02@2026
INSERT INTO usuarios (nome, email, matricula, senha_hash, tipo, ativo) VALUES (
    'Carlos Eduardo Souza',
    'resp02@teste.com',
    NULL,
    '$argon2id$v=19$m=65536,t=3,p=4$tyauT96TBKdB1F38HRDjoQ$1U/MvSy55UhY9al09Vnv8J56jxt2Bggr4zfZlzPPJKg',
    'responsavel',
    TRUE
);
SET @resp2_id = LAST_INSERT_ID();
INSERT INTO responsaveis (usuario_id) VALUES (@resp2_id);

-- =============================================================================
-- ALUNOS (2)
-- =============================================================================

-- Aluno 1  — matrícula: 2026001  senha: Aluno01@2026
INSERT INTO usuarios (nome, email, matricula, senha_hash, tipo, ativo) VALUES (
    'Gabriel Silva',
    NULL,
    '2026001',
    '$argon2id$v=19$m=65536,t=3,p=4$faHSHal3YJNxsfzbt7ESLA$wPXggeSQrSkvrjEsX1ocA74MledHh5kf5xovcRnAZaM',
    'aluno',
    TRUE
);
SET @aluno1_id = LAST_INSERT_ID();
INSERT INTO estudantes (usuario_id, serie, turma, saldo) VALUES (@aluno1_id, '8º Ano', 'A', 50.00);

-- Aluno 2  — matrícula: 2026002  senha: Aluno02@2026
INSERT INTO usuarios (nome, email, matricula, senha_hash, tipo, ativo) VALUES (
    'Isabela Souza',
    NULL,
    '2026002',
    '$argon2id$v=19$m=65536,t=3,p=4$rQvpm5L1TwN49NpnyNZgcw$0kZtjOgCw2/seYc0ISYyXVoVB3N+l3/D5JBymKJaruI',
    'aluno',
    TRUE
);
SET @aluno2_id = LAST_INSERT_ID();
INSERT INTO estudantes (usuario_id, serie, turma, saldo) VALUES (@aluno2_id, '9º Ano', 'B', 30.00);

-- =============================================================================
-- VÍNCULOS responsável → aluno
-- =============================================================================

INSERT INTO responsavel_estudante (responsavel_id, estudante_id)
VALUES (@resp1_id, @aluno1_id),
       (@resp2_id, @aluno2_id);

-- =============================================================================
-- PRODUTOS (38)
-- =============================================================================

INSERT INTO produtos (nome, descricao, preco, quantidade_estoque, ativo, emoji) VALUES
-- Lanches
('Misto Quente',            'Pão de forma, queijo e presunto grelhados',                       5.00,  30, TRUE, '🥪'),
('Bauru',                   'Pão francês, rosbife, tomate, pepino e molho especial',            7.50,  20, TRUE, '🥖'),
('Cachorro-Quente',         'Pão, salsicha, purê, ervilha, vinagrete e mostarda',               6.00,  25, TRUE, '🌭'),
('Hambúrguer Simples',      'Pão de hambúrguer, carne bovina, alface e tomate',                 9.00,  20, TRUE, '🍔'),
('Pão na Chapa',            'Pão francês com manteiga grelhado',                                3.00,  40, TRUE, '🍞'),
('Wrap de Frango',          'Tortilha, frango desfiado, alface e molho',                        8.50,  15, TRUE, '🌯'),
-- Salgados
('Coxinha de Frango',       'Massa crocante recheada com frango e catupiry',                    4.50,  50, TRUE, '🍗'),
('Pão de Queijo (2 un.)',   'Pão de queijo mineiro assado na hora',                             4.00,  60, TRUE, '🧆'),
('Enroladinho de Salsicha', 'Massa folhada enrolada em salsicha',                               3.50,  45, TRUE, '🌀'),
('Empada de Frango',        'Massa amanteigada recheada com frango',                            4.00,  30, TRUE, '🥧'),
('Quibe Assado',            'Quibe recheado com carne e hortelã, assado no forno',              4.50,  20, TRUE, '🟤'),
('Risole de Camarão',       'Massa frita recheada com camarão e catupiry',                      5.00,  15, TRUE, '🍤'),
-- Refeições
('Marmita do Dia',          'Arroz, feijão, proteína e salada conforme o cardápio',            12.00,  30, TRUE, '🍱'),
('Macarrão ao Molho',       'Espaguete com molho de tomate e carne moída',                      9.50,  20, TRUE, '🍝'),
('Arroz com Frango',        'Arroz temperado com frango grelhado e salada',                    10.50,  20, TRUE, '🍚'),
('Omelete',                 'Omelete de três ovos com queijo e presunto',                        7.00,  15, TRUE, '🍳'),
-- Acompanhamentos
('Batata Palha (pote)',      'Batata palha crocante temperada',                                  3.00,  40, TRUE, '🥔'),
('Salada de Frutas',        'Mix de frutas frescas da temporada',                               5.50,  25, TRUE, '🍓'),
('Iogurte com Granola',     'Iogurte natural com granola e mel',                                6.00,  20, TRUE, '🥣'),
('Biscoito Recheado (pct)', 'Pacote individual de biscoito recheado',                           2.50,  80, TRUE, '🍪'),
-- Doces
('Brigadeiro',              'Brigadeiro tradicional de chocolate',                               2.00, 100, TRUE, '🍫'),
('Beijinho',                'Docinho de coco com açúcar cristal',                               2.00, 100, TRUE, '🥥'),
('Brownie',                 'Brownie de chocolate com nozes',                                    5.00,  30, TRUE, '🟫'),
('Fatia de Bolo de Cenoura','Bolo de cenoura com cobertura de chocolate',                       4.50,  20, TRUE, '🎂'),
('Fatia de Bolo Formigueiro','Bolo de chocolate com granulado',                                 4.00,  20, TRUE, '🍰'),
('Doce de Leite (pote)',    'Doce de leite cremoso com 100 g',                                  4.00,  25, TRUE, '🟡'),
('Pudim de Leite',          'Pudim tradicional com calda de caramelo',                           4.50,  18, TRUE, '🍮'),
-- Bebidas quentes
('Café (copo)',              'Café coado na hora',                                               2.00,  80, TRUE, '☕'),
('Chocolate Quente',        'Achocolatado quente com leite integral',                            4.50,  30, TRUE, '🍫'),
('Leite (copo 200 ml)',      'Leite integral gelado ou quente',                                  3.00,  40, TRUE, '🥛'),
-- Bebidas frias
('Suco de Laranja Natural', 'Suco de laranja espremido na hora (300 ml)',                        5.50,  25, TRUE, '🍊'),
('Suco de Uva (caixinha)',  'Suco de uva integral de 200 ml',                                   3.50,  50, TRUE, '🍇'),
('Água (500 ml)',            'Água mineral sem gás',                                             2.00, 100, TRUE, '💧'),
('Refrigerante (lata)',      'Refrigerante gelado — sabor conforme disponibilidade',              4.00,  40, TRUE, '🥤'),
('Isotônico (garrafa)',      'Bebida isotônica para hidratação (500 ml)',                         5.00,  20, TRUE, '🏃'),
-- Combos
('Combo Lanche + Suco',     'Misto quente + suco de laranja com desconto',                      9.00,  15, TRUE, '🎁'),
('Combo Kids',              'Coxinha + pão de queijo + suco de uva (para crianças)',             9.00,  10, TRUE, '👶'),
('Salada Vegana',           'Mix de folhas, legumes e molho de limão (vegano)',                  8.00,  10, TRUE, '🥗');
