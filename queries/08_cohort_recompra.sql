-- Cohort de clientes: cada cohort é o grupo que fez a primeira compra no mesmo mês (pedidos entregues)
-- Recompra = comprar em outro dia (mesma regra do arquivo 07). 2016 fica de fora: são poucos clientes.

-- 1) Recompra em até 90 dias, por cohort
-- Janela fixa de 90 dias para comparar cohorts antigos e novos de forma justa.
-- Vai até 2018-05: os dados acabam em 29/08/2018, então os cohorts seguintes ainda não tiveram 90 dias.
WITH dias_compra AS (
    SELECT DISTINCT
        c.customer_unique_id             AS cliente,
        date(o.order_purchase_timestamp) AS dia
    FROM olist_orders_dataset o
    JOIN olist_customers_dataset c
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
),
primeira AS (
    SELECT
        cliente,
        MIN(dia) AS primeira_compra
    FROM dias_compra
    GROUP BY cliente
),
voltou AS (
    SELECT
        p.cliente,
        strftime('%Y-%m', p.primeira_compra) AS cohort,
        MAX(CASE WHEN d.dia > p.primeira_compra
                  AND julianday(d.dia) - julianday(p.primeira_compra) <= 90
                 THEN 1 ELSE 0 END)          AS voltou_90d
    FROM primeira p
    JOIN dias_compra d
        ON d.cliente = p.cliente
    GROUP BY p.cliente, cohort
)
SELECT
    cohort,
    COUNT(*)                                     AS clientes,
    SUM(voltou_90d)                              AS voltaram_90d,
    ROUND(100.0 * SUM(voltou_90d) / COUNT(*), 2) AS recompra_90d_pct
FROM voltou
WHERE cohort BETWEEN '2017-01' AND '2018-05'
GROUP BY cohort
ORDER BY cohort;

-- 2) Tabela de cohort: % de cada cohort que comprou de novo 1, 2 e 3 meses depois da primeira compra
-- Vai até 2018-04: é o último cohort com os 3 meses seguintes completos.
WITH dias_compra AS (
    SELECT DISTINCT
        c.customer_unique_id             AS cliente,
        date(o.order_purchase_timestamp) AS dia
    FROM olist_orders_dataset o
    JOIN olist_customers_dataset c
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
),
primeira AS (
    SELECT
        cliente,
        MIN(dia) AS primeira_compra
    FROM dias_compra
    GROUP BY cliente
),
meses AS (
    SELECT
        p.cliente,
        strftime('%Y-%m', p.primeira_compra) AS cohort,
        (CAST(strftime('%Y', d.dia) AS INTEGER) * 12 + CAST(strftime('%m', d.dia) AS INTEGER))
      - (CAST(strftime('%Y', p.primeira_compra) AS INTEGER) * 12 + CAST(strftime('%m', p.primeira_compra) AS INTEGER)) AS mes_n
    FROM primeira p
    JOIN dias_compra d
        ON d.cliente = p.cliente
)
SELECT
    cohort,
    COUNT(DISTINCT CASE WHEN mes_n = 0 THEN cliente END) AS clientes,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN mes_n = 1 THEN cliente END)
                / COUNT(DISTINCT CASE WHEN mes_n = 0 THEN cliente END), 2) AS mes_1_pct,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN mes_n = 2 THEN cliente END)
                / COUNT(DISTINCT CASE WHEN mes_n = 0 THEN cliente END), 2) AS mes_2_pct,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN mes_n = 3 THEN cliente END)
                / COUNT(DISTINCT CASE WHEN mes_n = 0 THEN cliente END), 2) AS mes_3_pct
FROM meses
WHERE cohort BETWEEN '2017-01' AND '2018-04'
GROUP BY cohort
ORDER BY cohort;