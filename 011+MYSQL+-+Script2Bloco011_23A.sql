
/*==================================================================================
Curso: MYSQL
Instrutor: Sandro Servino
https://www.linkedin.com/in/sandroservino/?originalSubdomain=pt
https://www.udemy.com/user/sandro-servino-3/

-------   FAZENDO BACKUP SEM EXPOR A SENHA DO ROOT OU USER DE BACKUP --------
https://dev.mysql.com/doc/refman/8.0/en/mysql-config-editor.html

Vamos ao DOS, e vamos tentar conectar ao servidor mysql com o comando client mysql sem senha.

mysql

Não vai funcionar porque precisamos entrar com a senha de um user ou mesmo do root, entao vamos tentar

mysql -u root -p

No meu caso, eu criei uma senha fraca 123. Em producao, jamais crie senhas fracas, principalmente
para root.

exit

Vamos rodar o script bk.bat, que criamos em aulas passadas para fazer backup. Lembrando que neste script
a senha do root ficou no arquivo. Voce deve colocar em uma pasta segura e remover permissoes para usuários
normais poder abrir o arquivo, mas ainda assim temos uma fragilidade porque a senha está dentro deste arquivo
nao criptografada.

Vamos ao DOS 
cd C:\mysqlapoio
rode bk.bat

-- Para relembrar, segue script bk.bat, onde o user root e a senha do root estão no arquivo.

-- ------------------------------------------------------------------------------------------

@echo off

for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%" & set "MS=%dt:~15,3%"
set "dirname=%DD%_%MM%_%YY%_%HH%%Min%"
 
set basedir=C:
set workdir=C:\mysqlapoio\backups\
set mysqlpassword=123
set mysqluser=root
set mysqldb=Dbteste
 
mysqldump -u %mysqluser% -p%mysqlpassword% %mysqldb% >%workdir%\backupdbtesteviabatch.sql

7z.exe a -tzip %dirname%.7z %workdir%\backupdbtesteviabatch.sql

MOVE %dirname%.7z %workdir%
DEL %workdir%\backupdbtesteviabatch.sql

-- ------------------------------------------------------------------------------------------

Agora vamos criar um arquivo criptografado com a senha do root dentro atraves do utilitario 
mysql_config_editor que por padrao fica na pasta C:\Program Files\MySQL\MySQL Server 8.0\bin

Vamos executar o comando abaixo. Se não trouxer nenhum resultado é porque não existe nenhum arquivo 
criptografado com o login e senha do root.

mysql_config_editor print --all

Para criarmos este arquivo senha o comando:

mysql_config_editor set --login-path=multiuseaccess_mysql_root --host=localhost --user=root --password --(passar o user e senha corretos a serem gravados, pois não verifica se estão corretos ou não. Cria-se apenas um por vez)

mysql_config_editor print --all

dica> foi criado um arquivo .mylogin.cnf com a senha criptograda do user definido no mysql_config_editor
vinculado a uma profiler ultiuseaccess_mysql_root que é unica e fica na memoria. Poderia criar 
outra profiler vinculado a outro user do mysql como por exemplo um user com privilegio de apenas
fazer backup. Este arquivo fica na pasta C:\Users\SEUUSERWINDOWS\AppData\Roaming\MySQL, no meu caso
C:\Users\SERVINO\AppData\Roaming\MySQL

obs: multiuseaccess_mysql_root será usado depois para fazer a conexao com o MYSQL server, ou seja, 
poderemos conexar o server sem precisar por exemplo colocar a senha no arquivo do bat, ou mesmo conectar o 
server, porque será criado uma variavel global no sistema operacional windows chamada multiuseaccess_mysql_root
e assim teremos permissao de conectar o server atraves desta conexao. Isto nao impede de ter que deixar o
arquivo bat de backup em um local seguro.

Podemos a partir daqui, logar passando o login e senha no client, desta forma:
mysql -u root -p

ou usando esta variavel global criada neste host
mysql --login-path=multiuseaccess_mysql_root

E assim poderemos agora alterar o script bat, para remover o login root e a senha do root de dentro
do arquivo, para nao deixar a senha exposta, correndo risco de alguem descobrir a senha do root.

Dica: A melhor solucao, seria criar um user no banco mysql apenas para backup e colocar esse user na role
backup, para evitar que alguem descubra esta variavel e logar com privilegio do root.
https://dev.mysql.com/doc/mysql-enterprise-backup/4.1/en/mysqlbackup.privileges.html

CREATE USER 'mysqlbackup'@'localhost' IDENTIFIED BY 'password';
GRANT RELOAD, SUPER, PROCESS ON *.* TO 'mysqlbackup'@'localhost';
GRANT CREATE, INSERT, DROP, UPDATE ON mysql.backup_progress TO 'mysqlbackup'@'localhost';
GRANT CREATE, INSERT, SELECT, DROP, UPDATE, ALTER ON mysql.backup_history 
    TO 'mysqlbackup'@'localhost';
GRANT REPLICATION CLIENT ON *.* TO 'mysqlbackup'@'localhost';
GRANT SELECT ON performance_schema.replication_group_members TO 'mysqlbackup'@'localhost';

-- ideal criar role e aribuir o paper ao user
CREATE USER 'mysqlbackup'@'localhost' IDENTIFIED BY 'password';
CREATE ROLE bkp_role;
GRANT RELOAD, SUPER, PROCESS ON *.* TO bkp_role;
GRANT CREATE, INSERT, DROP, UPDATE ON mysql.backup_progress TO bkp_role;
GRANT CREATE, INSERT, SELECT, DROP, UPDATE, ALTER ON mysql.backup_history 
    TO bkp_role;
GRANT REPLICATION CLIENT ON *.* TO bkp_role;
GRANT SELECT ON performance_schema.replication_group_members TO bkp_role;
GRANT bkp_role TO 'mysqlbackup'@'localhost';

mysql_config_editor set --login-path=multiuseaccess_mysql_root --host=localhost --user=mysqlbackup --password

-- Vamos criar um novo arquivo de backup bk_comsenhacriptografada.bat removendo o user e senha. O mesmo poderá 
-- ser feito com os script powershell .ps1 que voce viu nos exemplos.
-- ------------------------------------------------------------------------------------------

@echo off

for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%" & set "MS=%dt:~15,3%"
set "dirname=%DD%_%MM%_%YY%_%HH%%Min%"
 
set basedir=C:
set workdir=C:\mysqlapoio\backups\

set mysqldb=Dbteste
 
mysqldump --login-path=multiuseaccess_mysql_root %mysqldb% >%workdir%\backupdbtesteviabatch.sql

7z.exe a -tzip %dirname%.7z %workdir%\backupdbtesteviabatch.sql

MOVE %dirname%.7z %workdir%
DEL %workdir%\backupdbtesteviabatch.sql

-- ------------------------------------------------------------------------------------------

Vamos no DOS, e vamos rodar este script.

Vamos ao DOS 
cd C:\mysqlapoio
rode bk_comsenhacriptografada.bat

Verifique na pasta C:\mysqlapoio\backups\ que o backup foi feito com sucesso e assim poderã agora
colocar no task shedule ou agendador de tarefas para chamar este script.

Para remover este profiler, rode:

mysql_config_editor remove --login-path=multiuseaccess_mysql_root -- comando padrão que remove o profiler (sempre termina com root)

e assim nao conseguirá mais acessar o server com este profiler mais
mysql --login-path=multiuseaccess_mysql_root

Apenas desta forma:
mysql -u root -p


-- FIM






















                                                                                                                                                                                                                                                                  