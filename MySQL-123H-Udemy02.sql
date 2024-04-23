CREATE DATABaSE clientes
DEFAULT CHARACTER SET utf8mb4
DEFAULT COLLATE utf8mb4_0900_as_cs;

USE livraria;

CREATE TABLE autor (
	id_autor INT AUTO_INCREMENT PRIMARY KEY,
    nome_autor VARCHAR(45),
    sobrenome VARCHAR(40)
);

CREATE TABLE editora (
	id_editora INT NOT NULL AUTO_INCREMENT PRIMARY KEY, -- como é PRIMARY KEY, torna-se desnecessário colocar como NOT NULL
	nome_editora VARCHAR(45) NULL -- não é necessário colocar NULL, pois automaticamente é setado como NULL se não for NOT NULL
);

-- DROP TABLE livraria; 
-- DROP TABLE editora; 

CREATE TABLE livro (
	id_livro INT AUTO_INCREMENT PRIMARY KEY,
	nome_livro VARCHAR(45) NOT NULL,
    id_autor INT NOT NULL, -- posso ter FOREIGN KEY recebendo valores NULL
    id_editora INT NOT NULL,
    
	INDEX fk_id_autor (id_autor), -- criando indíces p/ melhor performance
    INDEX fk_id_editora (id_editora),
    
    CONSTRAINT fk_id_autor FOREIGN KEY (id_autor) 
		REFERENCES autor(id_autor)
	ON UPDATE RESTRICT 
    ON DELETE RESTRICT, -- padrão, mesmo se não mencionar (Integridade referencial de proteção contra UPDADE e DELETE da FOREIGN KEY)

	CONSTRAINT fk_id_editora FOREIGN KEY (id_editora)
		REFERENCES editora(id_editora)
	ON UPDATE RESTRICT 
    ON DELETE RESTRICT
);

ALTER TABLE livro DROP CONSTRAINT fk_id_autor;
ALTER TABLE livro ADD    
    CONSTRAINT fk_id_autor FOREIGN KEY (id_autor) 
		REFERENCES autor(id_autor)
	ON UPDATE RESTRICT 
    ON DELETE CASCADE;
    
ALTER TABLE livro DROP CONSTRAINT fk_id_editora;
ALTER TABLE livro ADD
	CONSTRAINT fk_id_editora FOREIGN KEY (id_editora)
		REFERENCES editora(id_editora)
	ON UPDATE RESTRICT 
    ON DELETE CASCADE;
    
 DROP TABLE livro; -- apenas consegui apagar pois mudei ON DELETE de RESTRICT p/ CASCADE