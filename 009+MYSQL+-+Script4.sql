
/*==================================================================================
Curso: MYSQL
Instrutor: Sandro Servino
https://www.linkedin.com/in/sandroservino/?originalSubdomain=pt
https://www.udemy.com/user/sandro-servino-3/

VIEWS                                                        
Vantagens das views                                          

Segurança
Você pode restringir o acesso dos usuários diretamente a uma tabela e permitir que acessem um subconjunto de dados por meio de VIEWS
Por exemplo, você pode permitir que os usuários acessem o nome do cliente, telefone, e-mail por meio de uma visualização,
mas restringi-los para acessar a conta bancária e outras informações confidenciais.

Simplicidade
Um banco de dados relacional pode ter muitas tabelas com relacionamentos complexos, por exemplo, um para um e um para muitos que tornam difícil a navegação.
No entanto, você pode simplificar as consultas complexas com associações e condições usando um conjunto de VIEWS

Consistência
Às vezes, você precisa escrever uma fórmula ou lógica complexa em cada consulta.
Para torná-lo consistente, você pode ocultar a lógica de consultas complexas e cálculos nas VIEWS
==================================================================================*/

SELECT
    *
FROM
customer;-- verifica sintaxe, index etc.

-- CRIANDO A VIEW

CREATE VIEW vw_custumerMadrid AS -- view não precisa chegar tudo, melhora a performance (guarda as views nos banco selecionado), view busca dados das tabelas
SELECT * FROM customer -- selecionando todos os dados
where city ='Madrid'; -- filtrando de Madrid

-- verificar a view criada

-- chamar a view
select * from vw_custumerMadrid; 

-- chamar a view com where
select   * 
FROM vw_custumerMadrid
where phone like '%555%'; -- usando filtros dentro da própria view (evitar %teste% por questão de performance)

-- inserindo dados na tabela atraves da viewid
insert into vw_custumerMadrid (id, firstname, lastname, city, country, phone)
values (100, 'sandro', 'servino de madrid', 'Madrid', 'espanha', '9999999');

insert into vw_custumerMadrid (id, firstname, lastname, city, country, phone)
values (101, 'sandro', 'servino do porto', 'porto', 'portugal', '9999999'); -- não vai aparecer no select por causa da city não ser Madrid

select * from vw_custumerMadrid; -- nao trouxe o sandro da cidade do porto porque esta chamando a view que filtra apenas os clientes de madrid

-- O que está por detrás da view é uma outra tabela, ou seja, se alterar algo na view, altera-se a tabela a partir da qual foi gerada a view

SELECT * FROM customer where lastname = 'servino do porto'; -- e aqui vai trazer porque estou fazendo pesquisa diretamente na tabela

-- Deletando dados em tabela atraves da VIEW
-- Deletar também é possível apontando para uma view, desde que tenha apenas uma tabela, se tiver um conjunto de tabelas relacionados não é possível. Ou ligar ON CASADE 

SET SQL_SAFE_UPDATES = 0; -- para poder deletar sem usar a cláusula PK (garantir integridade, pois pode ter mais de uma linha com 'servino de madrid, o que não é o caso aqui
delete  from vw_custumerMadrid where lastname = 'servino de madrid'; -- AND id <> 0 -- poderia ser usado (gambiarra), pois precisa passar PK junto no MySQL, ao invés usar SET SQL_SAFE_UPDATES = 0

SELECT * FROM vw_custumerMadrid where lastname = 'servino de madrid'; -- já apagado na view
SELECT * FROM customer where lastname = 'servino de madrid'; -- consequentemente apagou na tabela que serviu como molde para a view

select   *
FROM vw_custumerMadrid
where phone like '%555%';

BEGIN; -- fica apenas no log (segurança)
delete from vw_custumerMadrid
where phone like '%555%';
-- poderia ter mais blocos com insert, update etc (principalmente se forem dependentes, pois se o servidor cair, volta tudo, sem ser parcial a volta)
-- se der commit, commita todo o bloco, mesma coisa para o rollback
-- sempre dar commit depois

select   * -- apagado não definitivamente
FROM vw_custumerMadrid
where phone like '%555%';

ROLLBACK; -- retornando para estado anterior, como pode ser visto logo abaixo

select   *
FROM vw_custumerMadrid
where phone like '%555%';

-- View com Join
-- View (recupera dados) é sempre para select, nunca para updates, deletes etc.
CREATE VIEW dailysales AS
SELECT
    year(orderdate) AS y, -- retirando o ano de DATETIME por meio da função YEAR
    month(orderdate) AS m, -- -- retirando o mês de DATETIME por meio da função MONTH
    day(orderdate) AS d, -- retirando o dia de DATETIME por meio da função DAY
    p.id,
    productname,
    quantity * i.unitprice AS sales --  multiplicando quantidade e preço para obter as vendas (duas colunas)
FROM
    CLIENTE2.Order AS o
INNER JOIN orderitem AS i
    ON o.id = i.orderid
INNER JOIN product AS p
    ON p.id = i.productid; 
-- Não se pode ordenar (ORDER BY) dentro da criação da view, pois dá erro. Usa-se quando se chama a view pelo SELECT

-- Depois apenas rode

SELECT *  FROM dailysales ORDER BY y, m, d, sales desc; -- poderia apenas rodar esse comando após a view de dailysales criada, não tendo a necessidade de reutilizar aquele bloco grande e compleco de novo

select y as ano, m as mes, sum(sales) as VendasMes -- somando vendas do mês pelo agrupamento (y e m foram criadas dentro da view)
	from dailysales
	group by y, m -- agrupando por ano e mês (como só há 1 mês, não faz diferença agrupar por mês)
	order by ano ASC, mes DESC;

select y as ano, avg(sales) as VendasmediaANO -- média de cada ano
	from dailysales
	group by ano -- poderia usar y (ano ou y se referem a mesma coluna)
	order by Y asc;

-- PARA ALTERAR A VIEW ACRESCENTANDO DADOS DO CLIENTE

-- CREATE OR ALTER VIEW FUNCIONA APENAS NO SQL SERVER. 
CREATE OR ALTER VIEW dailysales -- cria ou altera caso já estista a view dailysales
AS
SELECT
    year(orderdate) AS y,
    month(orderdate) AS m,
    day(orderdate) AS d,
    p.id,
    productname,
    quantity * i.unitprice AS sales,
    c.FIRSTNAME, 
    c.LASTNAME
FROM
    CLIENTE2.Order AS o
INNER JOIN customer as c
    ON c.id = o.customerid 
INNER JOIN orderitem AS i
    ON o.id = i.orderid
INNER JOIN product AS p
    ON p.id = i.productid;
    
ALTER VIEW dailysales -- alterando view no MySQL
AS
SELECT
    year(orderdate) AS y,
    month(orderdate) AS m,
    day(orderdate) AS d,
    p.id,
    productname,
    quantity * i.unitprice AS sales,
    c.FIRSTNAME, 
    c.LASTNAME
FROM
    CLIENTE2.Order AS o
INNER JOIN customer as c
    ON c.id = o.customerid 
INNER JOIN orderitem AS i
    ON o.id = i.orderid
INNER JOIN product AS p
    ON p.id = i.productid;

SELECT *  FROM dailysales ORDER BY y, m, d, sales desc;

-- SELECT TOP 5 no SQL Server, ao invés de LIMIT 5
SELECT  CONCAT(FirstName , ' ' , LastName) AS NomeCompleto , sum(d.sales) AS Vendas FROM dailysales d -- concatenando primeiro e último nome -- é possível fazer JOIN com VIEW e tabelas (CUIDADO, acima de 6 JOINS com tabelas grandes é perigoso, ainda mais com VIEWS complexas, ou VIEW dentro de VIEW. Deixa o otimizador de consulta [query] confuso. Opte por criar tabelas temporárias para realizar JOINs, quebrando as querys)
group by d.FirstName, d.LastName -- agrupando por primeiro e úlitimo nome
limit 5; -- limitando 5 linhas

-- Deletar dados atraves de view que acessam varias tabelas
delete from dailysales; -- [FUNCIONA APENAS PARA UMA VIEW C/ UMA TABLE] não vai funcionar pois na view dailysales há dados de várias tabelas, não sabendo qual dado deletar de qual tabela (ON CASCADE não está ligado)
-- verifique o erro> Can not delete from join view 'cliente2.dailysales'

truncate table cliente2.dailysales; -- [FUNCIONA APENAS PARA TABLE] view, não tabela -- deleta dados de uma forma mais rápido que delete, a qual gera log, já o truncate não gera tantos logs
-- verifique o erro: Table 'cliente2.dailysales' doesn't exist
-- NAO É UMA TABELA PARA TER DADOS DELETADOS MAS SIM UMA VIEW

-- PARA DELETAR VIEW

DROP VIEW dailysales; -- deletando view

-- VERIFICAR SE A VIEW AINDA EXISTE

-- CRIAR NOVAMENTE A VIEW

CREATE VIEW dailysales
AS
SELECT
    year(orderdate) AS y,
    month(orderdate) AS m,
    day(orderdate) AS d,
    p.id,
    productname,
    quantity * i.unitprice AS sales,
    c.FIRSTNAME, 
    c.LASTNAME
FROM
    CLIENTE2.Order AS o
INNER JOIN customer as c
    ON c.id = o.customerid 
INNER JOIN orderitem AS i
    ON o.id = i.orderid
INNER JOIN product AS p
    ON p.id = i.productid;
    
-- DELETAR A ESTRTUTURA VIA DROP DE UMA VIEW DENTRO DE UMA TRANSACAO E DEPOIS REALIZAR ROLLBACK
    
BEGIN; -- não funcionará pois funciona apenas com DML
  DROP VIEW dailysales; -- apaga apenas a view, não a tabela da qual ela surgiu

ROLLBACK; -- não é possível voltar (commit implícito com DDL)

SELECT * FROM dailysales;
--  BEGIN, ROLLBACK: NAO FUNCIONA PARA CRIACAO DE OBJETOS E DELECAO DE OBJETOS, MAS SIM PARA TRANSACOES, OU SEJA, DADOS, DENTRO DE TABELAS
-- NO MYSQL COMANDOS DO TIPO DDL COMO CREATE TABLE, ALTER TABLE, CREATE VIEW, DROP VIEW,... O MYSQL FAZ COMMIT IMPLICITO
