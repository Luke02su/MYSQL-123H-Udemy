
/*==================================================================================
Curso: MYSQL
Instrutor: Sandro Servino
https://www.linkedin.com/in/sandroservino/?originalSubdomain=pt
https://www.udemy.com/user/sandro-servino-3/

-------   EVENTOS  --------

-- Evento é uma tarefa que executada de acordo com um agendamento previo. Pode executar comandos SQL, criar objetos no banco ou mesmo chamar Stored Procedures
-- Ele pode ocorrer apenas 1 unica vez ou se repetir de acordo com uma agenda criada, ou seja, todo segundo, minuto, hora, dia, semana, mes, ano
-- Verificar se o agendador de eventos está ativado: SHOW VARIABLES LIKE 'event%';
   Se estiver OFF, rodar este comando para mudar a variavel event_scheduler para ON, ativando o servico: SET GLOBAL event_scheduler = ON;

SINTAXE BASICA:

CREATE EVENT event_name
    ON SCHEDULE schedule -- quando vai rodar
    [ON COMPLETION [NOT] PRESERVE] -- facultativa (pode preservar em uma tabela de log ou não a execução histórica do evento)
    [ENABLE | DISABLE | DISABLE ON SLAVE] -- replicar no servidor secundário (escravo, slave)
    [COMMENT 'string'] -- facultativa (comentarios)
    DO event_body; -- faca o que está aqui dentro

schedule: {
    AT timestamp [+ INTERVAL interval] ... -- intervalos de tempo
  | EVERY interval -- a cada período de tempo
    [STARTS timestamp [+ INTERVAL interval] ...] -- começa em tal dia
    [ENDS timestamp [+ INTERVAL interval] ...] -- termina em tal dia
}

interval:
    quantity {YEAR | QUARTER | MONTH | DAY | HOUR | MINUTE |
              WEEK | SECOND | YEAR_MONTH | DAY_HOUR | DAY_MINUTE |
              DAY_SECOND | HOUR_MINUTE | HOUR_SECOND | MINUTE_SECOND} -- intervalos de tempo

- Podemos ainda alterar um EVENT existente com o comando ALTER EVENT nome_event ACAO
-- E com ACAO ainda podemos habilitar, desabilitar e renomear um EVENTO sem excluir do Sistema

- Podemos ver os eventos com SHOW EVENTS; ou SHOW EVENTS FROM bancodedados;
- E podemos deletar os eventos criados com DROP EVENT [IF EXISTS] nomeevento;


Documentacao oficial ORACLE com todas as permissoes: https://dev.mysql.com/doc/refman/8.0/en/create-event.html

==================================================================================*/

-- Vamos ao LAB1

-- Neste primeiro exemplo, vamos criar um evento, que logo que for criado vai inserir um registro em uma tabela

USE CLIENTE2;
SELECT * FROM Customer; -- Vamos ver as ultimas linhas desta tabela

-- Agora vamos criar um evento que assim que for criado ja vai executar uma tarefa

delimiter $$

CREATE EVENT inseredados -- criando evento
    ON SCHEDULE -- quando será executado
    AT CURRENT_TIMESTAMP -- será executado no tempo corrente do servidor, agora (timestamp), ou usar NOW()
    DO -- faça
      BEGIN
         INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone) -- inserindo dados 
                VALUES(270,'Joao NOVO','Anfefeefeders','Berlin','Germany','030-0074321');
      END $$ 

delimiter ;

-- Para vermos os Eventos que estão rodando ou agendados para rodar. Neste caso, se nao aparecer nada é porque o evento ja foi executado
SHOW EVENTS FROM CLIENTE2; -- inseriu os dados na mesma hora devido ao tempo corrente, por isso não mostra (verificar na tabela customer)

-- Agora vamos rodar novamente 

SELECT * FROM Customer;

-- ----------------------------------------------------------------------------------------------------

-- Vamos ao LAB2

-- Agora vamos agendar para executar um evento que vai ocorrer daqui 1 minuto

delimiter $$

CREATE EVENT inseredados1minuto
    ON SCHEDULE 
    AT NOW() + INTERVAL 1 MINUTE -- ao inves da funcao NOW(), poderiamos usar tambem CURRENT_TIMESTAMP + INTERVAL 1 MINUTE (poderia ser 1 hour, 2 day etc.)
    DO
      BEGIN
         INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)
                VALUES(280,'CLIENTE NOVO 1 MINUTO','Anfefeefeders','Berlin','Germany','030-0074321');
      END $$

delimiter ;

delimiter $$

CREATE EVENT inseredados1day
    ON SCHEDULE 
    AT NOW() + INTERVAL 1 DAY -- intervalo de 1 dia
    DO
      BEGIN
         INSERT INTO Customer
                VALUES(281,'CLIENTE NOVO 1 DAY','Bsfsfd','Salvador','Brasil','389282');
      END $$

delimiter ;

-- vAMOS VER SE JA ENTROU O REGISTRO 221
SELECT * FROM Customer;

-- E VAMOS VER O EVENTO
SHOW EVENTS FROM CLIENTE2; -- se sumir, sinal que já foi executado

-- -----------------------------------------------------------------------------------------------------

-- Vamos ao LAB3

-- Vamos criar um evento agora que vai ocorrer em um dia e horaria especifica, e apenas 1 vez

delimiter $$

CREATE EVENT ocorre1vez
    ON SCHEDULE AT '2024-05-27 23:59:00' -- executa em um dia e horário específico apenas 1 vez
    DO
      BEGIN -- faz parte do comando event (tudo dentro do begin e end deve ser executado)
        START TRANSACTION; -- transação única (tem que executar esse bloco de instruções. Se uma falhar, será dado rollback antes de commitar, ficando apenas no log), neste caso usar outro BEGIN não daria certo, pois aqui é destinado apenas para iniciar bloco de instruções
            INSERT INTO Customer (Id,FirstName,LastName,City,Country,Phone)
                VALUES(232,'CLIENTE NOVO 1 MINUTO','Anfefeefeders','Berlin','Germany','030-0074321');
             DELETE FROM Customer where id = 3;
        COMMIT; -- comitando (atualizando)
      END $$

delimiter ;

-- E VAMOS VER O EVENTO
SHOW EVENTS FROM CLIENTE2; -- mostra a data, se está habilitado, se é uma só vez etc.


-- -----------------------------------------------------------------------------------------------------

-- Vamos ao LAB4

-- Vamos criar um evento agora que vai Criar Objetos no banco de dados. Aqui poderia ser, ao inves de criar uma tabela, poderia rodar uma reindexacao, que ainda vamos ver.

delimiter $$

CREATE EVENT criatabelanova
    ON SCHEDULE AT CURRENT_TIMESTAMP 
    DO
      BEGIN
      
	CREATE TABLE  IF NOT EXISTS `CLIENTE2`.`TABELAEXEMPLOEVENTO` (
          `id` int NOT NULL ,
          `companyname` varchar(40)  NULL,
          `contactname` varchar(50)  NULL,
          `contacttitle` varchar(40) NULL,
          `city` varchar(40)  NULL,
          `country` varchar(40) NULL,
          `phone` varchar(30)  NULL,
          `fax` varchar(30) NULL,
          PRIMARY KEY (`id`)
                             ) ;
      END $$

delimiter ;

-- E VAMOS VER O EVENTO
SHOW EVENTS FROM CLIENTE2; -- não aparecerá tabelaexemploevento pois já foi executada em tempo corrente

-- ---------------------------------------------------------------------------------
-- Vamos ao LAB5

-- Vamos criar um evento agora que vai ser executado, a cada 1 MES, comecando em um dia definido, mas podeeria ser 1 vezm por minuto, hora, etc
-- Poderia ser usado por exemplo para deletar dados antigos em uma tabela de log

delimiter $$

CREATE EVENT roda1vezmes
    ON SCHEDULE EVERY 1 MONTH -- será executado a cada 1 mês
    STARTS '2024-05-30' -- começa
    ENDS  '2024-10-30' -- termina --  PODERIAMOS COLOCAR AINDA UMA DATA PARA O EVENTO PARAR DE RODAR, E SE NAO COLOCAR ENDS RODA POR TEMPO INDEFINIDO
    DO -- faça
     BEGIN
       UPDATE Product -- (poderia ser usado para deltar dados antigos em tabelas de logs, por exemplo)
             SET IsDiscontinued = 0 
             where IsDiscontinued=1;
     END $$

delimiter ;

-- E VAMOS VER O EVENTO
SHOW EVENTS FROM CLIENTE2; -- repare nas colunas

-- ----------------------------------------------------------------------------------

-- Vamos ao LAB6

-- Vamos criar um evento agora que vai ser executado de forma automatica a partir da hora atual do servidor, vai rodar a cada 1 hora e vai parar daqui 10 horas

delimiter $$

CREATE EVENT IF NOT EXISTS rodacada1hora
    ON SCHEDULE EVERY 1 HOUR -- executa a cada 1 hour (poderia ser minutes, days, years). Poderia ser uma data fixa
    STARTS CURRENT_TIMESTAMP -- começa no tempo corrente, poderia ser NOW()
    ENDS  CURRENT_TIMESTAMP + INTERVAL 10 HOUR -- termina agora + 2 hour, ou seja, daqui 2 horas após o começo
    DO
     BEGIN
       UPDATE Product
             SET IsDiscontinued = 0 
             where IsDiscontinued=1;
     END $$

delimiter ;

DROP EVENT rodacada1hora;

-- E VAMOS VER O EVENTO
SHOW EVENTS FROM CLIENTE2; -- repare nas colunas

-- -------------------------------------------------------------------------------

-- Para desabilitar um evento 
SHOW EVENTS FROM CLIENTE2;

ALTER EVENT rodacada1hora -- por algum motivo podemos desabilitar (STATUS fica disabled)
    DISABLE;
SHOW EVENTS FROM CLIENTE2;

-- Para habiliar o evento
ALTER EVENT rodacada1hora
   ENABLE;
SHOW EVENTS FROM CLIENTE2;

-- -------------------------------------------------------------------------------

/*-- renomear um database nãao é tão simples, necessário excluir bd e recriá-lo com o nome que deseja após fazer o backup
ALTER TABLE tabelaexemploevento RENAME TO tabelaexemploevento1; -- alterando nome da tabela
ALTER TABLE tabelaexemploevento1 MODIFY COLUMN fax VARCHAR(10); -- alterando o tipo primitivo (poderia usar change renomeando a coluna)
ALTER TABLE tabela CHANGE fax fax2 VARCHAR(30); -- após renomear tem que adicionar o tipo primitivo
*/
-- Para mudar o nome de um evento


SHOW EVENTS FROM CLIENTE2;

ALTER EVENT rodacada1hora
    RENAME TO rodacada1hora_NOVO; -- rename to para mudar o nome do event (roda normalmente, sem atrapalhar)

SHOW EVENTS FROM CLIENTE2;

-- -----------------------------------------------------------------------------

-- Para alterar um EVENTO EXISTENTE, MUDANDO SEU CODIGO INTERNO
-- alterando por algum motivo

DELIMITER $$
ALTER EVENT rodacada1hora_NOVO
    ON SCHEDULE
      AT CURRENT_TIMESTAMP + INTERVAL 1 DAY -- mudando o tempo
    DO
	BEGIN
		TRUNCATE TABLE Product; -- mudando a funcionalidade (apagando dados de product)
	END$$
DELIMITER ; -- não é necessário o delimiter, pois é apenas um pequeno bloco simples de instrução

SHOW EVENTS FROM CLIENTE2;

-- -------------------------------------------------------------------------------

-- Para deletar EVENTOS

SHOW EVENTS FROM CLIENTE2;

drop  EVENT if exists ocorre1vez; -- se existir, delete a estrututa com drop
drop  EVENT if exists roda1vezmes;
drop  EVENT if exists rodacada1hora_NOVO;
DROP EVENT IF EXISTS inseredados1day;

SHOW EVENTS FROM CLIENTE2;


-- ------------------------FIM

