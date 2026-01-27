Curso: MYSQL
Instrutor: Sandro Servino
https://www.linkedin.com/in/sandroservino/?originalSubdomain=pt
https://www.udemy.com/user/sandro-servino-3/

-- Firewall Corporativo MySQL
https://www.mysql.com/products/enterprise/firewall.html

-- O MySQL Enterprise Firewall, é um firewall em nivel de aplicação que protege contra ameaças de segurança cibernética fornecendo proteção em tempo real 
-- contra ataques específicos de banco de dados, PRINCIPALMENTE
-- CONTRA SQL INJECTION, QUE A MAIORIA DOS SITES NO MUNDO TEM ALGUMA VULNERABILIDADE DE SEGURANÇA QUE POSSIBILITA SQL INJECTION.
-- Alguns exemplo de SQL INJECTION - https://www.w3schools.com/sql/sql_injection.asp E https://www.devmedia.com.br/sql-injection/6102

-- O MySQL Enterprise Firewall protege seus dados monitorando, alertando e bloqueando atividades não autorizadas do banco de dados sem nenhuma 
-- alteração em seus aplicativos. Ele fornece vários modos operacionais para ajudar os administradores a bloquear, detectar e responder a ataques maliciosos ao banco de dados:

-- Permitir - as instruções SQL são executadas para as instruções que correspondem a uma lista de permissões aprovada
-- Bloquear - as instruções SQL são impedidas de executar que não correspondem a uma lista de permissões aprovada
-- Detectar - instruções SQL que não correspondem a uma lista de permissões são executadas e os administradores são notificados sobre violações de política.

-- ALGUMAS CARACTERISTICAS:

--1. Perfis de grupo. Cria uma lista composta de consultas permitidas para um grupo de usuários. Impõe a proteção de firewall em todos os perfis do grupo.
--2. Bloquear ataques de injeção de SQL (SQL INJECTION). O MySQL Enterprise Firewall bloqueia ataques de SQL Injection que podem resultar na perda de dados valiosos.
--3. Detecção de intrusão de banco de dados. Atuando como um alarme de segurança, o MySQL Enterprise Firewall notifica os 
--   administradores sobre a atividade da instrução SQL que não corresponde a uma lista de permissões aprovada.
--4. Monitoramento de ameaças em tempo real. O MySQL Enterprise Firewall monitora ameaças de banco de dados em tempo real. Todas as consultas recebidas passam por um 
--   mecanismo de análise SQL e são comparadas com uma lista de permissões aprovada de instruções SQL esperadas. Os ataques SQL são bloqueados se não representarem 
--   as instruções esperadas.
--5. Aprenda e crie listas de permissões. Crie automaticamente listas de permissões específicas do usuário de instruções SQL pré-aprovadas usando um sistema de 
--   autoaprendizagem. O MySQL Enterprise Firewall registra todas as instruções SQL recebidas e cria uma lista de permissões. Apenas as consultas recebidas que 
--   correspondem à lista de permissões são aprovadas e autorizadas a passar para o MySQL.
--6. Proteção transparente. O MySQL Enterprise Firewall não requer alterações em seu aplicativo, independentemente da linguagem de desenvolvimento, estrutura ou 
--   aplicativo de terceiros. 
--7. As operações permitidas (codigos sql) são carregadas para a memória do servidor para minimizar perda de performance.

-- -------------------------------------------------------------------------------------- INSTALANDO O PLUGIN

-- INSTALANDO O PLUGIN Firewall
-- https://dev.mysql.com/doc/refman/8.0/en/firewall-installation.html

-- A instalação do MySQL Enterprise Firewall é uma operação única que instala o plugin do firewall no mysql enterprise. 
-- A instalação pode ser realizada através de uma interface gráfica ou manualmente:

-- 1. No Windows, o MySQL Installer inclui uma opção para habilitar o MySQL Enterprise Firewall para você.
-- 2. O MySQL Workbench 6.3.4 ou superior pode instalar o MySQL Enterprise Firewall, habilitar ou desabilitar um firewall instalado ou desinstalar o firewall.
-- 3. A instalação manual do MySQL Enterprise Firewall envolve a execução de um script localizado no diretório share de sua instalação do MySQL.

-- Observação
-- Se instalado, o PLUGIN firewall envolve uma sobrecarga mínima, mesmo quando desativado. Para evitar essa sobrecarga, não instale o Firewall Corporativo MySQL
-- a menos que você planeje usá-lo.

-- Para ser usado pelo servidor, o arquivo de biblioteca de plugins deve estar localizado no diretório de plugins do MySQL 
-- (o diretório nomeado pela variável plugin_dir do sistema). Se necessário, configure o local do diretório do plug-in definindo o valor de plugin_dir 
-- na inicialização do servidor(my.ini). MAS NAO PRECISA ALTERAR PORQUE POR PADRAO A PASTA DOS PLUGINS ESTAO DENTRO DA PASTA LIB E O MYSQL JÁ SABE DISTO.
-- 

-- 1. Para instalar o MySQL Firewall, procure no share diretório de instalação do MySQL e escolha o script apropriado para sua plataforma. 
-- cd C:\Program Files\MySQL\MySQL Server 8.0\share

-- Os scripts disponíveis diferem no sufixo usado para se referir ao arquivo de biblioteca do plug-in: ATENCAO PARA VERIFICAR NA VM E NAO NO WINDOWS EXPLORER DO SEU COMPUTADOR QUE TEM O MYSQL COMMUNITY E AI NESTE MYSQL NAO TEM O PLUGIN.

-- win_install_firewall.sql: Escolha este script para sistemas Windows que usam .dll como sufixo de nome de arquivo.

-- linux_install_firewall.sql: Escolha este script para Linux e sistemas semelhantes que usam .so como sufixo de nome de arquivo.

-- 2. Execute o script da seguinte maneira no DOS da sua VM onde está instalado seu MYSQL ENTERPRISE:
-- cd C:\Program Files\MySQL\MySQL Server 8.0\share

mysql -u root -p < win_install_firewall.sql
Enter password: (enter root password here)

OBS> SE DER ESTE ERRO ('mysql' is not recognized as an internal or external command, operable program or batch file.), NAO ESQUECA DE COLOCAR NO 
PATH DO WINDOWS(Control Panel\System and Security\System\Advanced System Settings\Environment Variables\Path), a PASTA ONDE ESTA O BIN DO MYSQL: C:\Program Files\MySQL\MySQL Server 8.0\bin
Feche a janela DOS e abra NOVAMENTE COMO ADMINISTRADOR (cmd) e vá novamente para a pasta share: cd C:\Program Files\MySQL\MySQL Server 8.0\share,  e execute:

mysql -u root -p < win_install_firewall.sql

-- Se der OK na instalacao, vá ao workbench e rode o comando para confirmar que o plugin audit está instalado e pode verificar na aba server status.
SHOW GLOBAL VARIABLES LIKE 'mysql_firewall_mode';

-- Veja ainda, no menu SERVER, USERS AND PRIVILEGIES e veja que tem uma nova aba chamada FIREWALL RULES, onde poderá vincular regras de firewall para users ou grupo de users.
-- Veja também que agora no link Firewall do menu lateral direito, dentro do bloco MYSQL ENTERPRISE, que já está instalado o plugin e ativo e podemos desinstalar e desativar.

OBS>> AINDA PODERA INSTALAR O PLUGION FIREWALL PELO WORKBENCH ENTERPRISE, NA ABA, MYSQL ENTERPRISE, FIREWALL, BOTÃO Install Firewall.

-- --------------------------------------------------------------------------------------------------------------------------------------------------------

-- Atribuindo privilégios de firewall

-- Com o firewall instalado, conceda os privilégios apropriados à conta ou contas MySQL a serem usadas para administrá-lo. Os privilégios dependem de quais
-- operações de firewall uma conta deve ter permissão para executar:

-- Para checar quais os privilegios o user conectado tem, no caso root, rodar:
SHOW GRANTS FOR CURRENT_USER();

-- 1. Conceda o privilégio FIREWALL_EXEMPT (disponível a partir do MySQL 8.0.27) para qualquer conta que deva ser isenta de restrições de firewall. 
-- Isso é útil, por exemplo, para um administrador de banco de dados que configura o firewall, para evitar a possibilidade de uma configuração incorreta 
-- fazer com que até mesmo o administrador seja bloqueado e incapaz de executar instruções.

GRANT FIREWALL_EXEMPT ON *.* TO `root`@`localhost`;
SHOW GRANTS FOR CURRENT_USER();

-- se eu quiser remover este privilegio do root
revoke  FIREWALL_EXEMPT ON *.* from `root`@`localhost`;
SHOW GRANTS FOR CURRENT_USER();

-- 2. Conceda o privilégio FIREWALL_ADMIN a qualquer conta que deva ter acesso total ao firewall administrativo. 
-- (Algumas funções administrativas de firewall podem ser invocadas por contas que tenham FIREWALL_ADMIN ou o privilégio SUPER já em deprecated-obsoleto, 
-- conforme indicado nas descrições das funções individuais.)

GRANT FIREWALL_ADMIN ON *.* TO `root`@`localhost`;
SHOW GRANTS FOR CURRENT_USER();

-- e para remover este privilegio
revoke  FIREWALL_ADMIN ON *.* from `root`@`localhost`;
SHOW GRANTS FOR CURRENT_USER();

-- MAS PARA O NOSSO LABORATORIO VAMOS DAR OS DOIS PRIVILEGIOS PARA O USER ROOT. Voce poderia criar um outro user na producao, e dar direitos de DBA para este user,
-- como ja vimos nas aulas sobre ROLES e dar estes dois privilegios do firewall.

GRANT FIREWALL_ADMIN ON *.* TO `root`@`localhost`;
GRANT FIREWALL_EXEMPT ON *.* TO `root`@`localhost`;
SHOW GRANTS FOR CURRENT_USER();

-- 3. Conceda o privilégio FIREWALL_USER a qualquer conta que deva ter acesso administrativo apenas para suas próprias regras de firewall.

-- 4. Conceda o privilégio EXECUTE para os procedimentos armazenados do firewall no banco de dados do sistema mysql. 
-- Eles podem invocar funções administrativas, portanto, o acesso ao procedimento armazenado também requer os privilégios indicados anteriormente que são necessários para essas funções.

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------


-- 3. Para que seja carregado as configuracoes de firewall a cada start do servidor, voce deve colocar no arquivo my.ini. Se possivel usar o NOTEPAD++ para editar o my.ini
[mysqld]
mysql_firewall_mode=ON

-- PARE O MYSQL E DE START NOVAMENTE.

-- 3.1 Como alternativa, para definir e persistir a configuração do firewall em tempo de execução, SEM PRECISAR ATIVAR NO MY.INI, PODERÁ RODAR NO WORKBENCH:

SET PERSIST mysql_firewall_mode = ON;

-- OU PARA DESATIVAR
SET PERSIST mysql_firewall_mode = OFF;

SET GLOBLA mysql_firewall_mode = ON; -- é temporário

-- SET PERSIST define um valor para a instância MySQL em execução. Ele também salva o valor, fazendo com que ele seja transferido 
-- para reinicializações subsequentes do servidor. Para alterar um valor para a instância MySQL em execução sem que ela seja transferida 
-- para reinicializações subsequentes, use a palavra-chave GLOBAL em vez de PERSIST

-- ----------------------------------------------------------------------------------------------------------------

-- PRINCIPIOS FIREWALL

-- A maioria dos princípios de firewall se aplica de forma idêntica a perfis de grupo e perfis de conta. 

-- Os dois tipos de perfis diferem nestes aspectos:

-- 1. Uma lista de permissões de perfil de conta se aplica apenas a uma única conta. Uma lista de permissões de perfil de grupo se aplica quando a conta da sessão corresponde 
--    a qualquer conta que seja membro do grupo.

-- 2. Para aplicar uma lista de permissões a várias contas usando perfis de conta, é necessário registrar um perfil por conta e duplicar a lista de permissões em cada perfil. 
--    Isso implica treinar cada perfil de conta individualmente porque cada um deve ser treinado usando a única conta à qual se aplica.

-- 3. Uma lista de permissões de perfil de grupo se aplica a várias contas, sem a necessidade de duplicá-la para cada conta. Um perfil de grupo pode ser treinado usando 
--    qualquer uma ou todas as contas de membro do grupo, ou o treinamento pode ser limitado a um único membro. De qualquer forma, a lista de permissões se aplica a todos os membros.

-- 4. Os nomes de perfil de conta são baseados em combinações específicas de nome de usuário e nome de host que dependem de quais clientes se conectam ao servidor MySQL. 
--    Os nomes de perfil de grupo são escolhidos pelo administrador do firewall sem restrições além de que seu comprimento deve ser de 1 a 288 caracteres.

-- Observação
-- Devido às vantagens dos perfis de grupo sobre os perfis de conta e porque um perfil de grupo com uma única conta de membro é logicamente equivalente a um perfil de conta 
-- para essa conta, é recomendável que todos os novos perfis de firewall sejam criados como perfis de grupo. 
-- Os perfis de conta estão EM DEPRECATED - obsoletos a partir do MySQL 8.0.26 e estão sujeitos a remoção em uma versão futura do MySQL.

-- Para aplicativos que acessam uma instancia mysql, através de um user de servico, podemos criar regras especificas de firewall para este aplicativo de forma manual
-- ou ligarmos a opcao do firewall para aprender todos os comandos permitidos para este user, através da opcao RECORDING que vamos ver. Navegamos com o sistema, executando
-- todos os processos necessarios, que implicitamente envia para o banco comandos do tipo SELECT, DELETE, UPDATE, INSERTS, ... para o mysql firewall aprender e guardar
-- comandos especificos que serão permitidos e quando terminarmos, alteramos a opcao do firewall para ligar a proteção no firewall deste user, para PROTECTING e a partir
-- dai se chegar ao banco da aplicacao, qualquer operacao diferente que foi aprendida pelo firewall, rodando com o usuario de servico da aplicacao, será negada pelo firewall do mysql.

-- PARA ENTENDER, QUANDO LIGARMOS O MODULO DE APRENDIZADO, e for executado os 3 comandos abaixo, O FIREWALL irá capturar:
SELECT first_name, last_name FROM customer WHERE customer_id = 1;
select first_name, last_name from customer where customer_id = 99;
SELECT first_name, last_name FROM customer WHERE customer_id = 143;

-- MAS PARA O MYSQL FIREWALL SERÁ COMO UM COMANDO APENAS, e ele irá apenas substituir o valor da variavel customer_id para um coringa do tipo ?

SELECT `first_name` , `last_name` FROM `customer` WHERE `customer_id` = ?

-- DESTA FORMA DEPOIS QUE ESTIVER ATIVADO O FIREWALL E NAO MAIS EM MODULO DE APRENDIZADO E SE CHEGAR COMANDO IGUAL, APENAS VARIANDO O VALOR DA VARIAVEL SERA ACEITO PELO FIREWALL
-- E SERA EXECUTADO, MAS SE POR EXEMPLO CHEGAR ESTE COMANDO SELECT first_name, last_name FROM customer WHERE customer_id = 1 AND 1=1;
-- O FIREWALL VAI BLOQUEAR O COMANDO E NAO PERMITIRÁ QOE O MESMO SERÁ USADO PELO BANCO DE DADOS.

-- -------------------------------------------------------------------------------------------------------

-- Modos operacionais do perfil

--Cada perfil cadastrado no firewall possui seu próprio modo operacional, escolhido a partir destes valores:

--OFF: Este modo desabilita o perfil. O firewall o considera inativo e o ignora.

--RECORDING: Este é o modo de treinamento do firewall. As declarações recebidas de um cliente que corresponda ao perfil são consideradas aceitáveis ​​para o perfil e tornam-se 
--         parte de sua “impressão digital”. O firewall registra o formulário de resumo normalizado de cada instrução para aprender os padrões de instrução aceitáveis ​​
--         para o perfil. 

--PROTECTING: Neste modo, o perfil permite ou impede a execução de instruções. O firewall compara as instruções recebidas com a lista de permissões do perfil, 
--          aceitando apenas as instruções que correspondem e rejeitando as que não correspondem. Após treinar um perfil no modo RECORDING, 
--          alterne-o para o modo PROTECTING para proteger o MySQL contra o acesso por instruções que se desviam da lista de permissões. 
--          Se a variável de sistema mysql_firewall_trace estiver habilitada, o firewall também gravará instruções rejeitadas no log de erros.

--DETECTING: Este modo detecta, mas não bloqueia intrusões (instruções que são suspeitas porque não correspondem a nada na lista de permissões do perfil). 
--           No modo DETECTING, o firewall grava declarações suspeitas no log de erros, mas as aceita sem negar o acesso.

-- As operações de configuração do modo de firewall também permitem um valor de modo RESET.
-- Configurar um perfil para o modo RESET faz com que o firewall exclua todas as regras do perfil e defina seu modo como OFF.

-- Observação
-- As mensagens gravadas no log de erros no modo DETECTING ou porque mysql_firewall_trace está ativado são gravadas como Notas, 
-- que são mensagens informativas. Para garantir que essas mensagens apareçam no log de erros e não sejam descartadas, 
-- certifique-se de que a verbosidade do log de erros seja suficiente para incluir mensagens de informação, neste caso 
-- defina a variável de sistema log_error_verbosity com um valor de 3 no my.ini
--- -------------------------------------------------------------------------------------------------------------------

-- 5. AGORA VAMOS FAZER ALGUNS TESTES E VERIFICAR O FUNCIONAMENTO DO FIREWALL
--https://dev.mysql.com/doc/refman/8.0/en/firewall-usage.html

-- O procedimento a seguir mostra como registrar um perfil de grupo no firewall, treinar o firewall para conhecer as instruções aceitáveis ​​para esse perfil 
-- (sua lista de permissões), usar o perfil para proteger o MySQL contra a execução de instruções inaceitáveis ​​e adicionar e remover membros do grupo. 
-- O exemplo usa um nome de perfil de grupo de fwgrp. 
-- O perfil de exemplo é presumido para uso por clientes de um aplicativo que acessa tabelas no banco de dados CLIENTE2.

-- Use uma conta MySQL administrativa para executar as etapas deste procedimento (RECORDING-APRENDIZADO DO FIREWALL), exceto as etapas designadas para execução por contas-membro do perfil do grupo de firewall. 

-- ETAPAS:
1. crie as contas que serão membros do perfil do grupo fwgrp e conceda a elas os privilégios de acesso apropriados. 
-- As declarações de um membro são mostradas aqui (escolha uma senha apropriada):

CREATE USER if not exists 'member1'@'localhost' IDENTIFIED BY '123';
GRANT ALL ON CLIENTE2.* TO 'member1'@'localhost';

2. Use o procedimento armazenado sp_set_firewall_group_mode() para registrar o perfil do grupo com o firewall e colocar o perfil no modo RECORDING (treinamento):
CALL mysql.sp_set_firewall_group_mode('fwgrp', 'RECORDING');

3. Use o procedimento armazenado sp_firewall_group_enlist() para adicionar uma conta-membro inicial para uso no treinamento da lista de permissões do perfil do grupo:
CALL mysql.sp_firewall_group_enlist('fwgrp', 'member1@localhost');

4. Para treinar o perfil do grupo usando a conta de membro inicial, conecte-se ao servidor como member1, senha 123 do host do servidor para que o firewall veja uma conta de sessão 
-- de member1@localhost. Em seguida, execute algumas instruções para serem consideradas legítimas para o perfil. Por exemplo:

SELECT * FROM cliente2.customer;
SELECT * FROM cliente2.order where customerid = 78;
SELECT count(*) FROM cliente2.order ;

-- O firewall recebe as instruções da conta member1@localhost. Como essa conta é membro do perfil fwgrp, que está no modo RECORDING, o firewall interpreta as 
-- instruções como aplicáveis ​​ao fwgrp e registra a forma de resumo normalizada das instruções como regras na lista de permissões do fwgrp. 
-- Essas regras se aplicam a todas as contas que são membros do fwgrp, ou seja, poderia por exemplo usar uma outra conta vinculada a este grupo para permitir o firewall realizar novos aprendizados, e assim liberar ou bloquear 
-- recursos quando um dos users deste grupo realizar o acesso ao banco cliente2 e tentar executar comandos sql.

-- Observação
-- Até que o perfil do grupo fwgrp receba instruções no modo RECORDING, sua lista de permissões está vazia, o que equivale a “negar tudo”.
-- O perfil do grupo não pode ser alternado para o modo PROTECTING. Rejeitaria cada declaração, efetivamente proibindo as contas que são membros do grupo de executar qualquer declaração.
-- O perfil do grupo pode ser alterado para o modo DDETECTING. Nesse caso, o perfil aceita todas as declarações, mas as registra como suspeitas.

5. Neste ponto, as informações do perfil do grupo são armazenadas em cache(memoria), incluindo seu nome, associação e lista de permissões. 
-- Para ver essas informações, consulte as tabelas de firewall do Performance Schema:

-- rode na aba do user root que tem privilegio de ler a base de dados de sistema performance_schema
SELECT MODE FROM performance_schema.firewall_groups WHERE NAME = 'fwgrp';

SELECT * FROM performance_schema.firewall_membership
       WHERE GROUP_ID = 'fwgrp' ORDER BY MEMBER_ID;

6. Quando terminar o treinamento do user member1, Invoque sp_set_firewall_group_mode() novamente para alternar o perfil do grupo para o modo PROTEGER:
-- Va na aba do root, e execute o comando abaixo para terminar o aprendizado e já colocar o firewall operacional ativo para comecar a liberar ou bloquear os comandos
-- que ele nao aprendeu.
CALL mysql.sp_set_firewall_group_mode('fwgrp', 'PROTECTING');

-- SE DER ESTE ERRO, QUE NOS JA VIMOS EM AULAS ANTERIORES:
CALL mysql.sp_set_firewall_group_mode('fwgrp', 'PROTECTING')	Error Code: 1175. You are using safe update mode and you tried to update a table without a WHERE that uses a KEY column. 
 To disable safe mode, toggle the option in MENU Edit , Preferences -> SQL Editor (desmarque a ultima opcao desta janela) and reconnect workbench com root e rode novamente o comando.	

CALL mysql.sp_set_firewall_group_mode('fwgrp', 'PROTECTING');

-- verificar que ja está em modo de proteção
  SELECT MODE FROM performance_schema.firewall_groups
       WHERE NAME = 'fwgrp';

7. Vamos criar mais dois novos users e acrescentar no grupo fwgrp

    CREATE USER if not exists 'member2'@'localhost' IDENTIFIED BY '123';
       GRANT ALL ON CLIENTE2.* TO 'member2'@'localhost';
	   CREATE USER if not exists 'member3'@'localhost' IDENTIFIED BY '123';
       GRANT ALL ON CLIENTE2.* TO 'member3'@'localhost';
       CALL mysql.sp_firewall_group_enlist('fwgrp', 'member2@localhost');
       CALL mysql.sp_firewall_group_enlist('fwgrp', 'member3@localhost');

     SELECT * FROM performance_schema.firewall_membership
       WHERE GROUP_ID = 'fwgrp' ORDER BY MEMBER_ID;

8. Essas instruções não correspondem a nada na lista de permissões, portanto, o firewall rejeita cada uma delas com um erro:
use cliente2;
SHOW TABLES LIKE 'order%';

SELECT * FROM cliente2.order where customerid = 13 or 1=1;
SELECT count(*) FROM cliente2.product ;


9. Se a variável de sistema mysql_firewall_trace estiver habilitada, o firewall também gravará instruções rejeitadas no log de erros.
-- Podemos colocar esta variavel no my.ini como on, parar o mysql e dar start. Verificar no workbench, link firewall que está ativo.
[mysqld]
mysql_firewall_trace=ON
log_error_verbosity=3

SHOW VARIABLES LIKE 'mysql_firewall_trace';
SET PERSIST mysql_firewall_trace = ON;
SET `PERSIST log_error_verbosity = 3; -- tive de passar assim, pois somnete no my.ini não funcionou.

10. Va na aba do member1 e rode novamente o comando
SELECT * FROM cliente2.order where customerid = 13 or 1=1;

11. Va na pasta e veja o que foi gerado no arquivo de erro de log
C:\ProgramData\MySQL\MySQL Server 8.0\Data\DBSRV1.err

12. Caso os membros precisem ser removidos do perfil do grupo, use o procedimento armazenado sp_firewall_group_delist() em vez de sp_firewall_group_enlist(), na SESSAO DO ROOT:
CALL mysql.sp_firewall_group_delist('fwgrp', 'member3@localhost');

    SELECT * FROM performance_schema.firewall_membership
       WHERE GROUP_ID = 'fwgrp' ORDER BY MEMBER_ID;

13. O perfil do grupo de firewall agora é treinado para contas-membro. Quando os clientes se conectam usando qualquer conta do grupo e tentam executar instruções, 
-- o perfil protege o MySQL contra instruções não correspondidas pela lista de permissões do perfil.
-- Caso seja necessário treinamento adicional, você pode alternar o perfil novamente para o modo GRAVAÇÃO, NA SESSAO COMO ROOT OU NA SESSAO DE UM USER COM PRIVILEGIO DE FIREWALL ADMINISTRATOR, conforme falamos.
CALL mysql.sp_set_firewall_group_mode('fwgrp', 'RECORDING');

13.1 No entanto, isso permite que qualquer membro do grupo execute instruções e as adicione à lista de permissões. 
--   Para LIMITAR o treinamento adicional a um único membro do grupo, 
--   chame sp_set_firewall_group_mode_and_user(), que é como sp_set_firewall_group_mode(), mas usa mais um argumento especificando qual conta tem permissão para treinar 
--   o perfil no modo RECORDING. Por exemplo, para habilitar o treinamento apenas por member2@localhost, faça o seguinte:

CALL mysql.sp_set_firewall_group_mode_and_user('fwgrp', 'RECORDING', 'member2@localhost');
SELECT MODE FROM performance_schema.firewall_groups
       WHERE NAME = 'fwgrp';

13.2 E quando terminar o treinamento

CALL mysql.sp_set_firewall_group_mode('fwgrp', 'PROTECTING');
SELECT MODE FROM performance_schema.firewall_groups
       WHERE NAME = 'fwgrp';

obs: A conta de treinamento estabelecida por sp_set_firewall_group_mode_and_user() é salva no perfil do grupo, para que o firewall a lembre caso seja necessário 
mais treinamento posteriormente. Assim, se você chamar sp_set_firewall_group_mode() (que não aceita argumento de conta de treinamento), 
a conta de treinamento do perfil atual, member2@localhost, permanecerá inalterada.

13.3 Para limpar a conta de treinamento, OU SEJA, se realmente desejar habilitar todos os membros do grupo para realizar o treinamento no modo RECORDING, 
chame sp_set_firewall_group_mode_and_user() e passe um valor NULL para o argumento de conta:

CALL mysql.sp_set_firewall_group_mode_and_user('fwgrp', 'RECORDING', NULL);
SELECT MODE FROM performance_schema.firewall_groups
       WHERE NAME = 'fwgrp';

-- E DEPOIS DE TREINADO NOVAMENTE, PODE ATIVAR O FIREWALL
CALL mysql.sp_set_firewall_group_mode('fwgrp', 'PROTECTING');
SELECT MODE FROM performance_schema.firewall_groups
       WHERE NAME = 'fwgrp';

14. É possível detectar invasões registrando declarações não correspondentes como suspeitas sem negar o acesso. Primeiro, coloque o perfil do grupo no modo DETECÇÃO:
  CALL mysql.sp_set_firewall_group_mode('fwgrp', 'DETECTING');

  SELECT MODE FROM performance_schema.firewall_groups
       WHERE NAME = 'fwgrp';
       
14.1 Entao se conecte como member1 ou use a sessao do member1 para rodar os comandos
SELECT * FROM cliente2.order where customerid = 13 or 4=4;
SELECT count(*) FROM cliente2.product ;

14.2 Va na pasta e veja o que foi gerado no arquivo de erro de log
C:\ProgramData\MySQL\MySQL Server 8.0\Data\DBSRV1.err

15. Para desabilitar um perfil de grupo, altere seu modo para OFF:

CALL mysql.sp_set_firewall_group_mode('fwgrp', 'OFF');

15.1 Para retirar um usuário do grupo:

CALL mysql.sp_firewall_group_delist('fwgrp','member3@localhost');

15.1.2 CALL mysql.sp_set_firewall_group_mode_and_user('fwgrp', 'RECORDING', 'member2@localhost');

SELECT MODE FROM performance_schema.firewall_groups
       WHERE NAME = 'fwgrp';

16. Para esquecer todo o treinamento de um perfil e desativá-lo:
CALL mysql.sp_set_firewall_group_mode('fwgrp', 'RESET');

-- A operação de RESET faz com que o firewall exclua todas as regras do perfil e defina seu modo como DESLIGADO.

-- ------------------------------------------------------------------------------------------------------------------------------------------

-- ATENCAO:

-- NOS FIZEMOS TODO O PROCESSO ATRAVES DE GRUPOS, PORQUE É A MELHOR PRATICA. SE TIVESSEMOS APENAS 1 USER PARA TREINAR O FIREWALL PODERIAMOS AINDA ASSIM CRIAR
-- 1 GRUPO E COLOCAR O UNICO USUARIO NESTE GRUPO, MAS PODEMOS TREINAR O FIREWALL INDICANDO JÁ 1 USER ESPECIFICO, OU CADA USER, MAS ESTA OPCAO ESTA EM DEPRECATED
-- PARA TREINAR BASTARIA USAR AS MESMAS FUNCOES SO QUE AO INVES DE INDICAR UM GRUPO, IRIAMOS JA TREINAR USUARIO A USUARIO, COMO ASSIM:

CALL mysql.sp_set_firewall_mode('member1@localhost', 'RECORDING');
CALL mysql.sp_set_firewall_mode('member1@localhost', 'PROTECTING');
CALL mysql.sp_set_firewall_mode('member1@localhost', 'DETECTING');

-- ao inves do que fizemos antes atraves de grupos: CALL mysql.sp_set_firewall_group_mode('fwgrp', 'RECORDING');

-- Para testar, seria o mesmo processo do grupo. Me conectaria com member1, iria realizar as operacoes e depois iria retornar para aba do ROOT e daria o comando para iniciar a protecao
CALL mysql.sp_set_firewall_mode('member1@localhost', 'PROTECTING');

-- Para disabilitar uma conta especifica, na sessao do root:
CALL mysql.sp_set_firewall_mode('member1@localhost', 'OFF');

-- Para esquecer todo o treinamento de um perfil e desativá-lo:
CALL mysql.sp_set_firewall_mode('member1@localhost', 'RESET');

-- -------------------------------------------------------------------------------------------------------------------------------------------

-- Monitorando o Firewall
-- Para avaliar a atividade do firewall, examine suas variáveis ​​de status. Por exemplo, após realizar o procedimento mostrado anteriormente para treinar e proteger 
o perfil do grupo fwgrp, as variáveis ​​ficam assim:

SHOW GLOBAL STATUS LIKE 'Firewall%';

-- Voce consegue ver as mesmas informacoes pelo link firewall do workbench

-- ------------------------------- PARA REMOVER O PLUGIN FIREWALL

-- O MySQL Enterprise Firewall pode ser desinstalado usando o MySQL Workbench ou manualmente.

-- Verifique que está instalado
SHOW GLOBAL VARIABLES LIKE 'mysql_firewall_mode';

-- 1. Para remover o plugin FIREWALL, vocé poderá realizar no workbench, no mesmo local onde fez a instalação.
-- 2. Para desinstalar o MySQL Enterprise Firewall manualmente, execute as instruções a seguir. As instruções são usadas IF EXISTS porque, 
-- dependendo da versão do firewall instalada anteriormente, alguns objetos podem não existir ou podem ser descartados implicitamente pela desinstalação 
-- do plug-in que os instalou.

CALL mysql.sp_firewall_group_delist('fwgrp', 'member1@localhost');
CALL mysql.sp_firewall_group_delist('fwgrp', 'member2@localhost');

REVOKE FIREWALL_ADMIN ON *.* FROM 'root'@'localhost';
REVOKE FIREWALL_EXEMPT ON *.* FROM 'root'@'localhost';

DROP TABLE IF EXISTS mysql.firewall_group_allowlist;
DROP TABLE IF EXISTS mysql.firewall_groups;
DROP TABLE IF EXISTS mysql.firewall_membership;
DROP TABLE IF EXISTS mysql.firewall_users;
DROP TABLE IF EXISTS mysql.firewall_whitelist;

UNINSTALL PLUGIN MYSQL_FIREWALL;
UNINSTALL PLUGIN MYSQL_FIREWALL_USERS;
UNINSTALL PLUGIN MYSQL_FIREWALL_WHITELIST;

DROP FUNCTION IF EXISTS firewall_group_delist;
DROP FUNCTION IF EXISTS firewall_group_enlist;
DROP FUNCTION IF EXISTS mysql_firewall_flush_status;
DROP FUNCTION IF EXISTS normalize_statement;
DROP FUNCTION IF EXISTS read_firewall_group_allowlist;
DROP FUNCTION IF EXISTS read_firewall_groups;
DROP FUNCTION IF EXISTS read_firewall_users;
DROP FUNCTION IF EXISTS read_firewall_whitelist;
DROP FUNCTION IF EXISTS set_firewall_group_mode;
DROP FUNCTION IF EXISTS set_firewall_mode;

DROP PROCEDURE IF EXISTS mysql.sp_firewall_group_delist;
DROP PROCEDURE IF EXISTS mysql.sp_firewall_group_enlist;
DROP PROCEDURE IF EXISTS mysql.sp_reload_firewall_group_rules;
DROP PROCEDURE IF EXISTS mysql.sp_reload_firewall_rules;
DROP PROCEDURE IF EXISTS mysql.sp_set_firewall_group_mode;
DROP PROCEDURE IF EXISTS mysql.sp_set_firewall_group_mode_and_user;
DROP PROCEDURE IF EXISTS mysql.sp_set_firewall_mode;

revoke FIREWALL_ADMIN ON *.* from `root`@`localhost`;
revoke FIREWALL_EXEMPT ON *.* from `root`@`localhost`;

-- remover do my.ini os options para dar start no plugin firewall que não esta mais instalado ou mudar para OFF. Parar o mysql e dar start quando puder.
[mysqld]
#mysql_firewall_mode=ON
#mysql_firewall_trace =ON
#log_error_verbosity=3

--e check novamente:
SHOW GLOBAL VARIABLES LIKE 'mysql_firewall_mode';
-- ------------------------------------------------------------------------------------------------------------------------

--fim


