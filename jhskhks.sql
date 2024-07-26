
/*==================================================================================
Curso: MYSQL
Instrutor: Sandro Servino
https://www.linkedin.com/in/sandroservino/?originalSubdomain=pt
https://www.udemy.com/user/sandro-servino-3/

-------  Fazendo Checagem de Integridade do Banco de Dados e tabela

https://dev.mysql.com/doc/refman/5.7/en/mysqlcheck.html#option_mysqlcheck_auto-repair

Algumas vezes de forma emergencial ou de forma preventiva você precisará verificar e se necessário reparar bancos de dados ou tabelas MySQL, 
pois elas podem estar corrompidos. Algumas vezes pode ocorrer problema em tabelas, como por exemplo quando nao são corretamente fechadas em sessoes de aplicativos e quando
ocorre, constuma ser em tabelas do tipo myisam.

O comando mysqlcheck é uma ferramenta de manutenção que pode ser usada para verificar, reparar, analisar e otimizar várias tabelas a partir da linha de comando. 
Uma das melhores características do uso do mysqlcheck é que você não precisa parar o serviço MySQL para realizar a manutenção do banco de dados.

Observação : é fundamental fazer um backup de seus bancos de dados antes de executar uma operação de reparo de banco de dados, porque alguns reparos podem deletar dados
em tabelas com problemas

A checagem é realizada sobre as tabelas com objetivo de verificar se existe algum problema de 
perda de integridade ou algum problema de estrutura, tanto em tabelas do tipo MyISAM 
quanto INNODB

Uma reparação tenta corrigir este problemas e deixar a tabela livre para uso, mas pode ocorrer perda 
de dados e neste caso sempre o melhor é ter um bom processo de backups automatizados como ja vimos. A reparação deve ser feita em ultimo caso, quando não tem um backup recente.

OBS: Mas é aplicada para tabelas MYISAM. Em tabelas do tipo INNODB, deve tentar recuperar o restore desta tabela especifica atraves do mysqldump para um arquivo, deletar esta tabela
do banco e depois tentar recuperar esta tabela deste restore que foi feito para um file especifico, como exemplo:

mysqldump -uroot -p dbname tablename > backupfile
vai no mysql e delete a tabela do banco com drop table tablename 
volte para o DOS e tente subir o backup que fez desta tabela
mysql dbname < backupfile

OU tentar converter a tabela de MyISAM para INNODB, tentar reparar e depois converter novamente para Inoodb. 
Existem exemplos na internet de como pode fazer este processo. O processo é simples, baseado no comando ALTER TABLE:

Faca backup do banco ou das tabelas antes, se for necessario.

ALTER TABLE nomedatabela  ENGINE = MYISAM;

Execute o procedimento de reparacao da tabela com o comando mysqlcheck, que irá ver nas tabelas INNODB e depois retorne a tabela para arquitetura Inoodb, conforme abaixo.

ALTER TABLE nomedatabela ENGINE=InnoDB;

Faca backup do banco ou das tabelas antes, se for necessario.

Ainda, através do comando mysqlcheck, poderemos atualizar as estatisticas dos indices e otimizar as tabelas
para melhor performance, mas este tema iremos ver no modulo performance.

EXEMPLO DE COMANDOS:

# ira checar todas as tabelas do banco databasename
mysqlcheck -uroot -p databasename

# ira checar todas a tabela teste1 e teste2 do banco databasename
mysqlcheck -uroot -p databasename teste1 teste2

# ira checar as bases de dados databasename e databaseteste
mysqlcheck --databases -uroot -p databasename databaseteste

# ira checar todas as bases de dados da instancia mysql
mysqlcheck  -uroot -p --all-databases

Poderá ainda colocar opcoes para o comando realizar reparacao (myisam), 
analise (atualizar estatisticas dos indices) ou otimizar os indices (remover espacos e ordenando
fisicamente os indices pelos campos nos discos).

Options:
--check or -c
--extended or -e para checagem mais aprofundadas e demoradas nas tabelas
--medium-check or -m
--quick or -q para checagem apenas dos indices. Nao ira checar as tabelas.
--repair or -r
--analyze or -a
--optimize or -o
--force or -f

OBS> A RECOMENDACAO É RODAR O COMANDO mysqlcheck sem options, e se tiver algum problema, ai sim irá verificar
a estratégia se o melhor é retornar um backup ou fazer o repair. Este comando poderá ser rodado de forma manual
ou de forma automatica, 1 vez por dia, ou semana, em um script a ser chamado pelo agendador de tarefa e neste
caso poderá criar um arquivo de resultado e verificar este arquivo afim de checar se alguma tabela tem 
problema de estrutura, porque será indicado um problema.

Se algum problema ocorrer e se for necessario rodar o comando com a opcao repair, 
rodar mysqlcheck novamente primeiramente com as opcoes --repair e --quick, se o problema persistir
rodar novamente mysqlcheck com a opcao apenas --repair e se o problema persistir e nao tiver backup atualizado
rodar novamente mysqlcheck com as opcoes --repair e --force, e neste caso podera ter perda de dados nas tabelas
para o mysql tentar recuperar o que puder para liberar a tabela para uso.

Poderá e por boa pratica é bom rodar o comando como uma nova tarefa de forma automática para atualizar
as estatisticas dos indices, para que o otimizar de querie do mysql sempre tenha estatisticas atualizadas
para usar o melhor plano para resolver uma querie e ainda rodar otimizador de queries para remover
espaco dos indices e deixar os indices ordenados. A periodicidade depende do volume de alteracoes que sao feitas
no banco, mas como sugestao, rodar em intervalos de 7 a 30 dias, fora do horário de producao, se possivel.

OBS: EM ALGUNS CASOS, DEPOIS QUE RECUPERA TABELAS, PODE OCORRER DO MYSQL NAO SUBIR, É RARO MAS PODE OCORRER.
NESTE CENARIO DE START COM MYSQL COM A OPCAO --innodb_force_recovery no my.ini configurando parametro entre 1 e 6.
Estes valores indica o nivel de cautela para evitar um crash e aumenta o nivel de tolerancia
para o mysql dar start mesmo com problemas. Um bom numero é 3.
Quando voce da start as tabelas ficam com modo read only. Entre no server e faça backup full e depois delete as tabelas.
De restart novamente no banco sem esta opcao e tente subir o backup.
ESTA OPCAO é para uma crise onde nao tinha backups full anteriores, passou o repair e teve alguns problemas quando tentou
dar start no server.
LEIA ABAIXO
https://dev.mysql.com/doc/refman/8.0/en/forcing-innodb-recovery.html#:~:text=innodb_force_recovery%20is%200%20by%20default,of%20values%201%20and%202.


==================================================================================*/


-- LAB1

-- De tempo em tempo rodar mysqlcheck

-- vAMOS DAR UMA OLHADA NO BANCO CLIENTE2 E NAS TABELAS E VAMOS AO DOS PARA FAZER NOSSAS CHECAGENS
mysqlcheck CLIENTE2 -u root -p


-- LAB2

-- vAMOS DAR UMA OLHADA NO BANCO CLIENTE2 E VAMOS FAZER CHECK ESPECIFICO EM DUAS TABELAS
mysqlcheck CLIENTE2 order product -u root -p


-- LAB3

-- vAMOS DAR UMA CHECADA EM DOIS BANCOS DE DADOS
mysqlcheck --databases --extended  CLIENTE2 banconovo -u root -p

-- LAB4

-- vAMOS DAR UMA CHECADA EM TODOS OS BANCOS DE DADOS DA INSTANCIA MYSQL
mysqlcheck  -uroot -p --all-databases

-- LAB5
/*problemas podem ocorrer com a estrutura das tabelas, principalmente myisam. o ideal é retornar um backup mais atualizado, 
caso não seja possível o ideal é rodar mysqlcheck -r (--repair). Se tiver que tentar recuperar, 
use primeiro - r e - q (--quick) recuperação mais rápida, se possível. último caso -r e -f (---force). */

-- VAMOS TENTAR RECUPERAR UMA TABELA ACCOUNT DEPOIS DE UMA HIPOTETICA PERDA DE INTEGRIDADE
mysqlcheck -r -q cliente2 customer -u root -p -- (-r só funciona no myisam. alterar innodb para myisam). verificar sem usar -r para garantir
mysqlcheck -r CLIENTE2 account -u root -p
mysqlcheck -r --force CLIENTE2 account -u root -p -- última opção, risco de perder dados caso haja algum problema (lógico ou físico)

Ira receber esta mensagem por que esta tabela nao é MYISAM entao antes de reparar teriamos que alterar a tabela para isam, mas a melhor opcao seria tentar realizar um restore
do backup. SE NAO TIVER O BACKUP ANTERIOR, ANTES DE PASSAR O REPAIR, FACA UM BACKUP.

-- voltar para innofb LEMBRE-SE. Senão dá lock table. mesmo se for apenas uma tabela, bloqueia outras tabelas. BKP sempre

ALTER TABLE CLIENTE2.ACCOUNT ENGINE = MYISAM;


ALTER TABLE CLIENTE2.SUPPLIER ENGINE = MYISAM;
alter table product drop constraint fk_product_Supplier1;
set foreign_key_checks = 0;
set foreign_key_checks = 1;
describe product;
ALTER TABLE CLIENTE2.SUPPLIER ENGINE = INNODB;

alter table cliente2.product 
ADD constraint fk_product_Supplier1 FOREIGN KEY (supplierid) REFERENCES supplier(id) ON UPDATE CASCADE ON DELETE CASCADE;

select * from product;
select * from supplier;

cliente2.account
note     : The storage engine for the table doesn't support repair

VAMOS MUDAR A ARQUITETURA DESTA TABELA PARA MYISAM NO WORKBENCH:

ALTER TABLE CLIENTE2.ACCOUNT ENGINE = MYISAM;
-- se a tabela tiver FK teria que desabilitar esta FK antes ou deletar. Ja vimos como fazer em aulas passadas.

Vamos novamente no DOS e tentar rodar o comando para corrigir a tabela.
mysqlcheck -r CLIENTE2 account -u root -p

AGORA, NAO ESQUECE DE VOLTAR AO WORKBENCH E RETORNAR A TABELA PARA INNODB
ALTER TABLE CLIENTE2.ACCOUNT ENGINE = INNODB;

OBS: SE TIVESSE UM PROBLEMA GENERALIZADO EM TODAS AS TABELAS DO BANCO CLIENTE2 (teria que alterar todas tabelas para myisam, rodar depois voltar)
mysqlcheck -r --databases CLIENTE2 -u root -p

OU EM TODAS AS TABELAS DE TODAS AS BASES DE DADOS (última opção, tenta reparar. já virou caos nesse ponto)
mysqlcheck --auto-repair --all-databases -u root -p 

MAS ESTAO OPCOES É PARA UM CENÁRIO DE DESASTRE TOTAL, SEM BACKUPS, COMO ULTIMA OPCAO, ASSIM MESMO, ANTES DE RODAR, TENTAR FAZER BACKUP FULL, CLONE E COPIAR TODOS OS ARQUIVOS E PASTAS
DA PASTA DATA PARA LUGAR SEGURO.

-- LAB6

-- VAMOS CRIAR TAREFA PARA RODAR TODOS OS DIAS E CHECAR AS TABELAS

-- 1. Vamos criar uma pasta onde o script ira gerar log das checagens. No meu caso sera criado a pasta C:\mysqlapoio\logcheckdb
-- 2. Copie alguns arquivos antigos de teste, para a pasta C:\mysqlapoio\logcheckdb so para comprovar que o comando forfiles abaixo que esta no batch
--    ira deletar arquivos criados com mais de 15 dias desta pagina.
-- 3. Vamos criar um script checkdb.bat na pasta C:\mysqlapoio\ com o seguinte conteudo:

@echo off

for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%" & set "MS=%dt:~15,3%"
set "dirname=%DD%_%MM%_%YY%_%HH%%Min%"
 
mysqlcheck  --defaults-file=C:\mysqlapoio\config.cnf --all-databases > C:\mysqlapoio\logcheckdb\checkdb%dirname%.txt
forfiles /p "C:\mysqlapoio\logcheckdb" /s /m *.* /D -15 /C "cmd /c del @path"

-- 4. Vamos alterar o arquivo config.cnf para incluir o label do mysqlcheck e colocar ali o user root e a senha, para nao colocar no script checkdb.bat, conforme abaixo:

# Configuracoes de usuario
[mysqldump]
 user=root
 password=1234

[mysqladmin]
 user=root
 password=1234

[mysqlcheck]
 user=root
 password=1234

-- 5. Va no DOS, na pasta C:\mysqlapoio\ e execute como um teste o script checkdb.bat e veja se foi executado sem erros. Va na pasta C:\mysqlapoio\logcheckdb e veja se
-- o arquivo foi criado. Caso tenha havido algum erro, refaça o processo. O normal é seu windows ter o comando forfiles instalado. Se nao tiver, va no google e faca donwload.

-- 6. No final, vamos criar uma tarefa no agendador de tarefas do windows para rodar de forma manual e depois criar uma trigger para rodar a cada 1 minuto. Apos este
-- teste ja sabe que esta funcionando e pode quando quiser mudar a frequencia para por exemplo rodar 1 vez por dia, ou por semana por exemplo

-- OBS> NAO ESQUECA DE DELETAR ESTA TAREFA, PORQUE SENAO VAI FICAR RODANDO SEMPRE.

-- ---------------------------------------------------------------------------------------------------------------------------------------

-- OBS FINAL: AS OPCOES DE ANALISE E OTIMIZACAO IREMOS VER NO MODULO DE PERFORMANCE DO CURSO.


-- FIM






















                                                                                                                                                                                                                                                                  