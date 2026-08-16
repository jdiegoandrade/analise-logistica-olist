-- ETAPA 0
-- Aplicação do teste de análise estatística descritiva agrupada
-- Teste de Homocedasticidade


-- Conclusão: Não foi possível aplicar o teste, pois essa tabela trabalha basicamente com STRINGS.  



-- ETAPA 1

-- Para essa tabela em específico, não farei uma exposição detalhada da limpeza como fiz na tabela de Densidade de Carga, pois o processo já foi devidamente detalhado. Agora vou me deter em limpar rapidamente o que for necessário e consolidar todas as etapas de limpeza em uma única CTE. 

-- A tabela de Itens (que é objeto desta análise) foi reprovada, conforme pode ser verificado no teste de Homocedasticidade/ANOVA que apliquei. O resultado indicou que as colunas price  e freight_valuenão apresentavam variabilidades típicas de dados reais, sendo, portanto, dados sintéticos. 


-- Limpeza dos dados da tabela itens.

-- Detectando valores nulos

SELECT order_id, product_id, seller_id 
FROM `skilled-sunrise-486800-j9.analise_logistica.itens` 
    WHERE order_id IS NULL OR product_id IS NULL OR seller_id IS NULL;

-- Não foram detectados valores nulos.


-- Remoção de espaços em branco:

    SELECT 
        TRIM (order_id) AS ped_sem_esp, 
        TRIM (product_id) AS prod_sem_esp, 
        TRIM (seller_id) AS vend_sem_esp
FROM `skilled-sunrise-486800-j9.analise_logistica.itens`;



-- Verificação da integridade dos hashes:


SELECT
    order_id,
    product_id,
    seller_id
  FROM
  `skilled-sunrise-486800-j9.analise_logistica.itens`
  WHERE 
  NOT REGEXP_CONTAINS (order_id, r'^[a-f0-9A-F]{32}$') OR
  NOT REGEXP_CONTAINS (product_id, r'^[a-f0-9A-F]{32}$') OR
  NOT REGEXP_CONTAINS(seller_id, r'^[a-f0-9A-F]{32}$');

  -- Não foram encontradas inconsistências na integridade dos hashes.


  -- Verificando a existência de valores duplicados:


SELECT 
    COUNT (*) AS total_1,
    COUNT (DISTINCT order_id) AS id_ped,
    COUNT (*) - COUNT (DISTINCT order_id) AS dupl1
FROM `skilled-sunrise-486800-j9.analise_logistica.itens`;

-- Foram detectadas 13.984 valores duplicados na coluna order_id


SELECT 
    COUNT (*) AS total_2,
    COUNT (DISTINCT product_id) AS id_prod,
    COUNT (*) - COUNT (DISTINCT product_id) AS dupl2
FROM `skilled-sunrise-486800-j9.analise_logistica.itens`;

-- Foram detectados 79.699 valores duplicados na coluna product_id


SELECT 
    COUNT (*) AS total_3,
    COUNT (DISTINCT seller_id) AS id_vend,
    COUNT (*) - COUNT (DISTINCT seller_id) AS dupl3
FROM `skilled-sunrise-486800-j9.analise_logistica.itens`;

-- Foram identificados 109.555 valores duplicados na tabela seller_id


-- Tratando os valores duplicados:

-- Tratando as duplicadas da coluna order_id

SELECT DISTINCT order_id 
FROM `skilled-sunrise-486800-j9.analise_logistica.itens`;


-- Tratando as duplicadas da coluna product_id

SELECT DISTINCT product_id 
FROM `skilled-sunrise-486800-j9.analise_logistica.itens`;



-- Tratando as duplicadas da coluna seller_id

SELECT DISTINCT seller_id 
FROM `skilled-sunrise-486800-j9.analise_logistica.itens`;


-- Nessa tabela não foi necessário verificar maiísculas, minúsculas, validação de tipos, nem mínimo e máximo. 




-- CRIANDO A CTE DE LIMPEZA



WITH sem_nulos_1 AS (



    SELECT *
FROM `skilled-sunrise-486800-j9.analise_logistica.itens` 
    WHERE order_id IS NOT NULL AND product_id IS NOT NULL AND seller_id IS NOT NULL

),

sem_espacos AS (


    SELECT 
        TRIM(order_id) AS ped_sem_esp, 
        TRIM(product_id) AS prod_sem_esp, 
        TRIM(seller_id) AS vend_sem_esp
    FROM sem_nulos_1
),

integr_hash AS (

    SELECT
        ped_sem_esp,
        prod_sem_esp,
        vend_sem_esp
    FROM sem_espacos
    WHERE 
        REGEXP_CONTAINS(ped_sem_esp, r'^[a-f0-9A-F]{32}$') AND
        REGEXP_CONTAINS(prod_sem_esp, r'^[a-f0-9A-F]{32}$') AND
        REGEXP_CONTAINS(vend_sem_esp, r'^[a-f0-9A-F]{32}$')
),

limpeza_concluida AS (
    
    SELECT DISTINCT 
        ped_sem_esp,
        prod_sem_esp,
        vend_sem_esp
    FROM integr_hash
)

SELECT * FROM limpeza_concluida;




-- CRIANDO A TABELA A PARTIR DA CTE DE LIMPEZA:


CREATE OR REPLACE TABLE `skilled-sunrise-486800-j9.analise_logistica.tabela_id_analise` AS



WITH sem_nulos_1 AS (



    SELECT *
FROM `skilled-sunrise-486800-j9.analise_logistica.itens` 
    WHERE order_id IS NOT NULL AND product_id IS NOT NULL AND seller_id IS NOT NULL

),

sem_espacos AS (


    SELECT 
        TRIM(order_id) AS ped_sem_esp, 
        TRIM(product_id) AS prod_sem_esp, 
        TRIM(seller_id) AS vend_sem_esp
    FROM sem_nulos_1
),

integr_hash AS (
    SELECT
        ped_sem_esp,
        prod_sem_esp,
        vend_sem_esp
    FROM sem_espacos
    WHERE 
        REGEXP_CONTAINS(ped_sem_esp, r'^[a-f0-9A-F]{32}$') AND
        REGEXP_CONTAINS(prod_sem_esp, r'^[a-f0-9A-F]{32}$') AND
        REGEXP_CONTAINS(vend_sem_esp, r'^[a-f0-9A-F]{32}$')
),

limpeza_concluida AS (
    
    SELECT DISTINCT 
        ped_sem_esp AS id_pedido_ajustado,
        prod_sem_esp AS id_produto_ajustado,
        vend_sem_esp AS id_vendedor_ajustado
    FROM integr_hash
)

SELECT * FROM limpeza_concluida;




