-- Nexus Cantina
-- Estrutura inicial do banco de dados MySQL.
-- Este arquivo pode ser executado mais de uma vez sem apagar dados existentes.

CREATE DATABASE IF NOT EXISTS nexus_cantina
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE nexus_cantina;

CREATE TABLE IF NOT EXISTS responsaveis (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(120) NOT NULL,
    email VARCHAR(180) NOT NULL UNIQUE,
    senha_hash VARCHAR(255) NOT NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS alunos (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    responsavel_id BIGINT UNSIGNED NOT NULL,
    nome VARCHAR(120) NOT NULL,
    matricula VARCHAR(40) NOT NULL UNIQUE,
    senha_hash VARCHAR(255) NOT NULL,
    saldo DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    limite_gastos DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_aluno_saldo CHECK (saldo >= 0),
    CONSTRAINT chk_aluno_limite CHECK (limite_gastos >= 0),
    CONSTRAINT fk_aluno_responsavel
        FOREIGN KEY (responsavel_id) REFERENCES responsaveis (id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE INDEX idx_alunos_responsavel ON alunos (responsavel_id);

CREATE TABLE IF NOT EXISTS usuarios_cantina (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(120) NOT NULL,
    login VARCHAR(80) NOT NULL UNIQUE,
    senha_hash VARCHAR(255) NOT NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS produtos (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(120) NOT NULL,
    descricao VARCHAR(500),
    categoria VARCHAR(80),
    preco DECIMAL(10, 2) NOT NULL,
    quantidade_estoque INT UNSIGNED NOT NULL DEFAULT 0,
    imagem_url VARCHAR(500),
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_produto_preco CHECK (preco >= 0)
);

CREATE INDEX idx_produtos_ativos ON produtos (ativo);

CREATE TABLE IF NOT EXISTS pedidos (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    aluno_id BIGINT UNSIGNED NOT NULL,
    codigo_retirada CHAR(6) NOT NULL UNIQUE,
    intervalo ENUM('PRIMEIRO', 'SEGUNDO') NOT NULL,
    status ENUM('RECEBIDO', 'EM_PREPARO', 'PRONTO', 'RETIRADO') NOT NULL DEFAULT 'RECEBIDO',
    valor_total DECIMAL(10, 2) NOT NULL,
    criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    retirado_em TIMESTAMP NULL,
    CONSTRAINT chk_pedido_valor CHECK (valor_total > 0),
    CONSTRAINT fk_pedido_aluno
        FOREIGN KEY (aluno_id) REFERENCES alunos (id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE INDEX idx_pedidos_aluno ON pedidos (aluno_id);
CREATE INDEX idx_pedidos_fila ON pedidos (intervalo, status, criado_em);

CREATE TABLE IF NOT EXISTS itens_pedido (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    pedido_id BIGINT UNSIGNED NOT NULL,
    produto_id BIGINT UNSIGNED NOT NULL,
    nome_produto VARCHAR(120) NOT NULL,
    quantidade INT UNSIGNED NOT NULL,
    preco_unitario DECIMAL(10, 2) NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL,
    CONSTRAINT chk_item_quantidade CHECK (quantidade > 0),
    CONSTRAINT chk_item_preco CHECK (preco_unitario >= 0),
    CONSTRAINT chk_item_subtotal CHECK (subtotal >= 0),
    CONSTRAINT fk_item_pedido
        FOREIGN KEY (pedido_id) REFERENCES pedidos (id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_item_produto
        FOREIGN KEY (produto_id) REFERENCES produtos (id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE INDEX idx_itens_pedido ON itens_pedido (pedido_id);
CREATE INDEX idx_itens_produto ON itens_pedido (produto_id);

CREATE TABLE IF NOT EXISTS movimentacoes_saldo (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    aluno_id BIGINT UNSIGNED NOT NULL,
    responsavel_id BIGINT UNSIGNED NULL,
    pedido_id BIGINT UNSIGNED NULL,
    tipo ENUM('RECARGA', 'COMPRA', 'AJUSTE') NOT NULL,
    valor DECIMAL(10, 2) NOT NULL,
    saldo_anterior DECIMAL(10, 2) NOT NULL,
    saldo_posterior DECIMAL(10, 2) NOT NULL,
    descricao VARCHAR(255),
    criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_movimentacao_valor CHECK (valor > 0),
    CONSTRAINT chk_movimentacao_saldos CHECK (saldo_anterior >= 0 AND saldo_posterior >= 0),
    CONSTRAINT fk_movimentacao_aluno
        FOREIGN KEY (aluno_id) REFERENCES alunos (id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_movimentacao_responsavel
        FOREIGN KEY (responsavel_id) REFERENCES responsaveis (id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_movimentacao_pedido
        FOREIGN KEY (pedido_id) REFERENCES pedidos (id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE INDEX idx_movimentacoes_aluno ON movimentacoes_saldo (aluno_id, criado_em);
CREATE INDEX idx_movimentacoes_pedido ON movimentacoes_saldo (pedido_id);

