-- ETAPA 0
-- Aplicação do teste de análise estatística descritiva agrupada
-- Teste de Homocedasticidade


-- Conclusão: Não foi possível aplicar o teste, pois essa tabela trabalha basicamente com STRINGS.  



-- ETAPA 1
-- LIMPEZA DOS DADOS

-- Convertendo e validando tipos:
-- A intenção é mudar a natureza da coluna customer_zip_code_prefix de INTEGER para STRING.

SELECT CAST (customer_zip_code_prefix AS STRING) AS cod_postal_stringado
FROM `skilled-sunrise-486800-j9.analise_logistica.clientes_destino`;


-- Verificando valores nulos:

    SELECT *
FROM `skilled-sunrise-486800-j9.analise_logistica.clientes_destino`
WHERE customer_id IS NULL 
    OR customer_unique_id IS NULL 
    OR CAST (customer_zip_code_prefix AS STRING) IS NULL 
    OR customer_city IS NULL
    OR customer_state IS NULL;

-- Não foram encontrados valores nulos



-- Remoção de espaços em branco:

SELECT 
    TRIM (customer_id), 
    TRIM (customer_unique_id), 
    TRIM (CAST (customer_zip_code_prefix AS STRING)) AS cod_postal_stringado, 
    TRIM (customer_city), 
    TRIM (customer_state)
FROM `skilled-sunrise-486800-j9.analise_logistica.clientes_destino`;


-- Uniformidade da escrita da coluna customer_city utilizando a função INITCAP (iniciais maiúsculas):

SELECT 
    INITCAP (customer_city) AS cidades_inicio_maiusculo 
FROM `skilled-sunrise-486800-j9.analise_logistica.clientes_destino`;


-- Padronizando as preposições que ficaram com iniciais maúsculas:

SELECT
 REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(INITCAP(REPLACE(customer_city, '_', ' ')),
      ' E ', ' e '), ' De ', ' de '), ' Da ', ' da '), ' Do ', ' do '),
      ' Em ', ' em '), ' Com ', ' com '), ' Para ', ' para '), ' Por ', ' por '), 'ã', 'a'), 'á', 'a'), 'ó', 'o'), 'é', 'e'), 'í', 'i'), 'ú', 'u'), 'à', 'a'), 'â', 'a'), 'ç', 'c') AS cidade_inicial_maiuscula
FROM `skilled-sunrise-486800-j9.analise_logistica.clientes_destino`;



-- Verificando a presença de caracteres estranhos dentro da coluna customer_city

SELECT 
    customer_city,
    INITCAP(customer_city) AS cidade_limpa
FROM `skilled-sunrise-486800-j9.analise_logistica.clientes_destino`
WHERE REGEXP_CONTAINS (customer_city, r'[0-9/*"@#%^&()_+§=|\\\[\].;:!]');

-- Apenas um registro foi detectado: Quilômetro 14 do Mutum. Entretanto, não configura erro de digitação. A localidade informada tem todo potencial para ser um endereço válido, principalemte se for em alguma zona rural. Desta forma, manterei o registro no conjunto de dados.  


-- Verificando se coluna customer_state possui mais que dois caracteres:

SELECT 
    customer_state
FROM `skilled-sunrise-486800-j9.analise_logistica.clientes_destino`
WHERE LENGTH (customer_state) <> 2;

-- Não foram encontrados valores com mais que dois caracteres.


-- Garantindo que as entradas da coluna customer_state seja sempre uma das siglas dos estados brasileiros:


SELECT
    UPPER (customer_state) AS sigla_estado_cliente
FROM `skilled-sunrise-486800-j9.analise_logistica.clientes_destino`
WHERE customer_state IN ('AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA', 'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN', 'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO');




-- Verificando as siglas distintas e se elas abrangem todos os estados brasileiros:


SELECT 
    DISTINCT (customer_state)
FROM `skilled-sunrise-486800-j9.analise_logistica.clientes_destino`
GROUP BY 1
ORDER BY 1;

-- Todos os estados + o DF foram citados como valores distintos


-- Verificando se customer_id e customer_unique_id são chaves primárias ou estrangeiras.
-- Lembrando que para ser uma chave primária é preciso passar no teste de NULIDADE e UNICIDADE. Ambas já passaram no teste de nulidade, pois nenhuma apresentou valores nulos. Agora resta saber se passarão no teste de UNICIDADE. 

-- Testando a coluna customer_id:

SELECT 
    COUNT (*) AS total_linhas,
    COUNT (DISTINCT customer_id) AS id_unico,
    COUNT (*) - COUNT (DISTINCT customer_id) AS duplicatas
FROM `skilled-sunrise-486800-j9.analise_logistica.clientes_destino`;


-- Não foram identificados valores duplicados na coluna customer_id. Esse resultado classifica a coluna customer_id como chave primária, pois passou no teste de unicidade. 


-- Testando a coluna customer_unique_id:


SELECT 
    COUNT (*) AS total_linhas,
    COUNT (DISTINCT customer_unique_id) AS id_unico,
    COUNT (*) - COUNT (DISTINCT customer_unique_id) AS duplicatas
FROM `skilled-sunrise-486800-j9.analise_logistica.clientes_destino`;


-- Foram detectadas 3.345 linhas duplicadas, o que impede a coluna customer_unique_id de ser classificada como cahve primária. A coluna customer_unique_id funciona como uma chave estrangeira.


-- Verificando o comprimeto dos caracteres da coluna customer_zip_code_prefix:

SELECT
    customer_zip_code_prefix,
    LENGTH (CAST (customer_zip_code_prefix AS STRING)) AS tamanho
    FROM `skilled-sunrise-486800-j9.analise_logistica.clientes_destino`
    GROUP BY customer_zip_code_prefix
    HAVING LENGTH (CAST (customer_zip_code_prefix AS STRING)) <> 4;

-- Foram detectados 11.125 linhas cujo comprimento da string é diferente de 4.


-- Descobrindo quantos são os valores diferentes de 4:


SELECT 
    LENGTH (CAST(customer_zip_code_prefix AS STRING)) AS comprimento,
    COUNT (*) AS quantidade_de_linhas,
    COUNT (DISTINCT customer_zip_code_prefix) AS cp_unicos
FROM `skilled-sunrise-486800-j9.analise_logistica.clientes_destino`
GROUP BY 1
ORDER BY 1;

-- Existem 23.995 linhas cujo comprimento é de 4 caracteres. Como já sabemos, essa diferença se deve à ausência do numeral zero no início do código postal


-- Acrescentando o zero inicial em todas as ocorrências de 4 caracteres:

SELECT 
    LPAD (CAST(customer_zip_code_prefix AS STRING), 5, '0') AS code_limpo
  FROM `skilled-sunrise-486800-j9.analise_logistica.clientes_destino`
WHERE LPAD (CAST(customer_zip_code_prefix AS STRING), 5, '0') LIKE '0%';

-- Os zeros ausente foram devidamente tratados e 23.995 linhas foram corrigidas. 



-- Validando o padrão da coluna customer_id:

SELECT
  customer_id
  FROM
  `skilled-sunrise-486800-j9.analise_logistica.clientes_destino`
  WHERE 
  NOT REGEXP_CONTAINS (customer_id, r'^[a-f0-9A-F]{32}$');

-- Não foram encotradas inconsistências nos hashes e eles seguem o padrão hexadecimal.



-- Validando o padrão da coluna customer_unique_id:


SELECT
  customer_unique_id
  FROM
  `skilled-sunrise-486800-j9.analise_logistica.clientes_destino`
  WHERE 
  NOT REGEXP_CONTAINS (customer_id, r'^[a-f0-9A-F]{32}$');


-- Não foram encotradas inconsistências nos hashes e eles seguem o padrão hexadecimal.


-- Verificando se há valores 100% idênticos nas colunas (duplicados):


SELECT 
    customer_id,
    customer_unique_id,
    CAST(customer_zip_code_prefix AS STRING) AS cod_postal_str,
    customer_city,
    customer_state
FROM `skilled-sunrise-486800-j9.analise_logistica.clientes_destino`
GROUP BY 1, 2, 3, 4, 5;


-- Esse script garante que apenas linhas 100% idênticas sejam removidas e garante também que colunas que funcionam como chaves estrangeiras (a exemplo da coluna customer_zip_code_prefix) variem livremente. 




-- CRIANDO A CTE DE LIMPEZA


WITH carac_especial AS (

SELECT *,
    INITCAP(customer_city) AS cidade_limpa
FROM `skilled-sunrise-486800-j9.analise_logistica.clientes_destino`
WHERE NOT REGEXP_CONTAINS(customer_city, r'[0-9/*"@#%^&()_+§=|\\\[\].;:!]')
       OR CONTAINS_SUBSTR(customer_city, 'quilometro')

),

nao_nulos AS (


SELECT *
FROM carac_especial
WHERE customer_id IS NOT NULL 
    AND customer_unique_id IS NOT NULL 
    AND CAST (customer_zip_code_prefix AS STRING) IS NOT NULL 
    AND customer_city IS NOT NULL
    AND customer_state IS NOT NULL

),



mudanca_de_tipo AS (


SELECT 
    customer_id AS cliente_id_pk,
    customer_unique_id AS cliente_id_fk,
    customer_city AS cid_cliente,
    customer_state AS est_cliente,
    CAST (customer_zip_code_prefix AS STRING) AS cod_postal_st
FROM nao_nulos

),



em_branco AS (


SELECT 
    TRIM (cliente_id_pk) AS pk_id_cliente, 
    TRIM (cliente_id_fk) AS fk_id_cliente, 
    TRIM (CAST (cod_postal_st AS STRING)) AS cod_post_cli_str, 
    TRIM (cid_cliente) AS cliente_cid, 
    TRIM (est_cliente) AS cliente_est
FROM mudanca_de_tipo

), 



ini_maiusc AS (


SELECT
    pk_id_cliente AS cli_id_pk_ini_maiusc,
    fk_id_cliente AS cli_id_fk_ini_maiusc,
    cliente_est AS est_cliente_ini_maiusc,
    CAST (cod_post_cli_str AS STRING) AS cod_post_cli_str_ini_maiusc,
    INITCAP (cliente_cid) AS cidades_inicio_maiusculo 
FROM em_branco

), 


padronizar_preposicoes AS (


SELECT
    cli_id_pk_ini_maiusc AS cliente_id_primaria,
    cli_id_fk_ini_maiusc AS cliente_id_estrangeira,
    est_cliente_ini_maiusc AS estado_ok,
    CAST (cod_post_cli_str_ini_maiusc AS STRING) AS cod_post_atual,
 REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(INITCAP(REPLACE(cidades_inicio_maiusculo, '_', ' ')),
      ' E ', ' e '), ' De ', ' de '), ' Da ', ' da '), ' Do ', ' do '),
      ' Em ', ' em '), ' Com ', ' com '), ' Para ', ' para '), ' Por ', ' por '), 'ã', 'a'), 'á', 'a'), 'ó', 'o'), 'é', 'e'), 'í', 'i'), 'ú', 'u'), 'à', 'a'), 'â', 'a'), 'ç', 'c') AS cidade_inc_mai
FROM ini_maiusc

), 


acrescimo_zero AS (


SELECT 
    cidade_inc_mai AS destino,
    cliente_id_primaria AS cli_pk,
    cliente_id_estrangeira AS cli_fk,
    estado_ok AS est_destino,
    LPAD (CAST (cod_post_atual AS STRING), 5, '0') AS code_limpo
FROM padronizar_preposicoes
    

), 


padrao_do_hash AS (


SELECT
    destino AS cidade_destino_limpo,
    cli_pk AS cliente_pk_limpo,
    cli_fk AS cliente_fk_limpo,
    est_destino AS estado_destino_limpo,
    CAST (code_limpo AS STRING) AS cod_postal_limpo
FROM
  acrescimo_zero
WHERE 
  REGEXP_CONTAINS ( cli_pk, r'^[a-f0-9A-F]{32}$')

),



estado_cliente AS (



SELECT
    cidade_destino_limpo,
    cliente_pk_limpo,
    cliente_fk_limpo,
    cod_postal_limpo,
    UPPER (estado_destino_limpo) AS sigla_estado_cliente
FROM padrao_do_hash
WHERE estado_destino_limpo IN ('AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA', 'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN', 'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO')

), 

cte_destino AS (

SELECT 
    cliente_pk_limpo, 
    ANY_VALUE (cliente_fk_limpo) AS cliente_fk_ajust,
    ANY_VALUE (cidade_destino_limpo) AS cidade_destino_ajust,
    ANY_VALUE (cod_postal_limpo) AS cod_postal_ajust,
    ANY_VALUE (sigla_estado_cliente) AS sigla_estado_ajust
FROM estado_cliente
GROUP BY 1

)

SELECT * FROM cte_destino;



-- CRIAÇÃO DE UMA TABELA A PARTIR DA CTE DE LIMPEZA:


CREATE OR REPLACE TABLE `skilled-sunrise-486800-j9.analise_logistica.tabela_cliente_analise` AS



WITH carac_especial AS (

SELECT *,
    INITCAP(customer_city) AS cidade_limpa
FROM `skilled-sunrise-486800-j9.analise_logistica.clientes_destino`
WHERE NOT REGEXP_CONTAINS(customer_city, r'[0-9/*"@#%^&()_+§=|\\\[\].;:!]')
       OR CONTAINS_SUBSTR(customer_city, 'quilometro')

),

nao_nulos AS (


SELECT *
FROM carac_especial
WHERE customer_id IS NOT NULL 
    AND customer_unique_id IS NOT NULL 
    AND CAST (customer_zip_code_prefix AS STRING) IS NOT NULL 
    AND customer_city IS NOT NULL
    AND customer_state IS NOT NULL

),



mudanca_de_tipo AS (


SELECT 
    customer_id AS cliente_id_pk,
    customer_unique_id AS cliente_id_fk,
    customer_city AS cid_cliente,
    customer_state AS est_cliente,
    CAST (customer_zip_code_prefix AS STRING) AS cod_postal_st
FROM nao_nulos

),



em_branco AS (


SELECT 
    TRIM (cliente_id_pk) AS pk_id_cliente, 
    TRIM (cliente_id_fk) AS fk_id_cliente, 
    TRIM (CAST (cod_postal_st AS STRING)) AS cod_post_cli_str, 
    TRIM (cid_cliente) AS cliente_cid, 
    TRIM (est_cliente) AS cliente_est
FROM mudanca_de_tipo

), 



ini_maiusc AS (


SELECT
    pk_id_cliente AS cli_id_pk_ini_maiusc,
    fk_id_cliente AS cli_id_fk_ini_maiusc,
    cliente_est AS est_cliente_ini_maiusc,
    CAST (cod_post_cli_str AS STRING) AS cod_post_cli_str_ini_maiusc,
    INITCAP (cliente_cid) AS cidades_inicio_maiusculo 
FROM em_branco

), 


padronizar_preposicoes AS (


SELECT
    cli_id_pk_ini_maiusc AS cliente_id_primaria,
    cli_id_fk_ini_maiusc AS cliente_id_estrangeira,
    est_cliente_ini_maiusc AS estado_ok,
    CAST (cod_post_cli_str_ini_maiusc AS STRING) AS cod_post_atual,
 REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(INITCAP(REPLACE(cidades_inicio_maiusculo, '_', ' ')),
      ' E ', ' e '), ' De ', ' de '), ' Da ', ' da '), ' Do ', ' do '),
      ' Em ', ' em '), ' Com ', ' com '), ' Para ', ' para '), ' Por ', ' por '), 'ã', 'a'), 'á', 'a'), 'ó', 'o'), 'é', 'e'), 'í', 'i'), 'ú', 'u'), 'à', 'a'), 'â', 'a'), 'ç', 'c') AS cidade_inc_mai
FROM ini_maiusc

), 


acrescimo_zero AS (


SELECT 
    cidade_inc_mai AS destino,
    cliente_id_primaria AS cli_pk,
    cliente_id_estrangeira AS cli_fk,
    estado_ok AS est_destino,
    LPAD (CAST (cod_post_atual AS STRING), 5, '0') AS code_limpo
FROM padronizar_preposicoes
    

), 


padrao_do_hash AS (


SELECT
    destino AS cidade_destino_limpo,
    cli_pk AS cliente_pk_limpo,
    cli_fk AS cliente_fk_limpo,
    est_destino AS estado_destino_limpo,
    CAST (code_limpo AS STRING) AS cod_postal_limpo
FROM
  acrescimo_zero
WHERE 
  REGEXP_CONTAINS ( cli_pk, r'^[a-f0-9A-F]{32}$')

),



estado_cliente AS (



SELECT
    cidade_destino_limpo,
    cliente_pk_limpo,
    cliente_fk_limpo,
    cod_postal_limpo,
    UPPER (estado_destino_limpo) AS sigla_estado_cliente
FROM padrao_do_hash
WHERE estado_destino_limpo IN ('AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA', 'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN', 'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO')

), 

cte_destino AS (

SELECT 
    cliente_pk_limpo, 
    ANY_VALUE (cliente_fk_limpo) AS cliente_fk_ajust,
    ANY_VALUE (cidade_destino_limpo) AS cidade_destino_ajust,
    ANY_VALUE (cod_postal_limpo) AS cod_postal_ajust,
    ANY_VALUE (sigla_estado_cliente) AS sigla_estado_ajust
FROM estado_cliente
GROUP BY 1

)

SELECT * FROM cte_destino;






