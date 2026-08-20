
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


-- A query acima foi construída com uma engenharia e arquitetura diferentes. Tive muita dificuldade para conectar essas tabelas, pois toda vez que tentava executar um LEFT JOIN, o código quebrava. Aparentemente havia algum conflito entre o nome das tabelas e o comando SELECT. O SELECT serve para exibir COLUNAS de uma determinada tabela, portanto, mesmo colocando o asterisco isolado (*) após o comando, o código não rodava. Tentei de todas as formas possíveis fazer com que as tabelas e suas respectivas colunas fossem lidas e processadas pelo BigQuery, porém o sistema exibia um erro de sintaxe. Eu descobri, mediante pesquisa, que havia uma maneira de representar todas as colunas de todas as tabelas de uma única vez, entretanto sem utilizar o comando padrão SELECT + asterisco (*). Para resolver este impasse, usei aliases monossilábicos para representar as tabelas. Depois que o BigQuery fez a leitura dos aliases e os registrou na memória, eu os coloquei após o comando SELECT acompanhados de um ponto (.) e um asterisco (*). Esse mecanismo é chamado de QUALIFICAÇÃO DE ESCOPO. A combinação do alias + ponto (.) + asterisco (*) funciona como um atalho. Quando o BigQuery lê dc.* ou ids.*, o mecanismo por trás faz o seguinte: lê as tabelas e depois lê todas as colunas de cada uma das tabelas e as replica no comando SELECT. Em outras palavras, ele "desembrulha" a tabela e substitui aquele asterisco pela lista escrita de TODAS as colunas, separadas por vírgula. Foi assim que consegui resolver o problema e fazer com que todas as colunas de todas as tabelas citadas fossem lidas pelo SELECT.

-- Se eu não tivesse descoberto esse atalho e as tabelas limpas tivessem 20 colunas cada uma, por exemplo, eu seria obrigado a digitar manualmente, para cada uma das tabelas, os 20 nomes de colunas no topo do código. Ao usar dc.*, ids.*, eu mantenho a regra do SELECT (trazer colunas), mas uso o poder do banco de dados para listar todas elas de maneira mais prática, sem a necessidade de especificá-las uma a uma. 


-- Depois que solucionei o problema anterior, deparei-me com outro: a dificuldade de conectar as chaves primárias (PK) com as chaves estrangeiras (FK), bem como definir quem era TABELA DIMENSÃO e quem era TABELA FATO. Montei de maneira informal e improvisada um rascunho para o DIAGRAMA ENTIDADE-RELACIONAMENTO na tentativa de conseguir determinar de que forma uma tabela se comunicava com a outra. Desenhei retângulos para representar as tabelas; dentro dos retângulos listei somente as colunas que eu iria usar na minha análise e desprezei as colunas que considerei desnecessárias. 

-- A tabela de DENSIDADE DE CARGA foi a que melhor se encaixou no conceito da tabela fato, pois ela representa, indubitavelmente, o coração da minha análise. É justamente dessa tabela que vem as informações sobre os pesos e volumes das cargas (bjetos de análise do meu projeto) e sobre as quais eu não poderia perder uma única linha. Deste modo, ela foi escolhida como HUB e posicionei ela à esquerda do comando LEFT JOIN. Isso garante que o sistema faça a leitura considerando todas as suas linhas, gerando conexões perfeitas (quando suas chaves estrangeiras se correspondem com as chaves primárias de outra tabela dimensão) ou gerando linhas com valores nulos quando não há correspondênca entre as chaves. 


-- Outra candidata à Tabela Fato seria a tabela ÍTENS, pois ela marcava dados financeiros tais como preço dos produtos e preço do frete. Entretanto, minha análise não foca no clichê de análise de custo de frete. O preço do produto também é irrelevante na análise, visto que no modelo logístico tradicional de e-commerce, o preço do produto não dita a inteligência de malha de distribuição. Uma geladeira de R$ 3.000 e uma televisão de R$ 3.000 ocupam espaços totalmente diferentes e exigem frotas/veículos de entrega completamente distintos. Deste modo, optei por desconsiderar essas duas colunas reduzindo os dados a uma tabela formada essencialmente por IDs (ID do pedido, ID do produto e ID do vendedor). Nesse caso, a tabela de itens acabou se tornando uma mera Tabela Dimensão que comporta chaves primárias relevantes para fazer conexões. 



-- A modelagem de dados pedominante nesses JOINS é o Modelo Floco de Neve (Snowflake Schema). Existe uma tabela fato que se liga à tabela dimensão, mas também observamos tabelas dimensões se ligando a outras tabelas dimensão. A geolocalização se ligando ao cliente é um exemplo. Quando uma dimensão se conecta em outra dimensão antes de chegar na fato, as pontas da sua "estrela" se ramificam. É por isso que esse modelo se chama Floco de Neve.


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


