Curso MYSQL Completo
Instrutor: Sandro Servino
SandroServino.com.br

-- https://www.linkedin.com/in/sandroservino/?originalSubdomain=pt
-- https://www.udemy.com/user/sandro-servino-3/


COMPACTAÇÃO DE TABELAS E INDICES

CONCEITOS GERAIS

- Na maioria das vezes, as compactacoes diminuem o tamanho dos files das tabelas mas normalmente trazem perda de performance principalmente em operacoes escrita.
 A eficiência da compactação depende da natureza de seus dados, por exemplo em tabelas com campos char, varchar, text, blob que tenham
muitos dados repetidos.

- Files compactados trazem ganhos financeiros para armazenamento de dados, principalmente se trabalha na nuvem. Se tens máquina com muita capacidade de processamento,
- muita memória disponivel, discos rápidos ssd mas pequenos e necessidade de economia com gastos financeiros de armazenamento, pode ser algo a ser testado.

- As vezes pode ocorrer uma necessidade emergencial de compactar tabelas, devido a falta de espaco em disco e pode ser um recurso a ser util neste momento.

- Em geral, a compactação funciona melhor em tabelas que incluem um número razoável de colunas do tipo char, varchar, blob e text e onde os dados são lidos com muito 
mais frequência do que gravados, preferencialmente já estando na memória (buffer pool). Como não há maneiras garantidas de prever se a compactação não trará perdas significantes de performance
devido a compactacao e descompactacao, em situação específica, sempre teste com uma carga de trabalho específica.

- Compactação funciona identificando sequências repetidas de bytes em um bloco de dados. Dados completamente aleatórios são o pior caso para compactacao. 
Os dados típicos geralmente têm valores repetidos e, portanto, são compactados de forma eficaz, mas é claro que o trabalho de compactação e descompactação,
sempre que um dados novo for incluido, alterado ou pesquisado traz uma carga maior para a CPU e disco, que pode ser bem minimizado dependendo do tamanho do seu server e do acesso.
Pense por exemplo no tempo que leva para compactar arquivos e descompactar com programas como zip, por exemplo.

- Você escolhe se deseja ativar a compactação para cada tabela InnoDB. Quando habilitada, a compactação da tabela MySQL é automática e se aplica a todas as colunas de uma
- tabela e valores de índice.

- Como os índices geralmente são uma fração significativa do tamanho total de um banco de dados, a compactação pode resultar em economias significativas de armazenamento. 
- As operações de compactação e descompactação acontecem no servidor de banco de dados, que provavelmente é um sistema poderoso 
- dimensionado para lidar com a carga esperada.

- Para determinar se deve ou não compactar uma tabela específica e seus respectivos indices, realize experimentos. 
Você pode obter uma estimativa aproximada de quão eficientemente seus dados podem ser compactados em uma cópia do arquivo .ibd para uma tabela descompactada. 

- Fundamentalmente, a compactação funciona melhor quando o tempo de CPU está disponível e usa discos SSD para compactar e descompactar dados. 
Ao testar o desempenho de seu aplicativo com diferentes configurações de compactação, teste em uma plataforma semelhante à configuração planejada do sistema de produção.

-- LAB1

create database dbtestindicecompactado;
use dbtestindicecompactado;

CREATE TABLE big_table AS SELECT * FROM information_schema.columns;

INSERT INTO big_table SELECT * FROM big_table;
INSERT INTO big_table SELECT * FROM big_table;
INSERT INTO big_table SELECT * FROM big_table;
INSERT INTO big_table SELECT * FROM big_table;
INSERT INTO big_table SELECT * FROM big_table;
INSERT INTO big_table SELECT * FROM big_table;
INSERT INTO big_table SELECT * FROM big_table;
INSERT INTO big_table SELECT * FROM big_table;
INSERT INTO big_table SELECT * FROM big_table;

ALTER TABLE big_table ADD id int NOT NULL PRIMARY KEY auto_increment;

select count(id) from big_table; -- 1.970.688

-- -------------------------------------------------------------------

- Vamos criar uma tabela compactada

- O padrão default das paginas de dados e das paginas dos indices do mysql é de 16kb
- Normalmente, quando se busca uma compactação, é definido o tamanho da página compactada para 8K ou 4K bytes. KEY_BLOCK_SIZE=8 geralmente é uma escolha segura.

- Em uma tabela, cada página compactada pode ser configurada entre 1K, 2K, 4K até 8K.
- Para acessar os dados em uma página, o MySQL lê a página compactada do disco se ela ainda não estiver no buffer pool e, em seguida, descompacta a página 
- em seu formato original. 

- Definir o tamanho da página compactada muito grande desperdiça algum espaço, mas as páginas não precisam ser compactadas com tanta frequência. 
- Se o tamanho da página compactada for definido muito pequeno, as inserções ou atualizações podem exigir uma recompressão demorada e os nós da b-tree
- podem ter que ser divididos com mais frequência.

- Para determinar o melhor valor para KEY_BLOCK_SIZE, normalmente, você cria várias cópias da mesma tabela com valores diferentes para esta cláusula, 
- mede o tamanho dos arquivos .ibd resultantes e vê o desempenho de cada um com uma carga de trabalho realista.

- InnoDB suporta tamanhos de página de 32 KB e 64 KB, mas esses tamanhos de página não suportam compactação. 

- A compactação se aplica a uma tabela inteira e a todos os seus índices associados, não a linhas individuais, apesar do nome da cláusula ROW_FORMAT.

CREATE TABLE key_block_size_4 LIKE big_table;
ALTER TABLE key_block_size_4 key_block_size=4 row_format=compressed;
INSERT INTO key_block_size_4 SELECT * FROM big_table; -- MARQUE O TEMPO DE INSERT, 602 SEGUNDOS
select count(id) from key_block_size_4; --  segundos

-- Veja o tamanho do file .ibd --  ? MB, no meu caso, D:\MYSQL_CURSO\Data

CREATE TABLE key_block_size_8 LIKE big_table;
ALTER TABLE key_block_size_8 key_block_size=8 row_format=compressed;
INSERT INTO key_block_size_8 SELECT * FROM big_table; -- MARQUE O TEMPO DE INSERT, 625 SEGUNDOS
select count(id) from key_block_size_8;  --  segundos

-- Veja o tamanho do file .ibd --  ? MB, no meu caso, D:\MYSQL_CURSO\Data

CREATE TABLE key_block_size_1 LIKE big_table;
ALTER TABLE key_block_size_1 key_block_size=1 row_format=compressed;
INSERT INTO key_block_size_1 SELECT * FROM big_table; -- MARQUE O TEMPO DE INSERT, 1.632 SEGUNDOS
select count(id) from key_block_size_1;  --  segundos

-- Veja o tamanho do file .ibd --  ? MB, no meu caso, D:\MYSQL_CURSO\Data

- Na maioria dos casos, compactacao com 1kb nao reduz mais o tamanho do file, porque o MYSQL acaba fazendo mais split nas paginas dos dados, dividindo as linhas  
- (registros) em mais paginas de dados, ou seja, ao inves de deixar um registro em apenas 1 pagina de 16kb (PADRAO), pode ter que quebrar esta linha(REGISTRO) em mais paginas de dados, e deixando 
- ainda espacos em branco que sobraram nas paginas e a cada dado novo que for chegando tera que ficar fazendo mais splits novos, com tendencia do file ficar maior
- do que o file de 4K e até mesmo de 8k a medida que novos inserts ocorrem. Se o tamanho da página compactada for definido muito pequeno, as inserções ou atualizações podem exigir uma recompressão demorada e os nós 
- da árvore Btree podem ter que ser divididos com mais frequência (split), levando a arquivos de dados maiores e indexação menos eficiente e ainda mais perda de performance.
- Tente trabalhar com paginas de 4kb ou 8kb e faça seus testes.

-- LAB2

-- VAMOS FAZER TESTES DE CONSULTAS, ALTERACAO E DELECAO NAS TABELAS COMPACTADAS E NAO COMPACTADAS (16KB) E VAMOS MARCAR O TEMPO DE EXECUCAO E USO CPU.

-- TABELA NAO COMPACTADA
CREATE TABLE big_table_nocompress AS SELECT  * FROM information_schema.columns  limit 1;
TRUNCATE TABLE big_table_nocompress;
ALTER TABLE big_table_nocompress ADD id int NOT NULL PRIMARY KEY auto_increment;

INSERT INTO big_table_nocompress SELECT * FROM big_table; -- MARQUE O TEMPO DE INSERT, 595 SEGUNDOS

select count(id) from big_table_nocompress;  --  segundos

-- Veja o tamanho do file .ibd --  ? MB, no meu caso, D:\MYSQL_CURSO\Data

-- VAMOS EXECUTAR NOVAMENTE ESTAS CONSULTAS PARA CONFIRMAR OS TEMPOS?
select count(id) from key_block_size_1; 
select count(id) from key_block_size_4; 
select count(id) from key_block_size_8; 
select count(id) from big_table_nocompress;

-- QUAL A CONCLUSAO EM TERMOS DE PERFORMANCE?

-- ---------------

-- VAMOS VAMOS FAZER OUTROS TESTES DE CONSULTAS NAS TABELAS E MARCAR OS TEMPOS

select * from key_block_size_1; 
select * from key_block_size_4; 
select * from key_block_size_8; 
SELECT * FROM big_table_nocompress; 

-- VAMOS FAZER TESTES DE UPDATE E MARCAR TEMPO
-- vamos obrigar as queries ler paginas sem apoio de indices nonclustered, para ver se vai demorar mais tempo para achar os dados e alterar de acordo com compactacao ou nao.

UPDATE `dbtestindicecompactado`.`key_block_size_4`
SET
DATA_TYPE = "char"
WHERE DATA_TYPE = "varchar" AND ID<>0; -- tempo 288 secs

UPDATE `dbtestindicecompactado`.`key_block_size_8`
SET
DATA_TYPE = "char"
WHERE DATA_TYPE = "varchar" AND ID<>0; -- tempo 332 secs

UPDATE `dbtestindicecompactado`.`big_table_nocompress`
SET
DATA_TYPE = "char"
WHERE DATA_TYPE = "varchar" AND ID<>0; -- tempo 171 secs

-- VAMOS OTIMIZAR AS TABELAS PARA REMOVER ESPACOS FRAGMENTADOS PARA VERIFICAR SE TEMOS ALGUMAS MELHORIAS NOS TEMPOS, DEPOIS DE TERMOS COMPACTADO AS TABELAS

OPTIMIZE TABLE  key_block_size_4; 
OPTIMIZE TABLE  key_block_size_8; 

-- VAMOS VAMOS FAZER TESTES DE CONSULTAS NAS TABELAS E MARCAR OS TEMPOS
SELECT COUNT(id) FROM big_table_nocompress; 
select count(id) from key_block_size_4; 
select count(id) from key_block_size_8; 

SELECT * FROM big_table_nocompress; 
select * from key_block_size_4; 
select * from key_block_size_8; 

-- Pelos meus testes, compressao de 1kb e 4kb está descartado, sendo o melhor é manter o padrao de 16kb ou 8kb (padrao sql server) e neste caso
-- precisa sempre realizar testes antes em ambiente de homologacao (qa ou dev).

-- VAMOS FAZER TESTES DE UPDATE E MARCAR TEMPO
-- vamos obrigar as queries ler paginas sem apoio de indices nonclustered, para ver se vai demorar mais tempo para achar os dados e alterar de acordo com compactacao ou nao.

UPDATE `dbtestindicecompactado`.`key_block_size_4`
SET
DATA_TYPE = "varchar"
WHERE DATA_TYPE = "char" AND ID<>0; -- tempo 552 segundos

UPDATE `dbtestindicecompactado`.`key_block_size_8`
SET
DATA_TYPE = "varchar"
WHERE DATA_TYPE = "char" AND ID<>0; -- tempo 455 segundos

UPDATE `dbtestindicecompactado`.`big_table_nocompress`
SET
DATA_TYPE = "varchar"
WHERE DATA_TYPE = "char" AND ID<>0; -- -- tempo 197 segundos

-- VAMOS CRIAR INDICE NONCLUSTERED NA TABELA big_table_nocompress e key_block_size_8 por um campo, vamos verificar o tamanho dos files e vamos fazer buscas

ALTER TABLE `dbtestindicecompactado`.`key_block_size_8` 
ADD INDEX `idx_ordinal_position` (`ordinal_position` ASC) VISIBLE;
ALTER TABLE `dbtestindicecompactado`.`big_table_nocompress` 
ADD INDEX `idx_ordinal_position` (`ordinal_position` ASC) VISIBLE;

UPDATE `dbtestindicecompactado`.`key_block_size_8`
SET
ordinal_position = 1
WHERE ordinal_position = 2 AND ID<>0; -- 575 segundos

UPDATE `dbtestindicecompactado`.`big_table_nocompress`
SET
ordinal_position = 1
WHERE ordinal_position = 2 AND ID<>0; -- 211 segundos


-- VAMOS FAZER TESTE DE DELECAO E MARCAR TEMPO

delete from key_block_size_8 where ordinal_position = 1 ; -- 640 segundos
delete from big_table_nocompress where ordinal_position = 1 ; -- 398 segundos

delete from key_block_size_8 where id <> 0; -- 945 segundos
delete from big_table_nocompress where id <> 0; -- 491 segundos

-- LAB 3

-- Desativando a compactação de página

-- Veja o tamanho do file antes e depois

ALTER TABLE `dbtestindicecompactado`.`key_block_size_4` 
KEY_BLOCK_SIZE = 16 , ROW_FORMAT = DEFAULT ;

OPTIMIZE TABLE key_block_size_4;


-- fim


