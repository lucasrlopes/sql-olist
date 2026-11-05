-- Segmentação RFM de clientes (pedidos entregues)
-- R = recência: dias desde a última compra até 30/08/2018 (o dia seguinte à última compra da base)
-- F = frequência: dias diferentes de compra (mesma regra da 07_recompra_clientes.sql)
-- M = valor monetário: soma de price dos pedidos do cliente (sem frete)

-- 0) View com as notas R, F e M de cada cliente. Rode uma vez, e as consultas abaixo leem dela.
DROP VIEW IF EXISTS rfm_clientes;

CREATE VIEW rfm_clientes AS
WITH pedidos AS (
    SELECT
        c.customer_unique_id             AS cliente,
        o.order_id,
        date(o.order_purchase_timestamp) AS dia
    FROM olist_orders_dataset o
    JOIN olist_customers_dataset c
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
),
valor_pedido AS (
    SELECT
        order_id,
        SUM(price) AS valor
    FROM olist_order_items_dataset
    GROUP BY order_id
),
por_cliente AS (
    SELECT
        p.cliente,
        CAST(julianday('2018-08-30') - julianday(MAX(p.dia)) AS INTEGER) AS recencia_dias,
        COUNT(DISTINCT p.dia)                                            AS frequencia,
        SUM(v.valor)                                                     AS valor_total
    FROM pedidos p
    JOIN valor_pedido v
        ON v.order_id = p.order_id
    GROUP BY p.cliente
),
notas AS (
    SELECT
        *,
        NTILE(5) OVER (ORDER BY recencia_dias DESC) AS r,
        CASE WHEN frequencia = 1 THEN 1
             WHEN frequencia = 2 THEN 4
             ELSE 5
        END                                         AS f,
        NTILE(5) OVER (ORDER BY valor_total)        AS m
    FROM por_cliente
)
SELECT
    *,
    CASE
        WHEN f >= 4 AND r >= 4 THEN '1) Campeões'
        WHEN f >= 4            THEN '2) Fiéis inativos'
        WHEN r >= 4 AND m >= 4 THEN '3) Novos de alto valor'
        WHEN r >= 4            THEN '4) Novos de baixo valor'
        WHEN m >= 4            THEN '5) Alto valor inativo'
        ELSE                        '6) Baixo valor inativo'
    END AS segmento
FROM notas;

-- 1) Os 20 clientes de maior valor, com as notas
SELECT
    cliente,
    recencia_dias,
    frequencia,
    ROUND(valor_total, 2) AS valor_total,
    r, f, m,
    segmento
FROM rfm_clientes
ORDER BY valor_total DESC
LIMIT 20;

-- 2) Resumo por segmento
SELECT
    segmento,
    COUNT(*)                                                       AS clientes,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1)             AS pct_clientes,
    ROUND(SUM(valor_total), 2)                                     AS receita,
    ROUND(100.0 * SUM(valor_total) / SUM(SUM(valor_total)) OVER (), 1) AS pct_receita,
    ROUND(AVG(valor_total), 2)                                     AS valor_medio,
    ROUND(AVG(recencia_dias))                                      AS recencia_media_dias
FROM rfm_clientes
GROUP BY segmento
ORDER BY segmento;

-- 3) Limites de cada nota: de quantos dias e de quantos reais vai cada faixa
SELECT
    'R' AS nota_de, r AS nota,
    MIN(recencia_dias) AS minimo, MAX(recencia_dias) AS maximo,
    COUNT(*) AS clientes
FROM rfm_clientes
GROUP BY r
UNION ALL
SELECT
    'M', m,
    ROUND(MIN(valor_total), 2), ROUND(MAX(valor_total), 2),
    COUNT(*)
FROM rfm_clientes
GROUP BY m
ORDER BY nota_de DESC, nota;