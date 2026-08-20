
-- Executando os JOINS e concetando as tabelas


SELECT 
    dc.*, ids.*, ped.*, ven.*, cli.*, geo.* -- Qualificação de Escopo


FROM `skilled-sunrise-486800-j9.analise_logistica.dimensoes_carga_analise` AS dc  -- Tabela fato (hub)


-- 1. Engatando o Hub na tabela de ítens, aqui renomeada como "tabela_id_analise"


LEFT JOIN `skilled-sunrise-486800-j9.analise_logistica.tabela_id_analise` AS ids  -- Tabela dimensão 1
  ON ids.id_produto_ajustado = dc.id_produto_ajust2

-- 2. Engatando a tabela ítens com os pedidos


LEFT JOIN `skilled-sunrise-486800-j9.analise_logistica.status_pedido_analise` AS ped  -- Tabela dimensão 2
  ON ped.id_pedido_ajust = ids.id_pedido_ajustado

-- 3. Engatando o pedido com os clientes

LEFT JOIN `skilled-sunrise-486800-j9.analise_logistica.tabela_cliente_analise` AS cli  -- Tabela dimensão 3
  ON cli.cliente_pk_limpo = ped.id_cliente_ajust

-- 4. Engatando os clientes com o vendedor

LEFT JOIN `skilled-sunrise-486800-j9.analise_logistica.tabela_vendedor_analise` AS ven  -- Tabela dimensão 4
  ON ven.id_orig_vend = ids.id_vendedor_ajustado

-- 5. Engatando o vendedor com geolocalização 

LEFT JOIN `skilled-sunrise-486800-j9.analise_logistica.tabela_geolocalizacao_analise` AS geo  -- Tabela dimensão 5
  ON geo.geoloc_ajustada = cli.cod_postal_ajust;


-- Usando a estrutura de uma CTE para criar tabelas temporárias


WITH tabela_mestra AS (

  
  SELECT 
    dc.*, ids.*, ped.*, ven.*, cli.*, geo.*
FROM `skilled-sunrise-486800-j9.analise_logistica.dimensoes_carga_analise` AS dc


LEFT JOIN `skilled-sunrise-486800-j9.analise_logistica.tabela_id_analise` AS ids
  ON ids.id_produto_ajustado = dc.id_produto_ajust2


LEFT JOIN `skilled-sunrise-486800-j9.analise_logistica.status_pedido_analise` AS ped
  ON ped.id_pedido_ajust = ids.id_pedido_ajustado


LEFT JOIN `skilled-sunrise-486800-j9.analise_logistica.tabela_cliente_analise` AS cli
  ON cli.cliente_pk_limpo = ped.id_cliente_ajust


LEFT JOIN `skilled-sunrise-486800-j9.analise_logistica.tabela_vendedor_analise` AS ven
  ON ven.id_orig_vend = ids.id_vendedor_ajustado


LEFT JOIN `skilled-sunrise-486800-j9.analise_logistica.tabela_geolocalizacao_analise` AS geo
  ON geo.geoloc_ajustada = cli.cod_postal_ajust
)

SELECT * 
FROM tabela_mestra;


-- Criando uma TABELA ANALÍTICA PERMANENTE a partir da CTE para aplicar a ESTATÍSTICA DESCRITIVA:




CREATE OR REPLACE TABLE
`skilled-sunrise-486800-j9.analise_logistica.base_analitica` AS

WITH tabela_mestra AS (

  SELECT 
    dc.*, 
    ids.*, 
    ped.*, 
    ven.*,
    cli.*, 
    geo.*

  FROM `skilled-sunrise-486800-j9.analise_logistica.dimensoes_carga_analise` AS dc

  LEFT JOIN `skilled-sunrise-486800-j9.analise_logistica.tabela_id_analise` AS ids
    ON ids.id_produto_ajustado = dc.id_produto_ajust2

  LEFT JOIN `skilled-sunrise-486800-j9.analise_logistica.status_pedido_analise` AS ped
    ON ped.id_pedido_ajust = ids.id_pedido_ajustado

  LEFT JOIN `skilled-sunrise-486800-j9.analise_logistica.tabela_cliente_analise` AS cli
    ON cli.cliente_pk_limpo = ped.id_cliente_ajust

  LEFT JOIN `skilled-sunrise-486800-j9.analise_logistica.tabela_vendedor_analise` AS ven
    ON ven.id_orig_vend = ids.id_vendedor_ajustado

  LEFT JOIN `skilled-sunrise-486800-j9.analise_logistica.tabela_geolocalizacao_analise` AS geo
    ON geo.geoloc_ajustada = cli.cod_postal_ajust
)

SELECT *
FROM tabela_mestra;


