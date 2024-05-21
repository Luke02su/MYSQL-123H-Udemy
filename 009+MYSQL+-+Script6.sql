
/*==================================================================================
Curso: MYSQL
Instrutor: Sandro Servino
https://www.linkedin.com/in/sandroservino/?originalSubdomain=pt
https://www.udemy.com/user/sandro-servino-3/

 TRIGGER (gatilhos)                                      

- Triggers são stored procedures especiais executados automaticamente 
  em resposta aos eventos de objeto de banco de dados (INSERT, UPDATE e DELETE nas tabelas.).

- Triggers no MYSQL podem ser executados ANTES ou DEPOIS das operações de INSERT, UPDATE e DELETE de registros.

VANTAGENS:

- Parte do processamento que seria executado na aplicação é executado no banco da dados, 
  aliviando recursos do servidor de aplicacao ou maquina cliente.
- Facilita a manutenção, sem que seja necessário alterar o código fonte da aplicação. 
  Em alguns casos consegue resolver um problema da aplicacao quando nao tem acesso ao codigo fonte da aplicacao.
- As triggers fornecem outra maneira de verificar a integridade dos dados.
- As triggers fornecem uma maneira alternativa de executar tarefas agendadas. Ao usar triggers você não precisa 
  esperar que os eventos programados sejam executados, porque as triggers são chamados automaticamente antes 
  ou depois que uma alteração é feita nos dados em uma tabela.
- As triggers podem ser úteis para auditar as alterações de dados nas tabelas.

DESVANTAGEM:

- Algum USUÁRIO, que tenha acesso direto com privilegio adequado ao banco de dados, poderá visualizar e alterar 
  o processamento realizado pela trigger, desabilitar ou deletar a trigger.
- Requer maior conhecimento de manipulação do banco de dados (SQL) para realizar as operações internamente.

*IMPORTANTE:
- Poderá impactar na performance de forma negativa, quando grande quantidade de operacoes de alteracao na tabela ocorre.
  Uma Trigger é ativada para cada linha que é inserida, atualizada ou excluída. Por exemplo, se uma tabela 
  tiver 1.000.000 linhas inseridas, atualizadas ou excluídas, o gatilho é automaticamente invocado e pode no pior caso ser executado
  1.000.000 vezes para as 1.000.000 linhas afetadas, dependendo de como foi feito (ex> uso de cursores e whiles dentro da trigger). 
 - Um simples insert em uma tabela que tem trigger e que esta trigger
  realiza mudanca em varias tabelas e se cada uma destas tabelas tiver outras triggers, todas serao chamadas e pode ter problemas serios de performance.
 - Para manter transações atômicas e duráveis, qualquer objeto impactado por um gatilho manterá uma transação aberta até que o gatilho (e todos os 
  gatilhos subsequentes) sejam concluídos. Isso significa que gatilhos longos não apenas farão as transações durar mais, 
  mas também manterão os bloqueios e farão com que a contenção dure mais. 
- Quando se trata de registros de auditoria, esteja ciente de onde você faz o login de dados. Se voce escolher logar em uma tabela MyISAM, cada INSERT 
  em uma tabela MyISAM produz um bloqueio completo de tabela durante o INSERT. Isso pode se tornar um gargalo sério em um ambiente de alto tráfego e 
  muitas transações. Além disso, se o gatilho for contra uma tabela InnoDB e você registrar alterações no MyISAM de dentro da trigger, isso desabilitará 
  secretamente a conformidade com o ACID (integridade dos dados nas tabelas), que não pode ser revertido, uma vez os dados tendo entrado nas tabelas.

OBS:

1. Näo se pode chamar uma trigger como é feito com Stored Procedures
2. No MYSQL, as triggers, são executados em conjunto com operações em tabelas como inclusão, update e exclusão.
3. NO SQL SERVER para acessarmos os registros que estão sendo incluídos ou removidos, respectivamente, usamos as palavras
reservadas INSERTED e DELETED e no MYSQL usamos as palavras NEW e OLD.

==================================================================================*/

-- Exemplo de criacao de trigger. Vamos criar uma tabela que ira servir de log para 
-- guardar todas as transacoes realizadas em uma tabela

-- CRIANDO A TABELA QUE IRA GUARDAR OS DADOS DAS TRANSACOES REALIZADAS NA TABELA DE PRODUTO

USE CLIENTE2;

-- NO SQL SERVER PARA TESTARMOS SE EXISTE UMA TABELA ANTES DE EXCLUIR IRIAMOS EXECUTAR ESTE CODIGO:

-- IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[produto_auditoria]') AND type in (N'U'))
--     DROP TABLE [dbo].[produto_auditoria];

-- MAS NO MYSQL:
DROP TABLE IF EXISTS produto_auditoria;

-- NO SQL SERVER PODERIAMOS CRIAR A TABELA DESTA FORMAL:
-- CREATE TABLE produto_auditoria(
    id INT IDENTITY PRIMARY KEY, -- IDENTITY é auto_increment no SQL SERVER
    productid INT NOT NULL,
    productname NVARCHAR(50) NOT NULL,
    SupplierId INT NOT NULL,
    UnitPrice decimal(12,2) NOT NULL,
    package NVARCHAR(30) NOT NULL,
    IsDiscontinued bit NOT NULL,
    updatedat DATETIME NOT NULL,
    operation CHAR(3) NOT NULL,
    CHECK(operation = 'INS' or operation='DEL')
);

-- NO MYSQL IREMOS CRIAR DESTA FORMA.  MUITO POUCA MUDANCA. NESTE CASO, PARA NAO DAR ERRO DE SCRIPT APENAS TROCAR PALAVRA
-- RESERVADA NO SQL SERVER IDENTITY para auto_increment no MYSQL

drop table if exists produto_auditoria; 

CREATE TABLE produto_auditoria -- tabela de controle, log (dados de product virão apara cá)
(
    id INT auto_increment PRIMARY KEY,
    productid INT NOT NULL,
    productname VARCHAR(50) NOT NULL,
    SupplierId INT NOT NULL,
    UnitPrice decimal(12,2) NOT NULL,
    package VARCHAR(30) NOT NULL,
    IsDiscontinued bit NOT NULL,
    updatedat DATETIME NOT NULL,
    operation CHAR(3) NOT NULL,
    usuario VARCHAR(40) NOT NULL,
    CHECK(operation = 'INS' or operation='DEL') -- constraint sem nome (check garante que em operation entre INS (inserir) ou DEL (deletar)
);

-- ou poderia ser criado com esta sintaxe

DROP TABLE IF EXISTS produto_auditoria;
CREATE TABLE `produto_auditoria` (
  `id` int NOT NULL AUTO_INCREMENT,
  `productid` int NOT NULL,
  `productname` varchar(50) NOT NULL,
  `SupplierId` int NOT NULL,
  `UnitPrice` decimal(12,2) NOT NULL,
  `package` varchar(30) NOT NULL,
  `IsDiscontinued` bit(1) NOT NULL,
  `updatedat` datetime NOT NULL,
  `operation` char(3) NOT NULL,
  PRIMARY KEY (`id`), -- primary key no final
  CONSTRAINT `produto_auditoria_chk_1` CHECK (((`operation` = 'INS') or (`operation` = 'DEL'))) -- especificando constraint, dando um nome
);

-- ---------------------------------------------------------

-- CRIANDO A TRIGGER NA TABELA PRODUTO

-- NO SQL SERVER É ASSIM:

CREATE TRIGGER trg_produto_auditoria
ON Product  -- A TRIGGER SERA CRIADO NA TABELA PRODUCT
AFTER INSERT, DELETE -- NO CASO DO SQL SERVER VOCE PODE TER A MESMA TRIGGER PARA SER EXECUTADA APOS UM INSERT OU DELETE OU UPDATE, MAS NO MYSQL TERA QUE CRIAR 2 TRIGGERS
AS  -- CLAUSULA OBRIGATORIA NO SQL SERVER
BEGIN
    INSERT INTO produto_auditoria(
        productid, 
        productname,
        SupplierId,
        UnitPrice,
        package,
		IsDiscontinued,
        updatedat, 
        operation
    )
    SELECT
        i.id,
        i.productname,
        SupplierId,
        UnitPrice,
        package,
        IsDiscontinued,
        GETDATE(),
        'INS'
    FROM
        inserted i -- REPARAR NA TABELA QUE GUARDA OS NOVOS DADOS TEMPORARIOS QUE SERAO INSERIDOS NA TABELA produto_auditoria (NO SQL SERVER)
                   -- PORQUE HOUVE INCLUSAO DE NOVOS PRODUTOS NA TABELA PRODUCT
    UNION ALL
    SELECT
       d.id,
        productname,
        SupplierId,
        UnitPrice,
        package,
        IsDiscontinued,
        GETDATE(),
        'DEL'
    FROM
        deleted d; -- REPARAR NA TABELA QUE GUARDA OS NOVOS DADOS TEMPORARIOS QUE SERAO DELETADOS NA TABELA produto_auditoria (NO SQL SERVER)
                   -- PORQUE HOUVE DELECAO DE DADOS DE PRODUTOS NA TABELA PRODUCT
END
GO

ALTER TABLE [dbo].[Product] ENABLE TRIGGER [trg_produto_auditoria] -- NO SQL SERVER SERIA O COMANDO PARA ATIVAS A TRIGGER NA TABELA PRODUCT
GO


-- NO MYSQL É ASSIM:

DROP TRIGGER trg_produto_auditoriaINS;
-- mesma coisa no stored procedure
DELIMITER $$

CREATE TRIGGER trg_produto_auditoriaINS 
AFTER INSERT -- trigger executada depois de um insert, delete, update (before poderia ser usado)
ON Product -- trigger da tabela product (trigger será executada quando alguém der um insert em product)
FOR EACH ROW -- para cada linha será executado após begin
BEGIN
    INSERT INTO produto_auditoria(
        productid, 
        productname,
        SupplierId,
        UnitPrice,
        package,
		IsDiscontinued,
        updatedat, -- fixar a data de operação
        operation, -- fixar qual operação
        usuario
    )
    VALUES (
        NEW.id, -- no momento do insert, o MySQL pega os dados inseridos em Product e joga para tabela temporária NEW depois para producto_auditoria) (insert e update)
        NEW.productname,
        NEW.SupplierId,
        NEW.UnitPrice,
        NEW.package,
        NEW.IsDiscontinued,
        NOW(), -- traz data e hora corrente
        'INS',
        USER());  -- passando INS para operation para ter noção se o trigger foi de inserir ou deletar   -- REPARAR NA TABELA QUE GUARDA OS NOVOS DADOS TEMPORARIOS QUE SERAO INSERIDOS NA TABELA produto_auditoria (NO SQL SERVER) -- PORQUE HOUVE INCLUSAO DE NOVOS PRODUTOS NA TABELA PRODUCT
END$$

DELIMITER ;

-- Vamos verificar a trigger criada no workbench e atraves do comando abaixo:
show triggers;

-- E AGORA VAMOS CRIAR A TRIGGER QUE SERA EXECUTADA APENAS QUANDO UM DADO FOR EXCLUIDO DA TABELA PRODUTO

DROP TRIGGER IF EXISTS `cliente2`.`trg_produto_auditoriaDEL`;

DELIMITER $$

CREATE TRIGGER trg_produto_auditoriaDEL AFTER DELETE 
ON Product  -- A TRIGGER SERA CRIADO NA TABELA PRODUCT
FOR EACH ROW
BEGIN
    INSERT INTO produto_auditoria( -- como está em ordem, desnecessário especificar as colunas. TODAVIA, DEU ERRO AO DELETAR POIS APONTAVA QUE FALTAVA COLUNAS NÂO ESPECÍFICADAS, TIVE QUE ESPECIFICAR TODAS.
		productid, 
        productname,
        SupplierId,
        UnitPrice,
        package,
		IsDiscontinued,
        updatedat, -- fixar a data de operação
        operation, -- fixar qual operação
        usuario
    )
  
    VALUES (
        OLD.id, -- old guardará os dados depois de ser excluídos (delete e update)
        OLD.productname,
        OLD.SupplierId,
        OLD.UnitPrice,
        OLD.package,
        OLD.IsDiscontinued,
        NOW(),
        'DEL',
        USER()); -- sinalizar que deletou para operation    -- REPARAR NA TABELA QUE GUARDA OS NOVOS DADOS TEMPORARIOS QUE SERAO DELETADOS NA TABELA produto_auditoria (NO SQL SERVER)
                   -- PORQUE HOUVE DELECAO DE DADOS DE PRODUTOS NA TABELA PRODUCT
END$$

DELIMITER ;

-- -----------------

-- Vamos verificar a Trigger no MYSQL

-- Testando a Trigger

-- Vamos checar a tabela de log

SELECT 
    * 
FROM 
    produto_auditoria;
    
-- Isso que foi feito em triggers poderia ser feito em procedures, mas não seria automatizado.
-- VAMOS DAR INSERT AGORA NA TABELA DE PRODUTO

INSERT INTO product(id, -- após o insert na tabela product, a trigger levou os valores para a tabela product_auditoria
        productname,
        SupplierId,
        UnitPrice,
        package,
        IsDiscontinued)
VALUES (100,
    'PRODUTO X',
    1,
    1240,
    1,
    0);

-- Vamos checar a tabela de log

SELECT 
    * 
FROM 
    produto_auditoria;


-- Agora vamos testar a delecao de produto e ver o que ocorre

select * from product where  productname = 'PRODUTO X';

SET SQL_SAFE_UPDATES = 0;
DELETE FROM product WHERE productname = 'PRODUTO X'; -- após o delete na tabela product, a trigger levou os valores para a tabela product_auditoria

select * from product where  productname = 'PRODUTO X';


-- Vamos checar a tabela de log

SELECT 
    * 
FROM 
    produto_auditoria;
    
-- como guardar o nome do user na tabela de auditoria
select NOW();
SELECT USER();

-- -----------------------------------------------------------------------------------

-- TESTAR BEFORE TRIGGERS

-- OBS> DIFERENTEMENTE DO SQL SERVER, NO MYSQL COMO NO ORACLE VOCE PODE EXECUTAR TRIGGERS ANTES DE UMA TABELA SER ALTERADA, OU SEJA,
-- VOCE PODERA USAR BEFORE INSERT, BEFORE DELETE E BEFORE UPDATE NA TRIGGER EM UMA TABELA, QUE SERA EXECUTADA MESMO ANTES DO DADO
-- SER ALTERADO NA TABELA ONDE ESTA A TRIGGER

-- Geralmente, o uso de Before triggers é para executar a validação antes de aceitar dados na tabela e para verificar os 
-- valores antes de excluí-los da tabela e geralmente, o uso dos acionadores After é atualizar os dados em uma outra tabela 
-- devido a uma alteração ocorrida em uma determinada tabela.

-- Note que em um BEFORE INSERT Trigger, você pode acessar e alterar os NEW valores. No entanto, você não pode acessar os OLD valores 
-- porque os OLD valores obviamente não existem.

DROP TABLE  IF EXISTS `cliente2`.`account`;

CREATE TABLE account (acct_num INT, amount DECIMAL(10,2)); -- criando tabela account com dois valores

DROP TRIGGER IF EXISTS `cliente2`.`ins_sum`;

CREATE TRIGGER ins_sum BEFORE INSERT ON account -- antes da insert, pegará o valor passado armazenado em NEW.amount + @sum = @sum (Ideal para realizar checagem, validações etc.)
       FOR EACH ROW SET @sum = @sum + NEW.amount; -- se tivesse varias instruções dentro da trigger deveria usar BEGIN END
       
SET @sum = 0; -- variável criada e armazenada (não visível)
INSERT INTO account VALUES(137,14.98),(141,1937.50),(97,-100.00); -- dando três inserts em um único comando (ANTES DE DAR INSERT, PEGA O 14.98 [NEW.AMOUNT] + @SUM [0] = 14.98, DEPOIS  + 1937.50 + -100.00)
SELECT @sum AS 'Total amount inserted'; -- TRAZENDO VALOR DA VARIÁVEL 

SELECT 14.98+1937.50+(-100.00); -- dando select neste calc dá o valor correspondente para confirmar
SELECT * FROM account;


-- ------------------------FIM

