
/*==================================================================================
Curso: MYSQL
Instrutor: Sandro Servino
https://www.linkedin.com/in/sandroservino/?originalSubdomain=pt
https://www.udemy.com/user/sandro-servino-3/

-------   BACKUP  --------

- A primeira opcao, seria fazer copia de seguranca manuais pelo workbench de forma grafica.

- O utilitário do cliente mysqldump executa backups lógicos, produzindo um conjunto de instruções SQL que podem ser 
  executadas para reproduzir as definições originais do objeto do banco de dados e dados da tabela.

- Precisa ter privilegios para ler todos objetos de um banco de dados como root, ou ter all privileges (DBA) ou privilegio 
  de fazer backup, como visto em aulas passadas.

- Por padrao, o mysqldump Faz bloqueio das tabelas enquanto está realizando o Backup, então procure fazer o backup em horários que não impacte a produção.
  Não é eficiente (performance) para bases de dados muito grandes e com muitos usuários. Se os seus bancos forem INNODB poderá utilizar 
  o parametro --single-transaction para o mysqldump nao realizar bloqueios da tabela e o backup se manter integro, pois o mysql tira uma fotografia do banco antes de iniciar o backup.

- Existe um plugin para clonar um banco inteiro (fisico) que tem grande performance que pode ser util quando precisar copiar um banco muito grande
  rapidamente. https://dev.mysql.com/doc/refman/8.0/en/clone-plugin.html

- Em geral, existem três maneiras de usar o mysqldump para fazer backup de um conjunto de uma ou mais tabelas, um conjunto de um ou mais bancos de dados completos 
  ou um servidor MySQL inteiro (todos os bancos de dados):

mysqldump [options] db_name [tbl_name1, tbl_name2, ...]
mysqldump [options] --databases db_name1, db_name2, ...
mysqldump [options] --all-databases

Para ver a lista de todas as options existentes, procure - Option Syntax - Alphabetical Summary - https://dev.mysql.com/doc/refman/8.0/en/mysqldump.html

Documentacao oficial ORACLE com todas as permissoes: https://dev.mysql.com/doc/refman/8.0/en/mysqldump.html

==================================================================================*/

-- LAB1
-- Vamos fazer backup manual de uma base de dados pelo workbench através do menu Server->Data Export 

-- e Depois vamos fazer o restore através do menu Server-> Data Import
-- A titulo de curiosidade para verificar as tabelas INNODB e confirmar se os bancos foram criados com esta arquitetura

SELECT * FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'cliente2'
AND ENGINE != 'InnoDB';

SELECT * FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'cliente2';

SELECT * FROM INFORMATION_SCHEMA.TABLES
WHERE ENGINE != 'InnoDB';

-- Agora vamos voltar um restore e depois de feito restore verifique a estrutura da tabela e o conteudo 
-- Para isto, vamos deletar o banco de dados cliente2 que fizemos o backup

 DROP DATABASE cliente2;
-- Se aparecer este erro > drop database cliente, Error Code: 1010. Error dropping database (can't rmdir '.\cliente2\', errno: 17 - File exists)	0.000 sec
-- A instrução DROP DATABASE removerá todos os arquivos de tabela e, em seguida, removerá o diretório que representava o banco de dados. 
-- No entanto, ele não removerá arquivos que não sejam de tabela, tornando impossível remover o diretório.
-- Solução: Temos que descartar o banco de dados manualmente removendo todos os arquivos restantes no diretório do banco de dados e, 
--  em seguida, o próprio diretório.

-- Vamos verificar onde os bancos de dados estao, atraves do comando:
 select @@datadir;
-- Va nesta pasta e tente deletar todos os files visiveis e depois a pasta cliente2
-- Se nao conseguir deletar alguns dos files, e recebe mensagem que esta em uso, talvez tenha transacoes ainda aberta e nao comitadas
-- rode no workbench, nas mesma sessao que estava tentando deletar o banco
commit;

-- Novamente tente deletar o banco cliente2 no workbench.
 DROP DATABASE cliente2;

-- Agora vamos restaurar os dois tipos de backups que fizemos do banco cliente2, com todos os files e depois com arquivo unico. Verique que se colocarmos os backups de todos so files
-- na mesma pasta do backup unico, o mysql se confunde, entao coloque os tipos de backups em pasta separadas.

describe customer;
SELECT * FROM cliente2.customer;

-- ---------------------------------------------------------------------------------------------------------------

-- LAB2
-- Vamos fazer um backup full logico manual atraves do comando mysqldump pelo DOS

-- Vai no DOS e va na pasta c:\ProgramData\MySQL\data\MySQL Server 8.0\Data\ onde estão os bancos de dados. 
-- Para confirmar onde estao os bancos de dados por padrao, basta:
SHOW VARIABLES WHERE Variable_Name LIKE "%dir" ;
-- ou
select @@datadir;

-- Execute mysqldump e verifique se o DOS reconhece este comando. Se nao reconhecer configure o path do windows para em qualquer pasta, ele encontrar este programa que esta
-- na pasta C:\Program Files\MySQL\MySQL Server 8.0\bin

-- Execute o comando abaixo no DOS para realizar o backup sem bloquear as tabelas e mantendo o backup integro
-- Va na pasta cd c:\ProgramData\MySQL\data\MySQL Server 8.0\Data\cliente2 e vamos executar o comando abaixo para realizar o backup. 
-- execute dir para ver as tabelas do banco. Por padrao, na criacao do banco, o mysql cria 1 file para cada tabela do banco. Esta arquitetura traz ganhos de performance para mysql.

mysqldump -u root -p  cliente2  --single-transaction  > ..\backups\BK1my_large_db.sql -- -u user, -p password, single transaction não lock a tabela (innodb), podendno inserir durando o bkp, antes de fazer bkp tira uma foto do estado anterior, podendo retornar caso dê problemA)
-- entre com a senha do seu root
-- rode comando dir ..\backups\ e verifique o backup

-- Se quiser fazer backup de todas as bases de dados, rotinas (procedures e functions) e eventos
mysqldump -u root -p --all-databases --routines --events > ..\backups\ALLBK1my_large_db.sql -- 
e rode depois dir ..\backups\

-- se quiser fazer backup para mais de 1 banco de dados: CLIENTE2 e CLUBE
mysqldump -u root -p --databases cliente2 clube > ..\backups\bkCLIENTE2eCLUBE.sql -- fez bkp das views, tables and triggers, mas não das procedures, functions and events

-- se quiser fazer backup de apenas uma tabela produto do banco cliente2
mysqldump -u root -p cliente2 product > ..\backups\bktabelaproduto.sql 

-- obs: COPIE ESTES BACKUPs PARA UMA PASTA DIFERENTE NO SEU COMPUTADOR E SE PUDER EM OUTRO DISCO DIFERENTE DO DISCO DOS DADOS.

-- vamos agora deletar o banco de dados cliente2 e depois vamos subir o backup
-- Para isto, ao inves de deletar pelo workbench, que poderia, vamos deletar por linha de comando no DOS.
-- Primeiro vamos acessar o servidor mysql com o comando:
mysql -u root -p

-- veja as bases de dados disponiveis nesta instancia mysql
show databases;

-- Vamos deletar o banco cliente2
drop database cliente2; 

-- Se aparecer este erro > drop database cliente, Error Code: 1010. Error dropping database (can't rmdir '.\cliente2\', errno: 17 - File exists)	0.000 sec
-- A instrução DROP DATABASE removerá todos os arquivos de tabela e, em seguida, removerá o diretório que representava o banco de dados. 
-- No entanto, ele não removerá arquivos que não sejam de tabela, tornando impossível remover o diretório.
-- Solução: Temos que descartar o banco de dados manualmente removendo todos os arquivos restantes no diretório do banco de dados e, 
--  em seguida, o próprio diretório cliente2. 

-- Vamos verificar onde os bancos de dados estao, atraves do comando:
 select @@datadir;
-- Va nesta pasta e tente deletar todos os files visiveis e depois a pasta cliente2
-- Se nao conseguir deletar alguns dos files, e recebe mensagem que esta em uso, talvez tenha transacoes ainda aberta e nao comitadas
-- rode no workbench, nas mesma sessao que estava tentando deletar o banco
commit;
-- Se nao conseguir matar a pasta, veja no task manager, em todos os processos, cpu, e pesquisa palavra mysql e tente terminar processos que estejam lendo arquivo na pasta cliente2 e 
-- no ultimo caso, pare o mysql e delete a pasta cliente2 depois.

-- Novamente tente deletar o banco cliente2 no dos
 DROP DATABASE cliente2;

-- Verifique agora que o banco cliente2 nao aparece mas no workbench provando que workbench é apenas uma ferramenta cliente que nos ajuda a administrar o servidor mysql

-- Agora vamos sair da ferramenta client no DOS do mysql e vamos voltar para o prompt do DOS para recuperar nosso banco atraves da restauracao do backup full realizado
exit;

-- Vamos na pasta onde salvamos o backup
cd c:\ProgramData\MySQL\data\MySQL Server 8.0\Data\backups

-- e vamos rodar no DOS o comando para restaurar nosso banco cliente2 do backup realizado
mysql -u root -p cliente2 < BK1my_large_db.sql

-- vai dar um erro, porque quando criamos o backup nao pedimos para o backup criar o banco, mas é muito simples, basta entrar no mysql e criar database antes ou no workbench
mysql -u root -p

Create database cliente2;
-- se der um erro, pode ser que a pasta cliente2 esteja aberta sendo ainda usada por outro programa. Procure descobrir qual programa esta com esta pasta aberta ou tente desligar seu computador.
-- https://terminaldeinformacao.com/2019/06/12/como-ver-o-processo-que-esta-travando-um-arquivo-no-windows/
-- Va na aba de mais recursos, cpu, e pesquise mysql. Termine o processo que esteja bloqueando esta pasta c:\ProgramData\MySQL\data\MySQL Server 8.0\Data\cliente2
-- Va no windows explorer e busque c:\ProgramData\MySQL\data\MySQL Server 8.0\Data
-- e delete a pasta cliente2 manualmente

-- retorne para o prompt do DOS com comando EXIT e va para pasta onde colocou o backup, no meu caso
cd c:\ProgramData\MySQL\data\MySQL Server 8.0\Data\backups

-- NO DOS, entre no mysql e crie o banco cliente2
mysql -u root -p

create database cliente2;
show database cliente2;
exit;

-- agora suba o backup da pasta c:\ProgramData\MySQL\data\MySQL Server 8.0\Data\backups, com o comando:
mysql -u root -p cliente2 < BK1my_large_db.sql

-- veja que foi criado novamente a pasta cliente2 no windows explorer e as tabelas
c:\ProgramData\MySQL\data\MySQL Server 8.0\Data\cliente2 e no workbench tambem


-- ------------------------- fim da restauracao full. 

-- LAB3

-- Agora vamos fazer um backup da tabela account e depois deletar esta tabela do banco cliente2 e vamos tentar subir apenas o backup que fizemos para esta tabela, que foi feito
-- atraves deste comando:

cd c:\ProgramData\MySQL\data\MySQL Server 8.0\Data\cliente2
mysqldump -u root -p cliente2 account > bktabelaaccount.sql

-- Vamos entrar no DOS e conectar no mysql
mysql -u root -p

-- Vamos ver as tabelas do banco cliente2
use cliente2;
show tables;

-- vamos agora tentar deletar a tabela product
drop table account;
show tables;
exit;

-- para restaurar novamente devemos usar o comando mysql invertendo o sinal de > para <
mysql -u root -p cliente2 < bktabelaaccount.sql

-- ir no workbench e veja a tabela e o conteudo e no client do mysql no dos
use cliente2;
show tables;
select * from account;

-- -------------------------------------------------------------------------------------------------------

-- LAB4
-- Vamos fazer um backup incremental logico manual (log das transacoes) atraves do comando mysqldump pelo DOS

-- O backup full (completo), usando o mysqldump, é criado em um script com um conjunto de comandos SQL que podem restaurar um banco de dados (BACKUP lógico) 
-- ou voce pode fazer uma cópia bruta de diretórios e arquivos que contém dados MySQL (BACKUP físicos), mas nesse caso usando outro programa de backup.
-- Para bancos de dados grandes (> 10 GB), você provavelmente desejará usar a última opção, que iremos ver em um futuro LAB, mas por 
-- enquanto vamos continuar usando mysqldump para fazer nossos backups logicos.

-- O backup incremental pode ser feito fazendo backup dos logs binários do MySQL. 
-- Todas as operacoes
-- de insert, update e delete sao gravados no log que fica no disco. 
-- O log binário é um conjunto de arquivos que contém informações sobre modificações de dados feitas pelo servidor MySQL. 
-- O log consiste em um conjunto de arquivos de log binários, mais um arquivo de índice e no meu caso fica na pasta C:\ProgramData\MySQL\data\MySQL Server 8.0\data

-- Se eu quiser ver no workbench basta digitar
SHOW BINARY LOGS;

-- O MYSQL utiliza o arquivo de log binário para replicacao dos bancos para outros servers e possibilita a restauracao do backup em um ponto especifico do tempo, sem perder dados
-- entre o ultimo backup full e o momento atual, quando existe um problema na base de dados, ou depois de por exemplo rodar um comando de alteracao equivocada, como 
-- por exemplo um delete ou update sem where.

-- Por padrao o MYSQL 8.0 ja vem ligado a utilizacao do log e ele grava os arquivos de log na mesma pasta onde estao os arquivos de dados do seu banco de dados.
-- https://dev.mysql.com/doc/refman/8.0/en/replication-options-binary-log.html

-- Por padrao, cada arquivo de log binario pode ter até 1gb e depois de preenchido o MYSQL recicla e cria um novo arquivo de log onde as transacoes que alteram os dados sao realizadas 
-- neste arquivo, mantendo os outros arquivos no disco para serem copiadas (backups). Ainda por padrao o mysql mantem no disco até 30 files antes de serem reciclados. 

-- Quando o mysql é reinicializado um novo arquivo de log binário é gerado e definido como padrao, mantendo os outros anteriores na mesma pasta.
-- Garanta que seja um tempo que ja tenha feito backup destes arquivos para um local seguro, porque se houver crash do disco ou os antigos forem substituidos nao podera usar para restauracao
-- do backup incremental em um momento do tempo especifico, para restaurar o banco com as transacoes que estavam dentro de um destes arquivos de log binario.

-- Se desejar podera alterar o local dos arquivos binlogs para um disco diferente de onde estao os arquivos de dados. Dependendo do nivel de utilizacao dos discos, pode trazer ganhos de performance.
-- Para realizar estas alterações basta abrir o arquivo my.ini ou my.cnf conforme necessário e reinicie o servidor mysql. 
-- No meu caso, o my.ini esta na pasta C:\ProgramData\MySQL\data\MySQL Server 8.0

-- Vamos editar o my.ini e ver um pouco do conteudo deste arquivo de inicializado do MYSQL.

-- OBS: Podemos por exemplo, mudar o padrao onde os bancos de dados sao criados ou mesmo mover fisicamente os files para outro local, parando o mysql e alterando a variavel global da inicializacao
   # Path to the database root
   datadir=C:/ProgramData/MySQL/data/MySQL Server 8.0\Data

-- Para mudarmos o local de geracao poderiamos incluir as linhas abaixo por exemplo:
log_bin = caminho\mysql-bin.log

# Para reciclar os arquivos de log bin, mudando o padrao de 30 dias para 10
expire_logs_days = 30

# e mudando o tamanho padrao maximo de 1gb para 100M. Em alguns ambientes com baixa performance de io pode ser interessante
max_binlog_size = 100M

-- OBS> MAS expire_logs_days ESTA EM DEPRECATED.
https://dev.mysql.com/worklog/task/?id=10924#:~:text=Background%20%2D%2D%2D%2D%2D%2D,when%20binary%20log%20is%20flushed.

-- Na versão 8.0, uma nova variável c foi introduzida. Isso permitiu
-- que usuários possam definir o tempo de expiração, que não precisa ser múltiplo integral de dias. Isto é
-- a melhor maneira de definir o tempo de expiração e também mais flexível, tornará
-- a variável do sistema expire_logs_days desnecessária, de modo que deve ser preterida em
-- 8.0 e pode ser removido em uma versão posterior.
-- Valor padrão	2592000 seconds, ou 30 dias, conforme a variavel anterior. Este valor pode ser alterado. Valor maximo Valor máximo 4294967295 segundos.

-- Após o término do período de expiração, os arquivos de log binários podem ser removidos automaticamente atraves de reciclagem por outro.
-- As remoções possíveis acontecem na inicialização e quando o log binário é liberado. 
-- Para desabilitar a limpeza automática do log binário, especifique um valor de 0 explicitamente para binlog_expire_logs_seconds, 
-- e não especifique um valor para expire_logs_days.

-- Para remover arquivos de log binários manualmente, use a intrucao PURGE BINARY LOGS, mas antes vamos ver estes arquivos. 
-- Va no DOS
cd C:\ProgramData\MySQL\data\MySQL Server 8.0\data 
DIR

-- e depois no workbench veja estes arquivos
SHOW BINARY LOGS;

-- Antes de excluir manualmente os arquivos de log com os comandos abaixo, é aconselhavel fazer uma copia destes arquivos.

-- exemplo >
PURGE BINARY LOGS TO 'LUCAS-bin.000003'; -- deleta todos os logs binarios files, anteriores ao 91 e torna o indicado como o padrao de gravacao das transacoes

PURGE BINARY LOGS BEFORE '2024-06-03 22:46:26'; -- deleta todos os logs binarios files que tem transacoes antes da data indicado

-- rode novamente SHOW BINARY LOGS; e va no disco e veja
cd C:\ProgramData\MySQL\data\MySQL Server 8.0\data 
DIR

--  Se estiver usando replicação, você deve especificar um período de expiração que não seja inferior ao tempo máximo 
-- que suas réplicas podem ficar para trás da origem ou que tenha feito backup destes arquivos que ficam no disco, porque poderá precisar
-- deles para voltar o banco em um tempo determinado.

-- -------------------------------------

-- AGORA VAMOS AO LAB...

-- -------------------------------------

-- VAMOS CRIAR UM BANCO DE TESTE

-- CRIAR BANCO DE DADOS 'dbteste';
DROP DATABASE IF EXISTS dbteste;
CREATE DATABASE dbteste;

-- e criar tabela.
USE dbteste;
CREATE TABLE dbteste_t1 (
    id INT NOT NULL AUTO_INCREMENT,
    test_field VARCHAR(30) NOT NULL,
    time_created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
 ) ENGINE=InnoDB; -- ja é default na versao 8, mas se quiser apenas para deixar como padrao

-- E insira algumas linhas:

USE dbteste;
INSERT into dbteste_t1 (test_field) VALUES ('val1');
INSERT into dbteste_t1 (test_field) VALUES ('val2');
INSERT into dbteste_t1 (test_field) VALUES ('val3');

select * from dbteste_t1;

-- vamos agora fazer um backup full. Vamos para o DOS.
-- cd C:\ProgramData\MySQL\data\MySQL Server 8.0\data 
FLUSH LOGS; -- cria um novo log
mysqldump -u root -p  dbteste --single-transaction --flush-logs  > \backups\BKdbteste.sql


-- flush-logs fechará o log atual e abrirá um novo e definirá este novo como padrao para receber as novas transacoes daqui para diante.
-- Se você der uma olhada novamente em C:\ProgramData\MySQL\data\MySQL Server 8.0\data ou onde esta seus dados,
-- dando um dir, verá que um novo arquivo de log foi criado (DESKTOP-MKCDD14-bin.0000XX) ou mesmo rodando SHOW BINARY LOGS; no workbench.
-- Todas as alterações a partir de agora serão gravadas nesse arquivo.
-- Da próxima vez que você executar flush-logs ou reiniciar o servidor mysql, DESKTOP-MKCDD14-bin.0000XX+1 será criado e assim por diante.

-- Vamos agora inserir mais linhas no banco de dados:

USE dbteste;
INSERT into dbteste_t1 (test_field) VALUES ('val4');
INSERT into dbteste_t1 (test_field) VALUES ('val5');
INSERT into dbteste_t1 (test_field) VALUES ('val6');

select * from dbteste_t1;

-- Agora é hora de fazer backup incremental do arquivo de log padrao que esta sendo utilizado.

-- O MYSQL ira liberar e reclicar o arquivo de log padrao novamente e vai criar um novo.
-- IMPORTANTE: Neste momento é importante salvar o ultimo log binário em um local seguro, outro disco ou nuvem, ou fita.
-- Vamos ver os logs binarios criados. Pelo numero maior vera qual o que esta em uso. 
-- O ideal é salvar todos arquivos de log porque podera ser necessario usar um deles para retornar o banco em um tempo especifico. De tempo em tempo pode ir deletando 
-- do local de backup os logs mais antigos, porque ja vai ter backups full anteriores tambem.
SHOW BINARY LOGS;

-- Para liberar o log atual manualmente, reclicando e criando um novo log default, execute este comando no DOS
mysqladmin -u root -p flush-logs

-- OBS> Geralmente este processo de backup de log nao eh feito de forma manual logo apos o backup full. O que ocorre é fazermos apenas um backup full manual com flush log ou sem
-- para algum processo que precisamos garantir a integridade da base de dados, mas o mais normal, é criamos um script que ira realizar backups full de forma periodica com flush log
-- como 1 vez por dia, ou por semana, e um outro script que vai realizar o backup do log e vai rodar de forma automatica a cada x minutos ou x horas, mas vamos ver isto mais a frente.

-- Novo log binário é criado em C:\ProgramData\MySQL\data\MySQL Server 8.0\data ou onde esta seus dados.
-- Só precisamos salvar mysql-bin.00000x (anterior) em um local seguro, pois ele contém todas as alterações que fizemos após nosso backup completo.
-- Pode ver tambem pelo comando SHOW BINARY LOGS; que foi criado um novo arquivo de log que esta sendo usado agora para novos comandos

-- Vamos ver como nossa tabela está agora...

use dbteste;
select * from dbteste_t1; -- por enquanto nada mudou porque nao deletamos nenhum dado, apenas fizemos uma liberacao do arquivo de log anterior que tinha os ultimos 3 inserts.

-- Agora iremos deletar o banco de dados e tentaremos restaurá-lo a partir do backup.
drop database dbteste;

-- vamos recriar o banco de dados
create database dbteste;

-- e vamos para o DOS e vamos carregar o ultimo backup full
cd C:\ProgramData\MySQL\data\MySQL Server 8.0\data

mysql -u root -p dbteste < \backups\BKdbteste.sql -- CUIDADO AO FAZER BKP E IMPORTAR. NA HORA DE IMPORTAR VIA COMANDO DE FORMA ERRADA, ESCREVENDO ERRADO, PODE CORROMPER O ARQUIVO.

-- veja o conteudo da tabela e repare que voltou os dados de acordo com o ultimo backup full mas os dados novos que foram inseridos depois do backup nao 
-- retornaram mas estao no arquivo de log.
use dbteste;
select * from dbteste_t1;

-- Agora precisamos apenas aplicar as alterações que estao no log binário que desejamos. Para verificar os logs binarios gerados SHOW BINARY LOGS;
-- No DOS veja na pasta de dados o binlog que quer carregar ou no nosso exemplo, o arquivo de log que foi salvo em local protegido depois de termos feito reciclagem do log. As datas e horas dos arquivos de log 
-- sao importantes para verficar qual arquivo devera ser retornado.
SHOW BINARY LOGS;
cd C:\ProgramData\MySQL\data\MySQL Server 8.0\data

mysqlbinlog LUCAS-bin.000008 | mysql -uroot -p dbteste -- execute no cmd

-- retorne ao workbench e execute novamente
use dbteste;
select * from dbteste_t1; 
-- agora voce tem todos os dados atualizados, desde o ultimo backup full ate a ultima transacao que esta registrada no log. Poderia ter feito varios backups full e carregados todos os backups
-- mas backup full eh uma operacao mais pesada, porque copia todo o banco e nao apenas as ultimas transacoes.

-- OBS

-- Você também pode limitar a lista de consultas retornadas com hora de início e término. Por exemplo, para restaurar o banco de dados para o
-- estado como estava ate 2021-09-05 11:15:44, você pode usar o seguinte comando, depois de ter subido ultimo backup full
-- cd C:\ProgramData\MySQL\data\MySQL Server 8.0\data

-- rode comando no DOS, para restaurar backup full: mysql -u root -p dbteste < \backups\BKdbteste.sql

-- rode comando no DOS, para restaurar backup incremental para uma data e hora especifica, mas dependendo do caso, nao ira recuperar os inserts feitos porque precisa pegar o arquivo de log correto

-- mysqlbinlog --stop-datetime="2022-01-19 23:37:00" DESKTOP-MKCDD14-bin.000083 | mysql -uroot -p dbteste
-- va no workcbench e rode select * from dbteste_t1;

   -- restaura ultimo backup full
   mysql -u root -p dbteste < \backups\BKdbteste.sql
   -- Restaura (aplica) as transacoes que estano no arquivo 93 ate dia e horario especificado
   mysqlbinlog --stop-datetime="2022-01-26 20:06:00" DESKTOP-MKCDD14-bin.000093 | mysql -uroot -p dbteste
-- va no workcbench e rode 

  select * from dbteste_t1;

-- Você pode usar --start-datetime e --stop-datetime para localizar posições em logs binários,
-- e então usar essas posições nos parâmetros --start-position e --stop-position para limitar as consultas retornadas.

-- É uma boa ideia salvar logs binários em algum armazenamento SAN ou rsync-los periodicamente para outro local,
-- portanto , se algo der errado, você poderá primeiro restaurar os dados do último backup FULL
-- e , em seguida, restaurar dados adicionais desses novos logs com a aplicacao dos logs atraves do comando mysqlbinlog 

-- ------------------------------------------------------------------------------------------------------- fim

-- LAB5
-- Vamos criar script mais sofisticado para fazer backup full, vai compactar o arquivo de backup, vai salvar o backup em uma pasta, e vai deletar os backups antigos

-- Passos

-- 1. Primeiro vamos criar uma pasta no C:\mysqlapoio, que vai conter as nossas credenciais de acesso ao banco: config.cnf. 
--    Voce em seu ambiente de producao, deve proteger este arquivo para
--    apenas voce e algum grupo poder abrir este arquivo config,cnf porque a senha do root poderá estar dentro deste arquivo. 
--    Clique depois em propriedade do arquivo com botao direito do mouse e na aba segurança poderá realizar bloqueios de leitura.
-- O conteudo do arquivo config.cnf será: 

# Configuracoes de usuario
[mysqldump]
 user=root
 password=root

-- COLOQUE A SENHA QUE CRIOU PARA SEU ROOT.

-- Deve ter sido o arquivo com a extensao .txt. Altere no DOS para config.cnf

ren config.txt config.cnf

-- Podera ainda no windows explorer, clicar no meu exibir e ligar a opcao a direita chamada Extensoes de nomes de arquivos para exibir a extensao e assim poder alterar config.txt para config.cnf

-- 1.1 e vamos criar uma subpasta para guardar nossos backups, na pasta C:\mysqlapoio\backups e uma subpasta para guardar os erros na execucao do backup C:\mysqlapoio\backups\erros

-- 1.2 Faça um teste no DOS. Execute o comando powershell. Caso nao ache o comando pode nao estar instalado. Para instalar pesquise no google windows powershell download
--     https://docs.microsoft.com/pt-pt/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.2
--     Instale na pasta padrao, sugerida, e depois inclua no path do Windows para poder executar o powershell de qualquer pasta. Ja viu como pode fazer isto, quando executamos mysqldump.
--     Caso tenha conseguido executar o powershell e apareca PS pathDOS, digite EXIT para sair do powershell.

-- 1.3 Caso nao tenha com programa para compactar arquivos, 7zip, busque no google e instale-o e coloque no path do windows o caminho para de qualquer pasta poder executar o comando 7z.exe
--     que sera usado dentro do script para fazer o backup compactando o arquivo de backup.
--     https://www.7-zip.org/
--     O padrao de instalacao é C:\Program Files\7-Zip\, entao coloque no path do windows para poder executar 7z de qualquer lugar, senao tera problemas no script powershell.
--     Va no PowerShell como admin e execute 7z em qualquer pasta para verificar se funcionou. Se nao funcionou, feche a janela DOS onde esta o 
       powershell com exit, e abra novamente o powershell como admin e teste novamente o 7z. Se nao funcionou, abra o painel de controle, sistema e configure novamente a variavel path com o caminho da instalacao do 7z.

-- 2. Vamos agora criar na pasta C:\mysqlapoio um arquivo backupfulldb.ps1 com o conteudo abaixo. Ja renomei backupfulldb.txt.ps1 para backupfulldb.ps1.
--   Mas antes de executar o arquivo com powershell (C:\MYSQLAPOIO\backupfulldb.ps1), vá na batta e pesquise powershell, preferencialmente como administrador.
--   Dentro do powershell rode o comando Get-ExecutionPolicy. Se o resultado for Restricted é o padrao do powershell no windows 10 e similares, 
--   como uma politica de seguranca do powershell para evitar 
--   que seja rodado scripts ps1 nao assinados que pode trazer algum problema para o seu Sistema Operacional. 
--   Para poder rodar script abaixo rode: Set-ExecutionPolicy RemoteSigned, tecle S depois.
--   FAVOR, SE ESTIVER A RODAR EM SERVIDORES, VERIFICAR COM SUA POLITICA DE SEGURANÇA OU GRUPO DE SEGURANÇA SE PODE ALTERAR ESTE PARAMETRO, 
--   de qq forma em em servidores windwos a opcao RemoteSigned,  é a default .

--  OBS>  Se desejar, depois de ter terminado seu laboratorio e executado com sucesso os tasks automaticos de backup, 
--   rode novamente no powershell o Set-ExecutionPolicy [option] para retornar para restricted, se estava assim no seu computador (Set-ExecutionPolicy Restricted), como exemplo.
-- https://docs.microsoft.com/pt-pt/powershell/module/microsoft.powershell.core/about/about_execution_policies?view=powershell-7.2

-- --------------------------------------------------------------------------------------------------------------------------------------------
-- agora vamos criar o arquivo C:\MYSQLAPOIO\backupfulldb.ps1, com conteudo abaixo, que ira fazer backup full de uma base de dados especifica, 
-- compactar os arquivos e colocar em um local seguro.
-----------------------------------------------------------------------------------------------------------------------------------------------

$backuppath = "C:\mysqlapoio\backups\"  # Caminho para armazenar os backups, coloque a barra \ no final da caminho, caso use outra pasta para backup
$config = "C:\mysqlapoio\config.cnf"  # Caminho para o arquivo com as credenciais
$database = "dbteste" # Nome do nosso banco de dados
$errorLog = "C:\mysqlapoio\backups\erros\error_dump.log"  # Caminho para o nosso arquivo de log
$days = 30 # Dias para manter os arquivos de backup
$date = Get-Date
$timestamp = "" + $date.day + $date.month + $date.year + "_" + $date.hour + $date.minute 
$backupfile = $backuppath + $database + "_" + $timestamp +".sql"
$backupzip = $backuppath + $database + "_" + $timestamp +".zip"
  
# FAZ O BACKUP
mysqldump.exe --defaults-extra-file=$config --log-error=$errorLog  --result-file=$backupfile  --databases $database  --single-transaction --flush-logs 

# Inicia o processo de compactacao com 7zip  
7z.exe a -tzip $backupzip $backupfile
  
# Deleta o arquivo original e deixa apenas o zip
Del $backupfile
 
# Deleta arquivos antigos
CD $backuppath
$oldbackups = gci *.zip* 
  
for($i=0; $i -lt $oldbackups.count; $i++){ 
    if ($oldbackups[$i].CreationTime -lt $date.AddDays(-$days)){ 
        $oldbackups[$i] | Remove-Item -Confirm:$false
    } 
}

# fim

---------------------------------------------- SALVE O ARQUIVO PS1

-- e agora vamos rodar de forma manual

RETORAR POLITICA PARA RESTRITICA E VAMOS LIBERAR APENAS NA EXECUCAO PELO TASK SHEDULED
Set-ExecutionPolicy Restricted

C:\MYSQLAPOIO\backupfulldb.ps1

-- Depois altere a senha do root que esta na arquivo de configuracao e rode novamente o script e verifique se gerou arquivo de backup com algum conteudo e veja a pasta de erro

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------
-- Para podermos fazer backup de todas as bases de dados, a mudanca é simples, crie novo script C:\MYSQLAPOIO\backupfullALLdb.ps1
-- Pode inclusive duplicar o anterior, mudar o nome e depois o conteudo.
-- -------------------------------dbteste_t1dbteste_t1--------------------------------------------------------------------------------------------------------------------------

$backuppath = "C:\mysqlapoio\backups\"  # Caminho para armazenar os backups, coloque a barra \ no final da caminho, caso use outra pasta para backup
$config = "C:\mysqlapoio\config.cnf"  # Caminho para o arquivo com as credenciais (login e senha)
$database = "AllBkDbs" # Nome do nosso banco de dados
$errorLog = "C:\mysqlapoio\backups\erros\error_dump.log"  # Caminho para o nosso arquivo de erro de log
$days = 30 # Dias para manter os arquivos de backup
$date = Get-Date
$timestamp = "" + $date.day + $date.month + $date.year + "_" + $date.hour + $date.minute --(retirando de date day, month, year, hour, minute, concatenando em timestamp)
$backupfile = $backuppath + $database + "_" + $timestamp +".sql" --(caminho e pastas do backup)
$backupzip = $backuppath + $database + "_" + $timestamp +".zip" -- compactando
  
# FAZ O BACKUP ($ variáveis, flush log, cria um novo log)
mysqldump.exe --defaults-extra-file=$config --log-error=$errorLog  --result-file=$backupfile  --all-databases --single-transaction --flush-logs --routines --events 

# Inicia o processo de compactacao com 7zip  
7z.exe a -tzip $backupzip $backupfile
  
# Deleta o arquivo original e deixa apenas o zip
Del $backupfile
 
# Deleta arquivos antigos
CD $backuppath
$oldbackups = gci *.zip* 
  
for($i=0; $i -lt $oldbackups.count; $i++){ 
    if ($oldbackups[$i].CreationTime -lt $date.AddDays(-$days)){ 
        $oldbackups[$i] | Remove-Item -Confirm:$false
    } 
}

# fim

-- AGORA EXECUTE NO POWERSHELL e veja o resultado na pasta backups e erros
C:\MYSQLAPOIO\backupfullALLdb.ps1

--fonte
-- https://marquesfernandes.com/desenvolvimento/mysql-criando-rotinas-de-backups-no-windows-e-linux/

-- -------------------------------------------------------------------------------------

-- LAB6

-- Vamos criar um script para reciclar o log bin e realizar o backup do log para um lugar seguro, diferente do local onde
-- estao os dados. No meu caso irei colocar no mesmo disco, mas na vida real, copie para outro disco, nuvem ou fita.
-- Vamos agora criar na pasta C:\mysqlapoio um arquivo backupLOGdb.ps1 com o seguinte conteudo:

$dadosoriginaispath = "C:\ProgramData\MySQL\data\MySQL Server 8.0\data\*-bin.*" # caminho onde estao os seus arquivos bin log. Altere o caminho se precisar e mascara * do seus binlogs
$backuppath = "C:\mysqlapoio\backups\"  # Caminho para armazenar os backups, coloque a barra \ no final da caminho, caso use outra pasta para backup
$config = "C:\mysqlapoio\config.cnf"  # Caminho para o arquivo com as credenciais do root
$date = Get-Date
$timestamp = "" + $date.day + $date.month + $date.year + "_" + $date.hour + $date.minute 

$backupfile = "C:\mysqlapoio\backups\*-bin.*" # local onde foram copiados os binarios e aqui sera o local usado pelo 7z para compactar os arquivos biblog
$backupzip = $backuppath + "BINLOGBK_" + $timestamp +".zip"

# Aqui o mysql ira reclicar o logbin atual, criando um novo arquivo de log. Altere o caminho abaixo onde esta seu arquivo com a senha do root.
mysqladmin --defaults-extra-file=$config  flush-logs

# Aqui iremos copiar os arquivos de log que estao na pasta padrao para destino onde estarão todos os backups full e dos logs. Favor alterar o caminho se for necessário.
Copy-Item $dadosoriginaispath -Destination $backuppath 

# Inicia o processo de compactacao com 7zip  
7z.exe a -tzip $backupzip $backupfile

# Remove os arquivos original deixando apenas os binlogs compactados
Remove-item $backupfile

# Deleta arquivos antigos
CD $backuppath
$oldbackups = gci *.zip* 
  
for($i=0; $i -lt $oldbackups.count; $i++){ 
    if ($oldbackups[$i].CreationTime -lt $date.AddDays(-$days)){ 
        $oldbackups[$i] | Remove-Item -Confirm:$false
    } 
}

# fim

-- -------------------------------------------------------------------------------------

-- Agora edite o arquivo C:\mysqlapoio\config.cnf, e troque por este conteudo:

# Configuracoes de usuario
[mysqldump]
 user=root
 password=1234

[mysqladmin]
 user=root
 password=1234

-- Salve o arquivo e o feche. Criamos uma nova area que ira servir para executar o comando mysqladmin que esta dentro do script de backup do log, e desta forma nao 
-- ira colocar a senha, ate porque nao poderia, porque a intencao é criar uma tarefa que ira executar este script de forma automatica a cada 1 hora.

-- AGORA EXECUTE NO POWERSHELL  C:\mysqlapoio\backupLOGdb.ps1 e veja o resultado na pasta backups e erros
-- Lembre-se de acessar o powershell pela barra de tarefa, e preferencialmente rode como administrador

-- ---------------

-- LAB7
-- Vamos criar 2 tarefas no windows para rodar backups full uma vez por dia, e backup log a cada 1 hora, de forma automatica

-- VAMOS CRIAR TASK PARA FAZER BACKUP FULL DE UMA BASE DE DADOS ESPECIFICA

-- No meu caso, como estamos trabalhando neste momento com MYSQL instalado no desktop, vamos retornar a politica para execucao do powershell como Restricted.
-- Nao esqueca de rodar o powershell como administrador
-- Set-ExecutionPolicy Restricted
-- Como iremos executar o Powershell de forma automatica, e apenas naquele momento, iremos executar o script em um contexto sem restricao, atraves da opcao RemoteSigned no task sheduled

-- Iremos criar uma task no task shedule (agendador de tarefas) com uma acao: 
-- powershell -ExecutionPolicy RemoteSigned C:\MYSQLAPOIO\backupfulldb.ps1
-- Rode no powershell em qualquer pasta para ver se seu windows esta achando, senao coloque no path do windows ou na chamada para rodar o script no task sheduled, tente:
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy RemoteSigned C:\MYSQLAPOIO\backupfulldb.ps1

-- e vamos rodar esta task no conexto do seu usuário logado no windows desktop (qualquer versao aqui, como windows 10). 
-- Isto é apenas um LAB. No mundo real iremos criar uma task para rodar de forma automatica em um servidor windows server ou linux e nao 
-- no desktop windows. Neste momento para o windows server iremos rodar o powershell sob o usuário do windows, chamado SYSTEM ou SISTEMA (dependendo da lingua do windows server).

-- VAMOS CRIAR UMA OUTRA TASK PARA FAZER BACKUP FULL DE TODAS AS BASES DE DADOS NA INSTANCIA SQL
powershell -ExecutionPolicy RemoteSigned C:\MYSQLAPOIO\backupfullALLdb.ps1

-- VAMOS CRIAR UMA OUTRA TASK PARA FAZER BACKUP DOS BINLOGS (BACKUP INCREMENTAL)
powershell -ExecutionPolicy RemoteSigned C:\MYSQLAPOIO\backupLOGdb.ps1

-- VAMOS DEPOIS CRIAR NO AGENDADOR DE TAREFAS, TRIGGERS (GATILHOS) PARA EXECUTAR AS TAREFAS DE FORMA AUTOMATICA E COLOQUE PARA RODAR E VEJA NA PASTA DE BACKUP

-- -------------------------------------------------------------------------------------

-- LAB8
-- Uma outra opcao de fazer backups de forma automatica é com arquivos do tipo .bat, como exemplo:
-- Nao sao tao poderosos como powershell mas consegue fazer o trabalho. Na sua vida profissional, procure aprender a usar o powershell.
-- Como tarefa, procure melhorar o script abaixo, por exemplo, colocando a senha em outro arquivo de configuracao e deletando arquivos antigos. Procure na internet
-- como poderá fazer isto. É sua responsabilidade buscar o conhecimento, e nao existe ferramenta melhor do que a internet atraves de artigos e videos no youtube.

@echo off

for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a" -- definindo data e hora
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%" & set "MS=%dt:~15,3%"
set "dirname=%DD%_%MM%_%YY%_%HH%%Min%" -- concatenando dia, mês, ano, minuto
 
set basedir=C: -- definindo o disco (ideal disco diferente do c)
set workdir=C:\mysqlapoio\backups\ -- definindo o caminho
set mysqlpassword=1234 -- diferente do arquivo powershell, que busca no config .cnf, deixando a senha e user. Ideal, por segurança, é pôr em outro arquivo
set mysqluser=root -- diferente do arquivo powershell, que busca no config .cnf, deixando a senha e user
set mysqldb=Dbteste -- definindo base de dados
 
mysqldump -u %mysqluser% -p%mysqlpassword% %mysqldb% >%workdir%\backupdbtesteviabatch.sql -- bkp por meio do root, senha, db, caminho, nome do arquivo bat

7z.exe a -tzip %dirname%.7z %workdir%\backupdbtesteviabatch.sql -- compactando -- dirname(dia, mes, hora, minuto) -- workdir (caminho)

MOVE %dirname%.7z %workdir% -- (mover o arquivo zipado, de qualquer lugar onde tenha sido salvo, para este caminho)
DEL %workdir%\backupdbtesteviabatch.sql -- deletando o arquivo bkp, deixando apenas zip


-----

-- Puxando usser e password de config.cnf e apagando bkp após 30 dias

	@echo off
setlocal enabledelayedexpansion

:: Get local datetime and format it
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=!dt:~2,2!" & set "YYYY=!dt:~0,4!" & set "MM=!dt:~4,2!" & set "DD=!dt:~6,2!"
set "HH=!dt:~8,2!" & set "Min=!dt:~10,2!" & set "Sec=!dt:~12,2!" & set "MS=!dt:~15,3!"
set "dirname=!DD!_!MM!_!YY!_!HH!!Min!"

:: Set directories
set "basedir=C:"
set "workdir=C:\mysqlapoio\backups\"

:: Read MySQL credentials from config.cnf
for /f "tokens=1,2 delims==" %%i in (config.cnf) do (
    if "%%i"=="user" set "mysqluser=%%j"
    if "%%i"=="password" set "mysqlpassword=%%j"
)

:: Perform MySQL dump
mysqldump -u !mysqluser! -p!mysqlpassword! %mysqldb% > "%workdir%\backupdbtesteviabatch.sql"

:: Check if mysqldump was successful before proceeding
if not errorlevel 1 (
    :: Create a compressed archive with 7-Zip
    7z.exe a -tzip "%workdir%\!dirname!.7z" "%workdir%\backupdbtesteviabatch.sql"

    :: Move the archive if it was created successfully
    if exist "%workdir%\!dirname!.7z" (
        move "%workdir%\!dirname!.7z" "%workdir%"
    )

    :: Delete the SQL dump file
    del "%workdir%\backupdbtesteviabatch.sql"
) else (
    echo mysqldump failed, check your username and password.
)

:: Delete backups older than 30 days
forfiles /p "%workdir%" /s /m *.7z /d -30 /c "cmd /c del @path"

endlocal


-- -------------------------------------------------------------------------------------------------------

-- LAB9
-- Vamos restaurar um backup full e do BINLOG

-- VAMOS SIMULAR UM PROBLEMA NO DISCO OU NA BASE DE DADOS. VAMOS DELETAR A BASE DE DADOS DBTESTE E VAMOS TENTAR SUBIR O ULTIMO BACKUP FULL E LOG

-- Passos

-- 1. Vamos na pasta onde foram feitos os backups e vamos descompactar o ultimo backup full dbteste_522022_015.zip e o ultimo backup dos binlog

-- 2. Va no Workbench ou acesse o mysql pelo DOS, como já viu, e delete a base de dados DBTESTE, simulando assim uma destruicao da base de dados OU SE DESEJASSE QUE NAO HOUVESSE ACESSOS NA BASE ENQUANTO ESTAMOS SUBINDO OS BACKUPS E OS LOGS
DROP DATABASE DBTESTE;
-- 2.1. VAMOS CRIAR UM NOVO BANCO DE DADOS QUE SERA USADO PARA RESTAURAR NOSSO BACKUP E PODER APLICAR OS BINLOGS SEM QUE NENHUMA APLICACAO CONTINUE A REALIZAR TRANSACOES NO DBTESTE
CREATE DATABASE dbteste_emrestauracao;

-- 3. Vamos ao DOS agora e rodar o comando para restaurar o backup full
-- VAMOS CRIAR UM BANCO QUE NINGUEM TENHA ACESSO, OU NENHUMA APLICACAO, ENQUANTO ESTAMOS RESTAURANDO O BACKUP E APLICANDO AS TRANSACOES QUE ESTAO NO BIN LOG
-- Va na pasta abaixo onde criou seu backup e edite o arquivo de backup dbteste_522022_015.sql, substituindo o nome do banco dbteste para dbteste_emrestauracao e nao de acesso para ninguem
cd C:\mysqlapoio\backups
-- Salve o arquivo dbteste_522022_015.sql, alterado o nome do banco a ser criado, para evitar o acesso por algum servico ou aplicacao 
-- e execute o comando abaixo para restaurar o banco dbteste_emrestauracao

mysql -u root -p dbteste_emrestauracao < dbteste_522022_015.sql

-- veja o conteudo da tabela e repare que voltou os dados de acordo com o ultimo backup full mas provavelmente, no mundo real, se houvesse transacoes no banco apos 
-- ou mesmo durante o backup full estiver ocorrendo(lembre que com a opcao single transaction, o mysqldump nao bloqueia as tabelas, mas tira um retrato do banco antes de iniciar o backup), 
-- estas transacoes nao estarao no backup full e neste caso deveriamos aplicar as transacoes que estao no binlog dentro do banco dbteste_emrestauracao, depois de carregado o backup full.

use dbteste_emrestauracao ;
select * from dbteste_t1;

-- Agora precisamos apenas aplicar as transacoes no banco dbteste_emrestauracao, que estao nos logs binários que desejamos, que foram salvos como arquivos de backup, atraves por exemplo
-- dos comandos abaixo:

cd C:\mysqlapoio\backups\

mysqlbinlog DESKTOP-MKCDD14-bin.000194 | mysql -uroot -p dbteste_emrestauracao 
mysqlbinlog DESKTOP-MKCDD14-bin.000195 | mysql -uroot -p dbteste_emrestauracao 
mysqlbinlog DESKTOP-MKCDD14-bin.000196 | mysql -uroot -p dbteste_emrestauracao 
mysqlbinlog DESKTOP-MKCDD14-bin.000197 | mysql -uroot -p dbteste_emrestauracao 

-- Poderiamos aplicar os varios binlogs sem verificar o conteudo antes, como fizemos no exemplo anterior, ou usar o comando abaixo para gerar os .sql antes, abrir os binlogs e de repente remover um comando 
-- especifico a sequencia das restauracao. Cuidado com esta opcao, para nao remover uma alteracao feita em tabelas que o proximo comando poderia ter problemas de integridade referencial.

cd C:\mysqlapoio\backups\

mysqlbinlog DESKTOP-MKCDD14-bin.000194 >  C:\mysqlapoio\backups\bklogs.sql | mysql -uroot -p dbteste_emrestauracao 
mysqlbinlog DESKTOP-MKCDD14-bin.000195 >> C:\mysqlapoio\backups\bklogs.sql | mysql -uroot -p dbteste_emrestauracao 
mysqlbinlog DESKTOP-MKCDD14-bin.000196 >> C:\mysqlapoio\backups\bklogs.sql | mysql -uroot -p dbteste_emrestauracao 
mysqlbinlog DESKTOP-MKCDD14-bin.000197 >> C:\mysqlapoio\backups\bklogs.sql | mysql -uroot -p dbteste_emrestauracao 

-- Repare no arquivo C:\mysqlapoio\backups\bklogs.sql que esta sendo concatenado com todos os binlogs, aumentando de tamanho.
-- No final quando tiver o arquivo unico e por exemplo, se precisar, poderá remover algum comando critico, como um delete sem where ou algo especifico que nao impacte a integridade
-- das outras tabelas. Para aplicar no banco as transacoes do binlog lendo desta nova fonte, execute o comando abaixo:

mysql -u root -p -e "source C:\mysqlapoio\backups\bklogs.sql"

-- E lembre-se ainda que podemos usar o mysqlbonlog para retornar transacoes ate um dia especifico, como exemplo:
-- mysqlbinlog --stop-datetime="2022-01-19 23:37:00" DESKTOP-MKCDD14-bin.000083 | mysql -uroot -p dbteste

-- retorne ao workbench e execute novamente
use dbteste_emrestauracao ;
select * from dbteste_t1; 
-- agora voce tem todos os dados atualizados, desde o ultimo backup full ate a ultima transacao que esta registrada no log. Poderia ter feito varios backups full e carregados todos os backups
-- mas backup full eh uma operacao mais pesada, porque copia todo o banco e nao apenas as transacoes apos ultimo backup full.

-- 4. agora vamos fazer um backup full da base de dados de restauraçao com todas as transacoes ja aplicadas.
cd C:\mysqlapoio\backups\
mysqldump -u root -p  dbteste_emrestauracao --routines --events --flush-logs  > BKDBTESTEFINAL.sql

-- Va no workbench e crie banco novo dbteste novamente e depois vamos finalmente subir o backup dos objetos e dados neste banco
create database dbteste;

-- Vamos agora subir o backup realizar neste banco.
mysql -u root -p dbteste < BKDBTESTEFINAL.sql

-- E agora vamos deletar o banco  dbteste_emrestauracao
drop database  dbteste_emrestauracao;

-- FIM, agora o banco esta liberado para uso com todas as transacoes aplicacadas. Favor realizar varios testes em ambiente de homologacao antes de colocar em producao o processo.

-- -------------------------------------------------------------------------------------------------------

-- LAB10
-- UMA SOLUCAO FANTASTICA, COM CODIGO ABERTO E FREE PARA BACKUPS FULL, INCREMENTAIS, FAZ COMPACTACAO, NAO BLOQUEA AS TABELAS, ... É O PERCONA Xtrabackup 
-- Atualmente este software roda apenas no linux. 
-- Vamos ver no modulo linux do curso, mas se for lancado para o windows, provavelmente a sintaxe será o mesmo que no Linux

-- Pesquise no google a palavra Xtrabackup ou teste link:
https://www.percona.com/software/mysql-database/percona-xtrabackup

-- --------------------------------------------------------------------------------------------------------

-- LAB11
-- Vamos fazer backup fisico do banco e depois uma restauracao fisica usando o plugin clone no workbench
-- Ferramenta para fazer copia fisica (snapshot) dos bancos de forma muita rapida. Otimo para bases muito grandes.
-- Não faz bloqueios nas tabelas
-- Liberado na versao 8.x

-- ALGUMAS LIMITAÇOES:
-- 1. Apenas em tabelas INOODB
-- 2. Uma instância não pode ser clonada de uma versão ou versão diferente do servidor MySQL. O doador e o destinatário devem ter exatamente 
--    a mesma versão e versão do servidor MySQL. Por exemplo, você não pode clonar entre MySQL 5.7 e MySQL 8.0, ou entre MySQL 8.0.19 e 
--    MySQL 8.0.20. O plug-in clone é suportado apenas no MySQL 8.0.17 e superior.
-- 3. O plug-in clone não suporta a clonagem de configurações do servidor MySQL. A instância do servidor MySQL do destinatário mantém sua configuração, 
--    incluindo configurações de variáveis ​​de sistema persistentes (consulte a Seção 5.1.9.3, “Variáveis ​​de sistema persistentes” .)
-- 4. O plug-in clone não oferece suporte à clonagem de logs binários(backup transacional).
-- https://dev.mysql.com/doc/refman/8.0/en/clone-plugin-limitations.html

-- Estudo de caso de performance do backup usando plugin clone
https://mydbops.wordpress.com/2019/11/14/mysql-clone-plugin-speed-test/

-- ETAPAS

-- 1. Editar o arquivo de configuraçao de start do mysql, my.cnf ou my.ini e incluir algumas linhas para que no start do mysql seja carregado o dll do plugin clone

-- Parametros abaixo:Instala dll, liga compressao e coloca limite maximo de iops em MB para o disco para ter maxima performance do backup usando todo iops do disco ou 
-- limitando para durante o backup nao prejudicar aplicacao que estiver usando o mesmo disco
-- ou posso limitar banda da rede maxima para trafegar o backup pela rede se estivermos fazendo backup em outro servidor.
-- As linhas abaixo no my.ini devem estar abaixo do label [mysqld]

plugin-load="mysql_clone.dll"
clone-enable-compression
clone-max-data-bandwidth=50
clone-max-network-bandwidth=100

-- SALVAR O ARQUIVO
-- Se ao salvar receber um erro que nao tem permissao para salvar este arquivo, encontre seu arquivo my.ini que deve estar na pasta C:\ProgramData\MySQL\data\MySQL Server 8.0
-- Clique com botao direito em propriedades, segurança e se estiver rodando no seu notebook, selecione seu usuario e de permisao MODIFICAR no arquivo para poder modifica-lo.
-- Se estiver em um ambiente de servidores, irá mudar a permissao para alterar a propriedade deste arquivo de acordo com a politica de segurança da empresa, lhe dando permissáo 
-- para alterar ou grupo de administradores definido.

-- 2. Parar o servico do mysql e dar start novamente para carregar as configuracoes 
-- do arquivo my.cnf ou my.ini
-- No meu caso o arquivo my.ini esta na pasta C:\ProgramData\MySQL\data\MySQL Server 8.0
-- A pasta C:\ProgramData está escondida por default. Para fazer com que aparece no windows explorer, va no c:, selecione no menu EXIBIR, ITENS OCULTOS

-- OBS: O caminho padrao onde está a dll é C:\Program Files\MySQL\MySQL Server 8.0\lib\plugin\mysql_clone.dll. Verifique se foi instalado junto mas por padrao, provavelmente foi instalado.

-- 3. Vamos nos conectar no workbench na instancia sql com usuario root ou DBA ou um user com papel backup_admin e vamos rodar o seguinte comando para clonar nossa instancia na pasta
-- C:\mysqlapoio\clonebackup

clone LOCAL DATA DIRECTORY 'C:\\mysqlapoio\\clonebackup';
-- Va na pasta e veja a copia realizada. 

-- OBS> REPARE QUE EU COLOQUEI COM DUAS BARRAS \\
-- Se usar apenas \, o MYSQL não faz a copia.

-- Depois que clonou e ele criou os arquivos em uma pasta, se tentar repetir o mesmo comando clone LOCAL DATA DIRECTORY 'C:\\mysqlapoio\\clonebackup';
-- Error Code: 1007. Can't create database 'C:\mysqlapoio\clonebackup'; database exists	0.000 sec

-- Para clonar novamente precisaria antes deletar a pasta ou mover a pasta do snapshot para outro local. Poderia por exemplo mover e compactar como
-- um backup dos bancos da instancia mysql.

-- SE DEU ERRO ABAIXO:
	
-- Error Code: 1524. Plugin 'clone' is not loaded	0.000 sec
-- Houve algum problema para carregar a dll do plugin. Cheque o arquivo my.ini ou my.cnf na pasta C:\ProgramData\MySQL\data\MySQL Server 8.0 e coloque as linhas abaixo do label [mysqld]

plugin-load="mysql_clone.dll"
clone-enable-compression
clone-max-data-bandwidth=50
clone-max-network-bandwidth=100

-- Parar o servico mysql e dar start novamente

-- ------------------------------------------------------------ FIM COPIA, AGORA VAMOS TENTAR FAZER UMA RESTAURACAO DAS BASES DEPOIS DE UM DESASTRE DO SERVIDOR

-- ETAPAS

-- 0 ANTES DE QUALQUER OPERACAO QUE ENVOLVA DELECAO DE BASES DE DADOS, 
-- tente fazer um ultimo backup full e copiar todos os files que estao em C:\ProgramData\MySQL\MySQL Server 8.0\Data para outro local. 
-- SEU EMPREGO PODE DEPENDER DISTO. NAO CONFIE 100% EM SEUS BACKUPS ANTERIORES OU CLONES. FAÇA SEMPRE UM ULTIMO BACKUP DE TODAS AS BASES E DAS PASTAS E FILES DA PASTA DATA.

-- 1.  Vamos simular um desastre em nossa instancia. Vamos deletar o banconovo e vamos tentar recuperar toda a instancia mysql com o clone feito.
--     Vamos agora Parar o servico mysql.

-- 2. Copiar todos os arquivos que estao dentro da pasta C:\mysqlapoio\clonebackup para C:\ProgramData\MySQL\MySQL Server 8.0\Data e aceitar substituir. 
--    Quando o Windows perguntar se quer substituir todos os arquivos que estao em C:\ProgramData\MySQL\MySQL Server 8.0\Data, diga sim

-- 3. Iniciar o servico mysql 

-- SE APARECER ESTE ERRO NO START DO MYSSQL

alguns servicos sao interrompidos automaticamente se nao estiverem sendo usados por outros servicos

Procure em foruns para tentar achar a solucao. Veja que as vezes eh dificil achar a solucao devido a frase de erro estar em portugues. Va no google translate e traduza para ingles
que sua chance de achar a solucao será maior.

MYSQL some services are stopped automatically if they are not being used by other services

-- Mas o problema, provavelmente aconteceu porque nao copiou os arquivos do backup do clone para a pasta certa DATA, onde estao os bancos de dados.

-- Se o problema persistir apos rever o arquivo .ini e copiar novamente os arquivos, veja este link e tente seguir os passos, indicados, porque pode ocorrer este problema tambem:
https://madbray.com/mysql80-service-started-and-then-stopped-fixed/
-- Para baixar o notepad++ afim de verificar se algum hex foi colocado no my.ini conforme indicado no link acima
https://notepad-plus-plus.org/
OBS: PROCURE SEMPRE FAZER BACKUPS RECORRENTES DO MY.INI PORQUE EM UM MOMENTO DESTE PODERIA RESTAURAR O BACKUP DO MY.INI SE O PROBLEMA ESTIVESSE NO MY.INI

-- Se ainda nao conseguiu descobrir o problema, DEIXEI POR ULTIMO QUE A PRIMEIRA COISA QUE DEVE OLHAR É O LOG DO ERROR QUE GERALMENTE FICA NA PASTA DATA
-- NO MEU CASO BASTA ABRIR COM NOTEPAD O AQUIVO DESKTOP-MKCDD14.err

-- PARA TER CERTEZA DO NOME DO ARQUIVO DE LOG, BASTA ABRIR O MY.INI E PROCURAR O LABEL ABAIXO. NO SEU CASO, O NOME DO DESKTOP SERA OUTRO.
# Error Logging.
log-error="DESKTOP-MKCDD14.err"

-- SE PASSOU POR TODOS OS PROCESSOS E NAO CONSEGUIU RESOLVER, PODE SER QUE NA COPIA TER CORROMPIDO ALGUM ARQUIVO IMPORTANTE, OU NAO TER PARADO O SERVICO E TENTADO COPIAR ALGUNS ARQUIVOS E OUTROS NAO E AI TER PERDIDO AS REFERENCIAS
-- ENTRE OS ARQUIVOS E AI EM ULTIMO CASO TERA QUE REMOVER O MYSQL E INSTALAR
-- NOVAMENTE E DEPOIS COPIAR OS ARQUIVOS DO CLONE PARA PASTA DATA E DAR START NO MYSQL.
-- PARA ISTO, BAIXE NOVAMENTE DO SITE MYSQL O INSTALAR E QUANDO EXECUTAR APARECERÁ UMA JANELA ONDE PODERA REMOVER OS APLICATIVOS DO MYSQL E INSTALAR NOVAMENTE DEPOIS.


-- --------------------------------------------------------- FIM RESTORE

-- OBS: NA ULTIMA AULA, QUANDO TENTEI ABRIR O WORKBENCH APARECEU UM ERRO, QUE JA VINHA OCORRENDO ANTES, MAS NAO ERA NADA DE GRAVE
-- Para resolver va nesta pasta C:\Users\NOMESEUUSUARIO\AppData\Roaming\MySQL\Workbench\sql_workspaces
-- e delete todos os arquivos que estao na pasta sql_workspaces.
-- Feche o workbench e abra novamente e veja se o erro continua...

-- ---------------------------

-- Vamos agora agendar para este clone ser feita de forma recorrente e automatica, utilizando os recursos de EVENT que nos vimos em aulas passadas e agendador de eventos
-- do windows.

-- ETAPAS

-- 1. Primeiro vamos criar um evento no workbench, conforme abaixo:

-- Vamos agendar para executar um evento que vai ocorrer daqui 1 minuto e vai fazer o clone, como um teste do nosso lab.
-- Retorne as aulas sobre eventos e veja os exemplos. 
-- No script abaixo, vamos apenas rodar o evento para copiar os bancos de dados da instancia sql daqui 1 minuto, mas por exemplo voce pode criar eventos para rodar 1 vez por dia, ou a cada x horas
-- e ai voce vai fazer uma rotina casada com agendador de tarefas, para antes do evento rodar no workbench, o backup do clone ser movido para outra pasta e ser compactado 
-- para evitar erro quando o evento no workbench rodar e tentar fazer clone novamente, porque lembra que se tentarmos fazer clone a segunda vez da erro, porque a pasta ja existe
-- entao precisamos criar uma tarefa no windows para antes do clone rodar, a pasta ser movida para outro local.

use sys; -- deixe este comando ou marque um banco como default

delimiter $$

CREATE EVENT inseredados1minuto
    ON SCHEDULE AT NOW() + INTERVAL 1 MINUTE -- ao inves da funcao NOW(), poderiamos usar tambem CURRENT_TIMESTAMP + INTERVAL 1 MINUTE
    DO
      BEGIN
        clone LOCAL DATA DIRECTORY 'C:\\mysqlapoio\\clonebackup';
      END $$

delimiter ;

SHOW EVENTS ;

-- -------------------------------------------------------------------------------

-- 2. Agora vamos no agendador de tarefa do windows e vamos criar uma tarefa nova que vai rodar de forma automatica todo dia a cada 1 minuto, apenas como laboratorio, antes do EVENT do mysql rodar.
-- Neste caso esta tarefa vai rodar o script abaixo que vai mover a pasta do backup do clone para a pasta definitiva do backup, que o ideal que seria em outro disco e vamos
-- compactar esta pasta e concatenar com data e hora que este backup foi feito para nao termos problemas na proxima vez que rodar e para podermos saber quando foi feito.
-- Vamos salvar este script com o nome bkPluginClone.bat e vamos colocar na pasta mysqlapoio. 
-- Vou deixar o script pronto para voce baixar, mas se desejar criar o .bat segue o script. Atencao para mudar os caminhos da leitura do arquivo e do destino, se
-- criou novas pastas em locais diferentes

@echo off

for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%" & set "MS=%dt:~15,3%"
set "dirname=%DD%_%MM%_%YY%_%HH%%Min%"
 
set basedir=C:
set workdir=C:\mysqlapoio\clonebackup\
set BKclonedir=C:\mysqlapoio\backups\BACKUPS_PluginClone\

7z.exe a -t7z cloneBK%dirname%.7z %workdir%\

MOVE cloneBK%dirname%.7z %BKclonedir%
DEL %workdir%*.* /q /f
RD %workdir% /q /s

-- ----------------------------------------------------------------------------

-- 3. AGORA VAMOS CRIAR TAREFA NO AGENDADOR DE TAREFAS DO WINDOWS PARA RODAR ESTE SCRIPT DE FORMA ROTINEIRA ANTES DO MYSQL RODAR O EVENTO PARA FAZER O CLONE DAS BASES DE DADOS

-- Veja o resultado na pasta final do backup, sendo gerado varios backups compactados do clone

-- OBS: NAO ESQUECA DE DELETAR OU PARAR A ROTINA DE BACKUP NO AGENDADOR DE TAREFAS DO WINDOWS SENAO SEU DISCO VAI ENCHER DEVIDO OS BACKUPS

-- -----------------------------------------------------------------------------------------------------------------------------------------

-- LAB FINAL BACKUP NO WINDOWS

-- AGORA VAMOS CRIAR UMA ROTINA CASADA COM EVENT NO WORKBENCH E NO AGENDADOR DE TAREFAS, SIMULANDO UM EVENTO DE CLONE DE BACKUP QUE VAI OCORRER A CADA 3 MINUTOS E A COPIA DA PASTA
-- SENDO FEITO PELO AGENDADOR DE TAREFAS SENDO EXECUTADO ANTES OU PODERIA RODAR PRIMEIRO O EVENT PARA GERAR A PASTA E DEPOIS DE TER TERMINADO O CLONE AI AGENDAR O AGENDADOR DE TAREFAS
-- DO WINDOWS PARA RODAR E ASSIM COPIAR ESTA PASTA PARA LOCAL DEFINITIVO E DELETAR A PASTA ONDE O EVENT GERA. NO DIA A DIA, VAI SER MAIS FACIL, PORQUE NAO VAI FICANDO RODANDO ESTES
-- DOIS PROCESSOS A CADA 3 MINUTOS, MAS SIM POR EXEMPLO VAI RODAR O CLONE PARA GERAR O BACKUP 1 VEZ POR DIA, OU A CADA X HORAS E DEPOIS VAI CALCULAR O TEMPO DA COPIA PARA COLOCAR 
-- O AGENDADOR DO WINDOWS PARA COPUAR A PASTA PARA NOVO LOCAL E DELETAR A PASTA ORIGINAL, PARA NAO DAR ERRO NA PROXIMA EXECUCAO DO PLUG CLONE.
 OU X 
-- NAO SE ESQUECA DE NO FINAL DO LABORATORIO DELETAR A TAREFA DO AGENDADOR DE TAREFAS DO WINDOWS E O EVENT NO WORKBENCH. 
-- PARA DELETAR UM EVENT CONFORME JA VIMOS BASTA EXECUTAR drop EVENT if exists NOMEEVENTO;

-- VAMOS NO WORKBENCH E VAMOS CRIAR UM EVENT QUE VAI RODAR A CADA 3 MINUTOS. AQUI EH APENAS UM TESTE PARA DEMONSTRACAO PORQUE NO MUNDO REAL VOCE VAI COLOCAR PARA RODAR A CADA X HORAS,
-- OU X DIAS OU X SEMANAS,...

-- GARANTA QUE NAO EXISTA ESTA PASTA JA CRIADA NO DISCO C:\mysqlapoio\clonebackup

use sys;

delimiter $$
CREATE EVENT BKCLONE
    ON SCHEDULE EVERY 3 DAY_MINUTE
    ENDS  '2029-04-30' -- PODERIAMOS COLOCAR AINDA UMA DATA PARA O EVENTO PARAR DE RODAR, E SE NAO COLOCAR RODA POR TEMPO INDEFINIDO
    DO
     BEGIN
        clone LOCAL DATA DIRECTORY 'C:\\mysqlapoio\\clonebackup';
     END $$
delimiter ;

-- E VAMOS VER O EVENTO
SHOW EVENTS; -- repare nas colunas

-- CORRA AGORA E VAI NO AGENDADOR DE TAREFAS E CRIE UMA NOVA TAREFA PARA SER EXECUTADO A CADA 1 OU 2 MINUTOS PARA VERMOS NO LAB, 
-- OU NO MUNDO REAL X TEMPO DEPOIS DO CLONE RODAR, E VAI EXECUTAR O ARQUIVO C:\mysqlapoio\bkPluginClone.BAT
--  E ASSIM IRA COPIAR A PASTA clonebackup E SEUS ARQUIVOS PARA PASTA DEFINITIVA DOS BACKUPS PARA NA PROXIMA RODADA DO EVENT NAO OCORRER ERRO DEVIDO A PASTA C:\mysqlapoio\clonebackup' ESTAR AINDA LA.

-- NAO ESQUECA DE NO FINAL DELETAR O EVENTO DO WORKBENCH E A TAREFA DO AGENDADOR DE TAREFAS DO WINDOWS 8-)
-- RODE NO WORKBENCH:
drop EVENT if exists BKCLONE;
SHOW EVENTS;

-- E DELETE A TAREFA DO AGENDADOR DE TAREFAS DO WINDOWS

-- ABRACO E VAMOS MUDAR UM POUCO DE ASSUNTO PORQUE ACHO QUE JÁ ESTÁ CANSADO DE BACKUP. VOLTAREMOS A FALAR NO LINUX...

-- FIM
                                                                                                                                                                                                                                                         
