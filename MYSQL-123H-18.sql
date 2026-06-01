Curso MYSQL Completo
Instrutor: Sandro Servino
https://www.linkedin.com/in/sandroservino/?originalSubdomain=pt
https://www.udemy.com/user/sandro-servino-3/

PERFORMANCE - INDICES

CONCEITOS GERAIS

- Os índices são usados ​​para localizar rapidamente linhas com valores de coluna específicos. 
Sem um índice, o MySQL deve começar com a primeira linha e então ler toda a tabela para encontrar as linhas pesquisadas.
Quanto maior a tabela, mais isso custa. Se a tabela tiver um índice para as colunas em questão, o MySQL pode determinar rapidamente a posição a 
ser procurada no meio do arquivo de dados sem precisar examinar todos os dados. Isso é muito mais rápido do que ler cada linha sequencialmente.

- Os indices são atualizados de forma simultanea as operações de inserts, updates e deletes realizados nas tabelas, o que pode trazer perda de performance
nestas operações, então crie indices apenas quando realmente forem necessários.

VAMOS AO LABORATÓRIO

1 Vamos criar uma base de dados nova:

create database stackoverflow;

2 Vamos importar o backup BK_stackoverflow_users.sql para dentro do banco criado stackoverflow e vamos definir este banco com padrao.

3 Vamos verificar os campos da tabela criada e a quantidade de linhas:

 SELECT * FROM users order by displayname desc, location asc, reputation desc;

2.2 sec/ 0.9 sec

Verifique o tempo e a quantidade de leituras que fez e se usou algum indice ou fez uma busca em toda a tabela

Rode novamente:
 SELECT * FROM users order by displayname desc, location asc, reputation desc;

2.2 sec/ 0.9 sec

obs: duration é tempo de execucao da consulta do lado do cliente e fetch o tempo que demorou para montar os dados no client workbench.

Por padrao no MySQL 8.0, foi desativado o suporte para o cache de consulta, devido a problemas de performance encontrados.
https://dev.mysql.com/blog-archive/mysql-8-0-retiring-support-for-the-query-cache/

-- ------------------------------------------------------------------------------------------------------------

Agora vamos pesquisar um user especifico 

 SELECT * FROM users where id = 5000;

E vamos usar o comando explain para o vermos o que o otimizar de queires fez para resolver a querie com o menor custo possivel

explain SELECT * FROM users where id = 5000;

Agora, vamos criar um indice clustered atraves da criacao de uma PK pelo campo id.

ALTER TABLE users
ADD PRIMARY KEY(id);

obs: 

INDEX CLUSTERED

- Quando você define a PRIMARY KEY em uma tabela, InnoDB usa-o como o índice clusterizado (o indice clustered é a propria tabela, ordenada pelo campo do indice). 
- Cada tabela InnoDB requer um índice clusterizado. 
- Se você não tiver uma chave primária para uma tabela, o MySQL procurará o primeiro índice UNIQUE onde estão todas as colunas de chave sao NOT NULL e usará esse indice UNIQUE
  como o índice clusterizado.
- Caso a tabela InnoDB não tenha chave primária ou índice UNIQUE adequado, o MySQL gera internamente um índice clusterizado oculto nomeado GEN_CLUST_INDEX 
  em uma coluna sintética que contém os valores de ID da linha.

- Como um índice clusterizado armazena as linhas em ordem de classificação, cada tabela possui apenas um índice clusterizado.
- As buscas pelos campos da PK, geralmente são muito rapidas

INDEX NON-CLUSTERED

Como os índices secundários (nonclusterd) se relacionam com o índice clusterizado?
- Índices diferentes do índice clusterizado são conhecidos como índices secundários nonclustered e voce poderá ter dezenas/centenas de indices non clustered por tabela, 
  o que não é o ideal, devido ao custo de mante-los atualizados a cada insert, delete e update nas tabelas que tem estes indices. 
- Em InnoDB, cada registro em um índice secundário contém as colunas de chave primária. InnoDB usa esse valor de chave primária para pesquisar a linha no índice clusterizado.

Portanto, é vantajoso ter uma chave primária curta, caso contrário os índices secundários usarão mais espaço. 
Normalmente, a coluna de número inteiro de incremento automático é usada para a coluna de chave primária e é best practice em termos de performance e menor custo 
de armazenamento de dados.

-- ---------------------------------------------------------------------------

AGORA RODA NOVAMENTE:

 SELECT * FROM users order by displayname desc, location asc, reputation desc; -- usou algum indice?

SELECT * FROM users order by id; -- usou algum indice?
SELECT * FROM users order by id desc; -- usou algum indice? teve perda de tempo em relacao a order by asc?

e use o explain para verificar que agora ao inves de fazer uma leitura full table scan, em todas as linhas e todas as colunas, está fazendo
uma leitura full scan mas apenas no indice clustered criado para a PK

explain  SELECT id FROM users order by id;

Agora, vamos fazer uma busca seletiva

 SELECT * FROM users where id=5000; 

 explain  SELECT * FROM users where id=5000; 

Faca analise em termos de custo e tempo, comparado com os outros selects

-- ---------------------------------------------------------------------------

VAMOS CRIAR NOSSO PRIMEIRO INDICE NON-CLUSTERED

vamos antes realizar uma pesquisa na tabela users, buscando por uma pessoa especifica:

SELECT * FROM users where displayname = "Joel Spolsky";

Verifique a quantidade de tempo, linhas lidas e se usou algum indice ou fez busca em toda a tabela, para devolver uma quantidade pequena de dados

Vamos verificar uma situacao com o order by novamente:

SELECT * FROM users;
select * from users order by id;          -- repare no operador ORDER em amarelo, indicando que NAO precisou de fazer a ordenacao fisica em arquivo no disco
select * from users order by displayname; -- repare no operador ORDER em vermelho, indicando que precisou de fazer a ordenacao fisica em arquivo no disco
select displayname from users order by displayname; -- veja que agora o tempo reduziu. Cuidado com uso de *

Vamos rodar agora fazendo buscas por um nome:

SELECT * FROM users where displayname = "Joel Spolsky"; -- verifique a quantidade de linhas lidas da tabela para achar o joel
SELECT * FROM users where displayname = "Joel Spolsky" order by displayname; -- Repare que faz order by apenas nos dados retornados e por isto é tão rapido quando sem o order by

se nao filtrarmos pelo displayname e mandamos fazer order by pelo campo displayname, veja que ira usar operador ORDER com linhas vermelho, indicando alto custo, porque está
ordernando em disco devido a quantidade de dados a serem ordenados e o tempo aumenta bastante.

EXPLAIN SELECT * FROM users where displayname = "Joel Spolsky" order by displayname; -- VEJA QUE NAO USOU INDICE NENHUM E LEU TODAS AS LINHAS DA TABELA. O PERCENTUAL MAIS PROXIMO 
DE 100% É O MELHOR INDICATIVO, E MAIS PROXIMO DE 1% É O PIOR INDICATIVO. 
100% INDICA QUE 100% DOS DADOS PESQUISADOS FORAM TRAZIDOS, E 1% SIGNIFICA QUE O MYSQL PRECISOU LER 100% DAS LINHAS 
PARA SO TRAZER 1% QUE FOI SOLICITADO, OU SEJA, IMAGINA QUE TENHA UMA TABELA COM 100 NOMES, E PESQUISOU ANA PAULA, ELE PRECISOU LER TODOS OS 100 NOMES PARA TRAZER APENAS 1.
-- -----

AGORA VAMOS CRIAR UM INDICE NON-CLUSTERED PELO CAMPO DE BUSCA DISPLAYNAME

CREATE INDEX idx_UsersDisplayname1 ON users(displayname);

Se aparecer este erro: BLOB/TEXT column 'message_id' used in key specification without a key length
O erro acontece porque o MySQL pode indexar apenas os primeiros N caracteres de um BLOB ou TEXT. Então O erro acontece principalmente quando existe um tipo de 
campo/coluna TEXT ou BLOB ou aqueles que pertencem aos tipos TEXT ou BLOB como TINYBLOB, MEDIUMBLOB, LONGBLOB, TINYTEXT, MEDIUMTEXT, e LONGTEXT que você tenta fazer uma 
chave primária ou índice. Com full BLOB ou TEXT sem o valor de comprimento, o MySQL não pode garantir a exclusividade da coluna, pois é de tamanho variável e dinâmico. 
Portanto, ao usar os tipos BLOB ou TEXT como um índice, o valor de N deve ser fornecido para que o MySQL possa determinar o comprimento da chave. 
No entanto, o MySQL não suporta um limite de tamanho de chave em TEXT ou BLOB. TEXT(88) simplesmente não funcionará.

Então para criar indice neste campo, teremos que alterar o tipo de campo para por exemplo um valor maximo de dados que exista na coluna TEXT, no nosso exemplo varchar(256).

Poderiamos verificar com o codigo abaixo, a linha de dados que tem mais caracteres na coluna displayname e alterarmos a coluna com esta quantidade maxima de dados, para não
truncarmos dados na conversao e podemos colocar uma folga aceitavel para os futuros dados.

select displayname , LENGTH(displayname) as qtcaracteres from users order by qtcaracteres desc LIMIT 10;

-- 

VAMOS ALTERAR O TIPO DE DADOS DA COLUNA AGORA DE TEXT PARA VARCHAR(256), mas poderia ser 31.

ALTER TABLE users MODIFY COLUMN displayname VARCHAR(256);

E VAMOS NOVAMENTE CRIAR O INDICE PELO CAMPO DISPLAYNAME

CREATE INDEX idx_UsersDisplayname1 ON users(displayname);

E VAMOS REALIZAR NOVA PESQUISA

SELECT * FROM users where displayname = "Joel Spolsky"; -- REPARE NO TEMPO, NO NUMERO DE LINHAS VERIFICADOS E NO INDICE USADO. AINDA FOI NECESSARIO USAR O OPERADOR KEY LOOKUP,
PARA PEGAR OS OUTROS DADOS (*) QUE NAO ESTAVAM NO INDICE, QUE TEM APENAS DISPLAYNAME E ID (chave para indice clustered da tabela users)

Se nao usarmos o * e colocarmos apenas o campo displayname para ser retornado, o otimizador de querie usado na versao 8 do MYSQL deveria ler apenas os dados que estáo no indice non clustered, ou seja, 
náo precisara ir no indice clustered (a propria tabela) para pegar todos os outros dados e assim seria ainda mais rapido, porque leria menos dados. O SQL SERVER  neste caso faria assim.
Muitas vezes criamos indices compostos com mais de 1 campo, para evitar o key lookup mas o otimizar de queries do MYSQL sempre vai avaliar o que é menos custoso em termos de tempo
para trazer os dados e se ele achar que será menos custoso ler a tabela inteira, ao inves de usar um indice, ele fara. 

-- 

PARA VERMOS OS INDICES DE UMA TABELA

SHOW INDEXES FROM users;

A cardinalidade do índice refere-se à exclusividade dos valores armazenados em uma coluna especificada dentro de um índice. Quanto maior, melhor. No caso de uma Primary Key, 
o numero deve refletir a quantidade de linhas de uma tabela, porque PK não aceita valores duplicados para uma coluna(s). Se tiver uma tabela com indice pelo campo sexo, e tiver
100.000 linhas com 50% de sexo masculina e 50% do sexo feminino, terá um indice ruim, porque a metade da tabela tem colunas com o mesmo valor, e provavelmente em uma busca, o 
otimizar de queries pode perceber que ler toda a tabela terá menor custo, do que ler 50% dos dados do indice e depois fazer key lookup na tabela através do indice clustered para pegar os dados da pessoa.

O MySQL gera a cardinalidade do índice com base nas estatísticas armazenadas, que ainda iremos ver.

E SE FIZERMOS BUSCAR COM DUAS PESSOAS

SELECT * FROM users where displayname = "Joel Spolsky" OR displayname = "Milan"; -- REPARE NA QUANTIDADE DE LINHAS EXAMINADAS E QUANTIDADE DE LINHAS ENVIADAS PARA O CLIENTE
REPARE AINDA, QUE USOU O MESMO INDICE, MAS USOU UM OUTRO OPERADOR RANGE SCAN PORQUE TEVE QUE LER MAIS DADOS NO INDICE. ESTE OPERADOR (PROGRAMA), FOI USADO PORQUE ELE TEM RECURSOS
MELHORES PARA TRAZER MAIS DADOS DO QUE O KEYLOOKUP QUE FOI USADO NO CASO ANTERIOR.

AGORA E SE FIRMOS ISTO?

SELECT * FROM users where displayname = "Joel Spolsky" OR location = "Corvallis, OR"; 

VERIFIQUE NO ROWNS EXAMINED, E VERÁ QUE NOVAMENTE, MESMO TENDO INDICE PELO DISPLAYNAME TEVE QUE LER TODA A TABELA NOVAMENTE, PORQUE O INDICE EXISTE APENAS PARA O CAMPO DISPLAYNAME
E ASSIM PARA ACHAR ALEM DE TODOS COM DISPLAYNAME PESQUISADO NO INDICE, TERIA QUE LER TODAS AS LINHAS PARA ACHAR LOCATION PESQUISADO, PORQUE NAO TINHA INDICE PARA RESOLVER ESTA QUERIE.
VEJA NO GRAFICO QUE USOU O OPERADOR FULL TABLE SCAN

SELECT * FROM users where displayname = "Joel Spolsky" OR location = "Corvallis, OR"; -- MESMO INDICANDO QUE PODERIA USAR POR ESTIMATIVA O INDICE EXISTENTE POR DISPLAYNAME
O OTIMIZADOR DE QUERIE PREFIRIA FAZER BUSCA SEQUENCIAL NA TABELA (INDICE CLUSTERED) PORQUE O CUSTO EM TERMOS DE TEMPO SERIA MENOR. NO CASO O TEMPO TOTAL FOI DE CERCA DE
1.09s + 1.09s, PORQUE JA TERIA QUE LER TODA A TABELA MESMO PARA ACHAR OS VALORES DE LOCATION QUE NAO ESTAVAM NO INDICE E ASSIM JA FOI LENDO OS DADOS DE DISPLAYNAME NO SCAN TABLE.

PARA RESOLVERMOS ESTA QUERIE, PODEMOS CRIAR UM NOVO INDICE COM OS DOIS CAMPOS, MAS PARA QUE CRIAR UM NOVO INDICE, TRAZENDO MAIS CUSTOS PARA INSERT, DELETE E DELETE, SE 
PODEMOS ALTERAR O INDICE EXISTENTE POR DISPLAYNAME E APENAS ACRESCENTAR MAIS UM CAMPO NO INDICE. O INDICE SERA MAIOR MAS AINDA ASSIM É MELHOR DO QUE DOIS INDICES QUE PRECISARIAM
SER ATUALIZADOS EM TEMPO REAL, PORQUE LEMBRE-SE QUE INDICES SAO ARQUIVOS QUE FICAM NO DISCO E PRECISAR SER ALTERADOS DE FORMA SINCRONA COM OS DADOS DA TABELA.

SHOW INDEXES FROM users;

OBS: A ORDEM DOS CAMPOS NA BUSCA, OU SEJA, NO WHERE NÁO IMPORTA, PORQUE O MYSQL INVERTE PARA BATER COM A ORDEM DA CRIACAO DOS INDICES, MAS A ORDEM DA CRIACAO DOS INDICES
IMPORTA. VAMOS VER EM ALGUNS EXEMPLOS.

DROP INDEX idx_UsersDisplayname1 ON USERS;

ALTER TABLE users MODIFY COLUMN location VARCHAR(256);

CREATE INDEX idx_UsersDisplayname1 ON users(displayname, location);

SHOW INDEXES FROM users; -- apesar de mostrar duas linha, o indice é unico e pode confirmar pelo nome do indice nas duas colunas na mesma tabela e podera confirmar graficamente

Vamos fazer alguns testes:

SELECT * FROM users
 where displayname = "Joel Spolsky";  -- usa o indice criado, porque o indice foi criado, sendo a primeira coluna o campo displayname

 SELECT * FROM users
 where displayname = "Joel Spolsky" and location = "New York, NY"; -- usa o indice criado, porque bate com todas as colunas que estao no indice
 
  SELECT * FROM users
 where  location = "New York, NY" and displayname = "Joel Spolsky"; -- usa o indice criado, porque bate com todas as colunas que estao no indice. A ordem das colunas no where nao importa, mas sim na criacao do indice.
 
   SELECT * FROM users
 where  location = "Corvallis, OR"; -- nao usa indice, mas sim fall table scan, porque nao tem indice apenas por location e a ordem da criacao do indice importa.

OBS: ESTA MESMA REGRA VALE PARA BUSCAS COM 3 OU MAIS CAMPOS. SE TIVER CAMPO A,B,C, SE CRIAR O INDICE NESTA ORDERM (A,B,C), o MYSQL VAI USAR OS INDICES SE PASSAR PARAMETROS
APENAS A, A e B, A e B e C, em qualquer ordem no WHERE. AGORA SE NO WHERE PASSAR APENAS B, B e C o MYSQL nao vai usar o indice criado.

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- vAMOS FAZER UM NOVO EXERCICIO. Sera que teremos melhor performance se criarmos indice pelos campos usados no ordey by?

  SELECT * FROM users ORDER BY LastAccessDate; -- tempo de execucao, 2.04+2.944 Segundos
  select LastAccessDate FROM users ORDER BY LastAccessDate;  -- tempo de execucao, 1.62+1.84 segundos
  
  ALTER TABLE users MODIFY COLUMN LastAccessDate DATE; -- se aparecer esta mensagem, Error Code: 2013. Lost connection to MySQL server during query 30.016 sec, 
                                                               -- altere em edit, propriedades -> sql editor, a propriedade DBMS connection read timeout do workbench o tempo, 
                                                               -- deixando 0, para o comando nao cair por timeout.

-- obs: se for necessario mudar tipos de dados em grandes tabelas em ambientes de producao, antes faça backup e rode o processo em QA antes e depois rode em producao, preferencialmente
-- sem usuarios que estejam acessando esta tabela, porque bloqueios sao gerados. No final, faça uma analise dos dados alterados.
-- No meu notebook levou cerca de 1854 segundos para rodar.

 CREATE INDEX idx_UsersLastAcessDate1 ON users(LastAccessDate);

 SHOW INDEXES FROM users;

-- Agora, vamos rodar o mesmo codigo, e vamos verificar se houve ganhos em termos de tempo de execucao:

  SELECT * FROM users ORDER BY LastAccessDate; -- tempo de execucao, 1.78+2.68 Segundos. Houve um ganho, mas ainda precisou fazer order by no disco, porque foi solictado a devolucao de todos os campos que nao estavam no indice
  select LastAccessDate FROM users ORDER BY LastAccessDate;  -- tempo de execucao, 0.26+0.61 segundos. Aqui houve uma grande melhoria da performance, porque ja existia o indice ordenado pelo campo e so pediu para retornar este campo. 
                                                             -- Entáo o otimizador de querie nao precisou ir no indice clustered (a propria tabela). Ja trouxe os dados que estavam apenas no indice e vai reparar que o operador ORDER nao foi no disco (esta cor amarela).

RESUMINDO, SE HOUVER CONSULTAS QUE RODAM MILHARES DE VEZES AO DIA, COM ORDER BY, VERIFIQUE SE NÁO VALE A PENA CRIAR UM INDICE COM OS CAMPOS QUE ESTAO NO ORDER BY, MAS CUIDADO
PORQUE CADA INDICE A MAIS IMPACTA NO INSERT, UPDATE E DELETE E QUANTO MAIOR A QUANTIDADE DE COLUNAS NO INDICE, MAIOR VAI FICANDO O INDICE NO DISCO, MAIS TEMPO PARA ATUALIZAR O INDICE,
O BANCO VAI FICANDO MAIOR TIRANDO AS VEZES DADOS DA MEMORIA, E PROCESSOS DE BACKUP E RESTORE E CHECAGENS DE INTEGRIDADE DA BASE DEMORAM MAIS PARA ACONTECER.

-- ------------------------------------------------------------------------------------------------------------

-- VAMOS FAZER OUTROS EXERCICIOS

-- USO DE FUNCAO MIN, AVG E MAX JUNTO COM INDICES

SELECT avg(reputation), max(reputation), min(reputation) FROM users ; -- Tempo de execucao, 1.25+1.26 segundos e verifique a quantidade de leituras que precisou fazer.

-- Vamos criar um indice por este campo:

CREATE INDEX idx_UsersLastAcessReputation1 ON users(reputation); 

SELECT avg(reputation), max(reputation), min(reputation) FROM users ; -- tempo de execucao, 0.5+0.5 segundos. Fez leitura apenas no index, foi full, mas apenas no indice e nao na tabela inteira, que foi feito na pesquisa anterior, sem om indice idx_UsersLastAcessReputation1.

-- -------------------------------------------------

-- E COMO FUNCIONA O LIKE COM OS INDICES?

SHOW INDEXES FROM users;

-- Temos um indice idx_UsersDisplayname1, composto por dois campos displayname + location, então para o nosso exemplo, que quero fazer buscas por pedaço do nome, não precisamos
-- criar um novo indice apenas com displayname, mas sim aproveitarmos este indice, já que começa com displayname.

SELECT * FROM users where displayname = "Joel Spolsky"; -- Podemos verificar que o indice foi utilizado e com otima performance e baixo custo, lendo apenas 14 linhas e trazendo estas 14 linhas.

SELECT * FROM users where displayname like "Joel%"; -- Apesar do tempo maior, porque trouxe mais de 1000 linhas (cerca de 9 segundos), 
                                                    -- ainda assim usou o mesmo indice criado, usando um operador de leitura dentro do indice (index range scan)
                                                    -- porque o otimizador de querie do mysql, baseado nas estatisticas de cardinalidade deste indice, percebeu que teria menor
                                                    -- custo para trazer os dados, baseado neste indice do que fazer full scan em toda a tabela (mais 600 mil linhas), 
                                                    -- então ele fez um seek no primeiro registro no index ordenado, começando com joel% e fez a leitura sequencial dentro do indice e depois
                                                    -- saltou para indice clustered para pegar o restante dos dados.

SELECT displayname FROM users where displayname like "Joel%"; -- o ganho de tempo aqui é muito grande, de menos de 1 segundo, porque não precisou fazer look up no indice clustered
                                                              -- para retornar as outras colunas (*), que não estão no indice non clustered. CUIDADO COM USO DO *

explain SELECT * FROM users where displayname like "Joel%";

-- UM FORMA ALTERNATIVA DE AVALIAR A PERFORMANCE DE UMA QUERIE É UTILIZAR O EXPLAIN EM FORMATO JSON, CONFORME ABAIXO

explain format=json SELECT * FROM users where displayname like "Joel%"; -- PODE ESTAR LIMITADO A QUANTIDADE DE BYTES NO WORKBENCH, 
                                                                        -- AUMENTE NO MENU EDIT-> PREFERENCES -> SQL EXECUTION, NO CAMPO Max. Field Value Lenght to display in bytes de 256 para 1000 ou mais se for necessário.

DICAS do Peter Zaitsev (um dos fundadores do Percona):

1. Um componente que você deve observar é o QUERY_COST “custo da consulta”. O custo da consulta refere-se ao quão caro o MySQL considera essa consulta específica em termos do custo geral 
da execução da consulta e é baseado em muitos fatores diferentes. 

2. As consultas simples geralmente têm um custo de consulta inferior a 1.000. 
Consultas com um custo entre 1.000 e 100.000 são consideradas consultas de custo médio e geralmente são rápidas se você estiver executando apenas centenas dessas consultas 
por segundo (não dezenas de milhares). Consultas com um custo de mais de 100.000 são consultas caras. Muitas vezes, essas consultas ainda serão executadas rapidamente quando você 
for um único usuário no sistema, mas você deve pensar cuidadosamente sobre a frequência com que usa essas consultas em seus aplicativos interativos 
(especialmente à medida que o número de usuários aumenta).

3. Esses são números de desempenho aproximados, mas demonstram o princípio geral. Seu sistema pode lidar melhor ou pior com cargas de trabalho de consulta, dependendo de sua 
arquitetura e configuração.

4. O principal entre os fatores que determinam o custo da consulta é se a consulta está usando os índices corretamente. 
O comando EXPLAIN pode informar se uma consulta não está usando índices (geralmente por causa de como os índices são criados no banco de dados ou como a própria consulta é projetada). 
É por isso que é tão importante aprender a usar EXPLAIN.

5. Um índice melhora o desempenho da consulta porque reduz a quantidade de dados no banco de dados que as consultas devem verificar, mas tenha cuidado: não adicione índices que você não precisa! 
Índices desnecessários tornam os bancos de dados lentos.


Resultado da query:

{
   "query_block": {
     "select_id": 1,
     "cost_info": {
       "query_cost": "1200.50"
     },
     "table": {
       "table_name": "users",
       "access_type": "range",
       "possible_keys": [
         "idx_UsersDisplayname1"
       ],
       "key": "idx_UsersDisplayname1",
       "used_key_parts": [
         "displayname"
       ],
       "key_length": "1027",
       "rows_examined_per_scan": 1106,
       "rows_produced_per_join": 1106,
       "filtered": "100.00",
       "index_condition": "(`stackoverflow`.`users`.`displayname` like 'Joel%')",
       "cost_info": {
         "read_cost": "1089.90",
         "eval_cost": "110.60",
         "prefix_cost": "1200.50",
         "data_read_per_join": "2M"
       },
       "used_columns": [
         "Id",
         "CreationDate",
         "displayname",
         "DownVotes",
         "LastAccessDate",
         "location",
         "Reputation",
         "UpVotes",
         "Views"
       ]
     }
   }
 }


Uma outra forma de verificar o custo estimado da execucao de uma consulta seria atraves:

explain format=TREE  SELECT * FROM users where displayname = "Joel";

-> Index lookup on users using idx_UsersDisplayname1 (displayname='Joel')  (cost=274.21 rows=280)
 

explain format=TREE SELECT * FROM users order by displayname;

-> Sort: users.displayname  (cost=65979.63 rows=632293)
     -> Table scan on users  (cost=65979.63 rows=632293)
 
RESUMINDO, EXPLAIN descreve como o MySQL planeja executar uma determinada consulta. 
EXPLAIN indica o que é considerado para o otimizador de queries o melhor plano, após um processo de avaliação de milhares de maneiras de executar uma consulta. 
Isso quer dizer que essa é uma visualização de pré-execução. 

Se as estatisticas dos indices
estiverem atualizadas, provavelmente será o que o otimizador de querie vai executar quando este comando chegar, mas se estiver desatualizada, ele pode achar que os dados das tabelas
estavam de uma forma e assim poderá não usar o melhor indice, ou usar um indice errado, ou fazer um table scan quando poderia usar um indice ou ao contrario. 
Iremos conversar mais a frente sobre estatisticas dos indices e como manter atualizados.

-- --------------- ATENCAO

Mas EXPLAIN não nos diz se essas estimativas estão corretas ou em quais operações no plano de consulta o tempo é realmente gasto, pois é uma estimativa. EXPLAIN ANALYZE fará isso:

EXPLAIN ANALYZE SELECT * FROM users order by displayname;
-> Sort: users.displayname  (cost=65958.57 rows=632293) (actual time=2125.151..2287.525 rows=635558 loops=1)
     -> Table scan on users  (cost=65958.57 rows=632293) (actual time=283.556..1264.208 rows=635558 loops=1)

EXPLAIN ANALYZE SELECT * FROM users where displayname = "Joel";
-> Index lookup on users using idx_UsersDisplayname1 (displayname='Joel')  (cost=274.21 rows=280) (actual time=292.509..2111.681 rows=280 loops=1)
 
Na primeira parte, o EXPLAIN ANALYSE, traz valores baseados nas estatiticas dos indices cost=274.21 rows=280), ou seja, o otimizador de querie estima que o custo sera de 274 e o 
numero de linhas estimado para serem retornados será de 280 linhas e baseado nisto ira usar um determinado de plano de indice ou nao.

Na parte final, traz o que ele realmente fez (actual time=292.509..2111.681 rows=280 loops=1). Se a razao por exemplo do numero de linhas estimadas para retorno de 280, for na order por exemplo
de 10 vezes para mais ou menos, pode ser um indicativo de algum problema nas estatisticas dos indices, ou alguma querie que esta fazendo muitas conversoes usando funcoes
que podem estar confundido o otimizador de planos, fazendo ele usar ou deixar de usar um indice e assim ter resultados ruins. 292.509 siginifca o tempo em ms para o mysql trazer
a primeira linha e 2111.681 foi o tempo em ms para trazer a ultima linha. rows é o numero de linhas efetiva que ele trouxe e loops é o numero joins existente na querie, partindo de 1 com selects simples.

-- --------------- RETORNANDO AO LIKE


-- AGORA VOLTANDO AO TEMA DO LIKE, VAMOS VER COMO O OTIMIZADOR DE QUERIE SE COMPORTA COM ESTE TIPO DE BUSCA

SELECT * FROM users where displayname like "Joel%";

SELECT * FROM users where displayname like "%Joel%";

-- OBS: MAS POR QUE O PRIMEIRO SELECT, MESMO SENDO ESCOLHIDO O INDEX EXISTENTE, E TENDO LIDO MENOS DADOS DA TABELA, DEMOROU BEM MAIS TEMPO QUE RODAR A SEGUNDA QUERIE, QUE FEZ UM FULL TABLE SCAN?
-- Nos dois casos a tabela envolvida tinha cerca de 600 mil linhas. No primeiro caso, usou o operador seek para saltar para o primeiro registro valido e depois leu cerca de 1000 registros
-- mas a cada registro lido no index, teve que pular 1000 vezes para o index clustered pela PK, para buscar as outras informacoes (*).

-- E no segundo SELECT, como foi usado o curinga dos dois lados %, o otimizador nao conseguiu usar nenhum indice, fazendo full table scan, ou seja, para retornar as 1000 linhas 
-- precisou ler as 600 mil linhas. O otimizador indicou que esta consulta poderia ter um custo muito alto, mas neste caso, mesmo lendo todas as 600 mil linhas, foi mais rapido
-- para o mysql devido a velocidade do meu disco SSD, ler todas as linhas no primeiro indice clustered (tabela), do que na querie anterior, entao NEM SEMPRE O FULL TABLE SCAN 
-- SERA MAIS LENTO DO QUE O USO DE UM INDICE, DEPENDE POR EXEMPLO DA QUANTIDADE DE LINHAS DE UMA TABELA E DA VELOCIDADE DO DISCO E DA QUANTIDADE DE MEMORIA RAM EXISTENTE, POIS
-- MUITOS DOS DADOS JA PODERIAM ESTAR NO BUFFER CACHE.

AGORA, SE AO INVES DE LER TODOS OS CAMPOS (*), BUSCAR APENAS O CAMPO QUE ESTA NO INDICE CRIADO

SELECT displayname FROM users where displayname like "Joel%"; -- VEJA OS TEMPOS

SELECT displayname FROM users where displayname like "%Joel%"; -- VEJA OS TEMPOS

CREATE INDEX idx_UsersDisplayname2 ON users(displayname);

SHOW INDEXES FROM users;

-- -----------------------------------------------------------------

CUIDADO COM CONVERSOES FEITAS ATRAVES DE FUNCTIONS E IMPACTOS NOS INDICES

explain format=TREE select * from users where CreationDate = "2009-06-28"; -- vamos ver como o otimizar de querie estima o custo desta querie, quantas linhas vai precisar ler, e se vai usar algum indice ou table scan
-> Filter: (users.CreationDate = '2009-06-28')  (cost=65958.57 rows=63229)
     -> Table scan on users  (cost=65958.57 rows=632293)
 
EXPLAIN ANALYZE select * from users where CreationDate = "2009-06-28"; -- vamos ver o que foi estimado X execucao real
-> Filter: (users.CreationDate = '2009-06-28')  (cost=65971.36 rows=63229) (actual time=494.088..1397.246 rows=196 loops=1)
     -> Table scan on users  (cost=65971.36 rows=632293) (actual time=281.471..1278.925 rows=635558 loops=1) -- A ESTIMATIVA DE LEITURA DE LINHAS BATEU COM A REAL EXECUCAO DEMONSTRANDO ASSIM QUE O OTIMIZADOR DE QUERY IRIA UTILIZAR O MELHOR PLANO EXISTENTE, MAS NA LINHA ACIMA FOI DEMONSTRADO QUE PELO FILTRO SO RETORNOU 196 LINHAS, EVIDENCIANDO OPORTUNIDADE DE UM INDICE
     
Temos aqui uma otima oportunidade teorica de criarmos um indice por creationdate e trazer ganhos de performance, porque o otimizar teve que ler mais de 600 mil linhas para recuperar apenas 196.
Se a cardinalidade do indice for muito alta, ou seja, ter percentual altissimo de numeros diferentes de creationdate no indice o mysql usará este indice.
ao inves de usar tablescan.
 
select * from users where CreationDate = "2009-06-28";

SHOW INDEXES FROM users;

-- --------------------------

Vamos criar o indice entao:

ALTER TABLE users MODIFY COLUMN CreationDate DATE; -- se aparecer esta mensagem, Error Code: 2013. Lost connection to MySQL server during query 30.016 sec, 
                                                               -- altere em edit, propriedades -> sql editor, a propriedade DBMS connection read timeout do workbench o tempo, 
                                                               -- deixando 0, para o comando nao cair por timeout.

CREATE INDEX idx_Userscreationdate1 ON users(CreationDate); 

SHOW INDEXES FROM users; -- veja que a cardinalidade é ruim para este indice em relacao a quantidade de dados diferentes, ou seja tem apenas 335 datas unicas em um universo de mais 
                         -- de 600 mil linhas. Dependendo da data que seja buscada ou do periodo de data, 
                         -- o otimizador podera escolher ler toda a tabela que sera mais rapida do que achar no indicea data pesquida ou faixa de data e depois fazer lookup 
                         -- para pegar a restante das colunas no indice clustered

Vamos repetir os mesmos comandos e vamos verificar o custo, quantidade de leituras e o tempo.

explain format=TREE select * from users where CreationDate = "2009-06-28"; -- vamos ver como o otimizar de querie estima o custo desta querie, quntas linhas vai precisar ler, e se vai usar algum indice ou table scan
-> Index lookup on users using idx_Userscreationdate1 (CreationDate=DATE'2009-06-28')  (cost=210.34 rows=196)
 

EXPLAIN ANALYZE select * from users where CreationDate = "2009-06-28"; -- vamos ver o que foi estimado X execucao real
-> Index lookup on users using idx_Userscreationdate1 (CreationDate=DATE'2009-06-28')  (cost=210.44 rows=196) (actual time=334.498..394.869 rows=196 loops=1)

select * from users where CreationDate = "2009-06-28";
select CreationDate, id from users where CreationDate = "2009-06-28"; -- aqui deve rodar ainda mais rapido, porque lera apenas o indice criado que tem o creationdate e id


-- -------------------------------------------------------------AGORA VAMOS FAZER UMA CONSULTA COMO ESTA:

SHOW INDEXES FROM users;

select * from users where CreationDate >= "2009-06-28" AND CreationDate <= "2011-06-28"; -- veja que aqui como a quantidade de leitura seria menor, o otimizar de querie achou menos custoso usar um indice

select * from users where CreationDate >= "1900-06-28" AND CreationDate <= "2055-06-28"; -- mas, e neste caso?, TEMPO DE EXECUCAO 0.29+1.81 SEGUNDOS

Select * from users where year(CreationDate) =  "2009" ;-- agora e se quisermos trazer os dados dos usuarios criados em 2009. O que vai acontecer?

select * from users where CreationDate >= "2009-01-01 00:00:00" AND CreationDate <= "2009-12-31 23:59:59"; -- uma forma de usarmos o indice criado, trazendo o mesmo resultado 
                                                                                                           -- do comando acima. Mas porque mesmo tendo o indice, o mysql preferiu fazer table scan?
                                                                                                           -- TEMPO 0.46+1.51 SEGUNDOS

select count(*) from users where CreationDate >= "2009-01-01" AND CreationDate <= "2009-12-31"; -- Ira verificar, rodando este comando, que o comando acima trouxe 345142 linhas, ou seja,
                                                                                                -- mais da METADE da tabela, e assim, o table scan teria menor custo. Nos vimos que este indice tem baixa cardinalidade.

SE RODARMOS POR EXEMPLO, COM OUTRA FAIXA DE DATAS, VERA QUE AGORA O OTIMIZADOR DE QUERIE VAI USAR O INDICE PARA TRAZER OS DADOS, PORQUE PELA ESTATISTICA DO INDICE, ESTA FAIXA
DE DATAS, TEM POUCOS DADOS, OU SEJA, ALTA CARDINALIDADE, ENTAO VALE A PENA IR APENAS NO INDICE DO QUE LER A TABELA INTEIRA. PARA ISTO VAMOS DAR UM INSERT NA TABELA USERS
COM ESTAS NOVAS FAIXAS DE DATAS E VAMOS DEPOIS REALIZAR UMA BUSCA.

INSERT INTO stackoverflow.users
(Id,
CreationDate,
displayname,
DownVotes,
LastAccessDate,
location,
Reputation,
UpVotes,
Views)
VALUES
(9999999,
"2013-01-01",
"Sandro Servino",
"333",
"2013-01-01",
"porto",
"2",
"55",
"3");


INSERT INTO stackoverflow.users
(Id,
CreationDate,
displayname,
DownVotes,
LastAccessDate,
location,
Reputation,
UpVotes,
Views)
VALUES
(99999999,
"2013-12-31",
"ricardo gomes",
"333",
"2013-01-01",
"porto",
"2",
"55",
"3");


select * from users where CreationDate >= "2013-01-01 00:00:00" AND CreationDate <= "2013-12-31 23:59:59"; -- repare que agora para esta faixa de datas o otimizador usou o indice existente

-- e se voltarmos com a busca das faixas de datas anteriores com que centenas de milhas de linhas com as mesmas datas, o mesmo otimizador de querie, na busca com os mesmos campos e na mesma
-- tabela ira usar full table scan, porque seria menos custoso do que usar o indice criado

select * from users where CreationDate >= "2009-01-01 00:00:00" AND CreationDate <= "2009-12-31 23:59:59"; 

-- ATENCAO

-- E se forcassemos que o otimizador de querie usasse o indice existente idx_Userscreationdate1 por creationdate?

select * from users force index (idx_Userscreationdate1) where CreationDate >= "2009-01-01 00:00:00" AND CreationDate <= "2009-12-31 23:59:59"; -- TEMPO DE EXECUCAO 0.36+7.79 SEGUNDOS

INFORMACAO IMPORTANTE

No MySQL, quando você envia uma consulta SQL, o otimizador de consulta tentará usar um plano de execução para rodar a querie da melhor forma possivel, ou seja com menor tempo possivel.
Para determinar o melhor plano possível, o otimizador de consulta utiliza muitos parâmetros. Um dos parâmetros mais importantes para escolher qual índice usar é a 
distribuição de chaves armazenadas (indices), também conhecida como cardinalidade.
A cardinalidade, no entanto, pode não ser precisa, por exemplo, caso a tabela tenha sido muito modificada com muitas inserções, atualizacoes ou exclusões e porque por padrao trabalha
com uma amostragem de 20% do valores totais das chaves nos indices, que pode ser alterado até 100%.
Para resolver esse problema, o MYSQL atualiza de forma automática as estatisticas, alguns segundos apos 10% dos dados de um indice ser alterado, 
ou voce pode executar a instrução ANALYZE TABLE de forma manual ou periodicamente, para o MYSQL ler as paginas dos indices e atualizar as estatisticas dos indices (cardinalidade). 
Iremos ver logo logo.

CUIDADO COM ISTO

O MYSQL fornece uma maneira alternativa, QUE EU NAO INDICO, que permite forçar os índices que o otimizador de consulta deve usar como vimos e que nao foi bom, porque o tempo aumentou em relacao ao full table scan.

O problema é que em quase 100% dos casos, o otimizador de querie está correto ao escolher o melhor plano, mas mesmo que voce force o uso de algum
indice e resolva naquele momento, pode ocorrer dos dados mudarem novamente, e o que estava bom, passar a ficar péssimo. O ideal é manter as estatisticas atualizadas o que é feito
de forma automatica pelo mysql de tempo em tempo, mas pode ocorrer uma massiva mudança nos dados da tabela, que náo foram ainda atualizados nas estatiticas dos indices, por exemplo
porque a quantidade de atualizacao bateu 9% dos dados e assim
o mysql selecionou nos proximos codigos sql executados um plano para atacar a query baseado em estatisticas desatualizadas. Isto parece pouco, mas 9% de mudanças em uma tabela com 
1 bilhao de linhas, pode gerar impactos nas proximas consultas e ai neste caso, pode ser interessante forcar a execucao manual de um ANALYZE TABLE.

-- ------------------------------------------


-- VAMOS VER OUTRO EXEMPLO DE CONVERSAO QUE PODE TRAZER IMPACTO NEGATIVO PARA A PERFORMANCE

SHOW INDEXES FROM users; -- vamos ver indices existentes, se existe um indice que vai nos auxiliar a buscas usuarios pelo id.

SELECT * FROM USERS WHERE ID = "944442";

SELECT * FROM USERS WHERE CONVERT(ID,CHAR) = "944442"; -- problema de conversoes a esquerda do sinal. O otimizador de queries do mysql nao consegue resolver e apontar um indice existente

SELECT * FROM USERS WHERE ID = CONVERT("944442",char); -- a direira sim.

-- Seria a mesma logica destes dois selects abaixo:

SELECT * FROM USERS WHERE ID+1 = 944442; -- nao existe indice criado com expressao id+1 entao o otimizador de querie nao consegue achar um indice que atenda, quando se coloca expressao ao lado esquerdo do sinal de comparacao.
SELECT * FROM USERS WHERE ID = 944440 + 1; -- mas aqui o otimizador consegue fazer o calculo matematico primeiro e com o resultado vai no indice.

--------------------------------------------------------------------

PODEMOS PROTEGER A UNICIDADE DOS DADOS SEM O USO DE CHAVE PRIMARIA ATRAVÉS DE ALGUM OUTRO INDICE? A RESPOSTA É UNIQUE Index

CREATE UNIQUE INDEX idx_displaynameUnico
ON users (displayname);  -- diferentente do sql server por exemplo, por projeto, o indice unique no mysql aceita mais de um valor null em linhas diferentes.

CREATE UNIQUE INDEX idx_displaynameUnico
ON users (displayname, location);  

CREATE UNIQUE INDEX idx_displaynameUnico
ON users (id);  -- criamos um indice unique non-clustered pelo campo id, mas neste caso não é necessário 
                 -- porque já existe o indice PRIMARY que faz o mesmo, mas é indice clustered e como é PRIMARY nao aceita valores nulos

SHOW INDEXES FROM users;

drop index idx_displaynameUnico on users;

SHOW INDEXES FROM users;

--------------------------------------------------------------------

INDICES DESCENDENTES NAO SAO NECESSÁRIOS 

select * from users where CreationDate  between "2013-01-01 00:00:00" and  "2013-12-31 23:59:59" order by CreationDate asc;
explain select * from users where CreationDate  between "2013-01-01 00:00:00" and  "2013-12-31 23:59:59" order by CreationDate asc;

select * from users where CreationDate  between "2013-01-01 00:00:00" and  "2013-12-31 23:59:59" order by CreationDate desc;
explain select * from users where CreationDate  between "2013-01-01 00:00:00" and  "2013-12-31 23:59:59" order by CreationDate desc;

create index teste on users (DownVote desc) -- desnecessário, e pode ser prejudicial para desempenho, pois mysql faz automatico; 

O MYSQL na atual versão vai utilizar o mesmo indice, então nao precisa criar um indice novo pelo mesmo campo em ordem descendente.

--------------------------------------------------------------------

Criando índices FULLTEXT para pesquisa de texto completo

O MySQL provê o mecanismo de índices fulltext, efetuando buscas textuais com maior precisão. Este recurso é mais poderoso que o uso de like, pois, 
além de ordenar o resultado pela similaridade semântica, oferece mais opções para filtragem na consulta.
Aplicações com grande massa de texto que precisam efetuar pesquisas baseadas na relevância são candidatas ao uso de índices fulltext. 
O exemplo mais comum são páginas de busca, que retornam os resultados mais relevantes na frente. 
Podemos destacar também bibliotecas virtuais, pesquisas em arquivos de registro ou pesquisas em documentos que estão armazenados no banco de dados.
Evite criar índices fulltext em tabelas que sofrerão alguma rotina de importação, pois a carga de registros com esse índice é mais lenta. 
O ideal é criar o índice depois que a importação for concluída. Para efetuar a pesquisa através de um índice fulltext utilizamos as funções MATCH e AGAINST, 
que recebem o nome dos campos e o valor a ser pesquisado, respectivamente. https://www.devmedia.com.br/indices-fulltext-no-mysql/7631

SHOW INDEXES FROM users;

Vamos criar um indice do tipo FULLTEXT no campo location

CREATE FULLTEXT INDEX idx_fulltextLocation
ON users(location); -- se aparecer esta mensagem, Lost connection to MySQL server during query, 
                                                               -- altere em edit, propriedades -> sql editor, a propriedade DBMS connection read timeout do workbench o tempo, 
                                                               -- deixando 0, para o comando nao cair por timeout.

Vamos criar um indice normal pelo mesmo campo 

CREATE  INDEX idx_UsersLocation
ON users(location);

SHOW INDEXES FROM users; -- vamos ver os dois indices e a cardinalidade dos mesmos. Repare que a cardinalidade do indice fulltext foi melhor do que o indice normal

Vamos fazer algumas buscas
select * from users where location = "United States"; -- qual indice foi usado, quantidade de leituras e tempo?

SELECT *
 FROM users
 WHERE MATCH (location) AGAINST ("United States"); -- qual indice foi usado, quantidade de leituras e tempo?

Por experiencia, a performance de indices normais são muito mais performaticos do que indice fulltext, que sao criados em arquivos a parte e acabam por onerar as buscas, alem de tornar
os inserts, updates e deletes ainda mais lentos do que no uso de indices normais.

MAS QUANDO PODER SER UTIL?

1. Quando por exemplo, se tem muitas buscas por substrings de campos, em tabelas muito grandes e precisa de respostas mais rapidas, do tipo:

select * from users where location LIKE "%United States%"; -- qual foi o indice usado e a quantidade de linhas lidas?

SELECT *
 FROM users
 WHERE MATCH (location) AGAINST ("New"); -- veja que leu muito menos linhas, mas rodou no tempo pior, devido a arquitetura do indice ser necessario ler um arquivo a parte da tabela
                                         -- e ter que ser feito um join depois com indice cluster para buscar outros dados, mas em tabela muito maiores podem ter performance melhor
                                         -- do que o indice normal, mas deve ser usado apenas quando realmente for necessario.

2. Quando quer fazer buscas por palavra em varios campos da tabela. Pode criar apenas 1 indice. Se fosse usar indices normais, teria que criar 1 indice composto ou varios indices
por cada campo.

Como exemplo, poderiamos criar um indice assim

CREATE FULLTEXT INDEX idx_fulltextLocationdisplayname
ON users(location, displayname); 

SELECT id, displayname, location
 FROM users
 WHERE MATCH (displayname, location) AGAINST ('TheJuice'); -- o mysql vai usar o indice forcado criado, buscando exatamente a palavra thejuice nas duas colunas

SELECT id, displayname, location
 FROM users
 WHERE MATCH (displayname, location) AGAINST ('New York, NY, United States'); -- o mysql vai usar o indice forcado criado, buscando exatamente a palavra New York, NY, United States nas duas colunas

 SELECT id, displayname, location
 FROM users
 WHERE  location  like '%New York, NY, United States%'; -- agora, se dermos a liberdade do otimizador escolher um plano, veja que neste caso, ele preferiu fazer full table do que usar index fulltext, ate porque so vai usar se usarmos os comandos acima.
                                                        -- mas para titulo de verificacao nem sempre é o ideal em termos de tempo, apesar de que a quantidade de leituras usando fulltext scan
                                                        -- foi menor, entao em uma tabela com centenas de milhoes de linhas, poderia ser mais performatico do que usar like %dado%, ainda mais
                                                        -- se precisar fazer buscas com like %dado% em varias colunas da mesma tabela buscando uma determinada informacao.

NOTA> EM ALGUMAS APLICACACOES, QUANDO TEM MUITAS COLUNAS E O PEDACO DO MESMO DADO, PODE ESTAR EM VARIAS COLUNAS, PODE SER UMA ESTRATEGIA INTERESSANTE, COMO POR EXEMPLO
EM UM BLOG QUE TEM CAMPO TITULO E DESCRICAO E NAO SABE ONDE BUSCAR A INFORMACAO.

3. Buscas por similaridade, provavelmente a maior vantagem

Para cada registro, o MySQL atribui um valor de relevância, que representa a similaridade da string de pesquisa com a linha em questão. 
Um valor de relevância 0 (zero) significa nenhuma semelhança, fazendo com que o registro não seja exibido. O cálculo de relevância é 
feito através de um algoritmo projetado para pesquisa em grandes massas de texto, tornando a busca inadequada para pequenas tabelas. 
Entre as variáveis que são levadas em consideração nesse cálculo, o MySQL considera o número de palavras encontradas em cada campo do índice, 
o número de palavras encontradas por linha, o número de ocorrências da mesma palavra em todas as linhas, entre outros. 

Agora vamos fazer as mesmas buscas, mas um pouco diferente>

SELECT id, displayname, location
 FROM users
 WHERE MATCH (displayname, location) AGAINST ('Nova York, NY, estados unidos'); 

 SELECT id, displayname, location
 FROM users
 WHERE  location  like '%Nova York, NY, estados unidos%'; 

SE QUISERMOS VER A PONTUACAO DADA PELA SIMILARIDADE, PODEMOS RODAR ASSIM>

SELECT displayname, location, MATCH (displayname, location) AGAINST ('Nova York, NY, estados unidos')
 FROM users
 WHERE MATCH (displayname, location) AGAINST ('Nova York, NY, estados unidos'); -- DADOS COM SIMILARIDADE ZERO NAO SERAO DEMONSTRADOS, QUANTO MAIOR O NUMERO, MAIS SIMILAR O ALGORITMO ENTENDEU E IRA DEVOLVER PRIMEIRO E ASSIM PODEREMOS 
                                                                                -- USAR ESTA ORDENACAO PARA POR EXEMPLO DEVOLVER OS RESULTADOS EM UM SITE DE BUSCA.

-- E SE QUISERMOS FILTRAR PELO VALOR DA RELEVANCIA...

SELECT displayname, location, MATCH (displayname, location) AGAINST ('Nova York, NY, estados unidos')
 FROM users
 WHERE MATCH (displayname, location) AGAINST ('Nova York, NY, estados unidos')
 and MATCH (displayname, location) > 43 ; -- ERRO DE SINTAXE. COMO DESCOBRIR A CAUSA DO ERRO...

SELECT displayname, location, MATCH (displayname, location) AGAINST ('Nova York, NY, estados unidos') as relevancia
 FROM users
 WHERE MATCH (displayname, location) AGAINST ('Nova York, NY, estados unidos')
 LIMIT 10;  -- UMA SOLUCAO PALEATIVA, CHAMADA WORKAROUND OU NO POPULAR GAMBIARRA OU GAMBI, MAS NAO EH O IDEAL
 
 SELECT displayname, location, MATCH (displayname, location) AGAINST ('Nova York, NY, estados unidos') as relevancia
 FROM users
 WHERE MATCH (displayname, location) AGAINST ('Nova York, NY, estados unidos') > 13;  -- MAIS SIMPLES QUE IMAGINEI

-- ------------------------------

-- MATCH vs LIKE
Diversos aspectos diferenciam o mecanismo de MATCH do uso de LIKE. Vejamos:

1. O comando MATCH é mais veloz EM TABELAS COM MILHOES DE LINHAS, tendo em vista a indexação de cada palavra do campo que faz parte do índice fulltext.
2. A pesquisa fulltext foi criada com o objetivo de fornecer uma busca semântica em bases que contenham muito texto. Dessa forma, o MySQL desconsidera 
   palavras com menos de quatro caracteres. Expressões como “de”, “que” e “ou” são excluídas automaticamente da pesquisa. 
   Esta restrição é justificável na maioria dos casos, dada a baixa seletividade destas palavras em pesquisas textuais.
3. Uma palavra presente em mais de 50% dos registros será excluída da pesquisa, pois o MySQL considera sua relevância baixa.


Executando pesquisas fulltext em modo booleano

A partir da versão 4.0.1, o MySQL disponibiliza o recurso de pesquisa fulltext com parâmetros booleanos, aumentando significativamente o poder na construção de filtragens de texto.

A pesquisa booleana tem como base a manipulação de strings de acordo com alguns operadores. Veja a lista dos operadores disponíveis:

+ : a string deve estar presente em todos os registros retornados;

- : a string não deve estar presente nos registros retornados;

*: trabalha com parte da palavra a ser procurada;

“ ”: retorna a string entre aspas duplas exatamente da maneira como foi digitada;

( ): Agrupa palavras em sub-expressões;

< >: Muda a contribuição da string no cálculo da relevância. O operador < decrementa a relevância e o operador > aumenta a relevância;

~ : age como operador de negação. A contribuição de relevância da string se torna negativa.

NOTA: A pesquisa booleana desconsidera o filtro de 4 letras mínimas e de 50% de ocorrência no resultado. Portanto, se você precisa de uma busca que não leve em consideração essas restrições, utilize o modo booleano.

Veja alguns exemplos:

SELECT id, displayname, location
 FROM users
 WHERE MATCH (displayname, location) 
AGAINST ('+NEW -ESTADOS UNIDOS' IN BOOLEAN MODE);

VEJA A DIFERENCA

SELECT displayname, location
 FROM users
 WHERE MATCH (displayname, location) AGAINST ('New, NY, estados unidos');

Outro exemplo, se quisermos trazer registros que um dos campos do indice fulltext comecem com uma substring

SELECT id, displayname, location
 FROM users
 WHERE MATCH (displayname, location) 
AGAINST ('Flor*' IN BOOLEAN MODE); -- role a tela e veja que tem locations florida e pessoa Florian que esta no campo displayname

Outro exemplo se quisermos trazer apenas os registros que bata com a sequencia buscada, mas podendo trazer linhas a mais, se tiver valores antes ou depois do buscado.

SELECT id, displayname, location
 FROM users
 WHERE MATCH (displayname, location) 
 AGAINST ('"London, United Kingdom"' IN BOOLEAN MODE);

Resumo das características da pesquisa fulltext:

Desconsidera palavras com menos de quatro caracteres, caso IN BOOLEAN MODE não seja utilizado;
Desconsidera palavras presentes em mais de 50% dos registros, caso IN BOOLEAN MODE não seja utilizado;
É indicada para tabelas textuais grandes, contendo milhoes de registros;
Palavras hifenizadas são tratadas em separado. Por exemplo, em azul-celeste, o mecanismo busca pela ocorrência de azul e/ou celeste;
Por default, os registros são retornados por ordem descendente de relevância;
A pesquisa é case-insensitive (por exemplo, não há diferença entre “Server” ou “server”);
Uso de várias opções de operadores booleanos;
Melhor performance que o operador like;
A pesquisa em modo booleano também pode funcionar sem a existência de um índice fulltext. A performance, no entanto, será menor.

Algumas limitações do mecanismo de pesquisa:

- A criação deste tipo de índice causa uma queda no desempenho de operações INSERT e UPDATE. A perda é maior se comparada com o uso de índices comuns sobre colunas texto e mais explícita quando temos tabelas muito grandes.
- O parâmetro utilizado em AGAINST( ) deve ser do tipo string;

SHOW INDEXES FROM users;

-- Para deletar os indices criados

DROP INDEX idx_UsersLocation on users;
DROP INDEX idx_fulltextLocation on users;
DROP INDEX idx_fulltextLocationdisplayname on users;

SHOW INDEXES FROM users;

--------------------------------------------------------------------

Curso MYSQL Completo
Instrutor: Sandro Servino
https://www.linkedin.com/in/sandroservino/?originalSubdomain=pt
https://www.udemy.com/user/sandro-servino-3/

PERFORMANCE - ESTATISTICAS DOS INDICES

ANALYZE TABLE (atualizacao das estatisticas dos indices-cardinalidade)

No MySQL, quando você envia uma consulta SQL, o otimizador de consulta tentará usar um plano de execução para rodar a querie da melhor forma possivel, ou seja com menor tempo possivel.
Para determinar o melhor plano possível, o otimizador de consulta utiliza muitos parâmetros. Um dos parâmetros mais importantes para escolher qual índice usar é a 
distribuição de chaves armazenadas (indices), também conhecida como cardinalidade.
A cardinalidade, no entanto, pode não refletir exatamente a realidade dos dados de uma tabela, por exemplo, caso a tabela tenha sido muito modificada com muitas inserções, 
atualizacoes ou exclusões e porque por padrao trabalha
com uma amostragem de 20% doS valores totais das chaves nos indices, mas que podemos alterar este padrão até 100%.
Para resolver esse problema, o MYSQL atualiza de forma automática as estatisticas, alguns segundos após, em média, 10% dos dados de um indice ser alterado.
ou voce pode executar a instrução ANALYZE TABLE de forma manual ou periodicamente, para o MYSQL ler as paginas dos indices e atualizar as estatisticas dos indices (cardinalidade)
imediatamente. 

DICA: PARA QUEM TRABALHA COM SQL SERVER, É O FAMOSO COMANDO UPDATE STATISTICS


CONCEITOS IMPORTANTES PARA ENTENDER

1. ANALYZE TABLE executa uma análise randomica da distribuição de chaves dos indices (campos) e armazena a distribuição em 8 paginas de 16kb, em objetos de controle interno, em um espaço 
na memória (buffer pool) ou no disco (persinstencia fisica), se alterar uma configuracao.

2. Durante esta análise, a tabela é bloqueada, DEVIDO AO ANALYZE TABLE, com um bloqueio de leitura, geralmente por poucos segundos, mas pode demorar mais tempo, 
  dependendo da velocidade do disco, se tiver outro processo encadeado de ANALYZE TABLE rodando na mesma tabela que nao terminou, se a tabela está bloqueada por um outro processo, 
  e se principalmente alterou o padrao da configuracao que faz leitura em 20% das paginas de indices para por exemplo 100%. 
  As paginas de indices tem 16kb. A pagina de dados tambem tem 16kb. O padrao por exemplo do SQL SERVER é 8kb.

3. Se a tabela não tiver sido alterada desde a última análise de distribuição de chaves, a tabela não será analisada novamente.
  
  AQUI UM DETALHE:

  A partir do MySQL 5.6, o tamanho da página de uma InnoDB instância pode ser 4 KB, 8 KB ou 16 KB, controlado pela opção innodb_page_size. 
  A partir do MySQL 5.7.6, InnoDB também suporta tamanhos de página de 32 KB e 64 KB. 
  
  ATENCAO: Tamanhos de página menores podem ajudar no desempenho com dispositivos de armazenamento que usam tamanhos de bloco pequenos, principalmente para 
  dispositivos SSD em cargas de trabalho vinculadas a disco, como para aplicativos OLTP. À medida que as linhas individuais são atualizadas, menos dados são copiados 
  para a memória, gravados em disco, reorganizados, bloqueados e assim por diante, como exemplo é mais rápido e irá ter menos bloqueios ler 8 paginas de 8kb do que 8 paginas de 16kb,
  mas como näo é executado a atualizacao das estatisticas muitas vezes, apenas quando em média ao menos 10% dos dados são alterados e a quantidade de kbytes é muito pequena, não
  terá em média melhorias ou pioras visiveis, mas se desejar:
  
  FAÇA UM TESTE EM AMBIENTE DE QA, ALTERE A CONFIGURACAO PARA 8KB E REALIZAR SIMULACOES DE CARGA E EM PARALELO REALIZE TESTES COM INSERT, DELETE E UPDATES. IREMOS FAZER UM 
  TESTE SIMULADO COM O PADRAO DE 8 PAGINAS COM 16K. MARQUE SEUS TEMPOS, VEJA OS BLOQUEIOS, DEPOIS ALTERE AS CONFIGURACOES PARA 8 PAGINAS DE 16K, ATE 20 PAGINAS DE 64KB QUE 
  NESTE CASO O MYSQL GUARDARÁ AS ESTATISTICAS NO DISCO.

4. Se a tabela não tiver sido alterada desde a última análise de distribuição de chaves, a tabela não será analisada novamente, EVITANDO BLOQUEADOS DESNECESSARIOS

5. Para tabelas InnoDB, ANALYZE TABLE determina a cardinalidade do índice realizando mergulhos aleatórios em cada uma das árvores do índice e atualiza as estatisticas
de cardinalidade de cada índice. Como essas são apenas estimativas, execuções repetidas ANALYZE TABLE podem produzir números diferentes, dependendo de onde buscou os dados nas paginas dos indices.
Isso torna o pocesso de analise mais rapido, porque por padrao ira ler 20% das paginas de indices para criar as estatisticas, 
mas não 100%, pois não leva em consideração todas as linhas. ISTO PODE SER ALTERADO NO MY.INI, mas tem impactos em termos de tempo e bloqueios, se a tabela for muito grande.

6. Você pode tornar as estatísticas coletadas por ANALYZE TABLE mais precisas e mais estáveis ​​habilitando 
a opcao innodb_stats_persistent no my.ini. 

Com esta configuracao ativada
as estatisticas ficarão em arquivos no disco, e guardara 20 paginas de 16kb, e nao seráo perdidos quando o mysql dar restart, diferente do padrao, que guarda apenas em 
memoria 8 paginas de 16kb, mas que sao perdidas e sao carregadas apenas quando os novos selects por exemplo sao executados, o que na primeira busca dos usuarios podem ficar mais lentos
por que o otimizador de querie tera que ler os indices para criar as estatisticas e na primeira vez vai demorar mais. 

   6.1 Se innodb_stats_persistent estiver ativado, você pode alterar o número de mergulhos aleatórios modificando a variável do sistema innodb_stats_persistent_sample_pages. 
      Poderá por exemplo modificar para 100, o que significa que lerá 100% de todas as paginas dos indices para criar as estatisticas, o que deixara o otimizador de querie
      preparado para usar o melhor plano possivel, o melhor indice criado ou full table scan, porque terá uma visão ESTATISTICA MELHOR dos dados armazenados nas tabelas, 
      MAS POR OUTRO LADO DEIXARÁ O PROCESSO MAIS LENTO, PODENDO TRAZER TRANSTORNOS DE LOCK NAS TABELAS GRANDES POR MAIS TEMPO, QUANDO O PROCESSO ESTIVER RODANDO.
   6.2 O ideal é usar o comando EXPLAIN para verificar a precisão das estatísticas comparando a cardinalidade real de um índice com as estimativas. Ja vimos isto. 
       Se o numero for X10 para mais ou menos, rode novamente o ANALYZE TABLE porque pode estar desatualizado e se mantendo, tente mudar a opcao innodb_stats_persistent_sample_pages
       para valores superiores a 20 e rode novamente o ANALYZE TABLE para verificar se houve melhoras entre o real e o estimado.
   6.3 Se o ANALYZE TABLE estiver muito lento. Neste caso innodb_stats_persistent_sample_pages deve ser diminuído até que o tempo de execução do ANALYZE TABLE seja aceitável. 
       Diminuir muito o valor, no entanto, pode levar ao primeiro problema de estatísticas imprecisas e planos de execução de consulta abaixo do ideal.


7. Se quiser ver a estatistica dos indices, para ver a cardinalidade de cada indice de uma tabela, rode:
SHOW INDEX
  FROM USERS
  FROM STACKOVERFLOW;

Quanto maior a cardinalidade, melhor, mais selectivo será o indice e provavelmente será usado pelo otimizador de queries. Olha o exemplo da chave primaria
frente a quantidade de linhas da tabela users.

8. Quando um índice é adicionado a uma tabela existente, ou quando uma coluna é adicionada ou eliminada, as estatísticas de índice são calculadas.

9. Quando os indice sao reconstruidos, as estatisticas sao refeitas

10. A tabela innodb_table_stats inclue uma coluna que mostra quando as estatísticas de índice foram atualizadas pela última vez:
FIQUE ESPERTO COM TABELAS GRANDE QUE VOCE SABE QUE TEM MUITA ALTERACAO, MAS COM DATAS ANTIGAS DE ATUALIZACAO DAS ESTATISTICAS

SELECT * FROM mysql.innodb_table_stats;

-------------------------------------

INFORMACAO IMPORTANTE:
As estatísticas do otimizador são mantidas no disco quando innodb_stats_persistent=ON (default na atual versao mysql).

Anteriormente, as estatísticas do otimizador eram apagadas ao reiniciar o servidor e após alguns outros tipos de operações, 
e recalculadas no próximo acesso à tabela. Conseqüentemente, diferentes estimativas podem ser produzidas ao recalcular estatísticas 
levando a diferentes escolhas nos planos de execução de consulta e variação no desempenho da consulta. Se alterar para OFF, a cada restart do mysql
as estatisticas serão novamente carregadas nas execucoes dos comandos, independente de os dados nao terem sido mais de 10% alterados.

A option innodb_stats_auto_recalc é habilitada por padrão, controla se as estatísticas são calculadas automaticamente 
quando uma tabela sofre alterações em mais de 10% de suas linhas, para desligar deve configurar no my.ini innodb_stats_auto_recalc=off, 
mas ai teria que ficar rodando de forma manual o ANALYZE TABLE.

--------------------------------------

11. Se quiser ver todas as estatisticas dos indices e a cardinalidade de cada estatistica de cada indice.

SELECT database_name,table_name, index_name, stat_name, stat_value, stat_description
       FROM mysql.innodb_index_stats WHERE table_name like 'users' AND database_name like 'stackoverflow' ;


12. Se quiser verificar o tamanho de cada indice em uma tabela, incluindo os fulltextindex

FTS_DOC_ID_INDEX significa index fulltext

  SELECT SUM(stat_value) pages, index_name,
       SUM(stat_value)*@@innodb_page_size size
       FROM mysql.innodb_index_stats WHERE (table_name like 'users' AND database_name like 'stackoverflow' )
       AND stat_name = 'size' GROUP BY index_name;

O numero está em bytes

Cuidado com a quantidade de indices que tem em cada tabela e numero de colunas por indice.
Cuidado com PK com muitos campos
Cuidado com indices com campo text ou char ou vchar com uma grande quantidade de caracteres
Cuidado quando passa de mais de 5 indices em tabelas com centenas de milhares de linhas e com indices com mais de 5 colunas, pois poderá ter impactos
nos inserts, updates, e deletes, no tempo do backup e restore, na checagem de integridade das tabelas, no custo de armazenamento na nuvem, no tempo de atualizacao das estatisticas
gerando mais lock, no tempo de reconstrucao dos indices e lembre-se que os indices tambem ocupam espaco da memoria (buffer cache) muitas vezes fazendo o mysql remover dados
da memoria, o que vai levar a mais leitura no disco, deixando seu sistema mais lento.

-- -------------------------

VAMOS AO LAB

ABRA UM WORKBENCH, SELECIONE TODOS OS COMANDOS ABAIXO E RODE:

SELECT * FROM USERS ORDER BY DISPLAYNAME;
SELECT * FROM USERS ORDER BY ID;
SELECT * FROM USERS ORDER BY DISPLAYNAME;
SELECT * FROM USERS ORDER BY ID;
SELECT * FROM USERS ORDER BY DISPLAYNAME;
SELECT * FROM USERS ORDER BY ID;
SELECT * FROM USERS ORDER BY DISPLAYNAME;
SELECT * FROM USERS ORDER BY ID;
SELECT * FROM USERS ORDER BY DISPLAYNAME;
SELECT * FROM USERS ORDER BY ID;
SELECT * FROM USERS ORDER BY DISPLAYNAME;
SELECT * FROM USERS ORDER BY ID;
SELECT * FROM USERS ORDER BY DISPLAYNAME;
SELECT * FROM USERS ORDER BY ID;
SELECT * FROM USERS ORDER BY DISPLAYNAME;
SELECT * FROM USERS ORDER BY ID;
SELECT * FROM USERS ORDER BY DISPLAYNAME;
SELECT * FROM USERS ORDER BY ID;
SELECT * FROM USERS ORDER BY DISPLAYNAME;
SELECT * FROM USERS ORDER BY ID;
SELECT * FROM USERS ORDER BY DISPLAYNAME;
SELECT * FROM USERS ORDER BY ID;
SELECT * FROM USERS ORDER BY DISPLAYNAME;
SELECT * FROM USERS ORDER BY ID;
SELECT * FROM USERS ORDER BY DISPLAYNAME;
SELECT * FROM USERS ORDER BY ID;
SELECT * FROM USERS ORDER BY DISPLAYNAME;
SELECT * FROM USERS ORDER BY ID;
SELECT * FROM USERS ORDER BY DISPLAYNAME;
SELECT * FROM USERS ORDER BY ID;
SELECT * FROM USERS ORDER BY DISPLAYNAME;
SELECT * FROM USERS ORDER BY ID;

E NO OUTRO WORKBENCH RODE:

SELECT  * FROM USERS WHERE ID <> 1;
SELECT  * FROM USERS WHERE ID <> 2;
SELECT  * FROM USERS WHERE ID <> 3;
SELECT  * FROM USERS WHERE ID <> 4;
SELECT  * FROM USERS WHERE ID <> 5;
SELECT  * FROM USERS WHERE ID <> 6;
SELECT  * FROM USERS WHERE ID <> 7;
SELECT  * FROM USERS WHERE ID <> 8;
SELECT  * FROM USERS WHERE ID <> 9;
SELECT  * FROM USERS WHERE ID <> 10;

E EM OUTRO WORKBENCH RODE O COMANDO ABAIXO PARA VER OS PROCESOS QUE ESTAO RODANDO.
show processlist;

E NO OUTRO WORKBENCH, RODA OS COMANDOS ABAIXO PARA ATUALIZAR AS ESTATISTICAS DOS INDICES DA TABELA USERS. ESTOU FORCANDO RODAR VARIAS VEZES. POR PADRAO O MYSQL VAI LER 20% DAS PAGINAS DOS INDICES
PARA ATUALIZAR A INFORMACAO SOBRE A CARDINALIDADE DE CADA INDICE, NA ESTATISTICA DOS INDICES. 
POR PADRAO O INNODB GUARDA AS ESTATISTICAS EM 8 PAGINAS DE 16K EM MEMORIA DO SERVER, MAS PODE MUDAR
PARA SER PERSISTENTE NO DISCO PARA NAO PERDER QUANDO O MYSQL FOR REINICIADO E ASSIM IRA GUARDAR 20 PAGINAS DE 16KB NO DISCO, SO QUE IRIA DEMORAR AINDA MAIS PARA LER E IRIA GERAR
MAIS PROBLEMAS DE I/O NO DISCO, E MAIS TEMPO DE LOCK, MAS AS ESTATISTICAS SERIAM MAIS ACURADAS SE OS INDICES TIVEREM DADOS MUITO IRREGULARES, POIS MOSTRARIA COM MAIS PRECISAO COMO OS DADOS ESTAO, PORQUE AINDA ASSIM 
ESTARIA LIMITADO EM 20 PAGINAS DE 16 KB NO DISCO, E NAO UMA 
AMOSTRAGEM DE 20% GUARDADOS EM 8 PAGINAS DE 16KB QUE PODE SER AUMENTADO ATE 64KB, PORQUE SEMPRE QUE RODA, PODERIA PEGAR UMA PARTE DOS DADOS DOS INDICES QUE NAO REFLETE A REALIDADE DA TABELA, E ASSIM O PLANO PODERIA ESCOLHER UM INDICE
NAO TAO BOM, PARA RESOLVER UMA QUERY. TENTE BALANCEAR ESTE PERCENTUAL DE LEITURA DAS PAGINAS DOS INDICES DE ACORDO COM A SUA NECESSIDADE E VEJA, SE NAO É MELHOR DESLIGAR
O ANALYZE TABLE AUTOMATICO (que nao indico) QUE É FEITO QUANDO HA UMA MUDANÇA DE MAIS DE 10% DOS DADOS, PARA SER FEITO DE FORMA AGENDADA, ATRAVES DE CRIACAO DE EVENTOS QUE JA VIMOS, EM UM HORARIO
DE BAIXO USO, NO FINAL DE SEMANA, SE POSSIVEL.

ANALYZE TABLE USERS;
ANALYZE TABLE USERS;
ANALYZE TABLE USERS;
ANALYZE TABLE USERS;
ANALYZE TABLE USERS;
ANALYZE TABLE USERS;
ANALYZE TABLE USERS;
ANALYZE TABLE USERS;
ANALYZE TABLE USERS;
ANALYZE TABLE USERS;
ANALYZE TABLE USERS;
ANALYZE TABLE USERS;
ANALYZE TABLE USERS;
ANALYZE TABLE USERS;
ANALYZE TABLE USERS;
ANALYZE TABLE USERS;
ANALYZE TABLE USERS;
ANALYZE TABLE USERS;
ANALYZE TABLE USERS;
ANALYZE TABLE USERS;
ANALYZE TABLE USERS;
ANALYZE TABLE USERS;
ANALYZE TABLE USERS;
ANALYZE TABLE USERS;
ANALYZE TABLE USERS;
ANALYZE TABLE USERS;
ANALYZE TABLE USERS;
ANALYZE TABLE USERS;
ANALYZE TABLE USERS;
ANALYZE TABLE USERS;
ANALYZE TABLE USERS;
ANALYZE TABLE USERS;
ANALYZE TABLE USERS;
ANALYZE TABLE USERS;
ANALYZE TABLE USERS;
ANALYZE TABLE USERS;
ANALYZE TABLE USERS;
ANALYZE TABLE USERS;
ANALYZE TABLE USERS;
ANALYZE TABLE USERS;
ANALYZE TABLE USERS;
ANALYZE TABLE USERS;
ANALYZE TABLE USERS;
ANALYZE TABLE USERS;
ANALYZE TABLE USERS;
ANALYZE TABLE USERS;
ANALYZE TABLE USERS;
ANALYZE TABLE USERS;

AGORA RETORNE A ABA PARA VER OS PROCESSOS NOVAMENTE, REPARE QUE AGORA OS OUTROS COMANDOS ESTAO DEMORANDO MAIS PARA TERMINAREM PORQUE A TABELA ESTA SENDO BLOQUEADA PARA 
ALIMENTAR AS ESTATISTICAS, ENTAO CUIDADO COM A QUANTIDADE DE VEZES QUE ATUALIZA AS ESTATISTICAS EM TABELAS GRANDES, EM HORARIO COMERCIAL, E SE MUDAR PARA LER TODA AS PAGINAS
DOS INDICES AO INVES DE APENAS 20%

E EM OUTRO WORKBENCH RODE
show processlist;

Como matar um dos processos listados

Transact-SQL
kill <id> -- ENTAO VEJA QUAL O ID DO PROCESSO DO ANALYZE TABELA E DE UM KILL NESTE PROCESSO, E VEJA COMO OS COMANDOS VAO COMECAR A RODAR MAIS RAPIDOS.

Você deve substituir o <id> pelo número exibido na coluna ID.
o MySQL não possui opção de matar processos em massa/lote. Para fazer isso, você vai ter que fazer algum script que execute os comandos kill individualmente.

-- -------------------

SE QUISER AGENDAR A ATUALIZACAO DAS ESTATISTICAS VIA EVENTO

delimiter $$
CREATE EVENT ATUALIZAESTATISTICASAGORA
    ON SCHEDULE 
    AT CURRENT_TIMESTAMP
    DO
      BEGIN
         ANALYZE TABLE USERS;
         -- ANALYZE TABLE TABELAX; -- AQUI POSSO COLOCAR VARIAS TABELAS PARA SER ATUALIZADOS TODAS AS ESTATISTICAS DE TODOS OS INDICES DA TABELAX
         -- ANALYZE TABLE TABELAY;
      END $$
delimiter ;

-- E VAMOS VER O EVENTO
SHOW EVENTS FROM STACKOVERFLOW; -- repare nas colunas

-- --------------------------------------

-- E SE POR EXEMPLO QUISERMOS ATUALIZAR AS ESTATISTICAS A CADA 2 SEMANAS.

delimiter $$
CREATE EVENT ATUALIZADAESTATISTICASACADA2SEMANAS
    ON SCHEDULE EVERY 2 WEEK
    STARTS '2022-05-30'
    ENDS  '2022-06-30' -- PODERIAMOS COLOCAR AINDA UMA DATA PARA O EVENTO PARAR DE RODAR, E SE NAO COLOCAR RODA POR TEMPO INDEFINIDO
    DO
     BEGIN
		ANALYZE TABLE USERS;
		-- ANALYZE TABLE TABELAX; -- AQUI POSSO COLOCAR VARIAS TABELAS PARA SER ATUALIZADOS TODAS AS ESTATISTICAS DE TODOS OS INDICES DA TABELAX
		-- ANALYZE TABLE TABELAY;
     END $$
delimiter ;

-- E VAMOS VER O EVENTO
SHOW EVENTS FROM STACKOVERFLOW; -- repare nas colunas


------------------------------------------------------------------------------------------------------------------------------

OTIMIZANDO TABELAS E INDICES.

OPTIMIZE TABLE 

ALGUMS CONCEITOS

Se o seu aplicativo estiver executando muitas exclusões (delete em grandes blocos) no banco de dados MySQL, há uma grande possibilidade de que seus arquivos de dados MySQL estejam fragmentados.
Isso resultará em muito espaço não utilizado e também poderá afetar o desempenho. Quando voce realiza muitos updates, o que é normal, ou mesmo deletes pontuais normais dentro
de um sistema OLTP, espacos alocados mas não utilizados acabam sendo preenchidos com tempo com novos inserts ou updates.

A otimização de tabelas MySQL ajuda a reordenar as informações em discos dedicados para os bancos de dados que estao no MYSQL 
visando melhorar as velocidades de entrada e saída de dados. 
No entanto, saber quando realizar esta operacao é a chave para uma manutenção viável da tabela, sem impactar a producao (exclusive lock, I/O e CPU)
e quando vale a pena, para trazermos ganhos nas operacoes.

-- ENTÃO, COMO FAZER?

1. OPTIMIZE TABLE reorganiza o armazenamento físico de dados de tabela e índices associados, com a redução do espaço de armazenamento e desfragmentacao dos arquivos referentes as tabelas em disco, 
melhorando assim eficiência de E/S ao acessar a tabela. 

2. A reconstrução da tabela acionada por OPTIMIZE TABLE realiza um bloqueio de tabela exclusivo, que pode levar segundos, minutos ou horas dependendo da concorrencia e o tamanho, 
   porque por exemplo uma tabela com tecnologia 
   innodb, que está passando por este processo, tem seus dados exportados para uma nova tabela nova e no final do processo a tabela original é excluida e a nova tabela
   está desfragmentada e sem dados não alocados, e assim a tendencia que a nova tabela seja bem menor.

3. Após realizar operações com grande quantidade de exclusões em uma tabela InnoDB que possui seu próprio arquivo .ibd, porque foi criada com a innodb_file_per_table
  opção padrao habilitada, podemos de forma manual, ou agendada executar este comando, preferencialmente fora do horario comercial, se possivel para
  realizar a otimizacao desta tabela e assim termos ganhos de performance no acesso, porque se agendar para fazer esta operacao, em uma grande tabela em horario comercial
  poderá ter indisponibilidade de funcionalidades de um sistemas por horas, porque a tabela estará em exclusive lock, enquanto o processo estiver rodando.
  
  Ainda, quando a tabela e os índices são reorganizados, em muitos casos, principalmente após grandes processos de delecao de dados de uma tabela, com a execucao do comando OPTIMIZE TABLE,
  o espaço em disco é recuperado para uso pelo sistema operacional, desfragmentadas as paginas dos dados e indices com espacos alocados para mysql mas nao usados efetivamente, de
  forma logica nas tabelas internas de controle e fisica no file da tabela no disco e assim
  temos ganhos em termos de performance das queries, backup, restore e controle de custos de armazenamento, principalmente em ambiente de nuvem.

4. A execucao do comando OPTIMIZE TABLE atualiza as estatísticas dos índices e liberar espaço não utilizado no índice clusterizado e demais indices.

5. Algum nível de fragmentação é esperado. InnoDB preenche apenas 93% das páginas, para deixar espaço para atualizações sem precisar dividir (split) as páginas.

6. Grandes operações de exclusão deixam lacunas nas páginas de dados e indices, e os dados podem ficar desframentados no disco, o que pode valer a pena otimizar a tabela.

7. Antes de executar esta operacao, tente verificar com seus usuarios ou mesmo buscar informacoes no log das queries que demoram mais a rodar, se existe
oportunidade de melhorar os codigos SQL e/ou criar um novo indice e/ou atualizar alguma estatistica nao atualizada. Após, verifique as maiores tabelas que tiveram muitos dados
deletados e que são fonte de reclamacao do usuário e verifique em ambiente de QA se organizar a tabela e seus indices, trará melhorias na performance. 
Caso a resposta seja positiva, ja agende para horario com menos acesso para reorganizar a tabela e os indices da mesma, e lembre de fazer backup antes de iniciar a operacao, 
porque o processo deleta a tabela e recria.

9. A tabela de otimização pode ser executada para o mecanismo InnoDB e mecanismo MyISAM.

VAMOS AO LABORATORIO

LAB1

0 FACA BACKUP ANTES DO BANCO

1.0 Vamos encontrar tabelas para otimização. 
    show table status like "users" ;
    -- ANALYZE TABLE users; se a quantidade de linhas estiver desatualizada quando rodar o show table, rode esse comando para atualizar as estatisticas

   Data_length representa a quantidade aproximada de espaço em bytes que o indice clustered da tabela users ocupa no total. 
   No caso 45.678.592, aproximadamente 43 MB

   e Index_Length representa a quantidade aproximada de espaço em bytes dos indices non-clustered da tabela users ocupa no total.
   No caso 104.562.688, aproximadamente 99 MB

   e data_free 4.1943.04 (O número de bytes alocados, mas não utilizados).

Para verificar estes dados para todas as tabelas em um esquema selecionado, execute:
  
  select table_name, data_length, Index_Length, data_free
     from information_schema.tables
       where table_schema='stackoverflow'
         order by data_free desc;

Se quiser verificar a mesma informacao em MB

select table_name, round(data_length/1024/1024), round(Index_Length/1024/1024), round(data_free/1024/1024)
from information_schema.tables
where table_schema='stackoverflow'
order by data_free desc;


1.1 VAMOS VERIFICAR OS FILES DAS TABELAS NO DISCO. GUARDE O TAMANHO DE CADA ARQUIVO.
D:\MYSQL_CURSO\Data\stackoverflow
users.ibd
155 MB

1.2 Vamos rodar este comando para ver quantas linhas existe na tabelas users
  SELECT count(*) from users;
  -- 635.560
  -- Tempo de 5,51 segundos
  SELECT count(*) from users where id > 300000;
  -- 527.530
  -- Tempo de 1,72 segundos
  
1.3 Vamos rodar este comando para verificarmos o tamanho dos indices
  SELECT SUM(stat_value) pages, index_name,
       SUM(stat_value)*@@innodb_page_size size
       FROM mysql.innodb_index_stats WHERE (table_name like 'users' AND database_name like 'stackoverflow' )
       AND stat_name = 'size' GROUP BY index_name;

1.3.1 Se quisermos ver apenas o tamanho em bytes de todos os indices da tabela, incluindo PK (indice clustered) e FullText indice.
          
       SELECT SUM(stat_value)*@@innodb_page_size size
       FROM mysql.innodb_index_stats WHERE (table_name like 'users' AND database_name like 'stackoverflow' )
       AND stat_name = 'size' ;

      -- 150.241.280 bytes.

1.4 Vamos deletar estas linhas
     delete from users where id > 300000;

-- so por curiosidade, se quiser deletar uma tabela inteira, muito mais rapido, use:
-- TRUNCATE TABLE nomedatabela; -- mas aqui nao pode usar where

Quando terminar de deletar, apenas para confirmar, rode:

ANALYZE TABLE users; -- para forcar a atualizacao das estatisticas de forma imediata

SELECT count(*) from users;
-- 108.030 linhas 
-- Tempo de 68 segundos -- piorou bastante os tempos depois que deletei a maioria dos dados

SELECT count(*) from users where id > 300000;

-- o linhas
-- Tempo de 19 segundos -- piorou bastante os tempos depois que deletei a maioria dos dados

1.5 Vamos rodar este comando para verificarmos o tamanho dos indices
  SELECT SUM(stat_value) pages, index_name,
       SUM(stat_value)*@@innodb_page_size size
       FROM mysql.innodb_index_stats WHERE (table_name like 'users' AND database_name like 'stackoverflow' )
       AND stat_name = 'size' GROUP BY index_name;

         SELECT 
       SUM(stat_value)*@@innodb_page_size size
       FROM mysql.innodb_index_stats WHERE (table_name like 'users' AND database_name like 'stackoverflow' )
       AND stat_name = 'size' ;

-- 147.898.368 -- nao mudou muita coisa, em termos do tamanho de nenhum indice da tabela ou mesmo da pk (indice clustered), index fulltext, depois que deletamos mais de 500.000 linhas da tabela

1.6 VAMOS VERIFICAR OS FILES DAS TABELAS NO DISCO. GUARDE O TAMANHO DE CADA ARQUIVO.
users.ibd
152MB  -- nenhuma reducao fisica

Nao mudou nada no tamanho do file referente a tabela users.

1.7 E FINALMENTE...

rode...

OPTIMIZE TABLE users;  -- REPARE QUE O TEMPO É MAIOR

1.7.1 Enquanto está rodando, abre dois novos workbenchs e execute em um deles select * from users; e no outro workbench execute show processlist;

APARECEU MENSAGEM Table does not support optimize, doing recreate + analyze instead
DEVO ME PREOCUPAR? NÃO, APENAS UMA INDICACAO QUE EM TABELAS COM TECNOLOGIA INOODB NAO REALIZA A OTIMIZACAO, MAS SIM CRIA UMA TABELA NOVA E IMPORTA OS DADOS, DE FORMA
DESFRAGMENTADA, ELIMINANDO ESPACOS NAO ALOCADOS, REDUZINDO ASSIM O TAMANHO DO ARQUIVO FINAL.

NA VERDADE, O InnoDB não suporta o OPTIMIZE da mesma forma que o MyISAM. Faz algo diferente. Ele cria uma tabela vazia (usa ALTER TABLE)
 e copia todas as linhas da tabela existente para ela e, essencialmente, exclui a tabela antiga e renomeia a nova tabela e, em seguida, executa um ANALYZE para coletar estatísticas. 
Isso é o mais próximo que o InnoDB pode chegar de um OPTIMIZE.

O MySQL oficialmente recomenda não desfragmentar com freqüência (de hora em hora ou diariamente). 
Geralmente, de acordo com a situação real, você só precisa organizá-lo quando for necessário no meu ponto de vista, e deve ser avaliado e testado em QA. Quando for fazer 
em producao, realize um backup antes.

1.8 Vamos agora rodar este comando para verificarmos o tamanho dos indices
  SELECT SUM(stat_value) pages, index_name,
       SUM(stat_value)*@@innodb_page_size size
       FROM mysql.innodb_index_stats WHERE (table_name like 'users' AND database_name like 'stackoverflow' )
       AND stat_name = 'size' GROUP BY index_name;

         SELECT 
       SUM(stat_value)*@@innodb_page_size size
       FROM mysql.innodb_index_stats WHERE (table_name like 'users' AND database_name like 'stackoverflow' )
       AND stat_name = 'size' ;

       24.215.552 bytes  -- MAS AQUI JA VEMOS UM GRANDE GANHO EM TERMOS DE DIMINUICAO DOS INDICES

1.9 Vamos rodar novamente:

 show table status like "users" ;

VAMOS ATUALIZAR AS ESTATISTICAS
ANALYZE TABLE users

 Agora rode novamente:
 show table status like "users" ;

   Os resultados da otimização alteram os valores de data_length da tabela otimizada, indicando:
     - A otimização liberou o espaço alocado não utilizado.
     - O espaço geral do banco de dados é menor devido ao espaço liberado.

   Antes o data_lenght estava 45.678.592 e agora 8.929.280

-- -------------------------------------------------------------------------------------------------------------------

-- Rode e veja se os tempos melhoraram com file menor e desfragmentado e com as paginas de dados e indices otimizadas.

SELECT count(*) from users;
-- 108.030 linhas 
-- Tempo de 0.92 segundos

SELECT count(*) from users where id > 300000;

-- o linhas
-- Tempo de 0 segundos

Para confirmar a diminuicao do tamanho do file da tabela users que está no disco...

2.0  VAMOS AGORA VERIFICAR OS FILES DAS TABELAS NO DISCO. GUARDE O TAMANHO DE CADA ARQUIVO.

users.ibd
29 MB, ou seja 29/150*100, uma otimizacao de cerca de 80% em espaco da tabela em disco, com dados da propria tabela e tamanho dos indices, o que significa, mais 
dados em memoria, operacoes sql mais rapidas, backups e restores mais rapidos.

obs: Para otimizarmos varias tabelas:
OPTIMIZE TABLE <table 1>, <table 2>, <table 3>;

Se quisermos agendar para realizar a otimizacao 

delimiter $$
CREATE EVENT OTIMIZARTABELAS
    ON SCHEDULE EVERY 2 WEEK
    STARTS '2023-06-30 00:10:00'
    ENDS  '2024-07-30 00:00:00' -- PODERIAMOS COLOCAR AINDA UMA DATA PARA O EVENTO PARAR DE RODAR, E SE NAO COLOCAR RODA POR TEMPO INDEFINIDO
    DO
     BEGIN
		OPTIMIZE TABLE  USERS;

     END $$
delimiter ;

-- E VAMOS VER O EVENTO
SHOW EVENTS FROM STACKOVERFLOW; -- repare nas colunas

-- e para deletar o evento
drop event OTIMIZARTABELAS;

--------------------------------------------------------------------------------------------------------------------------------

Caro(a) Aluno(a) ou 

Chegamos ao fim do curso. Minha intenção é lancar novos módulos. Estou neste momento preparando novas aulas sobre alguns assuntos que irei lancar e
voce receberá sem nenhum custo, estes novos módulos e videos.

São eles:

Modulo Lock
Modulo MYSQL no Linux
Modulo Replicação e Inoodb Cluster
Modulo MYSQL na Nuvem Azure

Obrigado por ter chegado até aqui e parabéns. 

Caso tenha interesse em ser um DBA SQL SERVER e trabalhar com POWER BI, preparei um curso bem completo com 97 horas de video aula:

https://www.udemy.com/course/performance-no-sql-server/

-------------------------------------------------------------------

fim



