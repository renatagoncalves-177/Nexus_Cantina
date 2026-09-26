-- SQLite de desenvolvimento. Gerado a partir dos modelos SQLAlchemy.
PRAGMA foreign_keys=ON;
CREATE TABLE IF NOT EXISTS produtos (
	id INTEGER NOT NULL, 
	nome VARCHAR(120) NOT NULL, 
	descricao VARCHAR(255), 
	preco NUMERIC(10, 2) NOT NULL, 
	estoque INTEGER NOT NULL, 
	categoria VARCHAR(80) NOT NULL, 
	imagem_url VARCHAR(255), 
	ativo BOOLEAN NOT NULL, 
	emoji VARCHAR(10), 
	criado_em DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL, 
	atualizado_em DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL, 
	PRIMARY KEY (id), 
	CONSTRAINT chk_preco_produto CHECK (preco >= 0), 
	CONSTRAINT chk_estoque_produto CHECK (estoque >= 0)
)

;

CREATE TABLE IF NOT EXISTS usuarios (
	id INTEGER NOT NULL, 
	nome VARCHAR(120) NOT NULL, 
	email VARCHAR(160), 
	matricula VARCHAR(30), 
	senha_hash VARCHAR(255) NOT NULL, 
	tipo VARCHAR(20) NOT NULL, 
	ativo BOOLEAN NOT NULL, 
	criado_em DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL, 
	PRIMARY KEY (id)
)

;

CREATE TABLE IF NOT EXISTS administradores (
	usuario_id INTEGER NOT NULL, 
	PRIMARY KEY (usuario_id), 
	FOREIGN KEY(usuario_id) REFERENCES usuarios (id) ON DELETE CASCADE
)

;

CREATE TABLE IF NOT EXISTS responsaveis (
	usuario_id INTEGER NOT NULL, 
	PRIMARY KEY (usuario_id), 
	FOREIGN KEY(usuario_id) REFERENCES usuarios (id) ON DELETE CASCADE
)

;

CREATE TABLE IF NOT EXISTS estudantes (
	usuario_id INTEGER NOT NULL, 
	serie VARCHAR(30), 
	turma VARCHAR(30), 
	saldo NUMERIC(10, 2) NOT NULL, 
	responsavel_id INTEGER, 
	PRIMARY KEY (usuario_id), 
	CONSTRAINT chk_limite_saldo CHECK (saldo >= -250.00), 
	FOREIGN KEY(usuario_id) REFERENCES usuarios (id) ON DELETE CASCADE, 
	UNIQUE (responsavel_id), 
	FOREIGN KEY(responsavel_id) REFERENCES responsaveis (usuario_id)
)

;

CREATE TABLE IF NOT EXISTS pedidos (
	id INTEGER NOT NULL, 
	estudante_id INTEGER NOT NULL, 
	data_pedido DATE NOT NULL, 
	intervalo VARCHAR(30) NOT NULL, 
	intervalo_ativo VARCHAR(30), 
	status VARCHAR(20) NOT NULL, 
	total NUMERIC(10, 2) NOT NULL, 
	criado_em DATETIME NOT NULL, 
	chave VARCHAR(80) NOT NULL, 
	PRIMARY KEY (id), 
	UNIQUE (estudante_id, data_pedido, intervalo_ativo), 
	CHECK (total >= 0), 
	CHECK (status IN ('pendente', 'pronto', 'concluido', 'cancelado')), 
	FOREIGN KEY(estudante_id) REFERENCES estudantes (usuario_id), 
	UNIQUE (chave)
)

;

CREATE TABLE IF NOT EXISTS itens_pedido (
	id INTEGER NOT NULL, 
	pedido_id INTEGER NOT NULL, 
	produto_id INTEGER NOT NULL, 
	nome VARCHAR(120) NOT NULL, 
	quantidade INTEGER NOT NULL, 
	preco NUMERIC(10, 2) NOT NULL, 
	PRIMARY KEY (id), 
	UNIQUE (pedido_id, produto_id), 
	CHECK (quantidade > 0), 
	FOREIGN KEY(pedido_id) REFERENCES pedidos (id), 
	FOREIGN KEY(produto_id) REFERENCES produtos (id)
)

;

CREATE TABLE IF NOT EXISTS movimentacoes_saldo (
	id INTEGER NOT NULL, 
	estudante_id INTEGER NOT NULL, 
	pedido_id INTEGER, 
	tipo VARCHAR(20) NOT NULL, 
	valor NUMERIC(10, 2) NOT NULL, 
	saldo_apos NUMERIC(10, 2) NOT NULL, 
	criado_em DATETIME NOT NULL, 
	chave VARCHAR(100) NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(estudante_id) REFERENCES estudantes (usuario_id), 
	FOREIGN KEY(pedido_id) REFERENCES pedidos (id), 
	UNIQUE (chave)
)

;
CREATE UNIQUE INDEX IF NOT EXISTS ix_usuarios_email ON usuarios (email);
CREATE INDEX IF NOT EXISTS ix_usuarios_tipo ON usuarios (tipo);
CREATE UNIQUE INDEX IF NOT EXISTS ix_usuarios_matricula ON usuarios (matricula);
