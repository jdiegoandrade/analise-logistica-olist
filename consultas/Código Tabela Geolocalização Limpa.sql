-- ETAPA 0
-- Aplicação do teste de análise estatística descritiva agrupada
-- Teste de Homocedasticidade


-- Conclusão: Não foi possível aplicar o teste, pois essa tabela trabalha basicamente com STRINGS.  


-- ETAPA 1

-- Limpeza de Dados

-- Identificando valores nulos.



SELECT 
    geolocation_zip_code_prefix, 
    geolocation_city, 
    geolocation_state

 FROM `skilled-sunrise-486800-j9.analise_logistica.geolocalizacao`

WHERE 
    geolocation_zip_code_prefix IS NULL
    OR geolocation_city IS NULL
    OR geolocation_state IS NULL;

-- Não foi detectada a presença de valores nulos.


-- Transformando a coluna geolocation_zip_code_prefix em STRING:


SELECT 
    CAST (geolocation_zip_code_prefix AS STRING) AS geolocation_string
 FROM `skilled-sunrise-486800-j9.analise_logistica.geolocalizacao`;



-- Remoção de espaços extras:


SELECT 
    TRIM (CAST (geolocation_zip_code_prefix AS STRING)), 
    TRIM (geolocation_city), 
    TRIM (geolocation_state)

 FROM `skilled-sunrise-486800-j9.analise_logistica.geolocalizacao`;


-- Identificando o comprimento das strings com a função LENGTH:


SELECT 
    geolocation_state,
    LENGTH (CAST (geolocation_zip_code_prefix AS STRING)) AS compr_string,
    COUNT (geolocation_zip_code_prefix) AS contagem
FROM `skilled-sunrise-486800-j9.analise_logistica.geolocalizacao`
    WHERE 
LENGTH (CAST (geolocation_zip_code_prefix AS STRING)) >= 4
    GROUP BY 1, 2
    ORDER BY 2 DESC;

-- O resultado da consulta demonstrou 2 tipos de comprimento: 4 e 5 caracteres, sendo que AC, SP e RN possuem 4 caracteres no código postal, quando deveriam ter 5 caracteres. Os 4 caracteres estão distribuídos em 245.733 ocorrências.


-- Incluindo o numeral zero em todas as correspondências com 4 caracteres:


SELECT 
LPAD (CAST (geolocation_zip_code_prefix AS STRING), 5, '0') AS location_add_0,
FROM `skilled-sunrise-486800-j9.analise_logistica.geolocalizacao`
WHERE  LENGTH (CAST (geolocation_zip_code_prefix AS STRING)) = 4;


-- O resultado da consulta retornou exatas 245.733 linhas, o que comprova que todas as substituições foram efetuadas com sucesso. 


-- Transformando os caracteres da coluna geolocation_city de minúsculo para iniciais maiúsculas, mantendo as preposições minúsculas, além de corrigir divergências em relação a diacríticos (acentos).

SELECT
 REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(INITCAP(REPLACE(geolocation_city, '_', ' ')),
      ' E ', ' e '), ' De ', ' de '), ' Da ', ' da '), ' Do ', ' do '),
      ' Em ', ' em '), ' Com ', ' com '), ' Para ', ' para '), ' Por ', ' por '), 'ã', 'a'), 'á', 'a'), 'ó', 'o'), 'é', 'e'), 'í', 'i'), 'ú', 'u'), 'à', 'a'), 'â', 'a'), 'ç', 'c') AS nome_inicial_maiuscula
FROM `skilled-sunrise-486800-j9.analise_logistica.geolocalizacao`;


-- Verificando o comprimento da coluna geolocation_state e se existem strings diferentes de 2 caracteres.


SELECT 
    geolocation_state,
    LENGTH (CAST (geolocation_state AS STRING)) AS compr_estados
FROM `skilled-sunrise-486800-j9.analise_logistica.geolocalizacao`
WHERE LENGTH (CAST (geolocation_state AS STRING)) <> 2
GROUP BY 1;

-- O resultado demonstrou que não há siglas com comprimento de caracter diferente de 2.


-- Testando se as siglas correspondem realmente aos estados brasileiros ou se há alguma sigla com erro de digitação.


SELECT 
    DISTINCT (geolocation_state)
FROM `skilled-sunrise-486800-j9.analise_logistica.geolocalizacao`
GROUP BY 1
ORDER BY 1;

-- Não foram detectadas inconsistências em relação às siglas dos estados brasileiros. O resultado exibiu todas as siglas em ordem alfabética, sendo 26 estados mais o DF.


-- Transformando a coluna geolocation_zip_code_prefix em uma chave primária:
-- A medida se faz necessária, pois preciso de uma chave primária com valores exclusivos para conectar com as tabelas de origem e destino da carga (Chaves estrangeiras), mediante o código postal.

-- Verificando se geolocation_zip_code_prefix é uma chave primária:
-- Se relamente for uma chave primária, os valores de cada ocorrência deverão ser valores exclusivos e não podem ser nulos. O teste da nulidade feito em etapas anteriores já nos mostrou que não há valores nulos. Vamos verificar a ocorrência de valores duplicados, pois para que seja considerada uma chave primária, não pode haver valores de IDs duplicados.


SELECT 
    COUNT (*) AS total1,
    COUNT (DISTINCT LPAD (CAST (geolocation_zip_code_prefix AS STRING), 5, '0')) AS cep_distinct,
    COUNT (*) - COUNT(DISTINCT geolocation_zip_code_prefix) AS qtd_duplicadas
FROM `skilled-sunrise-486800-j9.analise_logistica.geolocalizacao`;



-- Foi identificado que existem 981.148 registros duplicados, logo precisamos tratar essas duplicatas e, uma vez definidos os valores exclusivos, essa coluna de geolocation_zip_code_prefix poderá funcionar como chave primária. São exatos 19.015 códigos postais distintos.


SELECT DISTINCT
LPAD (CAST (geolocation_zip_code_prefix AS STRING), 5, '0') AS location_add_0
FROM `skilled-sunrise-486800-j9.analise_logistica.geolocalizacao`
WHERE geolocation_zip_code_prefix IS NOT NULL;


-- O resultado retornou 19.015 linhas de valores exclusivos. Ainda acrescentei a cláusula WHERE que garante que os códigos postais nunca sejam nulos. 


-- CRIAÇÃO DA CTE DE LIMPEZA


WITH mudanca_tipo_str AS (



SELECT 
    geolocation_city, 
    geolocation_state,
    CAST (geolocation_zip_code_prefix AS STRING) AS geolocation_string
 FROM `skilled-sunrise-486800-j9.analise_logistica.geolocalizacao`

),


nulos AS (


SELECT 
    geolocation_string, 
    geolocation_city, 
    geolocation_state

 FROM mudanca_tipo_str

WHERE 
    geolocation_string IS NOT NULL
    AND geolocation_city IS NOT NULL
    AND geolocation_state IS NOT NULL

),

espaco_removido AS (

SELECT 
    TRIM (geolocation_string) AS geo_string, 
    TRIM (geolocation_city) AS nome_cidade, 
    TRIM (geolocation_state) AS nome_estados

 FROM nulos

),



acrescimo_zero_esq AS (


SELECT 
    nome_cidade,
    nome_estados,
(LPAD(CAST(geo_string AS STRING), 5, '0')) AS location_add_0
FROM espaco_removido

),


cidade_inic_maiusc AS (



SELECT
    location_add_0,  
    nome_estados,
 REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(INITCAP(REPLACE(nome_cidade, '_', ' ')),
      ' E ', ' e '), ' De ', ' de '), ' Da ', ' da '), ' Do ', ' do '),
      ' Em ', ' em '), ' Com ', ' com '), ' Para ', ' para '), ' Por ', ' por '), 'ã', 'a'), 'á', 'a'), 'ó', 'o'), 'é', 'e'), 'í', 'i'), 'ú', 'u'), 'à', 'a'), 'â', 'a'), 'ç', 'c') AS nome_inicial_maiuscula
FROM acrescimo_zero_esq

),


integridade_siglas AS (


SELECT
    location_add_0, 
    nome_inicial_maiuscula, 
    UPPER (nome_estados) AS sigla_estado
FROM cidade_inic_maiusc
WHERE nome_estados IN ('AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA', 'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN', 'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO')

),


cte_final AS (

SELECT
    location_add_0, 
    nome_inicial_maiuscula, 
    sigla_estado
FROM integridade_siglas

)

SELECT
    location_add_0, 
    MAX(nome_inicial_maiuscula) AS nome_inicial_maiuscula, 
    MAX(sigla_estado) AS sigla_estado
FROM cte_final
GROUP BY location_add_0 
ORDER BY location_add_0;

/*

JUSTIFICATIVA DO USO DA FUNÇÃO MAX (): 
Ao contrário do que muitos pensam, as funções MAX() e MIN() não servem apenas para números. No SQL, quando aplicadas a colunas do tipo STRING, elas utilizam a Ordem Lexicográfica para determinar qual string permanece e quais serão "descartadas".  
Para garantir que a coluna location_add_0 (CEP) atue como uma Chave Primária íntegra e sem duplicatas, foi utilizada a cláusula GROUP BY. Como o dataset original de geolocalização da Olist apresenta múltiplas entradas para o mesmo prefixo de CEP (devido a diferentes coordenadas geográficas e variações na grafia dos nomes das cidades), aplicou-se a função de agregação MAX() nas colunas de Cidade e Estado. Em uma situação de um duplo registro, ou registros múltiplos, a função vai permitir escolher um desses registros como o único válido e descartar os demais.
-- Essa abordagem garante que, em caso de inconsistências de digitação para o mesmo código postal, o SQL selecione de forma determinística apenas uma representação textual, evitando o erro de duplicação nas chaves e permitindo a conexão única com as outras tabelas.

-- Observe que o resultado final me retornou exatas 19.015 linhas, ou seja, 19.015 registros exclusivos. Esse número é coerente com o encontrado em etapas anteriores, em que utilizei o DISTINT para extrair os registros distintos.

*/



-- Transformando a CTE de limpeza em uma tabela permanete através do comando CREATE OR REPLACE TABLE:




CREATE OR REPLACE TABLE `skilled-sunrise-486800-j9.analise_logistica.tabela_geolocalizacao_analise` AS 


WITH mudanca_tipo_str AS (



SELECT 
    geolocation_city, 
    geolocation_state,
    CAST (geolocation_zip_code_prefix AS STRING) AS geolocation_string
 FROM `skilled-sunrise-486800-j9.analise_logistica.geolocalizacao`

),


nulos AS (


SELECT 
    geolocation_string, 
    geolocation_city, 
    geolocation_state

 FROM mudanca_tipo_str

WHERE 
    geolocation_string IS NOT NULL
    AND geolocation_city IS NOT NULL
    AND geolocation_state IS NOT NULL

),

espaco_removido AS (

SELECT 
    TRIM (geolocation_string) AS geo_string, 
    TRIM (geolocation_city) AS nome_cidade, 
    TRIM (geolocation_state) AS nome_estados

 FROM nulos

),



acrescimo_zero_esq AS (


SELECT 
    nome_cidade,
    nome_estados,
(LPAD(CAST(geo_string AS STRING), 5, '0')) AS location_add_0
FROM espaco_removido

),


cidade_inic_maiusc AS (



SELECT
    location_add_0,  
    nome_estados,
 REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(INITCAP(REPLACE(nome_cidade, '_', ' ')),
      ' E ', ' e '), ' De ', ' de '), ' Da ', ' da '), ' Do ', ' do '),
      ' Em ', ' em '), ' Com ', ' com '), ' Para ', ' para '), ' Por ', ' por '), 'ã', 'a'), 'á', 'a'), 'ó', 'o'), 'é', 'e'), 'í', 'i'), 'ú', 'u'), 'à', 'a'), 'â', 'a'), 'ç', 'c') AS nome_inicial_maiuscula
FROM acrescimo_zero_esq

),


integridade_siglas AS (


SELECT
    location_add_0, 
    nome_inicial_maiuscula, 
    UPPER (nome_estados) AS sigla_estado
FROM cidade_inic_maiusc
WHERE nome_estados IN ('AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA', 'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN', 'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO')

),


cte_final AS (

SELECT
    location_add_0, 
    nome_inicial_maiuscula, 
    sigla_estado
FROM integridade_siglas

)

SELECT
    location_add_0 AS geoloc_ajustada, 
    MAX(nome_inicial_maiuscula) AS cidade_geoloc, 
    MAX(sigla_estado) AS estado_geoloc
FROM cte_final
GROUP BY geoloc_ajustada 
ORDER BY geoloc_ajustada;
























