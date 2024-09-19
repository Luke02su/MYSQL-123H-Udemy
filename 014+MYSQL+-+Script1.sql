
/*==================================================================================
Curso: MYSQL
Instrutor: Sandro Servino
https://www.linkedin.com/in/sandroservino/?originalSubdomain=pt
https://www.udemy.com/user/sandro-servino-3/

-------  Mecanismos de log e auditoria em MySQL

https://dev.mysql.com/doc/refman/5.7/en/server-logs.html

- Por padrão, nenhum log é habilitado, exceto o log de erros que é salvo como um arquivo no Windows, como ja vimos em aulas anteriores.
- Você pode gerar log para transacoes sql em geral e tambem gerar log especifico para transacoes sql lentas durante o tempo de execução. 
- Você pode habilitar ou desabilitar o log ou alterar o nome do arquivo de log que é gravado no disco. 
- Você ainda pode dizer ao servidor mysql para gravar transacoes sql em tabelas de log, arquivos de log no disco como um arquivo ou ambos.

==================================================================================*/

-- LAB1

-- Vamos executar no workbench o comando abaixo afim de verificarmos se os logs estao sendo gerados por padrao e onde.
show variables like 'general_log%'; -- log para capturar transaçoes
show variables like 'slow_query_log%'; -- log para capturar transaçoes mais lentas

-- Veja o conteudo das tabelas de log, caso tenham os logs ja sendo capturados
select * from mysql.general_log;
select * from mysql.slow_log;

-- --------------------------------------------------------------------------------------------------------------------

-- VAMOS FAZER UM PARENTESE AQUI, ANTES DE CONTINUAR A FALAR SOBRE LOG...

-- Está tentando achar a base mysql no workbench e não está vendo?
-- digite show databases; 
-- Esquemas internos, como performance_schema , information_schema e mysql , estão ocultos por padrão para minimizar riscos desnecessários.
-- Para exibir, va no menu EDITAR, PREFERENCIAS, SQL EDITOR e MARQUE A OPCAO "Show Metadata and Internal Schemas". Feche o Workbench e abra-o novamente e veja as bases internas.
-- https://dev.mysql.com/doc/workbench/en/wb-sql-editor-navigator.html
-- https://dev.mysql.com/doc/workbench/en/wb-preferences-sql-editor.html#wb-preferences-sql-editor-main

-- Todo MySQL é fornecido com esquemas/bancos de dados de sistema padrão. Esses são:
--   mysql - é o banco de dados do sistema que contém tabelas que armazenam as informações exigidas pelo servidor MySQL
--   information_schema - fornece acesso aos metadados dos bancos de dados
--   performance_schema - é um recurso para monitorar a execução do MySQL Server em um nível baixo
--   sys - um conjunto de objetos que ajuda DBAs e desenvolvedores a interpretar dados coletados pelo banco Performance_Schema

-- Vamos voltar a falar sobre objetos destas bases internas que ajudam o DBA no seu dia a dia, até ja vimos vários exemplos como por exemplo
-- os comandos acima select * from mysql.general_log, mas existem varios objetos, como tabelas, views que podemos ler e levantar informacoes
-- sobre a instancia mysql, bancos de dados dos usuários e seus objetos, usuários, papéis, etc, estarão ai, porque como já ocorre nos melhores bancos do mundo
-- toda os metadados sobre todos os objetos dos bancos de usuários, informacoes uteis para identificarmos problemas de performance, auditoria, segurança, etc
-- ficam registrados nestes 4 bancos de dados de sistema, então teremos novas oportunidades de vermos outros objetos...

-- --------------------------------------------------------------------------------------------------------------------

--- MAS AGORA VOLTANDO AO TEMA DA AULA, OU SEJA LOG...

-- O conteúdo do log é acessível por meio de instruções SQL. Isso permite o uso de consultas que selecionam apenas as 
-- entradas de log que atendem a critérios específicos. Por exemplo, para selecionar o conteúdo de log associado a um 
-- cliente específico (o que pode ser útil para identificar consultas problemáticas desse cliente), 
-- é mais fácil fazer isso usando uma tabela de log do que um arquivo de log.

-- Em geral, o objetivo principal das tabelas de log é fornecer uma interface para os usuários observarem a execução em 
-- tempo de execução do servidor.

-- DETALHANDO MAIS...

-- Para gravar as transacoes gerais SQL na tabela de log e no arquivo de log no disco como um arquivo, use --log_output=TABLE,FILE para selecionar os destinos de log 
--    e --general_log para ATIVAR o log das transacoes gerais. 

--    Estes parametros devem estar no my.ini se quiser deixar gerando logs de forma definitiva apos o restart do servico mysql,
--    para por exemplo depois de um tempo de geracao, poder ler da tabela de logs o que estava a rodar de forma geral ou as queries 
--    com pior performance relativa, falo relativo porque mede apenas o tempo que elas rodam, e nao o gasto de cpu, que ela pode rodar em alguns momentos
--    de forma mais demorada porque esta a ser bloqueada por outro processo ou sobrecarga do servidor, mas já ajuda a identificar consultas que podem estar
--    sistematicamente rodando por mais tempo que seria o desejado. 
--    Neste caso, apos ter resolvido o problema, por exemplo criando indices, atualizando estatisticas ou alterando o codigo sql, 
--    poderá desligar esta opcao, ou pode deixar ligado para uma comprovacao de alteracao de dados, em caso de necessidade de uma futura auditoria. Não é o melhor instrumento
--    para auditoria, pois gera dependendo da quantidade de transacoes no banco e performance da maquina, perda de performance no sistema que utiliza o banco. Ainda, devido 
--    a falta de informacoes as vezes nececessarias para uma auditoria mais profunda, mas de qualquer forma vamos ver as possibilidades.

--    Pode se quiser, rodar de forma imediata apenas na sua sessao para verificar todas as transacoes sql em geral, atraves dos comandos:
SET GLOBAL general_log = 1; -- ON ativa log, mas se sair e voltar volta para 0, desativado
SET GLOBAL log_output = 'table'; -- gere log na tabela, mysql, nao no arquivo windows

select * from cliente2.order;
select * from mysql.general_log; -- guardando log de varios comandos

-- AQUI UM MACETE. RODANDO O COMANDO ACIMA, NO CAMPO ARGUMENT SÓ PODE VER OS COMANDOS EM HEXADECIMAL. RODE ESTE COMANDO ABAIXO PARA CONVERTER PARA TEXTO E ASSIM RESOLVER ESSE PROBLEMA
select a.*, convert(a.argument using utf8) as argumentSQL from mysql.general_log a;

-- Vamos gerar o log tambem no disco em um arquivo, para isto, de os comandos abaixo:
SET GLOBAL general_log = 1; -- aqui nao precisava mais ligar nesta sessao porque ja estava ligado, mas nao tem problema em colocar novamente.
SET GLOBAL log_output = 'FILE,TABLE'; -- gerando tabela e arquivo
SET global general_log_file= 'D:\\BKP_MYSQL_DATA\\Data\\mysqld-general-queryWB.log'; -- repare que precisa colocar \\ -- mudando pasta padrao para guardar logs (nção guarda informacao do user que fez, problema em termos de auditoria. Problema do community comparado ao enterprise)

-- ideal guardar logs em outro disco separado, rapido, gerando em arquivo (file)

-- Vamos ver o resultado agora na tabela e no arquivo no disco.

select * from cliente2.order;
select a.*, convert(a.argument using utf8) as argumentSQL from mysql.general_log a;

-- Para ver a confirmacao da configuracao na instancia mysql
show variables like 'general_log%';

-- e depois quando nao quiser mais salvar as novas transacoes sql no log, rodar:
SET GLOBAL general_log = 0;
show variables like 'general_log%';

-- OBS: Se estivesse ligado a geracao do log apenas via sessao no workbench, se parar o servico mysql, ele perde a configuracao de gerar log e volta para o padrao de nao gerar log
-- Para tornar permanente até que deseje remover novamente, vai precisar inserir estes parametros no my.ini ou my.cnf se estiver no linux

-- E se quiser deletar os dados da tabela de log rapidamente:
TRUNCATE mysql.general_log;
select * from mysql.general_log;

-- Para deletar os arquivos de log gerados no disco, basta ir na pasta e deletar o arquivo
--  D:\MYSQL_CURSO\Data\mysqld-general-queryWB.log

-- ------------------------------------------------------------------------------------------------------------------

-- LAB2

-- Para poder gravar as transacoes sql mais lentas apenas nas tabelas de log, use as opcoes --log_output=TABLE e --slow_query_log 

SET GLOBAL slow_query_log = 1;
SET GLOBAL long_query_time = 0.5; -- tempo em segundos que o mysql ira salvar no log as operacoes que levaram pelo menos 5 segundos
SET GLOBAL log_output = 'table';
select * from mysql.slow_log;

-- e para desabilitar
SET GLOBAL slow_query_log = 0;

-- ------- VAMOS A UM OUTRO EXEMPLO:

-- LIGUE O LOG E RODE O MESMO COMANDO para selecionar dados na tabela order e veja o que foi guardado no log

SET GLOBAL slow_query_log = 1;
SET GLOBAL long_query_time = 0.5; -- tempo em segundos
SET GLOBAL log_output = 'table';

-- Rode os comandoS abaixos:

select * from cliente2.product; -- este comando vai rodar muito rapido, entao nao deveria aparecer no log, mas o comando abaixo vai demorar 10 segundos e deveria aparecer.
SELECT SLEEP(10);  -- podera usar este codigo tambem DO SLEEP(10);

-- Depois de terminar de rodar, verifique o que foi gerado no log
select * from mysql.slow_log; 
-- repare que o campo sql_text ainda esta com BLOB e precisa converter para text para poder ler o comando.
select *, convert(sql_text using utf8) as argumentSQL from mysql.slow_log;

-- no final do processo desabilite a captura quando resolveu os problemas ou deixe durante um tempo para capturar as queries mais lentas
SET GLOBAL slow_query_log = 0;

-- VAMOS DELETAR OS LOGS
TRUNCATE mysql.general_log;
TRUNCATE mysql.slow_log;

select * from mysql.general_log;
select * from mysql.slow_log;

-- --------------------------------------------------------------------------------------------------------------

-- LAB 3

-- Para gerar arquivo no windows com operacoes mais lentas, podemos rodar no workbench

SET GLOBAL slow_query_log = 1;
SET GLOBAL long_query_time = 0.5; -- tempo em segundos que o mysql ira salvar no log as operacoes que levaram pelo menos 5 segundos
SET GLOBAL log_output = 'file';
SET GLOBAL slow_query_log_file  = 'D:\\BKP_MYSQL_DATA\\\Data\\mysqld-slow-queryNEW.log';

SELECT SLEEP(10);

-- Va no diso e veja o que foi gerado no arquivo mysqld-slow-queryNEW.log

-- e para desabilitar o log no workbench

SET GLOBAL slow_query_log = 0;

-- SE TIVER ALGUM ERRO ou nao for gerado o arquivo de log na pasta, verifique se nesta pasta tem permissao do user de servico do mysql
-- para criar e alterar arquivos. Va na pasta Data, onde estao seus dados, botao direito, propriedades, seguranca, e verifique se o user do 
-- mysql está lá com a opcao full control ou modificar. O usuario padrao é REDE se estiver em portugues. Veja em servicos mysql, na coluna
-- fazer logon como, o nome do usuario de servico que esta rodando seu mysq,

-- --------------------------------------------------------------------------------------------------------------------------

-- LAB 4

-- VAMOS CONFIGURAR AGORA o my.ini para tornar permanente a geracao do log, mesmo se reiniciar o servico mysql. VAMOS REALIZAR ALGUNS TESTES. PARE O MYSQL.
-- Coloque as linhas abaixo do label [mysqld] que vai estar no seu my.ini se estiver com mysql no windows
-- Procure sempre a fonte oficial primaria antes de sair buscando em foruns:
--    https://dev.mysql.com/doc/refman/8.0/en/server-system-variables.html#sysvar_general_log

-- MAS ATENCAO ****** NAO DUPLIQUE AS INFORMACOES ABAIXO NO MY.INI, PORQUE JA EXISTEM ESTAS VARIAVEIS. SE COPIAR OS CODIGOS ABAIXO E COLAR NO MY.INI
-- O MYSQL VAI INICIAR O SERVICO, VAI ATIVAR, OS LOGS ABAIXO, MAS VAI DESATIVAR PORQUE JA TEM ESTAS VARIVEIS NO MY.INI DEFINIDAS COMO 0, ENTAO BUSQUE NO MY.INI
-- E ALTERE PARA OS VALORES ABAIXO PARA REALIZAR SEUS TESTES, SE DESEJAR E DEPOIS RETORNE PARA 0, AS VARIAVEIS general-log E slow-query-log para nao ficar gerando log
-- e enchendo seu disco, se nao desejar.

# General and Slow logging.
log-output=FILE

general-log=1

general_log_file="mysqld-general-queryFILE.log"

slow-query-log=1

slow_query_log_file="mysqld-slow-queryFILE.log"

long_query_time=10

-- INICIE O SERVICO DO MYSQL E VERIFIQUE NA SUA PASTA DATA, QUE OS DOIS ARQUIVOS JA FORAM CRIADOS.

-- E RODE OS COMANDOS ABAIXOS NO WORKBENCH

show variables like 'general_log%';
show variables like 'slow_query_log%';

select * from cliente2.account;
SELECT SLEEP(10);  -- podera usar este codigo tambem DO SLEEP(10);

-- ABRA OS DOIS ARQUIVOS DE LOG E VEJA O CONTEUDO, agora repare que nao temos informacoes mais detalhada no log geral como por exemplo que executou comando 
-- especifico, o que é disponibilizado na auditoria para versao MYSQL Enterprise.

-- DEPOIS ALTERE NOVAMENTE O MY.INI DESABILITANDO OS LOGS

# General and Slow logging.
log-output=FILE

general-log=0

general_log_file="mysqld-general-queryFILE.log"

slow-query-log=0

slow_query_log_file="mysqld-slow-queryFILE.log"

long_query_time=10

-- ------------------------------------------------------------------------------------------------------------

-- LAB5

-- VAMOS VER UM EXEMPLO DE COMO PODERIAMOS USAR TRIGGER PARA GERAR auditorias de forma manual.
-- Vimos na aula sobre trigger um exemplo, mas vamos usar um outro exemplo mais sofisticado que controla insert, update e deletes usando objetos JSON
-- https://vladmihalcea.com/mysql-audit-logging-triggers/


use cliente2;

DROP TABLE IF EXISTS book_audit_log;

CREATE TABLE book_audit_log (
    book_id BIGINT NOT NULL,
    old_row_data JSON,
    new_row_data JSON,
    dml_type ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    dml_timestamp TIMESTAMP NOT NULL,
    dml_created_by VARCHAR(255) NOT NULL,
    PRIMARY KEY (book_id, dml_type, dml_timestamp)
);

DROP TABLE IF EXISTS book;

CREATE TABLE book (
    id BIGINT NOT NULL,
    author VARCHAR(255),
    new_row_data JSON,
    price_in_cents int,
    publisher VARCHAR(255),
    title VARCHAR(255),
    PRIMARY KEY (id)
);


-- VAMOS CRIAR AS TRIGGERS

DROP TRIGGER IF EXISTS book_insert_audit_trigger;

DELIMITER $$

CREATE TRIGGER book_insert_audit_trigger
AFTER INSERT ON book FOR EACH ROW
BEGIN
    INSERT INTO book_audit_log (
        book_id,
        old_row_data,
        new_row_data,
        dml_type,
        dml_timestamp,
        dml_created_by
    )
    VALUES(
        NEW.id,
        null,
        JSON_OBJECT(
            "title", NEW.title,
            "author", NEW.author,
            "price_in_cents", NEW.price_in_cents,
            "publisher", NEW.publisher
        ),
        'INSERT',
        CURRENT_TIMESTAMP,
        user()
    );
END$$

DELIMITER ;

-- -----------------------------------------------------------------

-- VAMOS TESTAR A INCLUSAO RODANDO O CODIGO

INSERT INTO book (
    id,
    author,
    price_in_cents,
    publisher,
    title
)
VALUES (
    1,
    'Vlad Mihalcea',
    3990,
    'Amazon',
    'High-Performance Java Persistence 1st edition'
);

-- -----------------------

-- E AGORA VAMOS VER O QUE FOI FOI GERADO NA TABELA DE LOG

select * from book;

select * from book_audit_log;

-- ---------------------------------------------------------------

-- VAMOS CRIAR A TRIGGER QUE IRA CONTROLAR OS UPDATES REALIZADOS

DROP TRIGGER IF EXISTS book_update_audit_trigger;

DELIMITER $$

CREATE TRIGGER book_update_audit_trigger
AFTER UPDATE ON book FOR EACH ROW
BEGIN
    INSERT INTO book_audit_log (
        book_id,
        old_row_data,
        new_row_data,
        dml_type,
        dml_timestamp,
        dml_created_by
    )
    VALUES(
        NEW.id,
        JSON_OBJECT(
            "title", OLD.title,
            "author", OLD.author,
            "price_in_cents", OLD.price_in_cents,
            "publisher", OLD.publisher
        ),
        JSON_OBJECT(
            "title", NEW.title,
            "author", NEW.author,
            "price_in_cents", NEW.price_in_cents,
            "publisher", NEW.publisher
        ),
        'UPDATE',
         CURRENT_TIMESTAMP,
        user()
    );
END$$

DELIMITER ;

-- -----------------------------------------------------------------

-- VAMOS TESTAR A ALTERACAO RODANDO O CODIGO

UPDATE book
SET price_in_cents = 4499
WHERE id = 1;

-- -----------------------

-- E AGORA VAMOS VER O QUE FOI FOI GERADO NA TABELA DE LOG

select * from book;

select * from book_audit_log;

-- -----------------------------------------------------------------

DROP TRIGGER IF EXISTS book_delete_audit_trigger;

DELIMITER $$

CREATE TRIGGER book_delete_audit_trigger
AFTER DELETE ON book FOR EACH ROW
BEGIN
    INSERT INTO book_audit_log (
        book_id,
        old_row_data,
        new_row_data,
        dml_type,
        dml_timestamp,
        dml_created_by
    )
    VALUES(
        OLD.id,
        JSON_OBJECT(
            "title", OLD.title,
            "author", OLD.author,
            "price_in_cents", OLD.price_in_cents,
            "publisher", OLD.publisher
        ),
        null,
        'DELETE',
        CURRENT_TIMESTAMP,
        user()
    );
END$$

DELIMITER ;

-- -----------------------------------------------------------------

-- VAMOS TESTAR A DELECAO RODANDO O CODIGO

DELETE FROM book
WHERE id = 1;

-- -----------------------

-- E AGORA VAMOS VER O QUE FOI FOI GERADO NA TABELA DE LOG

select * from book;

select * from book_audit_log;

-- -----------------------------------------------------------------------------------------------------------


-- SE PRECISARMOS LER OS DADOS DO JSON PARA GERAR UMA TABELA DE LOG NO BANCO, USE O CODIGO:

SELECT
   book_audit_log.dml_timestamp as version_timestamp, book_id,dml_type,
   r.*
FROM
    book_audit_log
LEFT JOIN
    JSON_TABLE(
        new_row_data,
        '$'
        COLUMNS (
            title VARCHAR(255) PATH '$.title',
            author VARCHAR(255) PATH '$.author',
            price_in_cents INT(11) PATH '$.price_in_cents',
            publisher VARCHAR(255) PATH '$.publisher'
        )
    ) AS r ON true
-- WHERE
    -- book_audit_log.book_id = 1
ORDER BY version_timestamp;

-- e ai basta criar uma tabela nova no banco a partir da execucao deste select, se quisermos, mas nao acho necessario porque ja existe uma tabela de log com json
-- se precisarmos podemos fazer para separar as colunas dentro do json em colunas em uma tabela.

DROP TABLE IF EXISTS cliente2.dados_de_log;

CREATE TABLE cliente2.dados_de_log AS
SELECT
   book_audit_log.dml_timestamp as version_timestamp, book_id,dml_type,
   r.*
FROM
    book_audit_log
LEFT JOIN
    JSON_TABLE(
        new_row_data,
        '$'
        COLUMNS (
            title VARCHAR(255) PATH '$.title',
            author VARCHAR(255) PATH '$.author',
            price_in_cents INT(11) PATH '$.price_in_cents',
            publisher VARCHAR(255) PATH '$.publisher'
        )
    ) AS r ON true
-- WHERE
    -- book_audit_log.book_id = 1
ORDER BY version_timestamp;

-- para ver o conteudo

select * from cliente2.dados_de_log; 

-- -------------------------------------------------------------------------------------------

-- Poderia se fosse necessario depois da primeira carga, onde foi criada a tabela, usar o comando abaixo, dentro de um EVENT para ficar dando carga nesta tabela. Deixo como um
-- exercicio se quiser fazer.

INSERT INTO cliente2.dados_de_log
SELECT
   book_audit_log.dml_timestamp as version_timestamp, book_id,dml_type,
   r.*
FROM
    book_audit_log
LEFT JOIN
    JSON_TABLE(
        new_row_data,
        '$'
        COLUMNS (
            title VARCHAR(255) PATH '$.title',
            author VARCHAR(255) PATH '$.author',
            price_in_cents INT(11) PATH '$.price_in_cents',
            publisher VARCHAR(255) PATH '$.publisher'
        )
    ) AS r ON true
-- WHERE 
    -- AQUI PODERIA COLOCAR UM CAMPO DA DATA DE HOJE COM A FUNCAO NOW() PARA SO PEGAR DO LOG DO JSON DADOS QUE FORAM GERADOS HOJE NO FINAL DO DIA
    -- OU OUTRO FILTRO PARA EVITAR DE PEGAR DO JSON DADOS QUE JA FORAM LANCADOS ANTERIORMENTE;;

-- -----------------------------------------------------------------------------------------------------------


-- LAB6

-- Agora se quisermos trabalhar com auditoria mais sofisticada, sem precisar criar tabelas com trigger ou usar o log do mysql 
-- community que nao traz detalhes no log em geral de quem esta realizando as transacoes e outras informacoes importantes como o ip do client que fez a alteraca, etc, 
-- precisamos adquirir o mysql enterprise
-- e instalar o pluggin de audtoria. Mas so instale se realmente for necessário gerar logs mais detalhados para auditorias internas e externas 
-- para fins de complaince.


-- Link Explicacao Mysql 
-- https://www.mysql.com/products/enterprise/audit.html
-- https://dev.mysql.com/doc/refman/8.0/en/audit-log.html

-- Link Download MySQL Enterprise Edition Trial
-- https://www.mysql.com/downloads/enterprise/

-- LInk para instalacao do MySQL Enterprise Audit
-- https://dev.mysql.com/doc/refman/8.0/en/audit-log-installation.html

-- FIM















                                                                                                                                                                                                                                                                                                                                                       SET global general_log_file= 'D:\\BKP_MYSQL\\BKP_MYSQL_DATA\\mysqld-general-queryWB.log'
