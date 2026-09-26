-- SQLite: 1 administrador, 50 alunos, 50 responsáveis e 38 produtos fictícios.
-- Exclusivo para desenvolvimento. Senha inicial das contas: 12345678 (Argon2id).
-- Reexecução preserva registros existentes; não apaga nem repõe saldos/estoques.
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

BEGIN IMMEDIATE;
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 1, 'Administrador Nexus', 'admin@nexuscantina.com', 'admin', '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'admin', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=1);
INSERT INTO administradores (usuario_id) SELECT 1 WHERE NOT EXISTS (SELECT 1 FROM administradores WHERE usuario_id=1);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 101, 'Mariana Silva', 'responsavel01@teste.example', NULL, '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'responsavel', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=101);
INSERT INTO responsaveis (usuario_id) SELECT 101 WHERE NOT EXISTS (SELECT 1 FROM responsaveis WHERE usuario_id=101);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 201, 'Ana Clara Silva', 'aluno01@teste.example', 'aluno01', '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'aluno', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=201);
INSERT INTO estudantes (usuario_id, serie, turma, saldo, responsavel_id) SELECT 201, '6º Ano', 'A', 50, 101 WHERE NOT EXISTS (SELECT 1 FROM estudantes WHERE usuario_id=201);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 102, 'Roberto Souza', 'responsavel02@teste.example', NULL, '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'responsavel', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=102);
INSERT INTO responsaveis (usuario_id) SELECT 102 WHERE NOT EXISTS (SELECT 1 FROM responsaveis WHERE usuario_id=102);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 202, 'Bruno Henrique Souza', 'aluno02@teste.example', 'aluno02', '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'aluno', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=202);
INSERT INTO estudantes (usuario_id, serie, turma, saldo, responsavel_id) SELECT 202, '7º Ano', 'A', 50, 102 WHERE NOT EXISTS (SELECT 1 FROM estudantes WHERE usuario_id=202);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 103, 'Patricia Santos', 'responsavel03@teste.example', NULL, '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'responsavel', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=103);
INSERT INTO responsaveis (usuario_id) SELECT 103 WHERE NOT EXISTS (SELECT 1 FROM responsaveis WHERE usuario_id=103);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 203, 'Carolina Oliveira Santos', 'aluno03@teste.example', 'aluno03', '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'aluno', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=203);
INSERT INTO estudantes (usuario_id, serie, turma, saldo, responsavel_id) SELECT 203, '8º Ano', 'A', 50, 103 WHERE NOT EXISTS (SELECT 1 FROM estudantes WHERE usuario_id=203);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 104, 'Carlos Lima', 'responsavel04@teste.example', NULL, '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'responsavel', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=104);
INSERT INTO responsaveis (usuario_id) SELECT 104 WHERE NOT EXISTS (SELECT 1 FROM responsaveis WHERE usuario_id=104);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 204, 'Daniel Costa Lima', 'aluno04@teste.example', 'aluno04', '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'aluno', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=204);
INSERT INTO estudantes (usuario_id, serie, turma, saldo, responsavel_id) SELECT 204, '9º Ano', 'A', 50, 104 WHERE NOT EXISTS (SELECT 1 FROM estudantes WHERE usuario_id=204);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 105, 'Fernanda Pereira', 'responsavel05@teste.example', NULL, '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'responsavel', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=105);
INSERT INTO responsaveis (usuario_id) SELECT 105 WHERE NOT EXISTS (SELECT 1 FROM responsaveis WHERE usuario_id=105);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 205, 'Eduarda Alves Pereira', 'aluno05@teste.example', 'aluno05', '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'aluno', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=205);
INSERT INTO estudantes (usuario_id, serie, turma, saldo, responsavel_id) SELECT 205, '1º Ano EM', 'A', 50, 105 WHERE NOT EXISTS (SELECT 1 FROM estudantes WHERE usuario_id=205);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 106, 'Ricardo Martins', 'responsavel06@teste.example', NULL, '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'responsavel', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=106);
INSERT INTO responsaveis (usuario_id) SELECT 106 WHERE NOT EXISTS (SELECT 1 FROM responsaveis WHERE usuario_id=106);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 206, 'Felipe Rodrigues Martins', 'aluno06@teste.example', 'aluno06', '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'aluno', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=206);
INSERT INTO estudantes (usuario_id, serie, turma, saldo, responsavel_id) SELECT 206, '2º Ano EM', 'A', 50, 106 WHERE NOT EXISTS (SELECT 1 FROM estudantes WHERE usuario_id=206);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 107, 'Luciana Rocha', 'responsavel07@teste.example', NULL, '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'responsavel', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=107);
INSERT INTO responsaveis (usuario_id) SELECT 107 WHERE NOT EXISTS (SELECT 1 FROM responsaveis WHERE usuario_id=107);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 207, 'Gabriela Ferreira Rocha', 'aluno07@teste.example', 'aluno07', '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'aluno', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=207);
INSERT INTO estudantes (usuario_id, serie, turma, saldo, responsavel_id) SELECT 207, '3º Ano EM', 'A', 50, 107 WHERE NOT EXISTS (SELECT 1 FROM estudantes WHERE usuario_id=207);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 108, 'Eduardo Ribeiro', 'responsavel08@teste.example', NULL, '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'responsavel', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=108);
INSERT INTO responsaveis (usuario_id) SELECT 108 WHERE NOT EXISTS (SELECT 1 FROM responsaveis WHERE usuario_id=108);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 208, 'Gustavo Almeida Ribeiro', 'aluno08@teste.example', 'aluno08', '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'aluno', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=208);
INSERT INTO estudantes (usuario_id, serie, turma, saldo, responsavel_id) SELECT 208, '6º Ano', 'A', 50, 108 WHERE NOT EXISTS (SELECT 1 FROM estudantes WHERE usuario_id=208);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 109, 'Sandra Costa', 'responsavel09@teste.example', NULL, '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'responsavel', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=109);
INSERT INTO responsaveis (usuario_id) SELECT 109 WHERE NOT EXISTS (SELECT 1 FROM responsaveis WHERE usuario_id=109);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 209, 'Helena Barbosa Costa', 'aluno09@teste.example', 'aluno09', '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'aluno', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=209);
INSERT INTO estudantes (usuario_id, serie, turma, saldo, responsavel_id) SELECT 209, '7º Ano', 'A', 50, 109 WHERE NOT EXISTS (SELECT 1 FROM estudantes WHERE usuario_id=209);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 110, 'Marcos Dias', 'responsavel10@teste.example', NULL, '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'responsavel', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=110);
INSERT INTO responsaveis (usuario_id) SELECT 110 WHERE NOT EXISTS (SELECT 1 FROM responsaveis WHERE usuario_id=110);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 210, 'Igor Nascimento Dias', 'aluno10@teste.example', 'aluno10', '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'aluno', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=210);
INSERT INTO estudantes (usuario_id, serie, turma, saldo, responsavel_id) SELECT 210, '8º Ano', 'A', 50, 110 WHERE NOT EXISTS (SELECT 1 FROM estudantes WHERE usuario_id=210);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 111, 'Cristiane Teixeira', 'responsavel11@teste.example', NULL, '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'responsavel', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=111);
INSERT INTO responsaveis (usuario_id) SELECT 111 WHERE NOT EXISTS (SELECT 1 FROM responsaveis WHERE usuario_id=111);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 211, 'Isabela Gomes Teixeira', 'aluno11@teste.example', 'aluno11', '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'aluno', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=211);
INSERT INTO estudantes (usuario_id, serie, turma, saldo, responsavel_id) SELECT 211, '9º Ano', 'A', 50, 111 WHERE NOT EXISTS (SELECT 1 FROM estudantes WHERE usuario_id=211);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 112, 'Paulo Cardoso', 'responsavel12@teste.example', NULL, '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'responsavel', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=112);
INSERT INTO responsaveis (usuario_id) SELECT 112 WHERE NOT EXISTS (SELECT 1 FROM responsaveis WHERE usuario_id=112);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 212, 'João Pedro Cardoso', 'aluno12@teste.example', 'aluno12', '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'aluno', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=212);
INSERT INTO estudantes (usuario_id, serie, turma, saldo, responsavel_id) SELECT 212, '1º Ano EM', 'A', 50, 112 WHERE NOT EXISTS (SELECT 1 FROM estudantes WHERE usuario_id=212);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 113, 'Adriana Melo', 'responsavel13@teste.example', NULL, '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'responsavel', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=113);
INSERT INTO responsaveis (usuario_id) SELECT 113 WHERE NOT EXISTS (SELECT 1 FROM responsaveis WHERE usuario_id=113);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 213, 'Julia Fernandes Melo', 'aluno13@teste.example', 'aluno13', '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'aluno', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=213);
INSERT INTO estudantes (usuario_id, serie, turma, saldo, responsavel_id) SELECT 213, '2º Ano EM', 'A', 50, 113 WHERE NOT EXISTS (SELECT 1 FROM estudantes WHERE usuario_id=213);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 114, 'Alexandre Pinto', 'responsavel14@teste.example', NULL, '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'responsavel', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=114);
INSERT INTO responsaveis (usuario_id) SELECT 114 WHERE NOT EXISTS (SELECT 1 FROM responsaveis WHERE usuario_id=114);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 214, 'Lucas Araujo Pinto', 'aluno14@teste.example', 'aluno14', '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'aluno', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=214);
INSERT INTO estudantes (usuario_id, serie, turma, saldo, responsavel_id) SELECT 214, '3º Ano EM', 'A', 50, 114 WHERE NOT EXISTS (SELECT 1 FROM estudantes WHERE usuario_id=214);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 115, 'Renata Moreira', 'responsavel15@teste.example', NULL, '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'responsavel', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=115);
INSERT INTO responsaveis (usuario_id) SELECT 115 WHERE NOT EXISTS (SELECT 1 FROM responsaveis WHERE usuario_id=115);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 215, 'Luiza Castro Moreira', 'aluno15@teste.example', 'aluno15', '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'aluno', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=215);
INSERT INTO estudantes (usuario_id, serie, turma, saldo, responsavel_id) SELECT 215, '6º Ano', 'A', 50, 115 WHERE NOT EXISTS (SELECT 1 FROM estudantes WHERE usuario_id=215);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 116, 'Sergio Cunha', 'responsavel16@teste.example', NULL, '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'responsavel', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=116);
INSERT INTO responsaveis (usuario_id) SELECT 116 WHERE NOT EXISTS (SELECT 1 FROM responsaveis WHERE usuario_id=116);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 216, 'Marcelo Freitas Cunha', 'aluno16@teste.example', 'aluno16', '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'aluno', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=216);
INSERT INTO estudantes (usuario_id, serie, turma, saldo, responsavel_id) SELECT 216, '7º Ano', 'A', 50, 116 WHERE NOT EXISTS (SELECT 1 FROM estudantes WHERE usuario_id=216);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 117, 'Tatiana Correia', 'responsavel17@teste.example', NULL, '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'responsavel', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=117);
INSERT INTO responsaveis (usuario_id) SELECT 117 WHERE NOT EXISTS (SELECT 1 FROM responsaveis WHERE usuario_id=117);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 217, 'Maria Eduarda Correia', 'aluno17@teste.example', 'aluno17', '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'aluno', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=217);
INSERT INTO estudantes (usuario_id, serie, turma, saldo, responsavel_id) SELECT 217, '8º Ano', 'A', 50, 117 WHERE NOT EXISTS (SELECT 1 FROM estudantes WHERE usuario_id=217);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 118, 'Wagner Nunes', 'responsavel18@teste.example', NULL, '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'responsavel', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=118);
INSERT INTO responsaveis (usuario_id) SELECT 118 WHERE NOT EXISTS (SELECT 1 FROM responsaveis WHERE usuario_id=118);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 218, 'Matheus Campos Nunes', 'aluno18@teste.example', 'aluno18', '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'aluno', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=218);
INSERT INTO estudantes (usuario_id, serie, turma, saldo, responsavel_id) SELECT 218, '9º Ano', 'A', 50, 118 WHERE NOT EXISTS (SELECT 1 FROM estudantes WHERE usuario_id=218);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 119, 'Simone Barros', 'responsavel19@teste.example', NULL, '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'responsavel', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=119);
INSERT INTO responsaveis (usuario_id) SELECT 119 WHERE NOT EXISTS (SELECT 1 FROM responsaveis WHERE usuario_id=119);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 219, 'Melissa Moura Barros', 'aluno19@teste.example', 'aluno19', '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'aluno', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=219);
INSERT INTO estudantes (usuario_id, serie, turma, saldo, responsavel_id) SELECT 219, '1º Ano EM', 'A', 50, 119 WHERE NOT EXISTS (SELECT 1 FROM estudantes WHERE usuario_id=219);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 120, 'Antonio Lopes', 'responsavel20@teste.example', NULL, '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'responsavel', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=120);
INSERT INTO responsaveis (usuario_id) SELECT 120 WHERE NOT EXISTS (SELECT 1 FROM responsaveis WHERE usuario_id=120);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 220, 'Miguel Carvalho Lopes', 'aluno20@teste.example', 'aluno20', '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'aluno', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=220);
INSERT INTO estudantes (usuario_id, serie, turma, saldo, responsavel_id) SELECT 220, '2º Ano EM', 'A', 50, 120 WHERE NOT EXISTS (SELECT 1 FROM estudantes WHERE usuario_id=220);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 121, 'Eliane Batista', 'responsavel21@teste.example', NULL, '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'responsavel', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=121);
INSERT INTO responsaveis (usuario_id) SELECT 121 WHERE NOT EXISTS (SELECT 1 FROM responsaveis WHERE usuario_id=121);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 221, 'Nicole Monteiro Batista', 'aluno21@teste.example', 'aluno21', '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'aluno', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=221);
INSERT INTO estudantes (usuario_id, serie, turma, saldo, responsavel_id) SELECT 221, '3º Ano EM', 'A', 50, 121 WHERE NOT EXISTS (SELECT 1 FROM estudantes WHERE usuario_id=221);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 122, 'Claudio Duarte', 'responsavel22@teste.example', NULL, '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'responsavel', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=122);
INSERT INTO responsaveis (usuario_id) SELECT 122 WHERE NOT EXISTS (SELECT 1 FROM responsaveis WHERE usuario_id=122);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 222, 'Otavio Vieira Duarte', 'aluno22@teste.example', 'aluno22', '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'aluno', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=222);
INSERT INTO estudantes (usuario_id, serie, turma, saldo, responsavel_id) SELECT 222, '6º Ano', 'A', 50, 122 WHERE NOT EXISTS (SELECT 1 FROM estudantes WHERE usuario_id=222);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 123, 'Juliana Mendes', 'responsavel23@teste.example', NULL, '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'responsavel', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=123);
INSERT INTO responsaveis (usuario_id) SELECT 123 WHERE NOT EXISTS (SELECT 1 FROM responsaveis WHERE usuario_id=123);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 223, 'Pedro Henrique Mendes', 'aluno23@teste.example', 'aluno23', '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'aluno', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=223);
INSERT INTO estudantes (usuario_id, serie, turma, saldo, responsavel_id) SELECT 223, '7º Ano', 'A', 50, 123 WHERE NOT EXISTS (SELECT 1 FROM estudantes WHERE usuario_id=223);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 124, 'Rodrigo Farias', 'responsavel24@teste.example', NULL, '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'responsavel', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=124);
INSERT INTO responsaveis (usuario_id) SELECT 124 WHERE NOT EXISTS (SELECT 1 FROM responsaveis WHERE usuario_id=124);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 224, 'Rafaela Machado Farias', 'aluno24@teste.example', 'aluno24', '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'aluno', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=224);
INSERT INTO estudantes (usuario_id, serie, turma, saldo, responsavel_id) SELECT 224, '8º Ano', 'A', 50, 124 WHERE NOT EXISTS (SELECT 1 FROM estudantes WHERE usuario_id=224);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 125, 'Monica Reis', 'responsavel25@teste.example', NULL, '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'responsavel', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=125);
INSERT INTO responsaveis (usuario_id) SELECT 125 WHERE NOT EXISTS (SELECT 1 FROM responsaveis WHERE usuario_id=125);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 225, 'Rafael Barbosa Reis', 'aluno25@teste.example', 'aluno25', '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'aluno', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=225);
INSERT INTO estudantes (usuario_id, serie, turma, saldo, responsavel_id) SELECT 225, '9º Ano', 'A', 50, 125 WHERE NOT EXISTS (SELECT 1 FROM estudantes WHERE usuario_id=225);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 126, 'Fabio Ramos', 'responsavel26@teste.example', NULL, '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'responsavel', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=126);
INSERT INTO responsaveis (usuario_id) SELECT 126 WHERE NOT EXISTS (SELECT 1 FROM responsaveis WHERE usuario_id=126);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 226, 'Sofia Azevedo Ramos', 'aluno26@teste.example', 'aluno26', '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'aluno', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=226);
INSERT INTO estudantes (usuario_id, serie, turma, saldo, responsavel_id) SELECT 226, '1º Ano EM', 'A', 50, 126 WHERE NOT EXISTS (SELECT 1 FROM estudantes WHERE usuario_id=226);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 127, 'Daniela Fonseca', 'responsavel27@teste.example', NULL, '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'responsavel', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=127);
INSERT INTO responsaveis (usuario_id) SELECT 127 WHERE NOT EXISTS (SELECT 1 FROM responsaveis WHERE usuario_id=127);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 227, 'Thiago Pires Fonseca', 'aluno27@teste.example', 'aluno27', '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'aluno', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=227);
INSERT INTO estudantes (usuario_id, serie, turma, saldo, responsavel_id) SELECT 227, '2º Ano EM', 'A', 50, 127 WHERE NOT EXISTS (SELECT 1 FROM estudantes WHERE usuario_id=227);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 128, 'Leandro Neves', 'responsavel28@teste.example', NULL, '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'responsavel', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=128);
INSERT INTO responsaveis (usuario_id) SELECT 128 WHERE NOT EXISTS (SELECT 1 FROM responsaveis WHERE usuario_id=128);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 228, 'Valentina Xavier Neves', 'aluno28@teste.example', 'aluno28', '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'aluno', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=228);
INSERT INTO estudantes (usuario_id, serie, turma, saldo, responsavel_id) SELECT 228, '3º Ano EM', 'A', 50, 128 WHERE NOT EXISTS (SELECT 1 FROM estudantes WHERE usuario_id=228);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 129, 'Vanessa Brito', 'responsavel29@teste.example', NULL, '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'responsavel', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=129);
INSERT INTO responsaveis (usuario_id) SELECT 129 WHERE NOT EXISTS (SELECT 1 FROM responsaveis WHERE usuario_id=129);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 229, 'Vitor Hugo Brito', 'aluno29@teste.example', 'aluno29', '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'aluno', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=229);
INSERT INTO estudantes (usuario_id, serie, turma, saldo, responsavel_id) SELECT 229, '6º Ano', 'A', 50, 129 WHERE NOT EXISTS (SELECT 1 FROM estudantes WHERE usuario_id=229);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 130, 'Jose Leal', 'responsavel30@teste.example', NULL, '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'responsavel', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=130);
INSERT INTO responsaveis (usuario_id) SELECT 130 WHERE NOT EXISTS (SELECT 1 FROM responsaveis WHERE usuario_id=130);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 230, 'Yasmin Martins Leal', 'aluno30@teste.example', 'aluno30', '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'aluno', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=230);
INSERT INTO estudantes (usuario_id, serie, turma, saldo, responsavel_id) SELECT 230, '7º Ano', 'A', 50, 130 WHERE NOT EXISTS (SELECT 1 FROM estudantes WHERE usuario_id=230);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 131, 'Camila Torres', 'responsavel31@teste.example', NULL, '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'responsavel', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=131);
INSERT INTO responsaveis (usuario_id) SELECT 131 WHERE NOT EXISTS (SELECT 1 FROM responsaveis WHERE usuario_id=131);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 231, 'Alice Ribeiro Torres', 'aluno31@teste.example', 'aluno31', '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'aluno', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=231);
INSERT INTO estudantes (usuario_id, serie, turma, saldo, responsavel_id) SELECT 231, '8º Ano', 'A', 50, 131 WHERE NOT EXISTS (SELECT 1 FROM estudantes WHERE usuario_id=231);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 132, 'Anderson Peixoto', 'responsavel32@teste.example', NULL, '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'responsavel', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=132);
INSERT INTO responsaveis (usuario_id) SELECT 132 WHERE NOT EXISTS (SELECT 1 FROM responsaveis WHERE usuario_id=132);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 232, 'Arthur Dias Peixoto', 'aluno32@teste.example', 'aluno32', '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'aluno', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=232);
INSERT INTO estudantes (usuario_id, serie, turma, saldo, responsavel_id) SELECT 232, '9º Ano', 'A', 50, 132 WHERE NOT EXISTS (SELECT 1 FROM estudantes WHERE usuario_id=232);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 133, 'Priscila Coelho', 'responsavel33@teste.example', NULL, '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'responsavel', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=133);
INSERT INTO responsaveis (usuario_id) SELECT 133 WHERE NOT EXISTS (SELECT 1 FROM responsaveis WHERE usuario_id=133);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 233, 'Beatriz Santos Coelho', 'aluno33@teste.example', 'aluno33', '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'aluno', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=233);
INSERT INTO estudantes (usuario_id, serie, turma, saldo, responsavel_id) SELECT 233, '1º Ano EM', 'A', 50, 133 WHERE NOT EXISTS (SELECT 1 FROM estudantes WHERE usuario_id=233);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 134, 'Cesar Lima', 'responsavel34@teste.example', NULL, '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'responsavel', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=134);
INSERT INTO responsaveis (usuario_id) SELECT 134 WHERE NOT EXISTS (SELECT 1 FROM responsaveis WHERE usuario_id=134);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 234, 'Caio Vinicius Lima', 'aluno34@teste.example', 'aluno34', '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'aluno', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=234);
INSERT INTO estudantes (usuario_id, serie, turma, saldo, responsavel_id) SELECT 234, '2º Ano EM', 'A', 50, 134 WHERE NOT EXISTS (SELECT 1 FROM estudantes WHERE usuario_id=234);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 135, 'Regina Tavares', 'responsavel35@teste.example', NULL, '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'responsavel', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=135);
INSERT INTO responsaveis (usuario_id) SELECT 135 WHERE NOT EXISTS (SELECT 1 FROM responsaveis WHERE usuario_id=135);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 235, 'Cecilia Rocha Tavares', 'aluno35@teste.example', 'aluno35', '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'aluno', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=235);
INSERT INTO estudantes (usuario_id, serie, turma, saldo, responsavel_id) SELECT 235, '3º Ano EM', 'A', 50, 135 WHERE NOT EXISTS (SELECT 1 FROM estudantes WHERE usuario_id=235);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 136, 'Mauricio Soares', 'responsavel36@teste.example', NULL, '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'responsavel', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=136);
INSERT INTO responsaveis (usuario_id) SELECT 136 WHERE NOT EXISTS (SELECT 1 FROM responsaveis WHERE usuario_id=136);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 236, 'Davi Ferreira Soares', 'aluno36@teste.example', 'aluno36', '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'aluno', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=236);
INSERT INTO estudantes (usuario_id, serie, turma, saldo, responsavel_id) SELECT 236, '6º Ano', 'A', 50, 136 WHERE NOT EXISTS (SELECT 1 FROM estudantes WHERE usuario_id=236);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 137, 'Aline Cavalcanti', 'responsavel37@teste.example', NULL, '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'responsavel', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=137);
INSERT INTO responsaveis (usuario_id) SELECT 137 WHERE NOT EXISTS (SELECT 1 FROM responsaveis WHERE usuario_id=137);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 237, 'Elisa Moura Cavalcanti', 'aluno37@teste.example', 'aluno37', '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'aluno', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=237);
INSERT INTO estudantes (usuario_id, serie, turma, saldo, responsavel_id) SELECT 237, '7º Ano', 'A', 50, 137 WHERE NOT EXISTS (SELECT 1 FROM estudantes WHERE usuario_id=237);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 138, 'Renato Melo', 'responsavel38@teste.example', NULL, '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'responsavel', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=138);
INSERT INTO responsaveis (usuario_id) SELECT 138 WHERE NOT EXISTS (SELECT 1 FROM responsaveis WHERE usuario_id=138);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 238, 'Enzo Gabriel Melo', 'aluno38@teste.example', 'aluno38', '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'aluno', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=238);
INSERT INTO estudantes (usuario_id, serie, turma, saldo, responsavel_id) SELECT 238, '8º Ano', 'A', 50, 138 WHERE NOT EXISTS (SELECT 1 FROM estudantes WHERE usuario_id=238);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 139, 'Rosana Andrade', 'responsavel39@teste.example', NULL, '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'responsavel', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=139);
INSERT INTO responsaveis (usuario_id) SELECT 139 WHERE NOT EXISTS (SELECT 1 FROM responsaveis WHERE usuario_id=139);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 239, 'Estela Nunes Andrade', 'aluno39@teste.example', 'aluno39', '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'aluno', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=239);
INSERT INTO estudantes (usuario_id, serie, turma, saldo, responsavel_id) SELECT 239, '9º Ano', 'A', 50, 139 WHERE NOT EXISTS (SELECT 1 FROM estudantes WHERE usuario_id=239);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 140, 'Vinicius Siqueira', 'responsavel40@teste.example', NULL, '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'responsavel', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=140);
INSERT INTO responsaveis (usuario_id) SELECT 140 WHERE NOT EXISTS (SELECT 1 FROM responsaveis WHERE usuario_id=140);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 240, 'Francisco Alves Siqueira', 'aluno40@teste.example', 'aluno40', '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'aluno', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=240);
INSERT INTO estudantes (usuario_id, serie, turma, saldo, responsavel_id) SELECT 240, '1º Ano EM', 'A', 50, 140 WHERE NOT EXISTS (SELECT 1 FROM estudantes WHERE usuario_id=240);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 141, 'Denise Borges', 'responsavel41@teste.example', NULL, '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'responsavel', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=141);
INSERT INTO responsaveis (usuario_id) SELECT 141 WHERE NOT EXISTS (SELECT 1 FROM responsaveis WHERE usuario_id=141);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 241, 'Giovana Teixeira Borges', 'aluno41@teste.example', 'aluno41', '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'aluno', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=241);
INSERT INTO estudantes (usuario_id, serie, turma, saldo, responsavel_id) SELECT 241, '2º Ano EM', 'A', 50, 141 WHERE NOT EXISTS (SELECT 1 FROM estudantes WHERE usuario_id=241);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 142, 'Geraldo Moraes', 'responsavel42@teste.example', NULL, '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'responsavel', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=142);
INSERT INTO responsaveis (usuario_id) SELECT 142 WHERE NOT EXISTS (SELECT 1 FROM responsaveis WHERE usuario_id=142);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 242, 'Heitor Costa Moraes', 'aluno42@teste.example', 'aluno42', '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'aluno', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=242);
INSERT INTO estudantes (usuario_id, serie, turma, saldo, responsavel_id) SELECT 242, '3º Ano EM', 'A', 50, 142 WHERE NOT EXISTS (SELECT 1 FROM estudantes WHERE usuario_id=242);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 143, 'Claudia Freire', 'responsavel43@teste.example', NULL, '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'responsavel', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=143);
INSERT INTO responsaveis (usuario_id) SELECT 143 WHERE NOT EXISTS (SELECT 1 FROM responsaveis WHERE usuario_id=143);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 243, 'Heloisa Pereira Freire', 'aluno43@teste.example', 'aluno43', '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'aluno', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=243);
INSERT INTO estudantes (usuario_id, serie, turma, saldo, responsavel_id) SELECT 243, '6º Ano', 'A', 50, 143 WHERE NOT EXISTS (SELECT 1 FROM estudantes WHERE usuario_id=243);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 144, 'Douglas Dantas', 'responsavel44@teste.example', NULL, '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'responsavel', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=144);
INSERT INTO responsaveis (usuario_id) SELECT 144 WHERE NOT EXISTS (SELECT 1 FROM responsaveis WHERE usuario_id=144);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 244, 'Isaac Oliveira Dantas', 'aluno44@teste.example', 'aluno44', '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'aluno', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=244);
INSERT INTO estudantes (usuario_id, serie, turma, saldo, responsavel_id) SELECT 244, '7º Ano', 'A', 50, 144 WHERE NOT EXISTS (SELECT 1 FROM estudantes WHERE usuario_id=244);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 145, 'Silvia Silveira', 'responsavel45@teste.example', NULL, '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'responsavel', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=145);
INSERT INTO responsaveis (usuario_id) SELECT 145 WHERE NOT EXISTS (SELECT 1 FROM responsaveis WHERE usuario_id=145);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 245, 'Lara Souza Silveira', 'aluno45@teste.example', 'aluno45', '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'aluno', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=245);
INSERT INTO estudantes (usuario_id, serie, turma, saldo, responsavel_id) SELECT 245, '8º Ano', 'A', 50, 145 WHERE NOT EXISTS (SELECT 1 FROM estudantes WHERE usuario_id=245);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 146, 'Nelson Figueiredo', 'responsavel46@teste.example', NULL, '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'responsavel', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=146);
INSERT INTO responsaveis (usuario_id) SELECT 146 WHERE NOT EXISTS (SELECT 1 FROM responsaveis WHERE usuario_id=146);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 246, 'Leonardo Gomes Figueiredo', 'aluno46@teste.example', 'aluno46', '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'aluno', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=246);
INSERT INTO estudantes (usuario_id, serie, turma, saldo, responsavel_id) SELECT 246, '9º Ano', 'A', 50, 146 WHERE NOT EXISTS (SELECT 1 FROM estudantes WHERE usuario_id=246);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 147, 'Andrea Amaral', 'responsavel47@teste.example', NULL, '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'responsavel', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=147);
INSERT INTO responsaveis (usuario_id) SELECT 147 WHERE NOT EXISTS (SELECT 1 FROM responsaveis WHERE usuario_id=147);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 247, 'Leticia Campos Amaral', 'aluno47@teste.example', 'aluno47', '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'aluno', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=247);
INSERT INTO estudantes (usuario_id, serie, turma, saldo, responsavel_id) SELECT 247, '1º Ano EM', 'A', 50, 147 WHERE NOT EXISTS (SELECT 1 FROM estudantes WHERE usuario_id=247);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 148, 'Sandro Rezende', 'responsavel48@teste.example', NULL, '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'responsavel', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=148);
INSERT INTO responsaveis (usuario_id) SELECT 148 WHERE NOT EXISTS (SELECT 1 FROM responsaveis WHERE usuario_id=148);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 248, 'Lorenzo Cardoso Rezende', 'aluno48@teste.example', 'aluno48', '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'aluno', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=248);
INSERT INTO estudantes (usuario_id, serie, turma, saldo, responsavel_id) SELECT 248, '2º Ano EM', 'A', 50, 148 WHERE NOT EXISTS (SELECT 1 FROM estudantes WHERE usuario_id=248);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 149, 'Viviane Sales', 'responsavel49@teste.example', NULL, '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'responsavel', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=149);
INSERT INTO responsaveis (usuario_id) SELECT 149 WHERE NOT EXISTS (SELECT 1 FROM responsaveis WHERE usuario_id=149);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 249, 'Manuela Araujo Sales', 'aluno49@teste.example', 'aluno49', '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'aluno', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=249);
INSERT INTO estudantes (usuario_id, serie, turma, saldo, responsavel_id) SELECT 249, '3º Ano EM', 'A', 50, 149 WHERE NOT EXISTS (SELECT 1 FROM estudantes WHERE usuario_id=249);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 150, 'Rogerio Aguiar', 'responsavel50@teste.example', NULL, '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'responsavel', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=150);
INSERT INTO responsaveis (usuario_id) SELECT 150 WHERE NOT EXISTS (SELECT 1 FROM responsaveis WHERE usuario_id=150);
INSERT INTO usuarios (id, nome, email, matricula, senha_hash, tipo, ativo) SELECT 250, 'Samuel Castro Aguiar', 'aluno50@teste.example', 'aluno50', '$argon2id$v=19$m=65536,t=3,p=4$03NReWtN2NSvBQyELOHPuw$yY9CHaRE8ZuzALZCNxBqhMURIZBhfhWacukZazFWM4c', 'aluno', 1 WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id=250);
INSERT INTO estudantes (usuario_id, serie, turma, saldo, responsavel_id) SELECT 250, '6º Ano', 'A', 50, 150 WHERE NOT EXISTS (SELECT 1 FROM estudantes WHERE usuario_id=250);
INSERT INTO produtos (id, nome, descricao, preco, estoque, categoria, imagem_url, ativo, emoji) SELECT 1, 'Pastel de calabresa com requeijão', 'Porção individual de pastel de calabresa com requeijão.', 7, 2, 'Salgados Assados', '/static/img/produtos/item_1.png', 1, '🍽️' WHERE NOT EXISTS (SELECT 1 FROM produtos WHERE id=1);
INSERT INTO produtos (id, nome, descricao, preco, estoque, categoria, imagem_url, ativo, emoji) SELECT 2, 'Coxinha de frango com catupiry assada', 'Porção individual de coxinha de frango com catupiry assada.', 8, 2, 'Salgados Assados', '/static/img/produtos/item_2.png', 1, '🍽️' WHERE NOT EXISTS (SELECT 1 FROM produtos WHERE id=2);
INSERT INTO produtos (id, nome, descricao, preco, estoque, categoria, imagem_url, ativo, emoji) SELECT 3, 'Croissant de presunto e queijo', 'Porção individual de croissant de presunto e queijo.', 9, 2, 'Salgados Assados', '/static/img/produtos/item_3.png', 1, '🍽️' WHERE NOT EXISTS (SELECT 1 FROM produtos WHERE id=3);
INSERT INTO produtos (id, nome, descricao, preco, estoque, categoria, imagem_url, ativo, emoji) SELECT 4, 'Empada de frango com cream cheese', 'Porção individual de empada de frango com cream cheese.', 8, 5, 'Salgados Assados', '/static/img/produtos/item_4.png', 1, '🍽️' WHERE NOT EXISTS (SELECT 1 FROM produtos WHERE id=4);
INSERT INTO produtos (id, nome, descricao, preco, estoque, categoria, imagem_url, ativo, emoji) SELECT 5, 'Enroladinho de salsicha assado', 'Porção individual de enroladinho de salsicha assado.', 6, 10, 'Salgados Assados', '/static/img/produtos/item_5.png', 1, '🍽️' WHERE NOT EXISTS (SELECT 1 FROM produtos WHERE id=5);
INSERT INTO produtos (id, nome, descricao, preco, estoque, categoria, imagem_url, ativo, emoji) SELECT 6, 'Pão de queijo tradicional grande', 'Porção individual de pão de queijo tradicional grande.', 5, 15, 'Salgados Assados', '/static/img/produtos/item_6.png', 1, '🍽️' WHERE NOT EXISTS (SELECT 1 FROM produtos WHERE id=6);
INSERT INTO produtos (id, nome, descricao, preco, estoque, categoria, imagem_url, ativo, emoji) SELECT 7, 'Esfiha aberta de carne moída', 'Porção individual de esfiha aberta de carne moída.', 6, 5, 'Salgados Assados', '/static/img/produtos/item_7.png', 1, '🍽️' WHERE NOT EXISTS (SELECT 1 FROM produtos WHERE id=7);
INSERT INTO produtos (id, nome, descricao, preco, estoque, categoria, imagem_url, ativo, emoji) SELECT 8, 'Folhado de frango com bacon', 'Porção individual de folhado de frango com bacon.', 9, 10, 'Salgados Assados', '/static/img/produtos/item_8.png', 1, '🍽️' WHERE NOT EXISTS (SELECT 1 FROM produtos WHERE id=8);
INSERT INTO produtos (id, nome, descricao, preco, estoque, categoria, imagem_url, ativo, emoji) SELECT 9, 'Mini pizza de mussarela e orégano', 'Porção individual de mini pizza de mussarela e orégano.', 8, 15, 'Salgados Assados', '/static/img/produtos/item_9.png', 1, '🍽️' WHERE NOT EXISTS (SELECT 1 FROM produtos WHERE id=9);
INSERT INTO produtos (id, nome, descricao, preco, estoque, categoria, imagem_url, ativo, emoji) SELECT 10, 'Hamburgão assado de x-salada', 'Porção individual de hamburgão assado de x-salada.', 12, 5, 'Salgados Assados', '/static/img/produtos/item_10.png', 1, '🍽️' WHERE NOT EXISTS (SELECT 1 FROM produtos WHERE id=10);
INSERT INTO produtos (id, nome, descricao, preco, estoque, categoria, imagem_url, ativo, emoji) SELECT 11, 'Kibe recheado com queijo', 'Porção individual de kibe recheado com queijo.', 7, 10, 'Salgados Fritos', '/static/img/produtos/item_11.png', 1, '🍽️' WHERE NOT EXISTS (SELECT 1 FROM produtos WHERE id=11);
INSERT INTO produtos (id, nome, descricao, preco, estoque, categoria, imagem_url, ativo, emoji) SELECT 12, 'Rissole de presunto e queijo', 'Porção individual de rissole de presunto e queijo.', 6, 15, 'Salgados Fritos', '/static/img/produtos/item_12.png', 1, '🍽️' WHERE NOT EXISTS (SELECT 1 FROM produtos WHERE id=12);
INSERT INTO produtos (id, nome, descricao, preco, estoque, categoria, imagem_url, ativo, emoji) SELECT 13, 'Pastel frito de carne louca', 'Porção individual de pastel frito de carne louca.', 8, 5, 'Salgados Fritos', '/static/img/produtos/item_13.png', 1, '🍽️' WHERE NOT EXISTS (SELECT 1 FROM produtos WHERE id=13);
INSERT INTO produtos (id, nome, descricao, preco, estoque, categoria, imagem_url, ativo, emoji) SELECT 14, 'Suco natural de laranja 500ml', 'Porção individual de suco natural de laranja 500ml.', 8, 10, 'Bebidas', '/static/img/produtos/item_14.png', 1, '🥤' WHERE NOT EXISTS (SELECT 1 FROM produtos WHERE id=14);
INSERT INTO produtos (id, nome, descricao, preco, estoque, categoria, imagem_url, ativo, emoji) SELECT 15, 'Suco natural de uva integral 300ml', 'Porção individual de suco natural de uva integral 300ml.', 7, 15, 'Bebidas', '/static/img/produtos/item_15.png', 1, '🥤' WHERE NOT EXISTS (SELECT 1 FROM produtos WHERE id=15);
INSERT INTO produtos (id, nome, descricao, preco, estoque, categoria, imagem_url, ativo, emoji) SELECT 16, 'Água mineral sem gás 500ml', 'Porção individual de água mineral sem gás 500ml.', 3, 5, 'Bebidas', '/static/img/produtos/item_16.png', 1, '🥤' WHERE NOT EXISTS (SELECT 1 FROM produtos WHERE id=16);
INSERT INTO produtos (id, nome, descricao, preco, estoque, categoria, imagem_url, ativo, emoji) SELECT 17, 'Água mineral com gás 500ml', 'Porção individual de água mineral com gás 500ml.', 4, 10, 'Bebidas', '/static/img/produtos/item_17.png', 1, '🥤' WHERE NOT EXISTS (SELECT 1 FROM produtos WHERE id=17);
INSERT INTO produtos (id, nome, descricao, preco, estoque, categoria, imagem_url, ativo, emoji) SELECT 18, 'Achocolatado Toddynho 200ml', 'Porção individual de achocolatado toddynho 200ml.', 5, 15, 'Bebidas', '/static/img/produtos/item_18.png', 1, '🥤' WHERE NOT EXISTS (SELECT 1 FROM produtos WHERE id=18);
INSERT INTO produtos (id, nome, descricao, preco, estoque, categoria, imagem_url, ativo, emoji) SELECT 19, 'Suco de caixa Del Valle Pêssego', 'Porção individual de suco de caixa del valle pêssego.', 5, 5, 'Bebidas', '/static/img/produtos/item_19.png', 1, '🥤' WHERE NOT EXISTS (SELECT 1 FROM produtos WHERE id=19);
INSERT INTO produtos (id, nome, descricao, preco, estoque, categoria, imagem_url, ativo, emoji) SELECT 20, 'Refrigerante Guaraná Antarctica Lata 350ml', 'Porção individual de refrigerante guaraná antarctica lata 350ml.', 6, 10, 'Bebidas', '/static/img/produtos/item_20.png', 1, '🥤' WHERE NOT EXISTS (SELECT 1 FROM produtos WHERE id=20);
INSERT INTO produtos (id, nome, descricao, preco, estoque, categoria, imagem_url, ativo, emoji) SELECT 21, 'Ice Tea Leão Limão 450ml', 'Porção individual de ice tea leão limão 450ml.', 7, 15, 'Bebidas', '/static/img/produtos/item_21.png', 1, '🥤' WHERE NOT EXISTS (SELECT 1 FROM produtos WHERE id=21);
INSERT INTO produtos (id, nome, descricao, preco, estoque, categoria, imagem_url, ativo, emoji) SELECT 22, 'Bolo de pote brigadeiro gourmet', 'Porção individual de bolo de pote brigadeiro gourmet.', 10, 5, 'Doces & Sobremesas', '/static/img/produtos/item_22.png', 1, '🍰' WHERE NOT EXISTS (SELECT 1 FROM produtos WHERE id=22);
INSERT INTO produtos (id, nome, descricao, preco, estoque, categoria, imagem_url, ativo, emoji) SELECT 23, 'Bolo de pote morango com leite ninho', 'Porção individual de bolo de pote morango com leite ninho.', 10, 10, 'Doces & Sobremesas', '/static/img/produtos/item_23.png', 1, '🍰' WHERE NOT EXISTS (SELECT 1 FROM produtos WHERE id=23);
INSERT INTO produtos (id, nome, descricao, preco, estoque, categoria, imagem_url, ativo, emoji) SELECT 24, 'Brigadeiro tradicional grande', 'Porção individual de brigadeiro tradicional grande.', 3, 15, 'Doces & Sobremesas', '/static/img/produtos/item_24.png', 1, '🍰' WHERE NOT EXISTS (SELECT 1 FROM produtos WHERE id=24);
INSERT INTO produtos (id, nome, descricao, preco, estoque, categoria, imagem_url, ativo, emoji) SELECT 25, 'Beijinho de coco com cravo', 'Porção individual de beijinho de coco com cravo.', 3, 5, 'Doces & Sobremesas', '/static/img/produtos/item_25.png', 1, '🍰' WHERE NOT EXISTS (SELECT 1 FROM produtos WHERE id=25);
INSERT INTO produtos (id, nome, descricao, preco, estoque, categoria, imagem_url, ativo, emoji) SELECT 26, 'Brownie de chocolate meio amargo', 'Porção individual de brownie de chocolate meio amargo.', 7, 10, 'Doces & Sobremesas', '/static/img/produtos/item_26.png', 1, '🍰' WHERE NOT EXISTS (SELECT 1 FROM produtos WHERE id=26);
INSERT INTO produtos (id, nome, descricao, preco, estoque, categoria, imagem_url, ativo, emoji) SELECT 27, 'Cookie com gotas de chocolate', 'Porção individual de cookie com gotas de chocolate.', 5, 15, 'Doces & Sobremesas', '/static/img/produtos/item_27.png', 1, '🍰' WHERE NOT EXISTS (SELECT 1 FROM produtos WHERE id=27);
INSERT INTO produtos (id, nome, descricao, preco, estoque, categoria, imagem_url, ativo, emoji) SELECT 28, 'Torta de limão individual', 'Porção individual de torta de limão individual.', 8, 5, 'Doces & Sobremesas', '/static/img/produtos/item_28.png', 1, '🍰' WHERE NOT EXISTS (SELECT 1 FROM produtos WHERE id=28);
INSERT INTO produtos (id, nome, descricao, preco, estoque, categoria, imagem_url, ativo, emoji) SELECT 29, 'Salada de frutas com aveia e mel', 'Porção individual de salada de frutas com aveia e mel.', 9, 10, 'Lanches Saudáveis', '/static/img/produtos/item_29.png', 1, '🍽️' WHERE NOT EXISTS (SELECT 1 FROM produtos WHERE id=29);
INSERT INTO produtos (id, nome, descricao, preco, estoque, categoria, imagem_url, ativo, emoji) SELECT 30, 'Sanduíche natural de frango desfiado com cenoura', 'Porção individual de sanduíche natural de frango desfiado com cenoura.', 10, 15, 'Lanches Saudáveis', '/static/img/produtos/item_30.png', 1, '🍽️' WHERE NOT EXISTS (SELECT 1 FROM produtos WHERE id=30);
INSERT INTO produtos (id, nome, descricao, preco, estoque, categoria, imagem_url, ativo, emoji) SELECT 31, 'Wrap integral de queijo minas e peito de peru', 'Porção individual de wrap integral de queijo minas e peito de peru.', 12, 5, 'Lanches Saudáveis', '/static/img/produtos/item_31.png', 1, '🍽️' WHERE NOT EXISTS (SELECT 1 FROM produtos WHERE id=31);
INSERT INTO produtos (id, nome, descricao, preco, estoque, categoria, imagem_url, ativo, emoji) SELECT 32, 'Barra de cereal de nuts e banana', 'Porção individual de barra de cereal de nuts e banana.', 4, 10, 'Lanches Saudáveis', '/static/img/produtos/item_32.png', 1, '🍽️' WHERE NOT EXISTS (SELECT 1 FROM produtos WHERE id=32);
INSERT INTO produtos (id, nome, descricao, preco, estoque, categoria, imagem_url, ativo, emoji) SELECT 33, 'Iogurte grego com granola', 'Porção individual de iogurte grego com granola.', 7, 15, 'Lanches Saudáveis', '/static/img/produtos/item_33.png', 1, '🍽️' WHERE NOT EXISTS (SELECT 1 FROM produtos WHERE id=33);
INSERT INTO produtos (id, nome, descricao, preco, estoque, categoria, imagem_url, ativo, emoji) SELECT 34, 'Prato Feito: Estrogonofe de frango com batata palha', 'Porção individual de prato feito: estrogonofe de frango com batata palha.', 20, 5, 'Pratos do Dia', '/static/img/produtos/item_34.png', 1, '🍽️' WHERE NOT EXISTS (SELECT 1 FROM produtos WHERE id=34);
INSERT INTO produtos (id, nome, descricao, preco, estoque, categoria, imagem_url, ativo, emoji) SELECT 35, 'Prato Feito: Escondidinho de carne seca com mandioca', 'Porção individual de prato feito: escondidinho de carne seca com mandioca.', 22, 10, 'Pratos do Dia', '/static/img/produtos/item_35.png', 1, '🍽️' WHERE NOT EXISTS (SELECT 1 FROM produtos WHERE id=35);
INSERT INTO produtos (id, nome, descricao, preco, estoque, categoria, imagem_url, ativo, emoji) SELECT 36, 'Prato Feito: Lasanha à bolonhesa individual', 'Porção individual de prato feito: lasanha à bolonhesa individual.', 20, 15, 'Pratos do Dia', '/static/img/produtos/item_36.png', 1, '🍽️' WHERE NOT EXISTS (SELECT 1 FROM produtos WHERE id=36);
INSERT INTO produtos (id, nome, descricao, preco, estoque, categoria, imagem_url, ativo, emoji) SELECT 37, 'Salgado maromba de frango com batata doce', 'Porção individual de salgado maromba de frango com batata doce.', 12, 5, 'Lanches Saudáveis', '/static/img/produtos/item_37.png', 1, '🍽️' WHERE NOT EXISTS (SELECT 1 FROM produtos WHERE id=37);
INSERT INTO produtos (id, nome, descricao, preco, estoque, categoria, imagem_url, ativo, emoji) SELECT 38, 'Chá gelado natural de hibisco com limão', 'Porção individual de chá gelado natural de hibisco com limão.', 6, 10, 'Bebidas', '/static/img/produtos/item_38.png', 1, '🥤' WHERE NOT EXISTS (SELECT 1 FROM produtos WHERE id=38);
COMMIT;
