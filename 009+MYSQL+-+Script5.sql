
/*==================================================================================
Curso: MYSQL
Instrutor: Sandro Servino
https://www.linkedin.com/in/sandroservino/?originalSubdomain=pt
https://www.udemy.com/user/sandro-servino-3/

 STORED PROCEDURE (SP)                                         

- As Stored Procedures (procedimentos armazenados) do MYSQL são usados para agrupar uma ou mais instruções SQL em unidades lógicas. 
- As Stored Procedures são armazenadas como objetos nomeados no servidor de banco de dados do MYSQL.
- Pode ser uma forma de minimizar o processamento do lado da aplicacao, principalmente web e minimizar trafego de codigos pesados pela rede

Em geral, a STORED PROCEDURE têm as seguintes vantagens:

- Ela roda diretamente na camada do banco de dados, de forma a reduzir a ocupação da largura de banda da rede e o atraso na execução da tarefa de consulta.
- Ela melhora a capacidade de reutilização e manutenção do código, agrega regras de negócios e melhora a segurança (posso por exemplo dar acesso a sp e nao tabela diretamente).
- O servidor armazenará em cache (memória ram) o plano que o otimizador de query usou de acordo com parametros usados e pode reaproveita-lo na execução das Stored Procedures, 
  o que pode reduzir a carga de execução repetida. Nao perde tempo em a cada chamada ter que verificar a sintaxe dos comandos internos e nao tem que compilar novamente.

Como tudo na vida, existem vantagens e desvantagens. AS SPs também têm alguns desvantagens:

- O MySQL não fornece boas ferramentas de desenvolvimento e depuração, portanto, é relativamente difícil depurar SPs.
- A eficiência da linguagem SQL em si não é tão alta quanto a da linguagem de programação de aplicativos e é relativamente básica.
- As SPs também podem aumentar a complexidade da implantação do aplicativo. Não apenas o código do aplicativo e as tabelas de banco 
  de dados precisam ser implantados, mas também as SPs precisam ser implantados, e se precisar migrar de sistema gerenciador de banco de dados, 
  voce terá que reescrever parte de todos os codigos SQL das SPs.
- No caso do MYSQL, o plano de execução de cada SP conectado é armazenado no cache (memória ram) de forma independente. 
  Se muitas conexões chamarem a mesma SP, o armazenamento em cache repetido causará um desperdício de recursos (memória ram).
- O código SQL da SP é difícil de interpretar. É difícil analisar um procedimento com baixa performance por exemplo, quando existe um procedimento com muitas instruçóes SQL dentro.
  Evite SP muito grandes.
 
==================================================================================*/


-- RODAR

SELECT  Id
      ,ProductName
      ,SupplierId
      ,UnitPrice
      ,Package
      ,IsDiscontinued
  FROM CLIENTE2.Product
  ORDER BY ProductName DESC;

-- CRIANDO PRIMEIRA STORED PROCEDURE

-- SERIA DESTA FORMA NO SQL SERVER, ...

CREATE PROCEDURE ProductList
AS
BEGIN
   SELECT Id
      ,ProductName
      ,SupplierId
      ,UnitPrice
      ,Package
      ,IsDiscontinued
  FROM CLIENTE2].[dbo].Product
  ORDER BY ProductName DESC
END;

-- MAS NO MYSQL PRECISA SER UM POUCO DIFERENTE:
-- Precisamos mudar o delimitador, porque podemos criar procedures no linux e la para cada instrucao, logo apos o ; ja seria executado
-- e pode existir varias operacoes dentro de uma stored procedure que nao deveria ser executada apos o ; mas sim apenas na chamada
-- da procedure que ai todos os comandos internos seriam executados como um bloco unico. 

DELIMITER $$

CREATE PROCEDURE ProductList()
BEGIN
   SELECT Id
      ,ProductName
      ,SupplierId
      ,UnitPrice
      ,Package
      ,IsDiscontinued
  FROM CLIENTE2.Product
  ORDER BY ProductName DESC;
END$$

DELIMITER ;


-- VERIFICAR A STORED PROCEDURE CRIADA NO WORKBENCH E VIA SCRIPTS ABAIXO:

SHOW PROCEDURE STATUS;

-- ou

use cliente2;
select routine_name, routine_type,definer,created,security_type,SQL_Data_Access from information_schema.routines 
where routine_type='PROCEDURE' and routine_schema='cliente2';

-- EXECUTANDO A STORED PROCEDURE CRIADA

-- NO SQL SERVER SERIA ASSIM:

EXECUTE ProductList;
OU
EXEC ProductList;

-- MAS NO MYSQL

call ProductList();

-- MODIFICANDO A STORED PROCEDURE 
-- NO SQL SERVER PODERIA USAR O ALTER PROCEDURE MAS NO MYSQL 8 E VRS ANTERIORES PRECISA DELETAR E CRIAR NOVAMENTE

DROP PROCEDURE IF EXISTS ProductList; 

DELIMITER $$

 CREATE PROCEDURE ProductList()
    BEGIN
       SELECT Id
          ,ProductName
          ,SupplierId
          ,UnitPrice
      FROM CLIENTE2.Product
      ORDER BY ProductName ASC
      LIMIT 3;
    END$$

DELIMITER ;

-- EXECUTE NOVAMENTE E VEJA O RESULTADO

CALL ProductList();


-- DELETANDO STORED PROCEDURE

DROP PROCEDURE ProductList;

-- Parameters nas Stored Procedure
-- Passando Parametro para a Stored Procedure. (IN | OUT | INOUT) (Parameter Name [datatype(length)])

--  IN Parameters

DROP PROCEDURE IF EXISTS ProductList; 

DELIMITER $$

 CREATE PROCEDURE ProductList(IN max_listprice DECIMAL(12,2))  -- NO SQL SERVER IRIA USAR @ NO NOME DA VARIAVEL
    BEGIN
       SELECT Id
          ,ProductName
          ,SupplierId
          ,UnitPrice
      FROM CLIENTE2.Product
       WHERE
        UnitPrice <= max_listprice
      ORDER BY ProductName ASC;
    END$$

DELIMITER ;

-- vamos chamar a proc passando parametro de valor maximo de preco para a proc trazer produtos mais baratos

CALL ProductList(21.00);

-- Podemos rodar o select abaixo para ver a lista completo
SELECT Id
          ,ProductName
          ,SupplierId
          ,UnitPrice
      FROM CLIENTE2.Product;


-- Passando mais de 1 Parametro para a Stored Procedure

DROP PROCEDURE IF EXISTS ProductList; 

DELIMITER $$

CREATE  PROCEDURE ProductList (IN min_listprice DECIMAL(12,2), IN max_listprice DECIMAL(12,2))
BEGIN
       SELECT Id
          ,ProductName
          ,SupplierId
          ,UnitPrice
      FROM CLIENTE2.Product
       WHERE
        UnitPrice <= max_listprice and
        UnitPrice >= min_listprice
      ORDER BY ProductName ASC;
    END$$

DELIMITER ;

-- Agora chame a PROCEDURE passando os 2 parametros

call ProductList (10, 200); -- a ordem da passagem dos parametros é essencial.

call ProductList (12, 14);


-- Alterando Stored Procedure. USANDO LIKE NA BUSCA

DROP PROCEDURE IF EXISTS ProductList; 

DELIMITER $$

CREATE  PROCEDURE ProductList (IN min_listprice DECIMAL(12,2), IN max_listprice DECIMAL(12,2), IN ProductNamePASSADA VARCHAR(50))
BEGIN
       SELECT Id
          ,ProductName
          ,SupplierId
          ,UnitPrice
      FROM CLIENTE2.Product
       WHERE
        UnitPrice <= max_listprice and
        UnitPrice >= min_listprice and
        productname LIKE CONCAT ('%' , productnamePASSADA , '%')
      ORDER BY UnitPrice DESC;
    END$$

DELIMITER ;

-- VAMOS EXECUTAR PASSANDO OS 3 PARAMENTROS

CALL ProductList (12, 15,'hok');


-- Criação de parâmetros opcionais

-- Ao executar Stored Procedure ProductList, você deve passar todos os três argumentos correspondentes aos três parâmetros.
-- O MYSQL, diferente do SQL SERVER, NAO permite que você especifique os valores padrão dos parâmetros, NO CREATE PROCEDURE, para que, ao chamar a SP (Stored Procedure), 
-- você possa ignorar os parâmetros com os valores padrão.
-- ENTAO PARA ESTE CASO VAMOS USAR UMA SOLUCAO DE CONTORNO

DROP PROCEDURE IF EXISTS ProductList; 

DELIMITER $$

CREATE PROCEDURE ProductList (IN min_listprice DECIMAL(12,2), IN max_listprice DECIMAL(12,2), IN productnamePASSADA VARCHAR(50))
BEGIN

IF min_listprice IS NULL THEN
    set min_listprice=0.00;
END IF;

if max_listprice IS NULL THEN
    set max_listprice=9999999999.99;
END IF;

SELECT Id
          ,ProductName
          ,UnitPrice
    FROM CLIENTE2.Product  
    WHERE
         UnitPrice >= min_listprice and
         UnitPrice <= max_listprice and
         productname LIKE CONCAT ('%' , productnamePASSADA , '%')
    ORDER BY
    id;
END$$

DELIMITER ;

-- VAMOS AGORA CHAMAR A PROCEDURE PASSANDO PARAMETROS

CALL ProductList (12, 15,'a');

CALL ProductList (NULL, NULL,'a');

CALL ProductList (70, NULL, 'a');

-- TRABALHANDO COM VARIAVEL

SET @orderdate = 2012; -- COLOCANDO VALORES NAS VARIAVEIS.
SELECT Id
      ,OrderDate
      ,OrderNumber
      ,CustomerId
      TotalAmount
  FROM CLIENTE2.Order
  where year(OrderDate) = @orderdate ;


-- Armazenando o resultado de uma consulta em uma variavel

SET @supplier_count = (
    SELECT 
        COUNT(*) 
    FROM 
        supplier
);

SELECT @supplier_count ; -- demonstrando o valor guardado na variavel @supplier_count


-- Armazenando valores em variaveis

SELECT     @productnameVAR := ProductName -- ATENCAO PARA USO DO := QUANDO TIVER MAIS DE UM CAMPO NO SELECT RECEBENDO DADOS
          , @listpriceVAR  := UnitPrice
    FROM CLIENTE2.Product 
    WHERE
        id = 1;
 
 SELECT @productnameVAR AS NomeProduto;
 SELECT @listpriceVAR   as PrecoUnitario;


-- OBS se retirar o where, nao vai dar erro, mas vai trazer os dados do ultimo registro

-- --------------------------------------------------------------------------------------------

--  OUT Parameters

-- A seguinte SP (Stored Procedure) retorna a quantidade de produtos existente

DROP PROCEDURE IF EXISTS totalprodutos; 

DELIMITER $$

CREATE PROCEDURE totalprodutos (
    OUT count_produto int
) 
BEGIN
    SELECT 
        count(id)
	INTO count_produto
    FROM
        product;
END$$

DELIMITER ;

-- CHAMANDO A SP

CALL totalprodutos(@totalprodutos);
SELECT @totalprodutos;

-- -------------------------------------------------------------------------------

-- IN OUT Parameters

-- A seguinte SP (Stored Procedure) retorna o nome do produto com passagem de um codigo de um produto especifico:

DROP PROCEDURE IF EXISTS Acharproduto; 

DELIMITER $$

CREATE PROCEDURE Acharproduto (
    IN produto_ID INT , 
    OUT nome_produto VARCHAR(50)
) 
BEGIN
    SELECT 
        productname
	INTO nome_produto 
    FROM
        product
    WHERE
        ID = produto_ID;
END$$

DELIMITER ;

-- CHAMANDO A SP, passando parametro precounitario = 2

SET @produto = 2;
CALL Acharproduto(@produto, @nome_produto);
SELECT @nome_produto;

-- ----------------------------------------------------------

-- ELSE IF EXEMPLO

 DELIMITER $$
 
 DROP PROCEDURE IF EXISTS SOMA ;
 
CREATE PROCEDURE SOMA ()

BEGIN

  SELECT 
        @vendas := SUM(unitprice * quantity) --  atencao para usar :=
    FROM
        orderitem i
    INNER JOIN cliente2.Order oo ON oo.id = i.OrderId
    WHERE
        YEAR(oo.orderdate) = 2012;

    SELECT @vendas;
    
    IF @vendas < 100 then
       SELECT @VENDAS AS 'Vendas de 2012 estao MENORES que 100';
    ELSEIF @vendas < 500 THEN
       SELECT  @VENDAS AS 'Vendas de 2012 estao MENORES que 500';
	ELSE 
       SELECT  @VENDAS AS 'Vendas de 2012 estao IGUAL OU MAIORES que 500';
    END IF;
    
END$$
    
DELIMITER ;

-- VAMOS CHAMAS A PROC
    
CALL SOMA();
    
-- -----------------------------------------------------

-- WHILE EXEMPLO

DELIMITER $$
 
 DROP PROCEDURE IF EXISTS testawhile ;
 
CREATE PROCEDURE testawhile ()

BEGIN

SET @qt = 0;

WHILE @qt <= 5 DO
    SELECT @qt;
    SET @qt = @qt + 1;
END WHILE;

END$$
    
DELIMITER ;

CALL testawhile ();
-- ----------------------------

-- WHILE EXEMPLO SAINDO DO LOOP COM COMANDO LEAVE. 
== NO SQL SERVER PARA SAIR DO LOOP IRIAMOS USAR O COMANDO BREAK

DELIMITER $$
 
 DROP PROCEDURE IF EXISTS testawhile ;
 
CREATE PROCEDURE testawhile ()

BEGIN

SET @qt = 0;

myloop: WHILE @qt <= 5
 DO
    SELECT @qt;
    SET @qt = @qt + 1;
    if @qt = 3 then
        LEAVE myloop;
    end if;
END WHILE myloop;

END$$
    
DELIMITER ;

-- CHAMAR A PROCEDURE

CALL testawhile();

-- ------------------------------------------------

-- SQL Server Dynamic SQL

-- exemplo 1

DROP PROCEDURE IF EXISTS dynamic ;

delimiter // 
CREATE PROCEDURE dynamic(IN tbl CHAR(64), IN col CHAR(64))
BEGIN
    SET @s = CONCAT('SELECT ',col,' FROM ',tbl );
    PREPARE stmt FROM @s;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END
//
delimiter ;

-- VAMOS CHAMAR A PROCEDURE PASSANDO PARAMETROS

call dynamic('customer','lastname');

call dynamic('customer','lastname,city');


-- exemplo 2

DROP PROCEDURE IF EXISTS dynamic2 ;

delimiter // 
CREATE PROCEDURE dynamic2(IN tbl CHAR(64), IN col CHAR(64), IN ordenacao CHAR(64))
BEGIN
    SET @s = CONCAT('SELECT ',col,' FROM ',tbl, ' ORDER BY ', ordenacao );
    PREPARE stmt FROM @s;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END
//
delimiter ;

call dynamic2('customer','id,lastname,city', 'lastname' );


-- ------------------------FIM

