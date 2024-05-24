
/*==================================================================================
Curso: MYSQL
Instrutor: Sandro Servino
https://www.linkedin.com/in/sandroservino/?originalSubdomain=pt
https://www.udemy.com/user/sandro-servino-3/

 FUNCTIONS   

As funções ajudam a simplificar seu código. Por exemplo, você 
pode ter um cálculo complexo que aparece em muitas consultas. 
Em vez de incluir a fórmula em cada consulta, você pode criar 
uma função que encapsula a fórmula e a usa em cada consulta.    

OBS:
0.  Existem dezenas de funcoes que ja vem do mysql, como SUM(), AVG(), MIN(), MAX(), CONCAT(), ETC. Basta pesquisa no Google que consegue a lista completa atualizada.
1.  Especificar um parâmetro como IN, OUT ou INOUT é válido apenas para um PROCEDURE. 
    Para uma FUNÇÃO, os parâmetros são sempre considerados parâmetros IN.  
2. A cláusula RETURNS pode ser especificada apenas para uma FUNCTION, 
   para a qual é obrigatória. Ele indica o tipo de retorno da função e o corpo 
   da função deve conter uma declaração de valor RETURN.     
3. O corpo da function consiste em uma instrução de rotina SQL válida. 
   Pode ser uma instrução simples, como SELECT ou INSERT, ou uma instrução composta 
   escrita usando BEGIN e END. As instruções compostas podem conter declarações, 
   loops e outras instruções da estrutura de controle.
4. Uma stored procedure é compilada no momento da criação e uma function a cada 
   execução, neste sentido, stored procedure podem ter ganhos de performance 
   comparados com a function e dependendo da qt de vezes que é executada e do tamanho da function
5. ** Stored procedure so podem ser executadas com CALL mas function são executadas com comando SELECT e podem
   ser bastante uteis neste contexto.
==================================================================================*/

-- VAMOS AOS EXEMPLOS 

DROP FUNCTION IF EXISTS OLA;

-- EXEMPLO NO MYSQL WORKBENCH. PODE IR DIGITANDO NO MYSQL CLIENT NO LINUX, LINHAS A LINHA DESTA FORMA SEM ;

CREATE FUNCTION ola (ss CHAR(20)) -- pode definir qual parâmetro receberá (não e obrigatório)
RETURNS CHAR(50) DETERMINISTIC -- Se fixar aqui se é deterministico ou nao, nao dara mais erros. (Retorna char(50), sendo determinística -- sempre especificar o tipo de caractere)
       RETURN CONCAT('ola , ',ss,'!'); -- retorna concatenando 'ola', 'ss','!'

-- PARA CHAMAR A FUNCTION PASSANDO PARAMETRO
SELECT ola('world'); -- ss

DROP FUNCTION IF EXISTS TESTE;

DELIMITER %%
CREATE FUNCTION teste(palavra CHAR(10))
RETURNS CHAR(10) DETERMINISTIC
BEGIN
	RETURN CONCAT('TE ', palavra);
END%%
DELIMITER ;

SELECT teste('amo!') AS status;
     
-- DE UMA OLHADA NA FUNCTION NO WORKBENCH
            
-- --------------------------------------------------------------

-- PARA OS ALUNOS QUE PASSARAM PELO MODULO SQL SERVER OU FIZERAM O CURSO DO SQL SERVER, O CREATE FUNCTION  É ASSIM:
CREATE FUNCTION FuncDesconto(
    @qt INT,
    @precounitario DEC(10,2),
    @desconto DEC(4,2)
)
RETURNS DEC(10,2)
AS 
BEGIN
    RETURN @qt * @precounitario * (1 - @desconto);
END;

-- Esta function sera utilizada como apoio a outras storage procedures. 
-- A partir de parametros enviados, de quantidade de produtos, valor unitario de um produto
-- e percentual de desconto, a function ira retornar desconto para o produto.

-- MAS NO MYSQL É ASSIM:

DROP FUNCTION IF EXISTS FuncDesconto;

DELIMITER $$

CREATE FUNCTION FuncDesconto(
    qt INT,
    precounitario DEC(10,2), -- dec é decimal
    desconto DEC(4,2)
)
RETURNS DEC(10,2) DETERMINISTIC -- retornando o tipo de dado primário (poderia ser DEC(4,2), não iria fazer diferença, a não ser se a multiplicação necessitasse de mais casas)

BEGIN -- início da instrução
    RETURN qt * precounitario * (1 - desconto); -- apenas uma instrução
END$$ -- fim da instrução

DELIMITER ;

-- PARA CHAMAR A FUNCTION PASSANDO PARAMETRO
SELECT FuncDesconto(1,100,0.1) valorvenda; -- poderia ser só .1

-- VAMOS VERIFICAR NO WORKBENCH E VIA SCRIPT A FUNCTION CRADA
SHOW FUNCTION STATUS WHERE db = 'CLIENTE2'; -- mostrando dados das functions criadas

-- OUTRO EXEMPLO

DROP FUNCTION IF EXISTS NIVELCLIENTE;

DELIMITER $$

CREATE FUNCTION NIVELCLIENTE(
	credito DECIMAL(10,2)
) 
RETURNS VARCHAR(20) DETERMINISTIC -- retorna varchar(20)
BEGIN
    DECLARE NIVELCLIENTE VARCHAR(20); -- declarando variável NIVELCLIENTE que receberá os valores após as confições se encaixarem no parãmetro de entrada (credito)

    IF credito < 1000 THEN -- se... então... -- comece sempre do menor para maior ou maior para menor (ordenado)
        SET NIVELCLIENTE = 'PRATA'; -- usando SET para atribuir valor  à variável 
    ELSEIF credito < 5000 THEN -- senão... então...
		SET NIVELCLIENTE = 'PLATINA';
    ELSEIF (credito >= 5000 AND -- função booleana
			credito <= 10000) THEN
        SET NIVELCLIENTE = 'OURO';
	ELSE -- else genérico para,caso não se enquadre em nenhuma das condições, retorne um valor not null
        SET NIVELCLIENTE = 'SUPEROURO';
    END IF; -- finalizando IF
	-- return the customer level
	RETURN (NIVELCLIENTE); -- retornando variável para função que chamará-la
END$$
DELIMITER ;

SELECT NIVELCLIENTE(100); -- passando parâmetros de entrada (credito) para a função
SELECT NIVELCLIENTE(4999);
SELECT NIVELCLIENTE(5000);
SELECT NIVELCLIENTE(10000);
SELECT NIVELCLIENTE(10001);  -- aqui tem erro de logica. Comece sempre neste tipo de logica da menor comparacao para maior ou vice versa para nao confundir
                             -- o compilador do mysql e lembre de verificar, se for necessário de fechar todas as possibiliade. AQUI PODERIA COLCOAR UMA 
							 -- EXCEL PARA TODOS OS OUTROS VALORES COMO UM ELSE GENERICO
                             -- ELSE
                                  -- SET NIVELCLIENTE = 'SUPER OURO';


-- Este proximo exemplo, demonstra como utilizar a function como apoio na execucao de alguma instrucao SQL

SELECT id, quantity, unitprice FROM ORDERITEM;

-- VAMOS ver como podemos chamar a function criada passando os parametros quantity, unitprice que estao sendo lidos em tempo real pelo select

SELECT 
    id, 
    FuncDesconto(Quantity,unitprice,0.1) valorvendafinal -- passando colunas quantity e unitprice na função -- usando a função FuncDesconto para diminuir o tamanho que ficaria esta instrução caso não houvesse função sendousada
FROM 
   orderitem
GROUP BY 
    id;

-- E PODEMOS COM O RESULTADO DO RETORNO DA FUNCTION FUNCDESCONTO ALIMENTAR FUNCAO SUM
SELECT 
    SUM(FuncDesconto(Quantity,unitprice,0.1)) valorvendafinal -- função criada dentro da SUM
FROM 
   orderitem;
    
-- QUER CHECAR SE ESTA CERTO, VAMOS VERIFICAR O ID 1
SELECT id, quantity, unitprice FROM ORDERITEM;
SELECT FuncDesconto(12,14,.1) valorvenda;

-- --------------- VAMOS A OUTRO EXEMPLO

DROP FUNCTION IF EXISTS SOMATUDO;

DELIMITER $$


CREATE FUNCTION SOMATUDO() -- criando função sem passar valor no parãmetro
RETURNS DEC(10,2)  deterministic

BEGIN
    DECLARE somatudovar DEC(10,2); -- declarando variável "tabela"
SELECT sum(unitprice*quantity) AS SOMATOTAL
    INTO somatudovar -- guardando (INTO) na "tabela" somatudovar resultado sum(unitprice*quantity)
    FROM orderitem;
RETURN somatudovar; -- retorna variável que tem a soma de tudo guardada

END$$

DELIMITER ;


-- EXECUTAR
SELECT SOMATUDO();


-- -----------------------------------------------------------------------------------------------------------------------------------------

-- --------- TABELAS TEMPORARIAS

-- O MYSQL NAO TEM VARIAVEIS DO TIPO TABELA COMO EXISTE NO SQL SERVER, MAS PODEMOS CRIAR TABELAS TEMPORARIAS
-- como também pode ser feito no SQL SERVER.

/*============================================================================================================================
TEMPORARY #TABLE 
- As tabelas temporarias serao limpas no final da sessao que estao sendo utilizadas.

Vantagens de usar tabela temporária

- O conjunto de dados da tabela temporária é necessário em outras consultas porque pode reduzir drasticamente a complexidade 
  de todo o sql (por exemplo, você divide uma consulta complexa, com mais de 7 joins, com groups by, etc, em pedaços de pequenas consultas com o 
  uso de tabelas temporárias), e no final faz um select com join entre estas tabelas temporarias. Queries complexas pode fazer
  com que o otimizador de queries crie planos ruins e quebrando as consultas em pequenas tabelas pode ter melhor desempenho em algumas situacoes
  
- O conjunto de resultados é necessário mais de uma vez em consultas diferentes, dentro de uma mesma sessao ou stored procedures, 
  portanto, elimina a necessidade de executar a consulta novamente para obter os mesmos dados.
  
============================================================================================================================*/

-- criando tabela temporaria local

use cliente2;

-- Poderia estar dentro de uma function, procedure ou function:
CREATE TEMPORARY TABLE customerBerlin -- essa tabela temporária existe apenas nesta sessão, depois de sair some
(
  id int NOT NULL,
  firstname varchar(40) DEFAULT NULL,
  lastname varchar(40) DEFAULT NULL,
  city varchar(40) DEFAULT NULL,
  country varchar(40) DEFAULT NULL,
  phone varchar(20) DEFAULT NULL,
  PRIMARY KEY (id) 
  );

INSERT INTO customerBerlin -- inserindo dados da tabela customer na customerBerlin
(id, firstname, lastname, city, country, phone )
SELECT id, firstname, lastname, city, country, phone
FROM customer
where city = "berlin";

/* Vamos ver o resultado */
SELECT * FROM customerBerlin;
SELECT * FROM customer
WHERE city = 'Berlin'; -- checando resultado da table customerBerlin

/* Para deletar a tabela temporaria 
NAO EH NECESSARIO DELETAR O OBJETO TABELA TEMPORARIA PORQUE ELE SERA AUTOMATICAMENTE DELETADO QUANDO A SESSAO QUE A CRIOU FOR FECHADA*/
DROP TABLE customerBerlin;

-- OBS> DIFERENTEMENTE DO SQL SERVER, NÃO É POSSIVEL, NA ATUAL VERSAO DO MYSQL, CRIAR STORED PROCEDURES TEMPORARIAS
-- ------------------------FIM

