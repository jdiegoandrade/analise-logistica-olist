
-- ETAPA 0
-- Aplicação do teste de análise estatística descritiva agrupada.
-- Teste de Homocedasticidade.


SELECT product_category_name,

  AVG (product_weight_g) AS media_peso,
  AVG (product_length_cm) AS media_comprimento, 
  AVG (product_height_cm) AS media_altura,
  AVG (product_width_cm) AS media_largura,

  STDDEV(product_weight_g) AS desvio_peso,
  STDDEV(product_length_cm) AS desvio_comprimento,
  STDDEV(product_height_cm) AS desvio_altura,
  STDDEV(product_width_cm) AS desvio_largura,

  MIN (product_weight_g) AS min_peso,
  MIN (product_length_cm) AS min_comp,
  MIN (product_height_cm) AS min_altura, 
  MIN (product_width_cm) AS min_largura,

  MAX (product_weight_g) AS max_peso,
  MAX (product_length_cm) AS max_comp,
  MAX (product_height_cm) AS max_altura, 
  MAX (product_width_cm) AS max_largura

 FROM `skilled-sunrise-486800-j9.analise_logistica.densidade_carga` 

GROUP BY product_category_name
ORDER BY media_peso DESC
 LIMIT 100;

 /* 
 CONCLUSÃO DA ETAPA 0 - ANÁLISE DE VARIABILIDADE E CONSISTÊNCIA
 
 A aplicação da estatística descritiva agrupada por categoria mercadológica 
 provou empiricamente que o dataset possui natureza REAL. A dispersão observada 
 através dos desvios padrões e a amplitude entre os valores mínimos e máximos 
 refletem o comportamento esperado de uma operação logística real.
 
 O conjunto de dados apresenta um comportamento HETEROCEDÁSTICO (variâncias 
 significativamente diferentes entre as categorias de produtos), o que é 
 característico do e-commerce brasileiro (onde convivem produtos leves como 
 cosméticos e pesados como móveis). 
 
 Fica validada a riqueza estatística da base para darmos início ao processo 
 de engenharia e higienização de dados.
 */


 -- Após verificação da viabilidade do dataset, procederemos ao processo de limpeza de dados. */



 -- ETAPA 1 
 -- TRATANDO OS VALORES NULOS


 -- Fazendo uma breve visualização da tabela para analisar as variáveis.


SELECT *
FROM `skilled-sunrise-486800-j9.analise_logistica.densidade_carga`
LIMIT 10;



-- Tratando os nulos da coluna product_id.

############

SELECT product_id
FROM `skilled-sunrise-486800-j9.analise_logistica.densidade_carga`
WHERE product_id IS NULL;


-- Foi constatado que não há valores nulos na coluna product_id.




-- Tratando os nulos da coluna product_category_name.

SELECT product_category_name
FROM `skilled-sunrise-486800-j9.analise_logistica.densidade_carga`
WHERE product_category_name IS NULL;
-- Foi constatado que há 610 valores nulos na coluna product_category_name.
-- Usando a função COALESCE para tratar os valores nulos e substituí-los por "Indisponível"

############

SELECT product_category_name,
COALESCE (product_category_name, "Indisponivel") AS categoria_nulo_tratada
FROM `skilled-sunrise-486800-j9.analise_logistica.densidade_carga`;



-- Tratando os nulos da coluna product_weight_g.

SELECT product_weight_g, product_category_name
FROM `skilled-sunrise-486800-j9.analise_logistica.densidade_carga`
WHERE product_weight_g IS NULL;

-- Foi constatado que há 2 valores nulos na coluna product_weight_g.
-- Usarei a função COALESCE para tratar os valores nulos e substituí-los pela média.
-- Como são apenas 2 valores, a média não irá distorcer os dados. 
-- Descobrindo quais categorias foram afetadas:

SELECT product_weight_g, product_category_name
FROM `skilled-sunrise-486800-j9.analise_logistica.densidade_carga`
WHERE product_weight_g IS NULL
GROUP BY product_category_name, product_weight_g;

-- A categoria de produtos afetada foi a categoria bebês e outra categoria está indisponível (valor nulo)
-- Calculando a média de peso para a categoria bebês:

SELECT 
    AVG (product_weight_g) AS media_peso
FROM `skilled-sunrise-486800-j9.analise_logistica.densidade_carga`
WHERE product_category_name = "bebes";

-- A média de peso para os produtos da categoria bebê não foi de 3655.20. 

-- Usando a função COALESCE para substituir o valor nulo pela média aritmética.

############

SELECT COALESCE(product_weight_g, 3655.20) AS peso_tratado
FROM `skilled-sunrise-486800-j9.analise_logistica.densidade_carga`;


-- Tratando os nulos da coluna product_length_cm.

SELECT product_length_cm
FROM `skilled-sunrise-486800-j9.analise_logistica.densidade_carga`
WHERE product_length_cm IS NULL;

-- Foram detectados 2 valores nulos.

-- Verificando as categorias às quais pertence:

SELECT product_length_cm, product_category_name
FROM `skilled-sunrise-486800-j9.analise_logistica.densidade_carga`
WHERE product_length_cm IS NULL
GROUP BY product_category_name, product_length_cm;

-- Foi constatado que uma das categorias é a de bebês e a outra está indisponível (valor nulo).

-- Calculando a média de comprimento dos produtos da categoria bebês:

SELECT 
AVG (product_length_cm) AS media_comprimento
FROM `skilled-sunrise-486800-j9.analise_logistica.densidade_carga`
WHERE product_category_name = "bebes";

-- A média de coprimento dessa categoria específica é de 37.14.

-- Substituindo os valores ausentes pela média:

############

SELECT
COALESCE(product_length_cm, 37.14) AS comprimento_tratado
FROM `skilled-sunrise-486800-j9.analise_logistica.densidade_carga`;

-- Tratando os nulos da coluna product_height_cm.

SELECT product_height_cm
FROM `skilled-sunrise-486800-j9.analise_logistica.densidade_carga`
WHERE product_height_cm IS NULL;

-- Foram encontrados 2 valores nulos.

-- Verificando a qual categoria eles pertencem:

SELECT product_height_cm, product_category_name
FROM `skilled-sunrise-486800-j9.analise_logistica.densidade_carga`
WHERE product_height_cm IS NULL
GROUP BY product_category_name, product_height_cm;

-- O produto pertence à categoria de bebês.

-- Calculando a média de altura dos produtos da categoria:

SELECT
AVG (product_height_cm) AS media_altura
FROM `skilled-sunrise-486800-j9.analise_logistica.densidade_carga`
WHERE product_category_name = "bebes";

-- A média de altura para a categoria é de 21.61.

-- Usando a função COALESCE para substiruir os nulos pela média:

############

SELECT
COALESCE(product_height_cm, 21.61) AS altura_tratada
FROM `skilled-sunrise-486800-j9.analise_logistica.densidade_carga`;


-- Tratando os nulos da coluna product_width_cm.

SELECT product_width_cm
FROM `skilled-sunrise-486800-j9.analise_logistica.densidade_carga`
WHERE product_width_cm IS NULL;

-- Foram encontrados 2 valores nulos.

-- Verificando a qual categoria ele pertence:

SELECT product_width_cm, product_category_name
FROM `skilled-sunrise-486800-j9`.`analise_logistica`.`densidade_carga`
WHERE product_width_cm IS NULL
GROUP BY product_category_name, product_width_cm;
-- Foi constatado que o dado não informado pertence à categoria de bebês.

-- Calculando a média de largura dos produtos da categoria bebês:


SELECT
AVG (product_width_cm) AS media_largura
FROM `skilled-sunrise-486800-j9.analise_logistica.densidade_carga`
WHERE product_category_name = "bebes";
-- A média encontrada foi de 28.71.

-- Substituindo os valores nuloe pela média através da função COALESCE:

############

SELECT
COALESCE(product_width_cm, 28.71) AS largura_tratada
FROM `skilled-sunrise-486800-j9.analise_logistica.densidade_carga`;



-- CRIAÇÃO DA CTE PARA VALORES NULOS



WITH nulos_limpos AS (

      SELECT product_id,            
COALESCE (product_category_name, "Indisponivel") AS categoria_nulo_tratada,
COALESCE (product_weight_g, 3655.20) AS peso_tratado,
COALESCE (product_length_cm, 37.14) AS comprimento_tratado,
COALESCE (product_height_cm, 21.61) AS altura_tratada,
COALESCE (product_width_cm, 28.71) AS largura_tratada 
    FROM `skilled-sunrise-486800-j9.analise_logistica.densidade_carga`
)

SELECT * FROM nulos_limpos;


-- ETAPA 2
-- TRATANDO OS ESPAÇOS EM BRANCO 
-- Fazendo uma breve visualizção da tabelas.


SELECT *
FROM `skilled-sunrise-486800-j9.analise_logistica.densidade_carga`
LIMIT 10;



-- A função TRIM permite remover espaços em branco antes e depois dos dados do tipo STRING.

-- Aplicação da função TRIM na coluna product_id.


SELECT TRIM(product_id) AS idproduto_sem_espaco
FROM `skilled-sunrise-486800-j9`.`analise_logistica`.`densidade_carga`;


-- Aplicação da função TRIM na coluna product_category_name.


SELECT TRIM(product_category_name) AS categoria_sem_espaco
FROM `skilled-sunrise-486800-j9`.`analise_logistica`.`densidade_carga`;



-- CRIAÇÃO DA CTE PARA VALORES COM ESPAÇOS REMOVIDOS

WITH espacos_removidos AS (


    SELECT 
    TRIM(product_id) AS idproduto_sem_espaco,
    TRIM(product_category_name) AS categoria_sem_espaco
FROM `skilled-sunrise-486800-j9`.`analise_logistica`.`densidade_carga` 


)

SELECT * FROM espacos_removidos;


-- ETAPA 3
-- TRATANDO MAIÚSCULAS E MINÚSCULAS
-- Fazendo uma breve visualizção da tabelas.



SELECT *
FROM `skilled-sunrise-486800-j9.analise_logistica.densidade_carga`
LIMIT 10;


-- Usando a função INITCAP para que as palavras iniciem com letras maiúsculas:

############

SELECT INITCAP(product_category_name) AS categoria_inic_maiusc
FROM `skilled-sunrise-486800-j9`.`analise_logistica`.`densidade_carga`;

-- Usando a função REPLACE para substituir o sublinhado pelo espaço:

############

SELECT
  INITCAP(REPLACE(product_category_name, '_', ' '))
    AS categoria_sem_subl
FROM `skilled-sunrise-486800-j9`.`analise_logistica`.`densidade_carga`;

-- Usando a função REPLACE para substituir preposições e conjunções que ficaram maiúsculas indevidamente

############

SELECT
  REPLACE(
    REPLACE(
      REPLACE(
        REPLACE(
          REPLACE(
            REPLACE(
              REPLACE(
                REPLACE(
                  INITCAP(REPLACE(product_category_name, '_', ' ')),
                  ' E ',
                  ' e '),
                ' De ',
                ' de '),
              ' Da ',
              ' da '),
            ' Do ',
            ' do '),
          ' Em ',
          ' em '),
        ' Com ',
        ' com '),
      ' Para ',
      ' para '),
    ' Por ',
    ' por ')
    AS categoria_prep_minus
FROM `skilled-sunrise-486800-j9`.`analise_logistica`.`densidade_carga`;

-- Verificando a integridade da coluna product_id com a função LENGTH.
-- A coluna do ID do produto é um hash (código alfanumérico) que deve sempre ter 32 caracteres.
-- Se houver comprimentos diferentes de 32, então há quebra na integridade dos dados.

############

SELECT product_id, 
LENGTH (product_id) AS comprimento_hash_id
FROM `skilled-sunrise-486800-j9`.`analise_logistica`.`densidade_carga`;

-- Verificando se algum ID é difetente de 32:

############

SELECT product_id, 
LENGTH (product_id) AS tamanho_id
FROM `skilled-sunrise-486800-j9`.`analise_logistica`.`densidade_carga`
WHERE LENGTH (product_id) <> 32;

-- Não foram identificadas inconsistências no ID do produto. Todos os hashs possuem 32 caracteres.


-- Validação de padrões e expressões regulares usando o REGEXP para identificar formatos inválidos.
-- Usar a função REGEXP para detectar formatos que fogem do padrão na coluna product_id.
-- O hash da coluna product_id deve ter 32 caracteres (como já sabemos) e, além disso, deve ser hexadecimal.
-- Isso significa que deve ser formado por 6 letras de A a F (ou de a a f, minúsculas) e 10 números (de 0 a 9)
-- Testando se há IDs corrompidos que a função LENGTH não detectou:

SELECT product_id, 
FROM `skilled-sunrise-486800-j9`.`analise_logistica`.`densidade_carga` 
WHERE
  NOT REGEXP_CONTAINS(product_id, r'^[0-9a-fA-F]{32}$');

 -- O teste REGEXP validou todos os hashes como consistentes e em conformidade com sua regra de criação.


-- ETAPA 4
-- CONVERSÃO DE TIPOS
-- Usar a função CAST para alterar tipo de dados.
-- Não há necessidade de mudança do tipo nesta tabela, pois todos os tipos são consistentes com a natureza das variáveis.


-- ETAPA 5
-- Identificar OUTLIERS extremos nas colunas de variáveis numéricas.
-- Será utilizado o Critério de Tukey com fator igual a 3,0 em vez de fator igual a 1,5.
-- O fator 3,0 se refere ao chamado OUTER FENCE (cercas externas) e identifica erros grosseiros de digitação, falha de sensores, fraudes gritantes e valores impossíveis.
-- Se uma observação se situa fora dos limites matemáticos do fator 3,0, a chance de ser um erro ou um evento raríssimo é altíssima.


-- Calculando o OUTER FENCE da coluna product_weight_g através de uma CTE. 

WITH outlier_extremo AS (

SELECT DISTINCT

    PERCENTILE_CONT (product_weight_g, 0.25) OVER () AS q1,
    PERCENTILE_CONT (product_weight_g, 0.75) OVER () AS q3
    
    FROM `skilled-sunrise-486800-j9`.`analise_logistica`.`densidade_carga`

)


SELECT
    q1,
    q3,
    (q3 - q1) AS iqr,
    (q1 - 3 * (q3 - q1)) AS outlier_min,
    (q3 + 3 * (q3 - q1)) AS outlier_max,
FROM outlier_extremo
LIMIT 1;

-- A CTE se mostrou mais adequada a esse tipo de caso, pois o cálculo do Q1, Q3 e IQR ficou menos complexo.

 
 /*
- Note que o Outer Fence traça limites matemáticos (superior e inferior) para marcar o que é outlier extremo ou não.O resultado negativo que estamos vendo (-4500.0) não é um outilier presente no dataset, e sim o marcador do limite matemático para detectar possíveis valores extremos. Ele não está me dizendo que há um valor negativo no conjunto de dados, e sim que números negativos abaixo de -4500.0 devem ser tratados como outliers. 

- Sobre o valor máximo de 6700.0, a lógica é a mesma. Ele é apenas um marcador que crava o limite matemático para detectar os valores discrepantes, ou seja, o que estiver dentro do intervalo é um valor normal e possível, e o que estiver acima ou além desse intervalo, seria um outlier extremo. Entretanto, perceba que pesos acima de 6700 gramas é algo perfeitamente aceitável dentro da logística de distribuição. Mesmo que multiplicássemos esse peso por 20, por 100, por 300 ainda assim ele estaria dentro da normalidade e jamais seria tratado como um outlier extremo.

- Isso quer dizer que a fórmula do Outer Fence falhou? De forma alguma. O que acontece é que estamos lidando com empresas de e-commerce, cujos pedidos são altamente fracionados e apresentam pesos baixos: capas de celular, toalhas, meias, etc. A estatística não enxerga essas nuances, ela enxerga apenas números. Cabe ao analista de dados interpretar os resultados de acordo com a realidade de negócio.

- Para efeitos práticos, vamos investigar a presença de valores negativos ou iguais a zero na coluna product_weight_g e fazer o estudo dos valores mínimos e máximos.

*/

-- Procurando valores menores ou iguais a zero na coluna product_weight_g:

SELECT product_category_name, product_weight_g
FROM `skilled-sunrise-486800-j9`.`analise_logistica`.`densidade_carga`
WHERE product_weight_g <= 0;

-- Não foram detectados valores negativos, mas foram detectados 4 valores iguais a zero. Provavelmente houve um erro de leitura ou uma falha no sensor da balança.



-- Tratando os valores iguais a zero:
-- Como sabemos que a categoria problemática é somente cama, mesa e banho, precisamos calcular a média de peso da categoria e substituir pelos valores zerados.

SELECT
    AVG(product_weight_g) AS media_cmb
    FROM `skilled-sunrise-486800-j9`.`analise_logistica`.`densidade_carga`
    WHERE product_category_name = "cama_mesa_banho";

-- A média de peso obtida para a categoria cama, mesa e banho foi de 2456.4.


-- Substituindo os valores zerados pela média:

############

SELECT 

  CASE
          WHEN product_weight_g = 0 THEN 2456.4
          ELSE product_weight_g
          END AS peso_nao_nulo
    
    FROM `skilled-sunrise-486800-j9`.`analise_logistica`.`densidade_carga`
    WHERE product_category_name = "cama_mesa_banho"
    AND product_weight_g = 0;

-- Calculando o MÍNIMO e o MÁXIMO da coluna product_weight_g para análise da conformidade:

SELECT
MIN (product_weight_g) AS peso_minimo,
MAX (product_weight_g) AS peso_maximo
FROM `skilled-sunrise-486800-j9`.`analise_logistica`.`densidade_carga`;

-- O peso mínimo (0) já foi tratado na etapa anterior e substituído pela média. O peso máxio está dentro da normalidade para as operações logísticas, visto que o resultado de 40.425 está expresso em gramas. Convertendo para Kg, ficamos com 40,42 Kg. Nã há necessidade de tratar o valor máximo da observação. 


-- Não vou aplicar o teste do Outer Fence para as demais variáveis, pois só mencionei o teste para fins didáticos. Como ele apenas traça os limitadores matemáticos para detectar valores extremos da observação, sua utilização se torna pouco prática para a etapa de limpeza. Nas demais variáveis, continuarei com o cálculo do mínimo, máximo e valores iguais a zero. 




-- Procurando valores menores ou iguais a zero na coluna product_length_cm:

SELECT product_category_name, product_length_cm
FROM `skilled-sunrise-486800-j9`.`analise_logistica`.`densidade_carga`
WHERE product_length_cm <= 0;
-- Não foram detectados valores menores ou iguais a zero na coluna product_length_cm.




-- Procurando valores menores ou iguais a zero na coluna product_height_cm.

SELECT product_category_name, product_height_cm
FROM `skilled-sunrise-486800-j9`.`analise_logistica`.`densidade_carga`
WHERE product_height_cm <= 0;

-- Não foram detectados valores menores ou iguais a zero na coluna product_height_cm.



-- Procurando valores menores ou iguais a zero na coluna product_width_cm.

SELECT product_category_name, product_width_cm
FROM `skilled-sunrise-486800-j9`.`analise_logistica`.`densidade_carga`
WHERE product_width_cm <= 0;

-- Não foram detectados valores menores ou iguais a zero na coluna product_width_cm




-- Calculando o Máximo e o Mínimo. Aqui, para não ficar tão extenso, vou calcular todos os máximos e mínimos de uma só vez.

SELECT

  MIN(product_length_cm) AS min_comp_cm,
  MAX(product_length_cm) AS max_comp_cm,

  MIN(product_height_cm) AS min_alt_cm,
  MAX(product_height_cm) AS max_alt_cm,

  MIN(product_width_cm) AS min_larg_cm,
  MAX(product_width_cm) AS max_larg_cm

FROM `skilled-sunrise-486800-j9`.`analise_logistica`.`densidade_carga`;

-- Todos os valores de mínimo e máximo estão dentro da normalidade e não ensejam limpeza. 


-- CRIAÇÃO DA CTE PARA CORRIGIR VALORES ZERADOS

WITH correc_peso_zero AS (

    SELECT 

      CASE
            WHEN product_weight_g = 0 THEN 2456.4
            ELSE product_weight_g
            END AS peso_nao_nulo
    
      FROM `skilled-sunrise-486800-j9`.`analise_logistica`.`densidade_carga`
      WHERE product_category_name = "cama_mesa_banho"
      AND product_weight_g = 0

)

SELECT * FROM correc_peso_zero;


-- ETAPA 6
-- Remoção de valores duplicados da coluna product_id.
-- Essa deve ser a última etapa de todas as etapas de limpeza, pois para o sistema reconhecer linhas 100% idênticas, os dados devem estar todos limpos e padronizados. Desta forma,é possível identificar com mais eficiência os valores duplicados que possuem 100% de correspondência exata. 



SELECT 
COUNT(*) AS total_linhas,
    COUNT(DISTINCT product_id) AS ids_unicos,
    COUNT(*) - COUNT(DISTINCT product_id) AS qtd_duplicatas
FROM `skilled-sunrise-486800-j9`.`analise_logistica`.`densidade_carga`;

-- Não foram encontradas linhas duplicadas em relação ao ID de produtos, o que é algo esperado, visto que chaves primárias não podem ter valores repetidos ou nulos. Os testes de nulidade e duplicidade confirmam se tratar de uma chave primária. 




-- Segue abaixo a CTE que exibe a tabela com todas as informações limpas:


WITH reject_nulos AS (

SELECT *,
FROM `skilled-sunrise-486800-j9.analise_logistica.densidade_carga`
WHERE product_id IS NOT NULL

),

nulos_limpos AS (
    SELECT *,           
    COALESCE (product_category_name, "Indisponivel") AS categoria_nulo_tratada,
    COALESCE (product_weight_g, 3655.20) AS peso_tratado,
    COALESCE (product_length_cm, 37.14) AS comprimento_tratado,
    COALESCE (product_height_cm, 21.61) AS altura_tratada,
    COALESCE (product_width_cm, 28.71) AS largura_tratada 
    FROM reject_nulos
),

espacos_removidos AS (
    SELECT *,
    TRIM (product_id) AS idproduto_sem_espaco, 
    TRIM (categoria_nulo_tratada) AS categoria_sem_espaco 
    FROM nulos_limpos
),

escrita_corrigida AS (
    SELECT *,
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
      INITCAP(REPLACE(categoria_sem_espaco, '_', ' ')),
      ' E ', ' e '), ' De ', ' de '), ' Da ', ' da '), ' Do ', ' do '),
      ' Em ', ' em '), ' Com ', ' com '), ' Para ', ' para '), ' Por ', ' por ') 
    AS categoria_prep_minus
    FROM espacos_removidos
    WHERE REGEXP_CONTAINS (idproduto_sem_espaco, r'^[0-9a-fA-F]{32}$')
),

correc_peso_zero AS (
    SELECT *,
      CASE
            WHEN categoria_sem_espaco = "cama_mesa_banho" AND peso_tratado = 0 THEN 2456.4
            ELSE peso_tratado
      END AS peso_nao_nulo
    FROM escrita_corrigida
),

limpeza_duplicatas AS (
  
  SELECT DISTINCT  -- O DISTINCT citado aqui garante que linhas 100% idênticas sejam excluídas/ignoradas.
    idproduto_sem_espaco,
    categoria_prep_minus,
    peso_nao_nulo,
    comprimento_tratado,
    altura_tratada,
    largura_tratada
  FROM correc_peso_zero
)


SELECT * FROM limpeza_duplicatas;





-- CRIANDO UMA TABELA A PARTIR DA CTE DE LIMPEZA:



CREATE OR REPLACE TABLE `skilled-sunrise-486800-j9.analise_logistica.dimensoes_carga_analise` AS



WITH reject_nulos AS (

SELECT *,
FROM `skilled-sunrise-486800-j9.analise_logistica.densidade_carga`
WHERE product_id IS NOT NULL

),

nulos_limpos AS (
    SELECT *,           
    COALESCE (product_category_name, "Indisponivel") AS categoria_nulo_tratada,
    COALESCE (product_weight_g, 3655.20) AS peso_tratado,
    COALESCE (product_length_cm, 37.14) AS comprimento_tratado,
    COALESCE (product_height_cm, 21.61) AS altura_tratada,
    COALESCE (product_width_cm, 28.71) AS largura_tratada 
    FROM reject_nulos
),

espacos_removidos AS (
    SELECT *,
    TRIM (product_id) AS idproduto_sem_espaco, 
    TRIM (categoria_nulo_tratada) AS categoria_sem_espaco 
    FROM nulos_limpos
),

escrita_corrigida AS (
    SELECT *,
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
      INITCAP(REPLACE(categoria_sem_espaco, '_', ' ')),
      ' E ', ' e '), ' De ', ' de '), ' Da ', ' da '), ' Do ', ' do '),
      ' Em ', ' em '), ' Com ', ' com '), ' Para ', ' para '), ' Por ', ' por ') 
    AS categoria_prep_minus
    FROM espacos_removidos
    WHERE REGEXP_CONTAINS (idproduto_sem_espaco, r'^[0-9a-fA-F]{32}$')
),

correc_peso_zero AS (
    SELECT *,
      CASE
            WHEN categoria_sem_espaco = "cama_mesa_banho" AND peso_tratado = 0 THEN 2456.4
            ELSE peso_tratado
      END AS peso_nao_nulo
    FROM escrita_corrigida
),

limpeza_duplicatas AS (
  
  SELECT DISTINCT  -- O DISTINCT citado aqui garante que linhas 100% idênticas sejam excluídas/ignoradas.
    idproduto_sem_espaco AS id_produto_ajust2,
    categoria_prep_minus AS categoria_ajust,
    peso_nao_nulo AS peso_em_gramas,
    comprimento_tratado AS comprimento_em_cm,
    altura_tratada AS altura_em_cm,
    largura_tratada AS largura_em_cm
  FROM correc_peso_zero
)


SELECT * FROM limpeza_duplicatas;










 


    