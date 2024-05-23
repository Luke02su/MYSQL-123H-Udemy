
/*==================================================================================
Curso: MYSQL
Instrutor: Sandro Servino
https://www.linkedin.com/in/sandroservino/?originalSubdomain=pt
https://www.udemy.com/user/sandro-servino-3/

-------   USERS, PRIVILEGIOS E PAPEIS  --------

- PRIVILEGIOS SOBRE DADOS

SELECT:	Realizar consultas em tabelas
INSERT:	Inserir dados em tabelas
UPDATE:	Atualizar dados em tabelas
DELETE:	Deletar dados em tabelas
EXECUTE: Chamar funções e stored procedures

- PRIVILEGIOS SOBRE OBJETOS DOS BANCOS DE DADOS

CREATE:	Criar tabela nova ou banco de dados
ALTER:	Alterar uma tabela existente
DROP :	Deletar tabela ou um banco de dados especifico
INDEX:	Criar ou excluir um índice em tabela
TRIGGER: Criar ou excluir trigger em tabela
CREATE VIEWS:	Criar visões de dados
CREATE ROUTINE:	Criar uma função ou stored procedure
ALTER ROUTINE:	Alterar ou excluir uma função ou stored procedure

- ALGUNS PRIVILEGIOS BEM ORIENTADOS PARA OS ADMINISTRADORES DOS BANCOS DE DADOS

CREATE USER e DROP USER: Criar e deletar os usuários que irão acessar os bancos de dados e seus objetos e dados
SHOW DATABASES:	Poder ver os nomes dos bancos de dados no servidor MYSQL
SHUTDOWN:	Parar o servidor MYSQL -- VAMOS RODAR E VER O SERVICO MYSQL
ALL:    	Todos os privilégios disponíveis, exceto GRANT OPTION
GRANT OPTION:	Permite dar privilégios a outros usuários

- NIVEIS DE PRIVILEGIO

Global – O usuário tem acesso a todas as tabelas de todos os bancos de dados
Database – Dá ao usuário permissao para acessar todas as tabelas de um banco de dados
Table – Dá acesso ao usuário a todas as colunas de uma tabela específica
Column – Dá acesso ao usuário apenas a colunas especificadas em uma determinada tabela.

- TABELAS DE CONTROLE DO MYSQL

O MySQL usa tabelas especiais internas para armazenar dados sobre os privilégios dos usuários, 
em um banco de dados chamado mysql. 

user	Armazena nomes e senhas de todos os usuários do servidor. 
db	Armazena privilégios dos bancos de dados
tables_priv	Armazena privilégios das tabelas
columns_priv	Armazena privilégios de colunas
procs_priv	Armazena privilégios de acesso a funções e stored procedures.

exemplo:
select * from mysql.user;
select * from mysql.db;
-- -------------------------------------------------

Documentacao oficial ORACLE com todas as permissoes:

https://dev.mysql.com/doc/refman/8.0/en/privileges-provided.html

==================================================================================*/


-- VAMOS AOS EXEMPLOS 

-- Podemos criar um novo user desta forma

CREATE USER IF NOT EXISTS 'paulo' IDENTIFIED BY '123'; -- criando usuário (mesma coisa se usasse 'paula'@'%') -- se paulo existir, para evitar dar erro -- identified by: criando senha -- evite senhas simples

SHOW GRANTS FOR paulo; -- Vamos ver se este user ja tem algum privilegio. GRANT USAGE, sinonimo de sem privilegio
-- https://dev.mysql.com/doc/refman/8.0/en/grant.html#:~:text=A%20user%20value%20in%20a,'%20user_name%20'%40'%25.

-- OU PODERIA SER DESTA FORMA PARA DAR ACESSO AO PAULO DE QQ IP
CREATE USER IF NOT EXISTS 'paulo2'@'%' -- por padrão cria assim, pode acessar este BD de qualquer lugar e em qualquer máquina (mesma coisa se não tiver @'%')  (PODERIA ADICIONAR UM IP ESPECÍFICO DE UMA MÁQUINA POR QUESITOS DE SEGURANÇA)
IDENTIFIED BY '123'; 

GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE -- Aqui iremos dar alguns privilegio, para paulo, acessando de qq local, a todas as tabelas do banco cliente2
ON cliente2.* -- * representa todos os objetos do BD cliente2. Se quisesse todos os bancos seria *.*
TO paulo; -- para determinado user

GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE -- Aqui iremos dar alguns privilegio, para paulo, acessando de qq local, a todas as tabelas do banco cliente2
ON cliente2.* 
TO paulo2;

-- Usa-se flush privilegies quando se altera a tabela de controle (mas não é recomendado). Se não desse o flush, o user não teria acesso. Ou parar o serviço do sql e iniciar novamente.
-- FLUSH PRIVILEGES; -- Você deve usar FLUSH PRIVILEGES somente se você modificar as tabelas de permissões diretamente usando instruções como INSERT, UPDATE ou DELETE.
-- ao inves de usar GRANT por exemplo. Não é recomendado pela Oracle usar neste caso, insert, update e delete para alterar tabelas internas do mysql.
-- https://dev.mysql.com/doc/refman/8.0/en/privilege-changes.html

SHOW GRANTS FOR paulo; -- GRANT USAGE: Sinônimo para “sem privilégios ”
SHOW GRANTS FOR paulo2;

SELECT * FROM mysql.user; -- exemplos de privilegios que ficam em tabelas internas de controle do mysql
SELECT * FROM mysql.db;
-- Se estas tabelas forem alteradas diretamente com comando UPDATE, o que não é recomendado, para os privilegios ja serem carregados para memoria do mysql
-- teria que dar flush privileges ou dar restart no server do mysql, senao, se tentasse acessar o banco com o user, o privilegio nao seria ainda reconhecido.

-- Dando privilegio de leitura a Maria, acessando apenas do localhost, e apenas na tabela order

CREATE USER IF NOT EXISTS 'MARIA'@'localhost' -- maria pode acessar do localhost (servidor do mysql local), poderia ser de outro servidor, VirtualBox, por exemplo
IDENTIFIED BY '123'; 

GRANT SELECT
ON cliente2.order -- pode acessar por SELECT apenas a tabela order do bd cliente2
TO MARIA@localhost;

SHOW GRANTS FOR MARIA@localhost;

-- NOTA:
-- Os bancos de dados que rodam no MySQL Comunity não contêm um mecanismo integrado para oferecer suporte à integracao com LINUX ou com  Active Directory (AD), COMO VIMOS NO SQLSERVER que existe 
-- a figura do login, que pode vir de um login do AD (WINDOWS) ou criado dentro do SQL SERVER e depois user do banco de dados que é criado dentro do SQLSERVER como 
-- ocorre no MYSQL.
-- No entanto, é possível configurar a autorização AD usando plug-ins e módulos de terceiros, como por exemplo:
-- https://www.percona.com/blog/2017/04/21/how-to-setup-and-troubleshoot-percona-pam-with-ldap-for-external-authentication/
-- https://www.strongdm.com/blog/active-directory-integration

-- Outra opcao é comprar licencas do MYSQL Enterprise: 
-- https://www.mysql.com/products/enterprise/security.html 
-- https://dev.mysql.com/doc/refman/8.0/en/ldap-pluggable-authentication.html
-- https://blog.pythian.com/authenticating-mysql-8-0-enterprise-active-directory/

-- MariaDB (uma versão binária compatível com MySQL, que tem codigo aberto e 100% gratuito) possui um módulo PAM open source disponível para ele, 
-- mas apenas para Unix / Linux. Pode instalar o MariaDB sem servidor e acessar via workbench sem windows:
-- http://kb.askmonty.org/en/pam-authentication-plugin/

-- ---------------------------------------------------------------- AGORA VAMOS VOLTAR AOS LABS

-- Dar privilegio ao rodrigo, vindo apenas do ip 127.0.0.1 de fazer leitura e alteracao, apenas na tabela customer, que está no banco cliente2, mas 
-- apenas nas colunas ID,firstname,lastname E AINDA DAR PRIVILEGIO AO RODRIGO DE DAR OS MESMOS PRIVILEGIOS PARA OUTROS USERS DEVIDO OPCAO WITH GRANT OPTION

CREATE USER IF NOT EXISTS 'rodrigo'@'127.0.0.1'
IDENTIFIED BY '123'; 

GRANT SELECT (id,firstname,lastname), UPDATE (ID,firstname,lastname)
ON cliente2.customer
TO 'rodrigo'@'127.0.0.1' WITH GRANT OPTION;

SHOW GRANTS FOR rodrigo@127.0.0.1;
-- ---------------------------------------

CREATE USER IF NOT EXISTS 'ANA'
IDENTIFIED BY '123'; 

GRANT ALL PRIVILEGES 
ON *.* 
TO ANA; -- DAR TODOS OS PRIVILEGIOS EM TODOS OS OBJETOS DE TODOS OS BANCOS DE DADOS PRA ANA ACESSAR DE QUALQUER IP
-- Cuidado com ALL PRIVILEGES porque esta criando aqui um super user que pode fazer qualquer coisa com todos os bancos de dados e instancia mysql, inclusive SHUTDOWN

SHOW GRANTS FOR ANA;

-- Va no menu database e se conecte como ANA
-- RODE O COMANDOS
SELECT USER();

-- Feche esta janela (sessao da user ANA)

-- REVOGANDO PRIVILEGIOS DADOS

REVOKE ALL privileges, GRANT OPTION FROM 'ANA'; 
-- REVOGANDO TODOS OS PRIVILEGIOS. Quando se revoga todos os privilegios, usando ALL, nao precisa indicar database e objetos
-- INCLUSIVE O PRIVILEGIO DA ANA DE DAR PRIVILEGIOS A OUTROS USERS, ATRAVES DO GRANT OPTION

SHOW GRANTS FOR ANA; -- nao tem mais nenhum privilegio

SHOW GRANTS FOR 'rodrigo'@'127.0.0.1';

REVOKE SELECT (id,firstname,lastname), UPDATE (ID,firstname,lastname) -- REVOGANDO O DIREITO DE LEITURA E ATUALICAO EM ALGUMAS COLUNAS DE ALGUMAS TABELAS PARA RODRIGO VINDO DO IP 127.0.0.1
ON cliente2.customer
FROM 'rodrigo'@'127.0.0.1';

SHOW GRANTS FOR 'rodrigo'@'127.0.0.1'; -- PARA REMOVER PRIVILEGIO GRANT OPTION , PRECISO SER EXPLICITO NO REVOKE. Este privilegio da direito deste user dar direitos que ele tem a outros users. Cuidado com este privilegio.

REVOKE grant option-- REVOGANDO O DIREITO DE LEITURA E ATUALICAO EM ALGUMAS COLUNAS DE ALGUMAS TABELAS PARA RODRIGO VINDO DO IP 127.0.0.1
ON cliente2.customer
FROM 'rodrigo'@'127.0.0.1';

SHOW GRANTS FOR 'rodrigo'@'127.0.0.1'; 

-- -----------------------------------------------------------------

-- ROLES (papeis)

/*====

Considere este cenário:
Um aplicativo usa um banco de dados denominado CLIENTE2.
Associado ao aplicativo, pode haver contas para desenvolvedores que criam e mantêm o aplicativo e para usuários que interagem com ele.
Os desenvolvedores precisam de acesso total ao banco de dados. Alguns usuários precisam apenas de acesso de leitura, 
outros precisam de acesso de leitura / gravação.

Para evitar conceder privilégios individualmente a possivelmente muitas contas de usuário, crie funções(ROLES)
como nomes para os conjuntos de privilégios necessários. Isso torna mais fácil conceder os privilégios necessários às contas 
de usuário, concedendo as funções apropriadas.

=====*/
DROP ROLE if exists 'app_desenvolvedor';
DROP ROLE if exists 'app_leitura';
DROP ROLE if exists 'app_gravacao';

CREATE ROLE if not exists 'app_desenvolvedor', 'app_leitura', 'app_gravacao';

GRANT ALL ON CLIENTE2.* TO 'app_desenvolvedor';
GRANT SELECT ON CLIENTE2.* TO 'app_leitura';
GRANT INSERT, UPDATE, DELETE ON CLIENTE2.* TO 'app_gravacao';

-- Agora, suponha que inicialmente você precise de uma conta de desenvolvedor, 
-- duas contas de usuário que precisam de acesso somente leitura e 
-- uma conta de usuário que precisa de acesso de leitura / gravação. Use CREATE USER para criar as contas:

CREATE USER 'dev1'@'localhost' IDENTIFIED BY 'dev1pass';
CREATE USER 'read_user1'@'localhost' IDENTIFIED BY 'read_user1pass';
CREATE USER 'read_user2'@'localhost' IDENTIFIED BY 'read_user2pass';
CREATE USER 'rw_user1'@'localhost' IDENTIFIED BY 'rw_user1pass';

-- Para atribuir a cada conta de usuário os privilégios necessários, você pode usar as instruções GRANT 
-- da mesma forma mostrada, mas isso requer a enumeração de privilégios individuais para cada usuário. 
-- Em vez disso, use uma sintaxe GRANT alternativa que permite a concessão de papeis (roles) em vez de privilégios:

-- Aqui eu faço a vinculacao do papel criado com suas permissoes ja definidas acima com os users criados.
GRANT 'app_desenvolvedor' TO 'dev1'@'localhost';
GRANT 'app_leitura' TO 'read_user1'@'localhost', 'read_user2'@'localhost';
GRANT 'app_leitura', 'app_gravacao' TO 'rw_user1'@'localhost';

SHOW GRANTS FOR 'app_leitura';  -- verificando privilegios de uma role

SHOW GRANTS FOR 'dev1'@'localhost' USING 'app_desenvolvedor'; -- verificando todos os privilegios dados ao dev1 no papel desenvolvedor

-- CLIQUE NO MENU DATABASE E SELECIONE A OPCAO PARA ABRIR UMA NOVA CONEXAO COMO USER dev1 SENHA dev1pass;
-- PARA VERIFICAR QUAL USER ESTA CONECTADO NAQUELA SESSAO
SELECT USER();
-- AGORA RODE ESTE COMANDO PARA VER AS ROLES RELACIONADAS A ESTE USER.
SELECT CURRENT_ROLE();
-- QUAL O RESULTADO?

-- Por padrão, conceder um papel a um user não faz com que o papel se torne automaticamente ativo nas sessões da conta. 
-- Por exemplo, como até agora na discussão anterior nenhuma função app_desenvolvedor foi ativada, se você se conectar ao servidor como dev1
-- e chamar a função CURRENT_ROLE (), o resultado será NENHUM (nenhuma função ativa):

-- Para especificar quais papeis devem se tornar ativos cada vez que um usuário se conecta ao servidor e se autentica, 
-- use SET DEFAULT ROLE. 

SET DEFAULT ROLE ALL TO
  'dev1'@'localhost',
  'read_user1'@'localhost',
  'read_user2'@'localhost',
  'rw_user1'@'localhost';

-- AGORA SE CONECTE NOVAMENTE COMO dev1. Repare que agora aparece ate o nome do banco a direia.
-- rode novamente o comando
SELECT CURRENT_ROLE();
SHOW GRANTS FOR 'dev1'@'localhost' USING 'app_desenvolvedor';
-- https://dev.mysql.com/doc/refman/8.0/en/roles.html

-- FECHE esta janela (sessao deste user dev1) e retorne sessao do root

-- PARA REVOGAR ROLES
-- Vamos fazer uma conexao agora com user rw_user1, senha rw_user1pass
-- Agora rode este comando para revogar alguns privilegios da ROLE que esta usuario rw_user1 esta vinculado
REVOKE INSERT, UPDATE, DELETE ON CLIENTE2.* FROM 'app_gravacao'; 
-- QUAL A MENSAGEM QUE DEU? Se foi esta "... Access denied for user 'rw_user1'@'localhost' to database 'cliente2'" está dentro do esperado
-- porque este user nao tem este privilegio para revogar estes privilegios. 
-- Para isto, acesse a sessao onde esta o root e rode o mesmo comando

SELECT USER(); -- para confirmar se esta na sessao root
REVOKE INSERT, UPDATE, DELETE ON CLIENTE2.* FROM 'app_gravacao'; -- para revogar alguns privilegios da role app_gravacao

-- Agora retorne para o usuario rw_user1 e rode esse comando para verificar se ele perdeu os privilegios de insert, update e delete
SHOW GRANTS FOR CURRENT_USER();

/*====
-- Quais sao as ROLES que vem de ORACLE (Versao ATUAL do mysql) 
-- e que podemos dar privilegio para usuarios nestas ROLES:

https://dev.mysql.com/doc/workbench/en/wb-mysql-connections-navigator-management-users-and-privileges.html

DBA: Concede os direitos para realizar todas as tarefas.
DBManager: Concede direitos em todos os bancos de dados, mas com excecao de alguns direitos predefinidos, como criar user, dar shutdown,...
MaintenanceAdmin: Concede direitos para manter o servidor, como parar o servico mysql (shutdown), dar show databases, carregar tabelas
ProcessAdmin: Concede direitos para avaliar, monitorar e eliminar (kill) os processos do usuário.
UserAdmin: Concede direitos para criar usuário e redefinir senhas.
SecurityAdmin: Concede direitos para gerenciar usuarios e conceder e revogar privilégios de servidor. Cuidado para quem da este direito porque ela pode criar um user com direito de DBA.
MonitorAdmin: Concede os direitos mínimos para monitorar o servidor.
DBDesigner: Concede direitos para criar e fazer engenharia reversa em qualquer esquema de banco de dados.
ReplicationAdmin: Concede os direitos necessários para configurar e gerenciar a replicação.
BackupAdmin: Concede direitos mínimos necessários para fazer backup de qualquer banco de dados.
Custom: Pode ser customizados privilegios.

Por padrao, cada um destas Roles Padroes do fabricante ja vem com permissoes padroes definidas, mas podem ser incluidas novas e retiradas,
ate graficamente pelo menu do workbench Server->Users and privilegies.

OBS EVITE SE CONECTAR COMO ROOT, se de um super direito como DBA, MaintenanceAdmin ou DBManager e conecte com seu usuario nomeado
ao inves de se conectar como root, principalmente se mais de um user tiver a senha do root, porque se alguem fizer algo errado
será dificil capturar em uma auditoria no mysql enterprise, quem realizou alguma operacao.

=====*/

-- VAMOS RETIRAR UM USER DE UMA ROLE

-- Na sessao do user rw_user1 rode um dos comandos abaixo e verifique que este user esta em duas roles

SHOW GRANTS;
SHOW GRANTS FOR CURRENT_USER;
SHOW GRANTS FOR CURRENT_USER();

-- Vamos remover o usuario do papel app_leitura. Para isto acesse a sessao (aba do workbench) do usuario root, ou crie um user com papel DBA
-- e rode o comando abaixo para remover o user rw_user1 do papel app_leitura

REVOKE app_leitura FROM 'rw_user1'@'localhost';

-- Retorne a sessao do usuario rw_user1 e rode o comando 
SHOW GRANTS FOR CURRENT_USER(); -- VEJA QUE ESTE USUARIO NAO ESTA MAIS NESTE PAPEL

-- SE QUISER DAR PRIVILEGIO TOTAL PARA UM USER, como DBA, na sessao do root, rode.
GRANT ALL PRIVILEGES ON cliente2.* TO 'rw_user1'@'localhost';

-- VAMOR DELETAR ROLE, na sessao root, rode:

DROP ROLE 'app_leitura', 'app_gravacao', 'app_desenvolvedor';

-- PARA DELETAR USER, na sessao do root, rode
DROP USER IF EXISTS 'paulo'@'%';
DROP USER IF EXISTS 'dev1'@'localhost';
DROP USER IF EXISTS 'read_user1'@'localhost';
DROP USER IF EXISTS 'read_user2'@'localhost';
DROP USER IF EXISTS 'rw_user1'@'localhost';

-- Se quiser dar shutdown via comando, no root rode
SHUTDOWN;
-- TEnte rodar algum comando e va em servicos e veja o que aconteceu com o servico do mysql. Cuidado com este comando porque ira parar o mysql e derrubar todos 
-- que estiverem conectados aos bancos de dados e as aplicacoes nao conseguirao mais conectar. De start no servico mysql e no workbench clique no icone de refresh e entre senha

-- ---------------------

-- VAMOS CRIAR USER, DAR PERMISSAO DE ACESSO, VINCULAR PAPEL E DESVINCULAR, AGORA PELO MODULO GRAFICO:
-- Para isto, acesso o menu Server -> Users and Privilegies

-- crie um user novo, e se conecte
select user();

-- ------------------------FIM

