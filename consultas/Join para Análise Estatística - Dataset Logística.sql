
-- Executando os JOINS e concetando as tabelas

-- Explicar o diagrama entidade-relacionamento e o Hub

SELECT 
    dc.*, ids.*, ped.*, ven.*, cli.*, geo.*
FROM `skilled-sunrise-486800-j9.analise_logistica.dimensoes_carga_analise` AS dc

-- 1. Engata o Hub na Carga 
LEFT JOIN `skilled-sunrise-486800-j9.analise_logistica.tabela_id_analise` AS ids
  ON ids.id_produto_ajustado = dc.id_produto_ajust2

-- 2. Engata o Pedido no Hub
LEFT JOIN `skilled-sunrise-486800-j9.analise_logistica.status_pedido_analise` AS ped
  ON ped.id_pedido_ajust = ids.id_pedido_ajustado

-- 3. Engata o Cliente no Pedido 
LEFT JOIN `skilled-sunrise-486800-j9.analise_logistica.tabela_cliente_analise` AS cli
  ON cli.cliente_pk_limpo = ped.id_cliente_ajust

-- 4. Engata o Vendedor no Hub
LEFT JOIN `skilled-sunrise-486800-j9.analise_logistica.tabela_vendedor_analise` AS ven
  ON ven.id_orig_vend = ids.id_vendedor_ajustado

-- 5. Engata a Geolocalização no Cliente (Destino da carga)
LEFT JOIN `skilled-sunrise-486800-j9.analise_logistica.tabela_geolocalizacao_analise` AS geo
  ON geo.geoloc_ajustada = cli.cod_postal_ajust;

 


-- Usando a estrutura de uma CTE para criar tabelas temporárias



WITH tabela_mestra AS (

  
  SELECT 
    dc.*, ids.*, ped.*, ven.*, cli.*, geo.*
FROM `skilled-sunrise-486800-j9.analise_logistica.dimensoes_carga_analise` AS dc

-- 1. Engata o Hub na Carga
LEFT JOIN `skilled-sunrise-486800-j9.analise_logistica.tabela_id_analise` AS ids
  ON ids.id_produto_ajustado = dc.id_produto_ajust2

-- 2. Engata o Pedido no Hub
LEFT JOIN `skilled-sunrise-486800-j9.analise_logistica.status_pedido_analise` AS ped
  ON ped.id_pedido_ajust = ids.id_pedido_ajustado

-- 3. Engata o Cliente no Pedido (Conforme seu diagrama)
LEFT JOIN `skilled-sunrise-486800-j9.analise_logistica.tabela_cliente_analise` AS cli
  ON cli.cliente_pk_limpo = ped.id_cliente_ajust

-- 4. Engata o Vendedor no Hub
LEFT JOIN `skilled-sunrise-486800-j9.analise_logistica.tabela_vendedor_analise` AS ven
  ON ven.id_orig_vend = ids.id_vendedor_ajustado

-- 5. Engata a Geolocalização no Cliente (Destino da carga)
LEFT JOIN `skilled-sunrise-486800-j9.analise_logistica.tabela_geolocalizacao_analise` AS geo
  ON geo.geoloc_ajustada = cli.cod_postal_ajust
)

SELECT * 
FROM tabela_mestra;








