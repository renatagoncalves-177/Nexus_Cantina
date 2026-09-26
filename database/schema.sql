CREATE DATABASE IF NOT EXISTS nexus_cantina
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE nexus_cantina;

CREATE TABLE usuarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(120) NOT NULL,
    email VARCHAR(160) UNIQUE,
    matricula VARCHAR(30) UNIQUE,
    senha_hash VARCHAR(255) NOT NULL,
    tipo ENUM('aluno', 'responsavel', 'admin') NOT NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT chk_identificador_usuario CHECK (
        (tipo = 'aluno' AND matricula IS NOT NULL)
        OR
        (tipo IN ('responsavel', 'admin') AND email IS NOT NULL)
    )
);

CREATE TABLE estudantes (
    usuario_id INT PRIMARY KEY,
    serie VARCHAR(30),
    turma VARCHAR(30),
    saldo DECIMAL(10,2) NOT NULL DEFAULT 0.00,

    CONSTRAINT chk_limite_saldo CHECK (saldo >= -250.00),
    CONSTRAINT fk_estudante_usuario
        FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
        ON DELETE CASCADE
);

CREATE TABLE responsaveis (
    usuario_id INT PRIMARY KEY,

    CONSTRAINT fk_responsavel_usuario
        FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
        ON DELETE CASCADE
);

CREATE TABLE administradores (
    usuario_id INT PRIMARY KEY,

    CONSTRAINT fk_administrador_usuario
        FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
        ON DELETE CASCADE
);

CREATE TABLE responsavel_estudante (
    responsavel_id INT NOT NULL,
    estudante_id INT NOT NULL,
    PRIMARY KEY (responsavel_id, estudante_id),

    CONSTRAINT fk_vinculo_responsavel
        FOREIGN KEY (responsavel_id) REFERENCES responsaveis(usuario_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_vinculo_estudante
        FOREIGN KEY (estudante_id) REFERENCES estudantes(usuario_id)
        ON DELETE CASCADE
);

CREATE TABLE produtos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(120) NOT NULL,
    descricao VARCHAR(255),
    preco DECIMAL(10,2) NOT NULL,
    quantidade_estoque INT NOT NULL DEFAULT 0,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT chk_preco_produto CHECK (preco >= 0),
    CONSTRAINT chk_estoque_produto CHECK (quantidade_estoque >= 0)
);

CREATE TABLE pedidos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    estudante_id INT NOT NULL,
    data_pedido DATE NOT NULL,
    intervalo ENUM('primeiro', 'segundo') NOT NULL,
    status ENUM('pendente', 'pronto', 'concluido', 'cancelado') NOT NULL DEFAULT 'pendente',
    total DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    intervalo_bloqueado VARCHAR(20)
        GENERATED ALWAYS AS (
            CASE WHEN status <> 'cancelado' THEN intervalo ELSE NULL END
        ) STORED,

    CONSTRAINT chk_total_pedido CHECK (total >= 0),
    CONSTRAINT uq_pedido_intervalo_dia
        UNIQUE (estudante_id, data_pedido, intervalo_bloqueado),
    CONSTRAINT fk_pedido_estudante
        FOREIGN KEY (estudante_id) REFERENCES estudantes(usuario_id)
        ON DELETE RESTRICT
);

CREATE TABLE itens_pedido (
    id INT PRIMARY KEY AUTO_INCREMENT,
    pedido_id INT NOT NULL,
    produto_id INT NOT NULL,
    quantidade INT NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL,

    CONSTRAINT chk_quantidade_item CHECK (quantidade > 0),
    CONSTRAINT chk_preco_item CHECK (preco_unitario >= 0),
    CONSTRAINT uq_produto_por_pedido UNIQUE (pedido_id, produto_id),
    CONSTRAINT fk_item_pedido
        FOREIGN KEY (pedido_id) REFERENCES pedidos(id)
        ON DELETE CASCADE,
    CONSTRAINT fk_item_produto
        FOREIGN KEY (produto_id) REFERENCES produtos(id)
        ON DELETE RESTRICT
);

CREATE TABLE movimentacoes_saldo (
    id INT PRIMARY KEY AUTO_INCREMENT,
    estudante_id INT NOT NULL,
    pedido_id INT,
    tipo ENUM('recarga', 'debito', 'estorno') NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    saldo_apos DECIMAL(10,2) NOT NULL,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_valor_movimentacao CHECK (valor > 0),
    CONSTRAINT chk_saldo_apos_movimentacao CHECK (saldo_apos >= -250.00),
    CONSTRAINT fk_movimentacao_estudante
        FOREIGN KEY (estudante_id) REFERENCES estudantes(usuario_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_movimentacao_pedido
        FOREIGN KEY (pedido_id) REFERENCES pedidos(id)
        ON DELETE RESTRICT
);

CREATE INDEX idx_pedidos_fila
    ON pedidos (data_pedido, status, intervalo);

CREATE INDEX idx_movimentacoes_estudante
    ON movimentacoes_saldo (estudante_id, criado_em);

-- Totais, estoque, saldo e estornos devem ser alterados em uma transação no
-- backend. Não há triggers para evitar regras duplicadas ou execuções parciais.