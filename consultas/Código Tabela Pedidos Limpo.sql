
-- ETAPA 0
-- Aplicação do teste de análise estatística descritiva agrupada
-- Teste de Homocedasticidade


-- Conclusão: Não foi possível aplicar o teste, pois essa tabela trabalha basicamente com STRINGS.  



-- ETAPA 1
-- Limpeza da tabela

-- Para essa tabela em específico, não farei uma exposição detalhada da limpeza como fiz na tabela de Densidade de Carga, pois o processo já foi devidamente detalhado. Agora vou me deter em limpar rapidamente o que for necessário e consolidar todas as etapas de limpeza em uma única CTE. 

-- A tabela de Pedidos (que é objeto desta análise), conforme verificado, não foi submetida ao teste de Homocedasticidade. As as colunas do tipo TIMESTAMP (datas) não fazem parte do escopo e objetivos desse projeto, pois não pretendo analisar prazos de entrega. Sendo assim, há dois elementos nessa tabela que são cruciais para o andamento do projeto: as colunas order_id e customer_id. Elas são importantes, pois funcionam como chaves primárias, o que me permite a conexão com outras tabelas através da função JOIN. Portanto, usarei essas duas colunas como chaves de conexão entre tabelas relacionais. 


-- Valores Nulos

        SELECT  order_id, customer_id, order_status
    FROM `skilled-sunrise-486800-j9.analise_logistica.pedidos` 
    WHERE order_id IS NULL OR customer_id IS NULL OR order_status IS NULL;

-- Não foram detectados valores nulos.


-- Espaço excessivo entre os dados:

    SELECT  
        TRIM (order_id) AS idpedido_sem_espaco, 
        TRIM (customer_id) AS idcliente_sem_espaco,
        TRIM (order_status) AS status_sem_espaco
    FROM `skilled-sunrise-486800-j9.analise_logistica.pedidos`;


-- Como estamos diantes de IDs formados por HASHS, não há necessidade de verificação quanto às iniciais serem maiúsculas ou não, pois qualquer alteração dessa natureza, corromperia a integridade e consistência do ID.

-- Também não há necessidade de validação de tipo, pois as três já são STRINGS e devem permanecer assim.


-- Verificando o conteúdo da coluna order_status:


SELECT DISTINCT order_status 
FROM `skilled-sunrise-486800-j9.analise_logistica.pedidos`
WHERE order_status <> 'approved'
AND order_status <> 'canceled'
GROUP BY order_status;

-- As primeiras linhas da tabela só mostravam pedidos aprovados ou cancelados, mas a função acima revelou que ela ainda filtra os pedidos por outros tipos de status: created, delivered, invoiced, processing, shipped e unavailable. Esses tipos de status serão importantes para fazermos análises específicas sobre os pedidos. Os resultados exclusivos demonstram que não há inconsistências de escrita. 

-- Transformando o conteúdo da coluna para iniciais maiúsculas:

SELECT INITCAP (order_status) 
FROM `skilled-sunrise-486800-j9.analise_logistica.pedidos`;



-- Criando um filtro para rejeitar qualquer palavra que seja diferente de Approved, Canceled, Created, Delivered, Invoiced, Processing, Shipped e Unavailable.

SELECT INITCAP (order_status) AS status_pedido
FROM `skilled-sunrise-486800-j9.analise_logistica.pedidos`
WHERE order_status IN ( 'approved', 'canceled', 'created', 'delivered', 'invoiced', 'processing', 'shipped', 'unavailable');




-- Validação dos padrões dos IDs usando o REGEXP:

SELECT
    order_id, customer_id,
  FROM
  `skilled-sunrise-486800-j9`.`analise_logistica`.`pedidos`
  WHERE 
  NOT REGEXP_CONTAINS (order_id, r'^[a-f0-9A-F]{32}$') OR
  NOT REGEXP_CONTAINS (customer_id, r'^[a-f0-9A-F]{32}$');

-- Não foram detectados problemas de integridade nos hashs.

-- Não há necessidade de testar de mínimo, máximo, valores negativos ou zerados, devido à natureza de string das variáveis. 

-- Remoção de duplicatas:


SELECT 
    COUNT (*) AS total_linhas,
    COUNT (DISTINCT order_id) AS id_pedido_unico,
    COUNT (*) - COUNT (DISTINCT order_id) AS duplicatas
FROM`skilled-sunrise-486800-j9`.`analise_logistica`.`pedidos`;

-- Não foram encontrados valores duplicados em relação à coluna order_id.


SELECT 
    COUNT (*) AS total_linhas1,
    COUNT (DISTINCT customer_id) AS id_cliente_unico,
    COUNT (*) - COUNT (DISTINCT customer_id) AS duplicatas1
FROM`skilled-sunrise-486800-j9`.`analise_logistica`.`pedidos`;

-- Não foram encontrados valores duplicados em relação à coluna customer_id.



-- CRIAÇÃO DA CTE DE LIMPEZA

-- A CTE abaixo exibe as informações que preciso já no formato de tabela LIMPA.



WITH tipos_de_status AS (
    

SELECT INITCAP (order_status) AS status,
                order_id, 
                customer_id
FROM `skilled-sunrise-486800-j9.analise_logistica.pedidos`
WHERE order_status IN ( 'approved', 'canceled', 'created', 'delivered', 'invoiced', 'processing', 'shipped', 'unavailable')

),


valor_nulo_tratado AS (


SELECT order_id, customer_id, status
    FROM tipos_de_status
    WHERE order_id IS NOT NULL AND customer_id IS NOT NULL AND status IS NOT NULL

),

espaco_removido AS (
    SELECT 
        TRIM (order_id) AS idpedido_sem_espaco, 
        TRIM (customer_id) AS idcliente_sem_espaco,
        TRIM (status) AS status_sem_espaco
    FROM valor_nulo_tratado
),

integridade_hash AS (
    SELECT 
        idpedido_sem_espaco,
        idcliente_sem_espaco,
        status_sem_espaco
    FROM espaco_removido
    WHERE 
        REGEXP_CONTAINS(idpedido_sem_espaco, r'^[a-f0-9A-F]{32}$') AND
        REGEXP_CONTAINS(idcliente_sem_espaco, r'^[a-f0-9A-F]{32}$')
),

limpeza_final AS (
    
    SELECT DISTINCT 
        idpedido_sem_espaco, 
        idcliente_sem_espaco,
        ANY_VALUE (status_sem_espaco) 
    FROM integridade_hash
    GROUP BY 1, 2
)

SELECT * FROM limpeza_final;




-- CRIAÇÃO DA TABELA A PARTIR DA CTE DE LIMPEZA:


CREATE OR REPLACE TABLE `skilled-sunrise-486800-j9.analise_logistica.status_pedido_analise` AS


WITH tipos_de_status AS (
    

SELECT INITCAP (order_status) AS status,
                order_id, 
                customer_id
FROM `skilled-sunrise-486800-j9.analise_logistica.pedidos`
WHERE order_status IN ( 'approved', 'canceled', 'created', 'delivered', 'invoiced', 'processing', 'shipped', 'unavailable')

),


valor_nulo_tratado AS (


SELECT order_id, customer_id, status
    FROM tipos_de_status
    WHERE order_id IS NOT NULL AND customer_id IS NOT NULL AND status IS NOT NULL

),

espaco_removido AS (
    SELECT 
        TRIM (order_id) AS idpedido_sem_espaco, 
        TRIM (customer_id) AS idcliente_sem_espaco,
        TRIM (status) AS status_sem_espaco
    FROM valor_nulo_tratado
),

integridade_hash AS (
    SELECT 
        idpedido_sem_espaco,
        idcliente_sem_espaco,
        status_sem_espaco
    FROM espaco_removido
    WHERE 
        REGEXP_CONTAINS(idpedido_sem_espaco, r'^[a-f0-9A-F]{32}$') AND
        REGEXP_CONTAINS(idcliente_sem_espaco, r'^[a-f0-9A-F]{32}$')
),

limpeza_final AS (
    
    SELECT DISTINCT 
        idpedido_sem_espaco AS id_pedido_ajust, 
        idcliente_sem_espaco AS id_cliente_ajust,
        ANY_VALUE (status_sem_espaco) AS status_pedido_ajust
    FROM integridade_hash
    GROUP BY 1, 2
)

SELECT * FROM limpeza_final;














    


