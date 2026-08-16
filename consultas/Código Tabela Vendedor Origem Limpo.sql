-- ETAPA 0
-- Aplicação do teste de análise estatística descritiva agrupada
-- Teste de Homocedasticidade


-- Conclusão: Não foi possível aplicar o teste, pois essa tabela trabalha basicamente com STRINGS.  



-- ETAPA 1
-- Limpeza de Dados

-- Identificando valores nulos:


SELECT
    seller_id, 
    seller_zip_code_prefix, 
    seller_city, 
    seller_state
FROM `skilled-sunrise-486800-j9.analise_logistica.vendedor_origem`

    WHERE 
    seller_id IS NULL 
    OR seller_zip_code_prefix IS NULL 
    OR seller_city IS NULL 
    OR seller_state IS NULL;

-- Não foram detectados valores nulos. O resultado está de acordo com o esperado, pricipalmente em relação à coluna seller_id, pois ela funciona como chave primária e não pode, em tese, ter valores nulos. 


-- Mudando o tipo de dado da coluna seller_zip_code_prefix de INTEGER para STRING
-- JUSTIFICATIVA: Campos numéricos (como INT ou FLOAT) removem automaticamente zeros à esquerda. Se um CEP for 01234-567 e estiver como número, ele será armazenado como 1234567. Ao converter para STRING, você garante que a estrutura original seja mantida.

SELECT
    CAST (seller_zip_code_prefix AS STRING) AS prefixo_alterado
FROM `skilled-sunrise-486800-j9.analise_logistica.vendedor_origem`;



-- Testando se foi realmente transformado em STRING
-- Vou usar o CAST associado a um argumento que só funciona com números. Num dado do tipo string, eu não consigo realizar operações matemáticas, portanto se o CAST deu certo, o código me retornará um erro. Assim como existem funções exclusivas para strings (a função LENGTH e TRIM, por exemplo), também existem certas funções e operações que só funcionam com dados do tipo número. Se eu realmente consegui transformar a coluna seller_zip_code_prefix de INTEGER para STRING, ao rodar o código abaixo, o sistema exibirá um erro.

/*

SELECT
    CAST (seller_zip_code_prefix AS STRING) AS prefixo_alterado
FROM `skilled-sunrise-486800-j9.analise_logistica.vendedor_origem`
    WHERE CAST (seller_zip_code_prefix AS STRING) > 0;

*/

-- Como esperado, o erro aconteceu, confirmando que a função CAST realmente mudou a natureza do dado de INTEGER para STRING. A função de filtragem foi incapaz de retornar resultados maiores que zero, pois a coluna seller_zip_code_prefix não está sendo mais tratada como número, e sim como texto. 



-- Removendo espaços excessivos:
-- Visto que a coluna seller_zip_code_prefix é do tipo INTEGER na tabela original, terei que aplicar a função CAST aqui também, pois a função TRIM é exclusiva para STRINGS. Se eu não aplicar o CAST, o código quebra. 


SELECT 
        TRIM (seller_id) AS id_sem_esp, 
        TRIM (CAST (seller_zip_code_prefix AS STRING)) AS cep_sem_esp, 
        TRIM (seller_city) AS cidade_sem_esp,
        TRIM (seller_state) AS vend_sem_esp
       
FROM `skilled-sunrise-486800-j9.analise_logistica.vendedor_origem`;



-- Testando o comprimento dos dados da coluna seller_zip_code_prefix através da função LENGTH ():


SELECT
    seller_zip_code_prefix,
    LENGTH (CAST (seller_zip_code_prefix AS STRING)) AS tamanho
    FROM `skilled-sunrise-486800-j9.analise_logistica.vendedor_origem`
    GROUP BY seller_zip_code_prefix
    HAVING LENGTH (CAST (seller_zip_code_prefix AS STRING)) <> 4;

-- Foram encontrados 1.415 registros cujo código da cidade é diferente de 4, ou seja, 1.415 registros cujo comprimento é 5. 
-- A explicação para essa variação pode ser a INEXISTÊNCIA do algarismo 0 NO INÍCIO desses códigos de 5 dígitos. Posto que na tabela original os códigos são tratados como números (INTEGER), a tendência é que o sistema remova os zeros que estâo à esquerda. A ideia agora é acrescentar o algarismo 0 no início de cada código de 4 algarismos para que fiquem todos no padrão adotado no Brasil (5 dígitos iniciais). Assim, o comprimento 5 que vemos como resultado ao executar o código, é o valor esperado do tamanho e presisamos padronizar a coluna inteira para 5 dígitos.


-- Testando se há mais valores heterogêneos:

SELECT 
    LENGTH(CAST(seller_zip_code_prefix AS STRING)) AS comprimento,
    COUNT(*) AS quantidade_de_linhas,
    COUNT(DISTINCT seller_zip_code_prefix) AS cp_unicos
FROM `skilled-sunrise-486800-j9.analise_logistica.vendedor_origem`
GROUP BY 1
ORDER BY 1;

-- De acordo com o resultado obtido, só há duas espécies de comprimento (4 ou 5 dígitos), o que aumenta ainda mais a suspeita de que o número faltante é o zero inicial (zero à esquerda) nas observações de 4 dígitos. São exatamente 1.027 observações de 4 dígitos.

-- Adicionando o número zero no início de todas as observações de 4 dígitos coma a função LPAD (LEFT PAD)
-- Essa função vai identificar todas as ocorrências de comprimento iguais a 4 e acrescentar um zero à esquerda.
-- O código abaixo converte para STRING e preenche com 0 até completar 5 dígitos.

SELECT 
    LPAD(CAST(seller_zip_code_prefix AS STRING), 5, '0') AS zip_code_limpo
  FROM `skilled-sunrise-486800-j9.analise_logistica.vendedor_origem`
WHERE LPAD(CAST(seller_zip_code_prefix AS STRING), 5, '0') LIKE '0%';

-- Pelo resultado mostrado no campo do NÚMERO DE LINHAS, 1.027 observações receberam o número zero em seu início e foram transformados em strings de 5 dígitos. O valor é coerente com a quantidade exibida pelo código anterior, que mostrava exatas 1.027 observações com 4 dígitos apenas. 

-- Testando a integridade dos IDs com o REGEXP:

SELECT
   seller_id
  FROM
  `skilled-sunrise-486800-j9.analise_logistica.vendedor_origem`
  WHERE 
  NOT REGEXP_CONTAINS (seller_id, r'^[a-f0-9A-F]{32}$');

-- Nenhuma inconsistência foi detectada nos hashes hexadecimais.


-- Testando se os IDs são exclusivos:

SELECT
    COUNT (*) AS total,
    COUNT (DISTINCT seller_id) AS val_exclusivos,
    COUNT (*) - COUNT (DISTINCT seller_id) AS numero_duplicadas
    FROM `skilled-sunrise-486800-j9.analise_logistica.vendedor_origem`;

-- O teste mostou que não há valores duplicados.



-- Removendo as inconsistências de escrita da coluna seller_city:

-- A coluna apresenta uma disposição de preenchimento bastante heterogênea, com presença de muitos caracteres especiais. Como não temos como prever quais caracteres podem aparecer dentro da coluna, vamos usar a função REGEXP_REPLACE para informar que só queremos manter o que for letra (com ou sem diacrítico, maiúscula ou minúscula, além do c-cedilha). A função TRIM permite remover espaços extras à esquerda e à direita do dado, a fim de padronizá-lo. 

SELECT 
    seller_id,
    TRIM (REGEXP_REPLACE(LOWER(seller_city), r'[^a-zA-Zá-úÁ-ÚãõÃÕçÇ\s]', ' ')) AS cidade_limpa
FROM `skilled-sunrise-486800-j9.analise_logistica.vendedor_origem`;

-- O resultado mostra que o aspecto da coluna melhorou bastante, mas as siglas dos estados ainda insistem em continuar aparecendo e devemos tratá-las.

-- Detectando a presença de caracteres especiais:


SELECT 
    seller_city,
    INITCAP(seller_city) AS cidade_limpa
FROM `skilled-sunrise-486800-j9.analise_logistica.vendedor_origem`
WHERE REGEXP_CONTAINS (seller_city, r'[0-9/*"@#%^&()_+§=|\\\[\].;:!]');

-- Foram detectadas 19 linhas com problemas graves de preenchimento. 


-- Em virtude da heterogeneidade dos dados, não consegui encontrar uma função que limpasse totalmente as inconsistências de escrita da coluna seller_city, mesmo usando inúmeros recursos avançados. Assim, optei por não mais usar essa coluna como referência. Minha ideia é usar a tabela de geolocalização e conectar ambas (a tabela de geolocalização e esta) usando o código postal como chave primária. 


-- Tratando inconsistência de escrita referente à sigla dos estados.


SELECT
    seller_state
FROM `skilled-sunrise-486800-j9.analise_logistica.vendedor_origem`
WHERE seller_state NOT IN ('AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA', 'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN', 'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO');

-- Não foram detectadas inconsistências de escrita na coluna seller_state. 




-- Testando se há duplicatas na coluna seller_id.

SELECT 
    COUNT(*) AS tot_linhas,
    COUNT(DISTINCT seller_id) AS ids_distinct,
    COUNT(*) - COUNT(DISTINCT seller_id) AS qtd_duplicadas
FROM `skilled-sunrise-486800-j9.analise_logistica.vendedor_origem`;

-- Não foram detectadas duplicatas na coluna seller_id. O resultado obtido está dentro do esperado, pois colunas de IDs (que normalmente servem como chaves primárias) não podem ter valores duplicados. Cada registro deve ser único. 



-- CRIANDO CTE DE LIMPEZA




WITH sigla_limpa AS (


SELECT
    seller_id, 
    seller_zip_code_prefix, 
    seller_city, 
    UPPER (seller_state) AS state_venda
FROM `skilled-sunrise-486800-j9.analise_logistica.vendedor_origem`
WHERE seller_state IN 
('AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA',
 'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN', 
 'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO')

),



limp_nulos AS (


SELECT 
    seller_id, 
    seller_zip_code_prefix,  
    state_venda
FROM sigla_limpa

    WHERE 
    seller_id IS NOT NULL 
    AND seller_zip_code_prefix IS NOT NULL 
    AND seller_city IS NOT NULL 
    AND state_venda IS NOT NULL

),


tipo_alterado AS (


SELECT
    state_venda,
    (seller_id),
    CAST (seller_zip_code_prefix AS STRING) AS prefixo_alterado
FROM limp_nulos

),

espaco_limpo AS (


SELECT 
        state_venda,
        (TRIM (seller_id)) AS id_sem_esp, 
        (TRIM (CAST (prefixo_alterado AS STRING))) AS cep_sem_esp
    FROM tipo_alterado


),

cep_add_zero_limpo AS (


SELECT
    state_venda,
    id_sem_esp,
    (LPAD(CAST(cep_sem_esp AS STRING), 5, '0')) AS zip_code_limpo
  FROM espaco_limpo

), 

integridade_regex AS (

SELECT
   state_venda,
   id_sem_esp,
   zip_code_limpo
  FROM cep_add_zero_limpo
  
WHERE REGEXP_CONTAINS (id_sem_esp, r'^[a-f0-9A-F]{32}$')


),


cte_limpa AS (

SELECT
    state_venda,
    id_sem_esp,
    ANY_VALUE(zip_code_limpo) AS zip_code_limpo

FROM integridade_regex
GROUP BY 
    id_sem_esp,
    state_venda


)

SELECT * FROM cte_limpa;

-- O GROUP BY no final da consulta me garante que os IDs serão sempre distintos e que os CEPs poderão variar livremente conforme rotas de entrega. Isso  é garantido pelo uso da função ANY_VALUE. A ação é necessária para que a chave primária (a coluna seller_id) sempre exiba valores exclusivos. 




-- CRIANDO UMA TABELA A PARTIR DA CTE DE LIMPEZA:


CREATE OR REPLACE TABLE `skilled-sunrise-486800-j9.analise_logistica.tabela_vendedor_analise` AS




WITH sigla_limpa AS (


SELECT
    seller_id, 
    seller_zip_code_prefix, 
    seller_city, 
    UPPER (seller_state) AS state_venda
FROM `skilled-sunrise-486800-j9.analise_logistica.vendedor_origem`
WHERE seller_state IN 
('AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA',
 'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN', 
 'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO')

),



limp_nulos AS (


SELECT 
    seller_id, 
    seller_zip_code_prefix,  
    state_venda
FROM sigla_limpa

    WHERE 
    seller_id IS NOT NULL 
    AND seller_zip_code_prefix IS NOT NULL 
    AND seller_city IS NOT NULL 
    AND state_venda IS NOT NULL

),


tipo_alterado AS (


SELECT
    state_venda,
    (seller_id),
    CAST (seller_zip_code_prefix AS STRING) AS prefixo_alterado
FROM limp_nulos

),

espaco_limpo AS (


SELECT 
        state_venda,
        (TRIM (seller_id)) AS id_sem_esp, 
        (TRIM (CAST (prefixo_alterado AS STRING))) AS cep_sem_esp
    FROM tipo_alterado


),

cep_add_zero_limpo AS (


SELECT
    state_venda,
    id_sem_esp,
    (LPAD(CAST(cep_sem_esp AS STRING), 5, '0')) AS zip_code_limpo
  FROM espaco_limpo

), 

integridade_regex AS (

SELECT
   state_venda,
   id_sem_esp,
   zip_code_limpo
  FROM cep_add_zero_limpo
  
WHERE REGEXP_CONTAINS (id_sem_esp, r'^[a-f0-9A-F]{32}$')


),


cte_limpa AS (

SELECT
    state_venda AS estado_origem_vend,
    id_sem_esp AS id_orig_vend,
    ANY_VALUE(zip_code_limpo) AS codigopostal_ajust

FROM integridade_regex
GROUP BY 
    id_sem_esp,
    state_venda


)

SELECT * FROM cte_limpa;





