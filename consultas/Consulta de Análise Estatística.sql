
--------------------------------------------------------------------------------
-- ETAPA 0: Inventário, Classificação e Engenharia de Variáveis




--------------------------------------------------------------------------------
-- ETAPA 1: Transformação de Dados e Padronização Logística


SELECT 
  categoria_ajust AS categoria_produto,
  status_pedido_ajust AS status_pedido,
  estado_origem_vend AS estado_origem,
  sigla_estado_ajust AS estado_destino,
  cidade_destino_ajust AS cidade_destino,

  -- Normalização de massa para escala industrial (kg e toneladas)
  (peso_em_gramas / 1000) AS peso_em_kg,
  (peso_em_gramas / 1000000) AS peso_em_ton,

  -- Conversão volumétrica de cm³ para m³
  (comprimento_em_cm * largura_em_cm * altura_em_cm) / 1000000 AS volume_em_m3,

  -- Razão de densidade (Peso/Volume) com tratamento robusto para divisão por zero
  ROUND(SAFE_DIVIDE
    ((peso_em_gramas / 1000), 
    ((comprimento_em_cm * altura_em_cm * largura_em_cm) / 1000000)), 2) AS fator_de_cubagem

FROM `skilled-sunrise-486800-j9.analise_logistica.base_analitica`;



--------------------------------------------------------------------------------
-- ETAPA 2: Matriz de Cruzamento Bivariado (Estrutura de Análise)



--------------------------------------------------------------------------------
-- ETAPA 3: Materialização da Tabela de Suporte Estatístico



CREATE OR REPLACE TABLE `skilled-sunrise-486800-j9.analise_logistica.metricas_estatisticas` AS
SELECT 
  categoria_ajust AS categoria_produto,
  status_pedido_ajust AS status_pedido,
  estado_origem_vend AS estado_origem,
  sigla_estado_ajust AS estado_destino,
  cidade_destino_ajust AS cidade_destino,
  (peso_em_gramas / 1000) AS peso_em_kg,
  (peso_em_gramas / 1000000) AS peso_em_ton,
  (comprimento_em_cm * largura_em_cm * altura_em_cm) / 1000000 AS volume_em_m3,
  ROUND(SAFE_DIVIDE
    ((peso_em_gramas / 1000), 
    ((comprimento_em_cm * altura_em_cm * largura_em_cm) / 1000000)), 2) AS fator_de_cubagem
FROM `skilled-sunrise-486800-j9.analise_logistica.base_analitica`;



--------------------------------------------------------------------------------
-- ETAPA 4: Estatística Descritiva



-- 4.1 Calculando a frequência absoluta do peso total por estado de origem:

SELECT
ROUND(SUM(peso_em_kg), 2) AS peso_total_kg,
estado_origem
FROM `skilled-sunrise-486800-j9.analise_logistica.metricas_estatisticas`
GROUP BY estado_origem
ORDER BY peso_total_kg DESC;



-- 4.2 Calculando a frequência absoluta do peso total por região usando a cláusula CASE WHEN:


SELECT
    CASE 
        WHEN estado_origem IN ('SP', 'RJ', 'MG', 'ES') THEN 'Sudeste'
        WHEN estado_origem IN ('PR', 'SC', 'RS') THEN 'Sul'
        WHEN estado_origem IN ('BA', 'PE', 'CE', 'MA', 'PB', 'RN', 'AL', 'SE', 'PI') THEN 'Nordeste'
        WHEN estado_origem IN ('MT', 'MS', 'GO', 'DF') THEN 'Centro-Oeste'
        WHEN estado_origem IN ('AM', 'PA', 'RO', 'TO', 'AC', 'AP', 'RR') THEN 'Norte'
        ELSE 'Não Identificado'
    END AS regiao_origem,
    ROUND(SUM(peso_em_kg), 2) AS peso_total_kg
FROM `skilled-sunrise-486800-j9.analise_logistica.metricas_estatisticas`
GROUP BY regiao_origem
ORDER BY peso_total_kg DESC;




-- 4.3 Calculando a média de peso (em quilos) por estado de origem:

SELECT estado_origem, 
  ROUND(AVG(peso_em_kg), 2) AS media_peso
FROM `skilled-sunrise-486800-j9.analise_logistica.metricas_estatisticas`
  GROUP BY estado_origem
  ORDER BY media_peso DESC;




-- 4.4 Calculando a frequência absoluta do total de despachos por estado:

SELECT 
    estado_origem,
    COUNT(*) AS total_despachos   
FROM `skilled-sunrise-486800-j9.analise_logistica.metricas_estatisticas`
GROUP BY estado_origem
ORDER BY total_despachos DESC;




-- 4.5 Calculando a frequência relativa (o percentual) de envios:


SELECT 
    estado_origem,
    COUNT(*) AS total_despachos,
    ROUND((COUNT(*) / (SELECT COUNT(*) FROM `skilled-sunrise-486800-j9.analise_logistica.metricas_estatisticas`)) * 100, 4) AS percentual_total
FROM `skilled-sunrise-486800-j9.analise_logistica.metricas_estatisticas`
GROUP BY estado_origem
ORDER BY percentual_total DESC;




-- 4.6 calculandoa frequência absoluta por região:

SELECT 
    CASE 
        WHEN estado_origem IN ('SP', 'RJ', 'MG', 'ES') THEN 'Sudeste'
        WHEN estado_origem IN ('PR', 'SC', 'RS') THEN 'Sul'
        WHEN estado_origem IN ('BA', 'PE', 'CE', 'MA', 'PB', 'RN', 'AL', 'SE', 'PI') THEN 'Nordeste'
        WHEN estado_origem IN ('MT', 'MS', 'GO', 'DF') THEN 'Centro-Oeste'
        WHEN estado_origem IN ('AM', 'PA', 'RO', 'TO', 'AC', 'AP', 'RR') THEN 'Norte'
        ELSE 'Não Identificado'
    END AS regiao_origem,
    
    -- Valor Absoluto: Total de despachos/envios realizados na região
    COUNT(*) AS valor_absoluto_despachos

FROM `skilled-sunrise-486800-j9.analise_logistica.metricas_estatisticas`
GROUP BY regiao_origem
ORDER BY valor_absoluto_despachos DESC;



-- 4.7 Calculando a frequência relativa de cargas despachadas por região:


SELECT
    CASE 
        WHEN estado_origem IN ('SP', 'RJ', 'MG', 'ES') THEN 'Sudeste'
        WHEN estado_origem IN ('PR', 'SC', 'RS') THEN 'Sul'
        WHEN estado_origem IN ('BA', 'PE', 'CE', 'MA', 'PB', 'RN', 'AL', 'SE', 'PI') THEN 'Nordeste'
        WHEN estado_origem IN ('MT', 'MS', 'GO', 'DF') THEN 'Centro-Oeste'
        WHEN estado_origem IN ('AM', 'PA', 'RO', 'TO', 'AC', 'AP', 'RR') THEN 'Norte'
        ELSE 'Não Identificado'
    END AS regiao_origem,
    COUNT(*) AS total_despachos,
    ROUND((COUNT(*) / (SELECT COUNT(*) FROM `skilled-sunrise-486800-j9.analise_logistica.metricas_estatisticas`)) * 100, 4) AS percentual_total
FROM `skilled-sunrise-486800-j9.analise_logistica.metricas_estatisticas`
GROUP BY regiao_origem
ORDER BY percentual_total DESC;



-- 4.8 Calculando a média de peso por Região:


SELECT
    CASE 
        WHEN estado_origem IN ('SP', 'RJ', 'MG', 'ES') THEN 'Sudeste'
        WHEN estado_origem IN ('PR', 'SC', 'RS') THEN 'Sul'
        WHEN estado_origem IN ('BA', 'PE', 'CE', 'MA', 'PB', 'RN', 'AL', 'SE', 'PI') THEN 'Nordeste'
        WHEN estado_origem IN ('MT', 'MS', 'GO', 'DF') THEN 'Centro-Oeste'
        WHEN estado_origem IN ('AM', 'PA', 'RO', 'TO', 'AC', 'AP', 'RR') THEN 'Norte'
        ELSE 'Não Identificado'
    END AS regiao_origem,
    ROUND(AVG(peso_em_kg), 2) AS media_peso
FROM `skilled-sunrise-486800-j9.analise_logistica.metricas_estatisticas`
GROUP BY regiao_origem
ORDER BY media_peso DESC;



-- A próxima etapa consistirá no cálculo e análise das medianas, permitindo realizar um comparativo direto com as médias e avaliar o grau de assimetria da distribuição de dados.



-- 4.9 Calculando a mediana do peso por estado

SELECT DISTINCT
  estado_origem, 
  (PERCENTILE_CONT(peso_em_kg, 0.5) OVER(PARTITION BY estado_origem)) AS mediana_peso
FROM `skilled-sunrise-486800-j9.analise_logistica.metricas_estatisticas`
ORDER BY mediana_peso DESC;




-- 4.10 Calculando a mediana do peso por região:


SELECT DISTINCT
    CASE 
        WHEN estado_origem IN ('SP', 'RJ', 'MG', 'ES') THEN 'Sudeste'
        WHEN estado_origem IN ('PR', 'SC', 'RS') THEN 'Sul'
        WHEN estado_origem IN ('BA', 'PE', 'CE', 'MA', 'PB', 'RN', 'AL', 'SE', 'PI') THEN 'Nordeste'
        WHEN estado_origem IN ('MT', 'MS', 'GO', 'DF') THEN 'Centro-Oeste'
        WHEN estado_origem IN ('AM', 'PA', 'RO', 'TO', 'AC', 'AP', 'RR') THEN 'Norte'
        ELSE 'Não Identificado'
    END AS regiao_origem,
    PERCENTILE_CONT(peso_em_kg, 0.5) OVER(PARTITION BY

            CASE 
                WHEN estado_origem IN ('SP', 'RJ', 'MG', 'ES') THEN 'Sudeste'
                WHEN estado_origem IN ('PR', 'SC', 'RS') THEN 'Sul'
                WHEN estado_origem IN ('BA', 'PE', 'CE', 'MA', 'PB', 'RN', 'AL', 'SE', 'PI') THEN 'Nordeste'
                WHEN estado_origem IN ('MT', 'MS', 'GO', 'DF') THEN 'Centro-Oeste'
                WHEN estado_origem IN ('AM', 'PA', 'RO', 'TO', 'AC', 'AP', 'RR') THEN 'Norte'
                ELSE 'Não Identificado'
            END
    ) AS mediana_peso
FROM `skilled-sunrise-486800-j9.analise_logistica.metricas_estatisticas`
ORDER BY mediana_peso DESC;



-- 4.11 Calculando o intervalo interquartílico por estado:

SELECT DISTINCT
    estado_origem,
    COUNT(*) OVER(PARTITION BY estado_origem) AS total_despachos,
    -- Aplicando o TRUNC no Q1:
    TRUNC(PERCENTILE_CONT(peso_em_kg, 0.25) OVER(PARTITION BY estado_origem), 3) AS q1_peso,
    -- Aplicando o TRUNC no Q3:
    TRUNC(PERCENTILE_CONT(peso_em_kg, 0.75) OVER(PARTITION BY estado_origem), 3) AS q3_peso,
    -- Aplicando o TRUNC no IQR:
    TRUNC(
        (PERCENTILE_CONT(peso_em_kg, 0.75) OVER(PARTITION BY estado_origem) - 
         PERCENTILE_CONT(peso_em_kg, 0.25) OVER(PARTITION BY estado_origem)), 3
    ) AS iqr_peso
FROM `skilled-sunrise-486800-j9.analise_logistica.metricas_estatisticas`
ORDER BY iqr_peso DESC;



-- 4.12 Calculando o intervalo interquartílico por região:


SELECT DISTINCT
    CASE 
        WHEN estado_origem IN ('SP', 'RJ', 'MG', 'ES') THEN 'Sudeste'
        WHEN estado_origem IN ('PR', 'SC', 'RS') THEN 'Sul'
        WHEN estado_origem IN ('BA', 'PE', 'CE', 'MA', 'PB', 'RN', 'AL', 'SE', 'PI') THEN 'Nordeste'
        WHEN estado_origem IN ('MT', 'MS', 'GO', 'DF') THEN 'Centro-Oeste'
        WHEN estado_origem IN ('AM', 'PA', 'RO', 'TO', 'AC', 'AP', 'RR') THEN 'Norte'
        ELSE 'Não Identificado'
    END AS regiao_origem,
    TRUNC(PERCENTILE_CONT(peso_em_kg, 0.25) OVER(
        PARTITION BY 
            CASE 
                WHEN estado_origem IN ('SP', 'RJ', 'MG', 'ES') THEN 'Sudeste'
                WHEN estado_origem IN ('PR', 'SC', 'RS') THEN 'Sul'
                WHEN estado_origem IN ('BA', 'PE', 'CE', 'MA', 'PB', 'RN', 'AL', 'SE', 'PI') THEN 'Nordeste'
                WHEN estado_origem IN ('MT', 'MS', 'GO', 'DF') THEN 'Centro-Oeste'
                WHEN estado_origem IN ('AM', 'PA', 'RO', 'TO', 'AC', 'AP', 'RR') THEN 'Norte'
                ELSE 'Não Identificado'
            END
    ), 3) AS q1_peso,
    TRUNC(PERCENTILE_CONT(peso_em_kg, 0.75) OVER(
        PARTITION BY 
            CASE 
                WHEN estado_origem IN ('SP', 'RJ', 'MG', 'ES') THEN 'Sudeste'
                WHEN estado_origem IN ('PR', 'SC', 'RS') THEN 'Sul'
                WHEN estado_origem IN ('BA', 'PE', 'CE', 'MA', 'PB', 'RN', 'AL', 'SE', 'PI') THEN 'Nordeste'
                WHEN estado_origem IN ('MT', 'MS', 'GO', 'DF') THEN 'Centro-Oeste'
                WHEN estado_origem IN ('AM', 'PA', 'RO', 'TO', 'AC', 'AP', 'RR') THEN 'Norte'
                ELSE 'Não Identificado'
            END
    ), 3) AS q3_peso,
    TRUNC(
        (PERCENTILE_CONT(peso_em_kg, 0.75) OVER(
            PARTITION BY 
                CASE 
                    WHEN estado_origem IN ('SP', 'RJ', 'MG', 'ES') THEN 'Sudeste'
                    WHEN estado_origem IN ('PR', 'SC', 'RS') THEN 'Sul'
                    WHEN estado_origem IN ('BA', 'PE', 'CE', 'MA', 'PB', 'RN', 'AL', 'SE', 'PI') THEN 'Nordeste'
                    WHEN estado_origem IN ('MT', 'MS', 'GO', 'DF') THEN 'Centro-Oeste'
                    WHEN estado_origem IN ('AM', 'PA', 'RO', 'TO', 'AC', 'AP', 'RR') THEN 'Norte'
                    ELSE 'Não Identificado'
                END
        ) - 
         PERCENTILE_CONT(peso_em_kg, 0.25) OVER(
            PARTITION BY 
                CASE 
                    WHEN estado_origem IN ('SP', 'RJ', 'MG', 'ES') THEN 'Sudeste'
                    WHEN estado_origem IN ('PR', 'SC', 'RS') THEN 'Sul'
                    WHEN estado_origem IN ('BA', 'PE', 'CE', 'MA', 'PB', 'RN', 'AL', 'SE', 'PI') THEN 'Nordeste'
                    WHEN estado_origem IN ('MT', 'MS', 'GO', 'DF') THEN 'Centro-Oeste'
                    WHEN estado_origem IN ('AM', 'PA', 'RO', 'TO', 'AC', 'AP', 'RR') THEN 'Norte'
                    ELSE 'Não Identificado'
                END
        )), 3
    ) AS iqr_peso
FROM `skilled-sunrise-486800-j9.analise_logistica.metricas_estatisticas`
ORDER BY iqr_peso DESC;



-- 4.13 Definindo os limites de corte para outliers por estado:




WITH metricas_base AS (
    SELECT DISTINCT
        estado_origem,
        COUNT(*) OVER(PARTITION BY estado_origem) AS total_despachos,
        PERCENTILE_CONT(peso_em_kg, 0.25) OVER(PARTITION BY estado_origem) AS q1,
        PERCENTILE_CONT(peso_em_kg, 0.75) OVER(PARTITION BY estado_origem) AS q3
    FROM `skilled-sunrise-486800-j9.analise_logistica.metricas_estatisticas`
),
limites_tukey AS (
    SELECT 
        estado_origem,
        total_despachos,
        q1,
        q3,
        (q3 - q1) AS iqr,
        (q3 + (1.5 * (q3 - q1))) AS limite_superior_moderado,
        (q3 + (3.0 * (q3 - q1))) AS limite_superior_extremo
    FROM metricas_base
)
SELECT 
    estado_origem,
    total_despachos,
    TRUNC(q1, 3) AS q1_peso,
    TRUNC(q3, 3) AS q3_peso,
    TRUNC(iqr, 3) AS iqr_peso,
    TRUNC(limite_superior_moderado, 3) AS corte_moderado_kg,
    TRUNC(limite_superior_extremo, 3) AS corte_extremo_kg
FROM limites_tukey
ORDER BY corte_moderado_kg DESC; 




-- 4.14 Definindo os limites de corte para outliers por região:



WITH metricas_base AS (
    SELECT DISTINCT
        CASE 
            WHEN estado_origem IN ('SP', 'RJ', 'MG', 'ES') THEN 'Sudeste'
            WHEN estado_origem IN ('PR', 'SC', 'RS') THEN 'Sul'
            WHEN estado_origem IN ('BA', 'PE', 'CE', 'MA', 'PB', 'RN', 'AL', 'SE', 'PI') THEN 'Nordeste'
            WHEN estado_origem IN ('MT', 'MS', 'GO', 'DF') THEN 'Centro-Oeste'
            WHEN estado_origem IN ('AM', 'PA', 'RO', 'TO', 'AC', 'AP', 'RR') THEN 'Norte'
            ELSE 'Não Identificado'
        END AS regiao_origem,
        PERCENTILE_CONT(peso_em_kg, 0.25) OVER(PARTITION BY 
            CASE 
                WHEN estado_origem IN ('SP', 'RJ', 'MG', 'ES') THEN 'Sudeste'
                WHEN estado_origem IN ('PR', 'SC', 'RS') THEN 'Sul'
                WHEN estado_origem IN ('BA', 'PE', 'CE', 'MA', 'PB', 'RN', 'AL', 'SE', 'PI') THEN 'Nordeste'
                WHEN estado_origem IN ('MT', 'MS', 'GO', 'DF') THEN 'Centro-Oeste'
                WHEN estado_origem IN ('AM', 'PA', 'RO', 'TO', 'AC', 'AP', 'RR') THEN 'Norte'
                ELSE 'Não Identificado'
            END
        ) AS q1,
        PERCENTILE_CONT(peso_em_kg, 0.75) OVER(PARTITION BY 
            CASE 
                WHEN estado_origem IN ('SP', 'RJ', 'MG', 'ES') THEN 'Sudeste'
                WHEN estado_origem IN ('PR', 'SC', 'RS') THEN 'Sul'
                WHEN estado_origem IN ('BA', 'PE', 'CE', 'MA', 'PB', 'RN', 'AL', 'SE', 'PI') THEN 'Nordeste'
                WHEN estado_origem IN ('MT', 'MS', 'GO', 'DF') THEN 'Centro-Oeste'
                WHEN estado_origem IN ('AM', 'PA', 'RO', 'TO', 'AC', 'AP', 'RR') THEN 'Norte'
                ELSE 'Não Identificado'
            END
        ) AS q3
    FROM `skilled-sunrise-486800-j9.analise_logistica.metricas_estatisticas`
),
limites_tukey AS (
    SELECT 
        regiao_origem,
        q1,
        q3,
        (q3 - q1) AS iqr,
        (q3 + (1.5 * (q3 - q1))) AS limite_superior_moderado,
        (q3 + (3.0 * (q3 - q1))) AS limite_superior_extremo
    FROM metricas_base
)
SELECT 
    regiao_origem,
    TRUNC(q1, 3) AS q1_peso,
    TRUNC(q3, 3) AS q3_peso,
    TRUNC(iqr, 3) AS iqr_peso,
    TRUNC(limite_superior_moderado, 3) AS corte_moderado_kg,
    TRUNC(limite_superior_extremo, 3) AS corte_extremo_kg
FROM limites_tukey
ORDER BY corte_moderado_kg DESC;




-- 4.15 Contagem e representatividade de outliers por estado:


-- OBJETIVO: Identificar e contar individualmente quantos despachos de origem ficaram acima do limite superior moderado de Tukey de seu respectivo estado. 


WITH limites_base AS (
    SELECT DISTINCT
        estado_origem,
        PERCENTILE_CONT(peso_em_kg, 0.25) OVER(PARTITION BY estado_origem) AS q1,
        PERCENTILE_CONT(peso_em_kg, 0.75) OVER(PARTITION BY estado_origem) AS q3
    FROM `skilled-sunrise-486800-j9.analise_logistica.metricas_estatisticas`
),
regras_corte AS (
    SELECT 
        estado_origem,
        (q3 + (1.5 * (q3 - q1))) AS limite_superior_moderado
    FROM limites_base
)
SELECT 
    b.estado_origem,
    COUNT(*) AS total_despachos,
    -- Conta apenas as linhas onde o peso furou o limite do respectivo estado:
    COUNT(CASE WHEN b.peso_em_kg > c.limite_superior_moderado THEN 1 END) AS qte_outliers_moderados,
    -- Calcula a participação percentual desses outliers na operação do estado:
    TRUNC((COUNT(CASE WHEN b.peso_em_kg > c.limite_superior_moderado THEN 1 END) / COUNT(*)) * 100, 2) AS percentual_outliers
FROM `skilled-sunrise-486800-j9.analise_logistica.metricas_estatisticas` b
JOIN regras_corte c ON b.estado_origem = c.estado_origem
GROUP BY b.estado_origem
ORDER BY qte_outliers_moderados DESC;




-- 4.16 Identificação de valores extremos (mínimo e máximo) por estado:


-- OBJETIVO: Mapear o menor e o maior peso despachado por cada hub de origem, calculando a amplitude total da distribuição. 



SELECT 
    estado_origem,
    COUNT(*) AS total_despachos,
    MIN(peso_em_kg) AS peso_minimo_kg,
    MAX(peso_em_kg) AS peso_maximo_kg,
    -- Calcula a amplitude total da variação de peso do estado:
    TRUNC(MAX(peso_em_kg) - MIN(peso_em_kg), 3) AS amplitude_peso_kg
FROM `skilled-sunrise-486800-j9.analise_logistica.metricas_estatisticas`
GROUP BY estado_origem
ORDER BY amplitude_peso_kg DESC;




-- 4.17 Calculando o Desvio Padrão Amostral e o Coeficiente de Variação - CV.


SELECT 
    estado_origem,
    COUNT(*) AS total_despachos,
    TRUNC(AVG(peso_em_kg), 3) AS media_peso_kg,
    -- Calcula o Desvio Padrão Amostral travado em 3 casas decimais:
    TRUNC(STDDEV_SAMP(peso_em_kg), 3) AS desvio_padrao_peso,
    -- Calcula o Coeficiente de Variação com 4 casas:
    TRUNC((STDDEV_SAMP(peso_em_kg) / AVG(peso_em_kg)) * 100, 4) AS coeficiente_variacao_percentual
FROM `skilled-sunrise-486800-j9.analise_logistica.metricas_estatisticas`
GROUP BY estado_origem
ORDER BY desvio_padrao_peso DESC;


-- 4.17.1 Cálculo do desvio padrão e coeficiente de variação por região de origem:


SELECT DISTINCT
    CASE 
        WHEN estado_origem IN ('SP', 'RJ', 'MG', 'ES') THEN 'Sudeste'
        WHEN estado_origem IN ('PR', 'SC', 'RS') THEN 'Sul'
        WHEN estado_origem IN ('BA', 'PE', 'CE', 'MA', 'PB', 'RN', 'AL', 'SE', 'PI') THEN 'Nordeste'
        WHEN estado_origem IN ('MT', 'MS', 'GO', 'DF') THEN 'Centro-Oeste'
        WHEN estado_origem IN ('AM', 'PA', 'RO', 'TO', 'AC', 'AP', 'RR') THEN 'Norte'
        ELSE 'Não Identificado'
    END AS regiao_origem,
    
    TRUNC(STDDEV_SAMP(peso_em_kg) OVER(
        PARTITION BY 
            CASE 
                WHEN estado_origem IN ('SP', 'RJ', 'MG', 'ES') THEN 'Sudeste'
                WHEN estado_origem IN ('PR', 'SC', 'RS') THEN 'Sul'
                WHEN estado_origem IN ('BA', 'PE', 'CE', 'MA', 'PB', 'RN', 'AL', 'SE', 'PI') THEN 'Nordeste'
                WHEN estado_origem IN ('MT', 'MS', 'GO', 'DF') THEN 'Centro-Oeste'
                WHEN estado_origem IN ('AM', 'PA', 'RO', 'TO', 'AC', 'AP', 'RR') THEN 'Norte'
                ELSE 'Não Identificado'
            END
    ), 3) AS desvio_padrao_peso_kg,

    TRUNC((STDDEV_SAMP(peso_em_kg) OVER(
        PARTITION BY 
            CASE 
                WHEN estado_origem IN ('SP', 'RJ', 'MG', 'ES') THEN 'Sudeste'
                WHEN estado_origem IN ('PR', 'SC', 'RS') THEN 'Sul'
                WHEN estado_origem IN ('BA', 'PE', 'CE', 'MA', 'PB', 'RN', 'AL', 'SE', 'PI') THEN 'Nordeste'
                WHEN estado_origem IN ('MT', 'MS', 'GO', 'DF') THEN 'Centro-Oeste'
                WHEN estado_origem IN ('AM', 'PA', 'RO', 'TO', 'AC', 'AP', 'RR') THEN 'Norte'
                ELSE 'Não Identificado'
            END
    ) / AVG(peso_em_kg) OVER(
        PARTITION BY 
            CASE 
                WHEN estado_origem IN ('SP', 'RJ', 'MG', 'ES') THEN 'Sudeste'
                WHEN estado_origem IN ('PR', 'SC', 'RS') THEN 'Sul'
                WHEN estado_origem IN ('BA', 'PE', 'CE', 'MA', 'PB', 'RN', 'AL', 'SE', 'PI') THEN 'Nordeste'
                WHEN estado_origem IN ('MT', 'MS', 'GO', 'DF') THEN 'Centro-Oeste'
                WHEN estado_origem IN ('AM', 'PA', 'RO', 'TO', 'AC', 'AP', 'RR') THEN 'Norte'
                ELSE 'Não Identificado'
            END
    )) * 100, 4) AS cv_peso_percentual

FROM `skilled-sunrise-486800-j9.analise_logistica.metricas_estatisticas`
ORDER BY cv_peso_percentual DESC;


-- OBS.: A partir de agora, a fim de consolidar melhor os dados e facilitar a visualização nos gráticos, vou focar na análise macro das regiões brasileiras em detrimento aos estados. Uma análise por estado polui os gráfico, enquanto, por região, a visualização se torna mais limpa.



-- 4.18 Calculando medida de tendência central (média e mediana) do volume (em cm³) por região de origem:

-- OBJETIVO: Conversão de m³ para cm³ mantendo o tipo FLOAT64 contínuo via função TRUNC para resguardar a precisão fina dos dados decimais.


SELECT DISTINCT
    CASE 
        WHEN estado_origem IN ('SP', 'RJ', 'MG', 'ES') THEN 'Sudeste'
        WHEN estado_origem IN ('PR', 'SC', 'RS') THEN 'Sul'
        WHEN estado_origem IN ('BA', 'PE', 'CE', 'MA', 'PB', 'RN', 'AL', 'SE', 'PI') THEN 'Nordeste'
        WHEN estado_origem IN ('MT', 'MS', 'GO', 'DF') THEN 'Centro-Oeste'
        WHEN estado_origem IN ('AM', 'PA', 'RO', 'TO', 'AC', 'AP', 'RR') THEN 'Norte'
        ELSE 'Não Identificado'
    END AS regiao_origem,
    
    -- Média convertida para cm³ e truncada em 3 casas decimais:
    TRUNC(AVG(volume_em_m3) OVER(
        PARTITION BY 
            CASE 
                WHEN estado_origem IN ('SP', 'RJ', 'MG', 'ES') THEN 'Sudeste'
                WHEN estado_origem IN ('PR', 'SC', 'RS') THEN 'Sul'
                WHEN estado_origem IN ('BA', 'PE', 'CE', 'MA', 'PB', 'RN', 'AL', 'SE', 'PI') THEN 'Nordeste'
                WHEN estado_origem IN ('MT', 'MS', 'GO', 'DF') THEN 'Centro-Oeste'
                WHEN estado_origem IN ('AM', 'PA', 'RO', 'TO', 'AC', 'AP', 'RR') THEN 'Norte'
                ELSE 'Não Identificado'
            END
    ) * 1000000, 3) AS media_volume_cm3,
    
    -- Mediana convertida para cm³ e truncada em 3 casas decimais:
    TRUNC(PERCENTILE_CONT(volume_em_m3, 0.5) OVER(
        PARTITION BY 
            CASE 
                WHEN estado_origem IN ('SP', 'RJ', 'MG', 'ES') THEN 'Sudeste'
                WHEN estado_origem IN ('PR', 'SC', 'RS') THEN 'Sul'
                WHEN estado_origem IN ('BA', 'PE', 'CE', 'MA', 'PB', 'RN', 'AL', 'SE', 'PI') THEN 'Nordeste'
                WHEN estado_origem IN ('MT', 'MS', 'GO', 'DF') THEN 'Centro-Oeste'
                WHEN estado_origem IN ('AM', 'PA', 'RO', 'TO', 'AC', 'AP', 'RR') THEN 'Norte'
                ELSE 'Não Identificado'
            END
    ) * 1000000, 3) AS mediana_volume_cm3

FROM `skilled-sunrise-486800-j9.analise_logistica.metricas_estatisticas`
ORDER BY media_volume_cm3 DESC;




-- 4.19 Calculando os quartis (Q1/Q3) e intervalo interquartílico (IQR) do volume por região de origem:



SELECT DISTINCT
    CASE 
        WHEN estado_origem IN ('SP', 'RJ', 'MG', 'ES') THEN 'Sudeste'
        WHEN estado_origem IN ('PR', 'SC', 'RS') THEN 'Sul'
        WHEN estado_origem IN ('BA', 'PE', 'CE', 'MA', 'PB', 'RN', 'AL', 'SE', 'PI') THEN 'Nordeste'
        WHEN estado_origem IN ('MT', 'MS', 'GO', 'DF') THEN 'Centro-Oeste'
        WHEN estado_origem IN ('AM', 'PA', 'RO', 'TO', 'AC', 'AP', 'RR') THEN 'Norte'
        ELSE 'Não Identificado'
    END AS regiao_origem,
    
    -- Primeiro Quartil (Q1 / Percentil 25%) em cm³:
    TRUNC(PERCENTILE_CONT(volume_em_m3, 0.25) OVER(
        PARTITION BY 
            CASE 
                WHEN estado_origem IN ('SP', 'RJ', 'MG', 'ES') THEN 'Sudeste'
                WHEN estado_origem IN ('PR', 'SC', 'RS') THEN 'Sul'
                WHEN estado_origem IN ('BA', 'PE', 'CE', 'MA', 'PB', 'RN', 'AL', 'SE', 'PI') THEN 'Nordeste'
                WHEN estado_origem IN ('MT', 'MS', 'GO', 'DF') THEN 'Centro-Oeste'
                WHEN estado_origem IN ('AM', 'PA', 'RO', 'TO', 'AC', 'AP', 'RR') THEN 'Norte'
                ELSE 'Não Identificado'
            END
    ) * 1000000, 3) AS q1_volume_cm3,
    
    -- Terceiro Quartil (Q3 / Percentil 75%) em cm³:
    TRUNC(PERCENTILE_CONT(volume_em_m3, 0.75) OVER(
        PARTITION BY 
            CASE 
                WHEN estado_origem IN ('SP', 'RJ', 'MG', 'ES') THEN 'Sudeste'
                WHEN estado_origem IN ('PR', 'SC', 'RS') THEN 'Sul'
                WHEN estado_origem IN ('BA', 'PE', 'CE', 'MA', 'PB', 'RN', 'AL', 'SE', 'PI') THEN 'Nordeste'
                WHEN estado_origem IN ('MT', 'MS', 'GO', 'DF') THEN 'Centro-Oeste'
                WHEN estado_origem IN ('AM', 'PA', 'RO', 'TO', 'AC', 'AP', 'RR') THEN 'Norte'
                ELSE 'Não Identificado'
            END
    ) * 1000000, 3) AS q3_volume_cm3,
    
    -- Intervalo Interquartílico (IQR = Q3 - Q1) em cm³:
    TRUNC((
        PERCENTILE_CONT(volume_em_m3, 0.75) OVER(
            PARTITION BY 
                CASE 
                    WHEN estado_origem IN ('SP', 'RJ', 'MG', 'ES') THEN 'Sudeste'
                    WHEN estado_origem IN ('PR', 'SC', 'RS') THEN 'Sul'
                    WHEN estado_origem IN ('BA', 'PE', 'CE', 'MA', 'PB', 'RN', 'AL', 'SE', 'PI') THEN 'Nordeste'
                    WHEN estado_origem IN ('MT', 'MS', 'GO', 'DF') THEN 'Centro-Oeste'
                    WHEN estado_origem IN ('AM', 'PA', 'RO', 'TO', 'AC', 'AP', 'RR') THEN 'Norte'
                    ELSE 'Não Identificado'
                END
        ) - 
        PERCENTILE_CONT(volume_em_m3, 0.25) OVER(
            PARTITION BY 
                CASE 
                    WHEN estado_origem IN ('SP', 'RJ', 'MG', 'ES') THEN 'Sudeste'
                    WHEN estado_origem IN ('PR', 'SC', 'RS') THEN 'Sul'
                    WHEN estado_origem IN ('BA', 'PE', 'CE', 'MA', 'PB', 'RN', 'AL', 'SE', 'PI') THEN 'Nordeste'
                    WHEN estado_origem IN ('MT', 'MS', 'GO', 'DF') THEN 'Centro-Oeste'
                    WHEN estado_origem IN ('AM', 'PA', 'RO', 'TO', 'AC', 'AP', 'RR') THEN 'Norte'
                    ELSE 'Não Identificado'
                END
        )
    ) * 1000000, 3) AS iqr_volume_cm3

FROM `skilled-sunrise-486800-j9.analise_logistica.metricas_estatisticas`
ORDER BY iqr_volume_cm3 DESC;




-- 4.20 Calculando mínimo, máximo e amplitude total do volume por região de origem:


SELECT DISTINCT
    CASE 
        WHEN estado_origem IN ('SP', 'RJ', 'MG', 'ES') THEN 'Sudeste'
        WHEN estado_origem IN ('PR', 'SC', 'RS') THEN 'Sul'
        WHEN estado_origem IN ('BA', 'PE', 'CE', 'MA', 'PB', 'RN', 'AL', 'SE', 'PI') THEN 'Nordeste'
        WHEN estado_origem IN ('MT', 'MS', 'GO', 'DF') THEN 'Centro-Oeste'
        WHEN estado_origem IN ('AM', 'PA', 'RO', 'TO', 'AC', 'AP', 'RR') THEN 'Norte'
        ELSE 'Não Identificado'
    END AS regiao_origem,
    
    -- Volume Mínimo em cm³:
    TRUNC(MIN(volume_em_m3) OVER(
        PARTITION BY 
            CASE 
                WHEN estado_origem IN ('SP', 'RJ', 'MG', 'ES') THEN 'Sudeste'
                WHEN estado_origem IN ('PR', 'SC', 'RS') THEN 'Sul'
                WHEN estado_origem IN ('BA', 'PE', 'CE', 'MA', 'PB', 'RN', 'AL', 'SE', 'PI') THEN 'Nordeste'
                WHEN estado_origem IN ('MT', 'MS', 'GO', 'DF') THEN 'Centro-Oeste'
                WHEN estado_origem IN ('AM', 'PA', 'RO', 'TO', 'AC', 'AP', 'RR') THEN 'Norte'
                ELSE 'Não Identificado'
            END
    ) * 1000000, 3) AS min_volume_cm3,
    
    -- Volume Máximo em cm³:
    TRUNC(MAX(volume_em_m3) OVER(
        PARTITION BY 
            CASE 
                WHEN estado_origem IN ('SP', 'RJ', 'MG', 'ES') THEN 'Sudeste'
                WHEN estado_origem IN ('PR', 'SC', 'RS') THEN 'Sul'
                WHEN estado_origem IN ('BA', 'PE', 'CE', 'MA', 'PB', 'RN', 'AL', 'SE', 'PI') THEN 'Nordeste'
                WHEN estado_origem IN ('MT', 'MS', 'GO', 'DF') THEN 'Centro-Oeste'
                WHEN estado_origem IN ('AM', 'PA', 'RO', 'TO', 'AC', 'AP', 'RR') THEN 'Norte'
                ELSE 'Não Identificado'
            END
    ) * 1000000, 3) AS max_volume_cm3,

    -- Amplitude Total (Máximo - Mínimo) em cm³:
    TRUNC((
        MAX(volume_em_m3) OVER(
            PARTITION BY 
                CASE 
                    WHEN estado_origem IN ('SP', 'RJ', 'MG', 'ES') THEN 'Sudeste'
                    WHEN estado_origem IN ('PR', 'SC', 'RS') THEN 'Sul'
                    WHEN estado_origem IN ('BA', 'PE', 'CE', 'MA', 'PB', 'RN', 'AL', 'SE', 'PI') THEN 'Nordeste'
                    WHEN estado_origem IN ('MT', 'MS', 'GO', 'DF') THEN 'Centro-Oeste'
                    WHEN estado_origem IN ('AM', 'PA', 'RO', 'TO', 'AC', 'AP', 'RR') THEN 'Norte'
                    ELSE 'Não Identificado'
                END
        ) - 
        MIN(volume_em_m3) OVER(
            PARTITION BY 
                CASE 
                    WHEN estado_origem IN ('SP', 'RJ', 'MG', 'ES') THEN 'Sudeste'
                    WHEN estado_origem IN ('PR', 'SC', 'RS') THEN 'Sul'
                    WHEN estado_origem IN ('BA', 'PE', 'CE', 'MA', 'PB', 'RN', 'AL', 'SE', 'PI') THEN 'Nordeste'
                    WHEN estado_origem IN ('MT', 'MS', 'GO', 'DF') THEN 'Centro-Oeste'
                    WHEN estado_origem IN ('AM', 'PA', 'RO', 'TO', 'AC', 'AP', 'RR') THEN 'Norte'
                    ELSE 'Não Identificado'
                END
        )
    ) * 1000000, 3) AS amplitude_volume_cm3

FROM `skilled-sunrise-486800-j9.analise_logistica.metricas_estatisticas`
ORDER BY amplitude_volume_cm3 DESC;



-- 4.21 Calculando o desvio padrão e o coeficiente de variação do volume por região de origem:


SELECT DISTINCT
    CASE 
        WHEN estado_origem IN ('SP', 'RJ', 'MG', 'ES') THEN 'Sudeste'
        WHEN estado_origem IN ('PR', 'SC', 'RS') THEN 'Sul'
        WHEN estado_origem IN ('BA', 'PE', 'CE', 'MA', 'PB', 'RN', 'AL', 'SE', 'PI') THEN 'Nordeste'
        WHEN estado_origem IN ('MT', 'MS', 'GO', 'DF') THEN 'Centro-Oeste'
        WHEN estado_origem IN ('AM', 'PA', 'RO', 'TO', 'AC', 'AP', 'RR') THEN 'Norte'
        ELSE 'Não Identificado'
    END AS regiao_origem,
    
    -- Desvio Padrão Amostral convertido para cm³ e truncado em 3 casas:
    TRUNC(STDDEV_SAMP(volume_em_m3) OVER(
        PARTITION BY 
            CASE 
                WHEN estado_origem IN ('SP', 'RJ', 'MG', 'ES') THEN 'Sudeste'
                WHEN estado_origem IN ('PR', 'SC', 'RS') THEN 'Sul'
                WHEN estado_origem IN ('BA', 'PE', 'CE', 'MA', 'PB', 'RN', 'AL', 'SE', 'PI') THEN 'Nordeste'
                WHEN estado_origem IN ('MT', 'MS', 'GO', 'DF') THEN 'Centro-Oeste'
                WHEN estado_origem IN ('AM', 'PA', 'RO', 'TO', 'AC', 'AP', 'RR') THEN 'Norte'
                ELSE 'Não Identificado'
            END
    ) * 1000000, 3) AS desvio_padrao_volume_cm3,
    
    -- Coeficiente de Variação (%) truncado em 4 casas:
    TRUNC((STDDEV_SAMP(volume_em_m3) OVER(
        PARTITION BY 
            CASE 
                WHEN estado_origem IN ('SP', 'RJ', 'MG', 'ES') THEN 'Sudeste'
                WHEN estado_origem IN ('PR', 'SC', 'RS') THEN 'Sul'
                WHEN estado_origem IN ('BA', 'PE', 'CE', 'MA', 'PB', 'RN', 'AL', 'SE', 'PI') THEN 'Nordeste'
                WHEN estado_origem IN ('MT', 'MS', 'GO', 'DF') THEN 'Centro-Oeste'
                WHEN estado_origem IN ('AM', 'PA', 'RO', 'TO', 'AC', 'AP', 'RR') THEN 'Norte'
                ELSE 'Não Identificado'
            END
    ) / AVG(volume_em_m3) OVER(
        PARTITION BY 
            CASE 
                WHEN estado_origem IN ('SP', 'RJ', 'MG', 'ES') THEN 'Sudeste'
                WHEN estado_origem IN ('PR', 'SC', 'RS') THEN 'Sul'
                WHEN estado_origem IN ('BA', 'PE', 'CE', 'MA', 'PB', 'RN', 'AL', 'SE', 'PI') THEN 'Nordeste'
                WHEN estado_origem IN ('MT', 'MS', 'GO', 'DF') THEN 'Centro-Oeste'
                WHEN estado_origem IN ('AM', 'PA', 'RO', 'TO', 'AC', 'AP', 'RR') THEN 'Norte'
                ELSE 'Não Identificado'
            END
    )) * 100, 4) AS cv_volume_percentual

FROM `skilled-sunrise-486800-j9.analise_logistica.metricas_estatisticas`
ORDER BY desvio_padrao_volume_cm3 DESC;



-- 4.22 Calculando o peso de cada categoria:



SELECT 
    categoria_produto,
    TRUNC(SUM(peso_em_kg), 2) AS peso_total_kg
FROM `skilled-sunrise-486800-j9.analise_logistica.metricas_estatisticas`
GROUP BY categoria_produto
ORDER BY peso_total_kg DESC;




-- 4.23 Métricas Estatísticas Descritivas do Peso - Top 5 Categorias Líderes:


WITH metricas_base AS (
    SELECT 
        categoria_produto,
        peso_em_kg,
        -- Mediana calculada via Window Function:
        PERCENTILE_CONT(peso_em_kg, 0.5) OVER(PARTITION BY categoria_produto) AS mediana_janela,
        -- Contagem de linhas para descobrir quais são as 5 maiores categorias:
        COUNT(*) OVER(PARTITION BY categoria_produto) AS total_pedidos_categoria
    FROM `skilled-sunrise-486800-j9.analise_logistica.metricas_estatisticas`
)

SELECT 
    categoria_produto,
    total_pedidos_categoria AS total_despachos,
    TRUNC(MIN(peso_em_kg), 3) AS peso_min_kg,
    TRUNC(MAX(peso_em_kg), 3) AS peso_max_kg,
    TRUNC(MAX(peso_em_kg) - MIN(peso_em_kg), 3) AS amplitude_kg,
    TRUNC(AVG(peso_em_kg), 3) AS peso_medio_kg,
    TRUNC(ANY_VALUE(mediana_janela), 3) AS peso_mediano_kg,
    TRUNC(STDDEV_SAMP(peso_em_kg), 3) AS desvio_padrao_kg
FROM metricas_base
GROUP BY categoria_produto, total_pedidos_categoria
QUALIFY ROW_NUMBER() OVER (ORDER BY total_pedidos_categoria DESC) <= 5
ORDER BY total_despachos DESC;



-- 4.24 Análise de Volume Absoluto por Status do Pedido:



SELECT 
    status_pedido,
    COUNT(*) AS valor_absoluto_pedidos
FROM `skilled-sunrise-486800-j9.analise_logistica.metricas_estatisticas`
GROUP BY status_pedido
ORDER BY valor_absoluto_pedidos DESC;




-- 4.25 Matriz Cruzada de Status de Pedido por Região (Valores Absolutos e Relativos):



WITH base_status_regiao AS (
    SELECT 
        CASE 
            WHEN estado_origem IN ('SP', 'RJ', 'MG', 'ES') THEN 'Sudeste'
            WHEN estado_origem IN ('PR', 'SC', 'RS') THEN 'Sul'
            WHEN estado_origem IN ('BA', 'PE', 'CE', 'MA', 'PB', 'RN', 'AL', 'SE', 'PI') THEN 'Nordeste'
            WHEN estado_origem IN ('MT', 'MS', 'GO', 'DF') THEN 'Centro-Oeste'
            WHEN estado_origem IN ('AM', 'PA', 'RO', 'TO', 'AC', 'AP', 'RR') THEN 'Norte'
            ELSE 'Não Identificado'
        END AS regiao_origem,
        status_pedido
    FROM `skilled-sunrise-486800-j9.analise_logistica.metricas_estatisticas`
),

contagem_matriz AS (
    SELECT 
        regiao_origem,
        COUNT(*) AS total_pedidos_regiao,
        -- Contagem absoluta por status (Agregação Condicional):
        COUNT(CASE WHEN status_pedido = 'Delivered' THEN 1 END) AS qtd_delivered,
        COUNT(CASE WHEN status_pedido = 'Shipped' THEN 1 END) AS qtd_shipped,
        COUNT(CASE WHEN status_pedido = 'Canceled' THEN 1 END) AS qtd_canceled
    FROM base_status_regiao
    GROUP BY regiao_origem
)

SELECT 
    regiao_origem,
    total_pedidos_regiao AS volume_total,
    
    -- Colunas de Status Entregue (Absoluto e % de eficiência da região):
    qtd_delivered AS entregues_absoluto,
    TRUNC((qtd_delivered / total_pedidos_regiao) * 100, 2) AS entregues_porcentagem,
    
    -- Colunas de Status Em Trânsito (Absoluto e % de carga ativa na rua):
    qtd_shipped AS em_transito_absoluto,
    TRUNC((qtd_shipped / total_pedidos_regiao) * 100, 2) AS em_transito_porcentagem,
    
    -- Colunas de Status Cancelado (Absoluto e % de perda/atrito na região):
    qtd_canceled AS cancelados_absoluto,
    TRUNC((qtd_canceled / total_pedidos_regiao) * 100, 2) AS cancelados_porcentagem

FROM contagem_matriz
ORDER BY entregues_porcentagem DESC;



-- 4.26 Análise de Recebimentos por Região de Destino (Valores Absolutos e Relativos):



WITH base_destino AS (
    SELECT 
        CASE 
            WHEN estado_destino IN ('SP', 'RJ', 'MG', 'ES') THEN 'Sudeste'
            WHEN estado_destino IN ('PR', 'SC', 'RS') THEN 'Sul'
            WHEN estado_destino IN ('BA', 'PE', 'CE', 'MA', 'PB', 'RN', 'AL', 'SE', 'PI') THEN 'Nordeste'
            WHEN estado_destino IN ('MT', 'MS', 'GO', 'DF') THEN 'Centro-Oeste'
            WHEN estado_destino IN ('AM', 'PA', 'RO', 'TO', 'AC', 'AP', 'RR') THEN 'Norte'
            ELSE 'Não Identificado'
        END AS regiao_destino
    FROM `skilled-sunrise-486800-j9.analise_logistica.metricas_estatisticas`
),

contagem_destino AS (
    SELECT 
        regiao_destino,
        -- Valor Absoluto: Quantidade total de pedidos recebidos na região
        COUNT(*) AS valor_absoluto_recebimentos,
        -- Total geral de pedidos da base para cálculo do percentual global
        SUM(COUNT(*)) OVER() AS total_geral_pedidos
    FROM base_destino
    GROUP BY regiao_destino
)

SELECT 
    regiao_destino,
    valor_absoluto_recebimentos,
    -- Valor Relativo: Percentual que o destino representa no ecossistema logístico
    TRUNC((valor_absoluto_recebimentos / total_geral_pedidos) * 100, 2) AS valor_relativo_porcentagem
FROM contagem_destino
ORDER BY valor_relativo_porcentagem DESC;




-- 4.27 Média e mediana do peso por região de destino:

WITH base_mediana_destino AS (
    SELECT 
        CASE 
            WHEN estado_destino IN ('SP', 'RJ', 'MG', 'ES') THEN 'Sudeste'
            WHEN estado_destino IN ('PR', 'SC', 'RS') THEN 'Sul'
            WHEN estado_destino IN ('BA', 'PE', 'CE', 'MA', 'PB', 'RN', 'AL', 'SE', 'PI') THEN 'Nordeste'
            WHEN estado_destino IN ('MT', 'MS', 'GO', 'DF') THEN 'Centro-Oeste'
            WHEN estado_destino IN ('AM', 'PA', 'RO', 'TO', 'AC', 'AP', 'RR') THEN 'Norte'
            ELSE 'Não Identificado'
        END AS regiao_destino,
        peso_em_kg,
        -- Mediana calculada via Window Function por região de destino:
        PERCENTILE_CONT(peso_em_kg, 0.5) OVER(PARTITION BY 
            CASE 
                WHEN estado_destino IN ('SP', 'RJ', 'MG', 'ES') THEN 'Sudeste'
                WHEN estado_destino IN ('PR', 'SC', 'RS') THEN 'Sul'
                WHEN estado_destino IN ('BA', 'PE', 'CE', 'MA', 'PB', 'RN', 'AL', 'SE', 'PI') THEN 'Nordeste'
                WHEN estado_destino IN ('MT', 'MS', 'GO', 'DF') THEN 'Centro-Oeste'
                WHEN estado_destino IN ('AM', 'PA', 'RO', 'TO', 'AC', 'AP', 'RR') THEN 'Norte'
                ELSE 'Não Identificado'
            END
        ) AS mediana_janela
    FROM `skilled-sunrise-486800-j9.analise_logistica.metricas_estatisticas`
)

SELECT 
    regiao_destino,
    COUNT(*) AS total_pedidos_recebidos,
    -- Média truncada em 3 casas decimais:
    TRUNC(AVG(peso_em_kg), 3) AS peso_medio_recebimento_kg,
    -- Mediana capturada e truncada em 3 casas decimais:
    TRUNC(ANY_VALUE(mediana_janela), 3) AS peso_mediano_recebimento_kg
FROM base_mediana_destino
GROUP BY regiao_destino
ORDER BY peso_medio_recebimento_kg DESC;




-- 4.28 Calculando os quartis (Q1/Q3) e intervalo interquartílico (IQR) do peso por destino:



SELECT DISTINCT
    CASE 
        WHEN estado_destino IN ('SP', 'RJ', 'MG', 'ES') THEN 'Sudeste'
        WHEN estado_destino IN ('PR', 'SC', 'RS') THEN 'Sul'
        WHEN estado_destino IN ('BA', 'PE', 'CE', 'MA', 'PB', 'RN', 'AL', 'SE', 'PI') THEN 'Nordeste'
        WHEN estado_destino IN ('MT', 'MS', 'GO', 'DF') THEN 'Centro-Oeste'
        WHEN estado_destino IN ('AM', 'PA', 'RO', 'TO', 'AC', 'AP', 'RR') THEN 'Norte'
        ELSE 'Não Identificado'
    END AS regiao_destino,
    
    -- Primeiro Quartil (Q1 / Percentil 25%) em kg:
    TRUNC(PERCENTILE_CONT(peso_em_kg, 0.25) OVER(
        PARTITION BY 
            CASE 
                WHEN estado_destino IN ('SP', 'RJ', 'MG', 'ES') THEN 'Sudeste'
                WHEN estado_destino IN ('PR', 'SC', 'RS') THEN 'Sul'
                WHEN estado_destino IN ('BA', 'PE', 'CE', 'MA', 'PB', 'RN', 'AL', 'SE', 'PI') THEN 'Nordeste'
                WHEN estado_destino IN ('MT', 'MS', 'GO', 'DF') THEN 'Centro-Oeste'
                WHEN estado_destino IN ('AM', 'PA', 'RO', 'TO', 'AC', 'AP', 'RR') THEN 'Norte'
                ELSE 'Não Identificado'
            END
    ), 3) AS q1_peso_kg,
    
    -- Terceiro Quartil (Q3 / Percentil 75%) em kg:
    TRUNC(PERCENTILE_CONT(peso_em_kg, 0.75) OVER(
        PARTITION BY 
            CASE 
                WHEN estado_destino IN ('SP', 'RJ', 'MG', 'ES') THEN 'Sudeste'
                WHEN estado_destino IN ('PR', 'SC', 'RS') THEN 'Sul'
                WHEN estado_destino IN ('BA', 'PE', 'CE', 'MA', 'PB', 'RN', 'AL', 'SE', 'PI') THEN 'Nordeste'
                WHEN estado_destino IN ('MT', 'MS', 'GO', 'DF') THEN 'Centro-Oeste'
                WHEN estado_destino IN ('AM', 'PA', 'RO', 'TO', 'AC', 'AP', 'RR') THEN 'Norte'
                ELSE 'Não Identificado'
            END
    ), 3) AS q3_peso_kg,
    
    -- Intervalo Interquartílico (IQR = Q3 - Q1) em kg:
    TRUNC((
        PERCENTILE_CONT(peso_em_kg, 0.75) OVER(
            PARTITION BY 
                CASE 
                    WHEN estado_destino IN ('SP', 'RJ', 'MG', 'ES') THEN 'Sudeste'
                    WHEN estado_destino IN ('PR', 'SC', 'RS') THEN 'Sul'
                    WHEN estado_destino IN ('BA', 'PE', 'CE', 'MA', 'PB', 'RN', 'AL', 'SE', 'PI') THEN 'Nordeste'
                    WHEN estado_destino IN ('MT', 'MS', 'GO', 'DF') THEN 'Centro-Oeste' -- Nota: Mantendo consistência com estado_destino
                    WHEN estado_destino IN ('MT', 'MS', 'GO', 'DF') THEN 'Centro-Oeste'
                    WHEN estado_destino IN ('AM', 'PA', 'RO', 'TO', 'AC', 'AP', 'RR') THEN 'Norte'
                    ELSE 'Não Identificado'
                END
        ) - 
        PERCENTILE_CONT(peso_em_kg, 0.25) OVER(
            PARTITION BY 
                CASE 
                    WHEN estado_destino IN ('SP', 'RJ', 'MG', 'ES') THEN 'Sudeste'
                    WHEN estado_destino IN ('PR', 'SC', 'RS') THEN 'Sul'
                    WHEN estado_destino IN ('BA', 'PE', 'CE', 'MA', 'PB', 'RN', 'AL', 'SE', 'PI') THEN 'Nordeste'
                    WHEN estado_destino IN ('MT', 'MS', 'GO', 'DF') THEN 'Centro-Oeste'
                    WHEN estado_destino IN ('AM', 'PA', 'RO', 'TO', 'AC', 'AP', 'RR') THEN 'Norte'
                    ELSE 'Não Identificado'
                END
        )
    ), 3) AS iqr_peso_kg

FROM `skilled-sunrise-486800-j9.analise_logistica.metricas_estatisticas`
ORDER BY iqr_peso_kg DESC;




-- 4.29 Calculando mínimo, máximo e amplitude total do peso por região de destino:



SELECT DISTINCT
    CASE 
        WHEN estado_destino IN ('SP', 'RJ', 'MG', 'ES') THEN 'Sudeste'
        WHEN estado_destino IN ('PR', 'SC', 'RS') THEN 'Sul'
        WHEN estado_destino IN ('BA', 'PE', 'CE', 'MA', 'PB', 'RN', 'AL', 'SE', 'PI') THEN 'Nordeste'
        WHEN estado_destino IN ('MT', 'MS', 'GO', 'DF') THEN 'Centro-Oeste'
        WHEN estado_destino IN ('AM', 'PA', 'RO', 'TO', 'AC', 'AP', 'RR') THEN 'Norte'
        ELSE 'Não Identificado'
    END AS regiao_destino,
    
    -- Peso Mínimo recebido em kg:
    TRUNC(MIN(peso_em_kg) OVER(
        PARTITION BY 
            CASE 
                WHEN estado_destino IN ('SP', 'RJ', 'MG', 'ES') THEN 'Sudeste'
                WHEN estado_destino IN ('PR', 'SC', 'RS') THEN 'Sul'
                WHEN estado_destino IN ('BA', 'PE', 'CE', 'MA', 'PB', 'RN', 'AL', 'SE', 'PI') THEN 'Nordeste'
                WHEN estado_destino IN ('MT', 'MS', 'GO', 'DF') THEN 'Centro-Oeste'
                WHEN estado_destino IN ('AM', 'PA', 'RO', 'TO', 'AC', 'AP', 'RR') THEN 'Norte'
                ELSE 'Não Identificado'
            END
    ), 3) AS min_peso_destino_kg,
    
    -- Peso Máximo recebido em kg:
    TRUNC(MAX(peso_em_kg) OVER(
        PARTITION BY 
            CASE 
                WHEN estado_destino IN ('SP', 'RJ', 'MG', 'ES') THEN 'Sudeste'
                WHEN estado_destino IN ('PR', 'SC', 'RS') THEN 'Sul'
                WHEN estado_destino IN ('BA', 'PE', 'CE', 'MA', 'PB', 'RN', 'AL', 'SE', 'PI') THEN 'Nordeste'
                WHEN estado_destino IN ('MT', 'MS', 'GO', 'DF') THEN 'Centro-Oeste'
                WHEN estado_destino IN ('AM', 'PA', 'RO', 'TO', 'AC', 'AP', 'RR') THEN 'Norte'
                ELSE 'Não Identificado'
            END
    ), 3) AS max_peso_destino_kg,

    -- Amplitude Total (Máximo - Mínimo) em kg:
    TRUNC((
        MAX(peso_em_kg) OVER(
            PARTITION BY 
                CASE 
                    WHEN estado_destino IN ('SP', 'RJ', 'MG', 'ES') THEN 'Sudeste'
                    WHEN estado_destino IN ('PR', 'SC', 'RS') THEN 'Sul'
                    WHEN estado_destino IN ('BA', 'PE', 'CE', 'MA', 'PB', 'RN', 'AL', 'SE', 'PI') THEN 'Nordeste'
                    WHEN estado_destino IN ('MT', 'MS', 'GO', 'DF') THEN 'Centro-Oeste'
                    WHEN estado_destino IN ('AM', 'PA', 'RO', 'TO', 'AC', 'AP', 'RR') THEN 'Norte'
                    ELSE 'Não Identificado'
                END
        ) - 
        MIN(peso_em_kg) OVER(
            PARTITION BY 
                CASE 
                    WHEN estado_destino IN ('SP', 'RJ', 'MG', 'ES') THEN 'Sudeste'
                    WHEN estado_destino IN ('PR', 'SC', 'RS') THEN 'Sul'
                    WHEN estado_destino IN ('BA', 'PE', 'CE', 'MA', 'PB', 'RN', 'AL', 'SE', 'PI') THEN 'Nordeste'
                    WHEN estado_destino IN ('MT', 'MS', 'GO', 'DF') THEN 'Centro-Oeste'
                    WHEN estado_destino IN ('AM', 'PA', 'RO', 'TO', 'AC', 'AP', 'RR') THEN 'Norte'
                    ELSE 'Não Identificado'
                END
        )
    ), 3) AS amplitude_peso_destino_kg

FROM `skilled-sunrise-486800-j9.analise_logistica.metricas_estatisticas`
ORDER BY amplitude_peso_destino_kg DESC;



-- 4.30 Desvio padrão e coeficiente de variação do peso por região de destino:



WITH metricas_variabilidade AS (
    SELECT 
        CASE 
            WHEN estado_destino IN ('SP', 'RJ', 'MG', 'ES') THEN 'Sudeste'
            WHEN estado_destino IN ('PR', 'SC', 'RS') THEN 'Sul'
            WHEN estado_destino IN ('BA', 'PE', 'CE', 'MA', 'PB', 'RN', 'AL', 'SE', 'PI') THEN 'Nordeste'
            WHEN estado_destino IN ('MT', 'MS', 'GO', 'DF') THEN 'Centro-Oeste'
            WHEN estado_destino IN ('AM', 'PA', 'RO', 'TO', 'AC', 'AP', 'RR') THEN 'Norte'
            ELSE 'Não Identificado'
        END AS regiao_destino,
        
        -- Desvio Padrão Amostral por Destino:
        STDDEV_SAMP(peso_em_kg) OVER(PARTITION BY 
            CASE 
                WHEN estado_destino IN ('SP', 'RJ', 'MG', 'ES') THEN 'Sudeste'
                WHEN estado_destino IN ('PR', 'SC', 'RS') THEN 'Sul'
                WHEN estado_destino IN ('BA', 'PE', 'CE', 'MA', 'PB', 'RN', 'AL', 'SE', 'PI') THEN 'Nordeste'
                WHEN estado_destino IN ('MT', 'MS', 'GO', 'DF') THEN 'Centro-Oeste'
                WHEN estado_destino IN ('AM', 'PA', 'RO', 'TO', 'AC', 'AP', 'RR') THEN 'Norte'
                ELSE 'Não Identificado'
            END
        ) AS desvio_padrao_janela,
        
        -- Média por Destino para base do cálculo do Coeficiente de Variação:
        AVG(peso_em_kg) OVER(PARTITION BY 
            CASE 
                WHEN estado_destino IN ('SP', 'RJ', 'MG', 'ES') THEN 'Sudeste'
                WHEN estado_destino IN ('PR', 'SC', 'RS') THEN 'Sul'
                WHEN estado_destino IN ('BA', 'PE', 'CE', 'MA', 'PB', 'RN', 'AL', 'SE', 'PI') THEN 'Nordeste'
                WHEN estado_destino IN ('MT', 'MS', 'GO', 'DF') THEN 'Centro-Oeste'
                WHEN estado_destino IN ('AM', 'PA', 'RO', 'TO', 'AC', 'AP', 'RR') THEN 'Norte'
                ELSE 'Não Identificado'
            END
        ) AS media_janela
    FROM `skilled-sunrise-486800-j9.analise_logistica.metricas_estatisticas`
)

SELECT DISTINCT
    regiao_destino,
    -- Desvio Padrão truncado em 3 casas decimais:
    TRUNC(desvio_padrao_janela, 3) AS desvio_padrao_peso_kg,
    -- Coeficiente de Variação expresso em formato percentual relativo (%):
    TRUNC((desvio_padrao_janela / media_janela) * 100, 2) AS coeficiente_variacao_pct
FROM metricas_variabilidade
ORDER BY coeficiente_variacao_pct DESC;



























