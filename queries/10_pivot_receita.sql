-- Pivot da receita: anos nas linhas e meses nas colunas (pedidos entregues)
WITH receita_mes AS (
    SELECT
        strftime('%Y', o.order_purchase_timestamp) AS ano,
        strftime('%m', o.order_purchase_timestamp) AS mes,
        SUM(oi.price)                              AS receita
    FROM olist_orders_dataset o
    JOIN olist_order_items_dataset oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY ano, mes
)
SELECT
    ano,
    ROUND(SUM(CASE WHEN mes = '01' THEN receita END), 0) AS jan,
    ROUND(SUM(CASE WHEN mes = '02' THEN receita END), 0) AS fev,
    ROUND(SUM(CASE WHEN mes = '03' THEN receita END), 0) AS mar,
    ROUND(SUM(CASE WHEN mes = '04' THEN receita END), 0) AS abr,
    ROUND(SUM(CASE WHEN mes = '05' THEN receita END), 0) AS mai,
    ROUND(SUM(CASE WHEN mes = '06' THEN receita END), 0) AS jun,
    ROUND(SUM(CASE WHEN mes = '07' THEN receita END), 0) AS jul,
    ROUND(SUM(CASE WHEN mes = '08' THEN receita END), 0) AS ago,
    ROUND(SUM(CASE WHEN mes = '09' THEN receita END), 0) AS "set",
    ROUND(SUM(CASE WHEN mes = '10' THEN receita END), 0) AS "out",
    ROUND(SUM(CASE WHEN mes = '11' THEN receita END), 0) AS nov,
    ROUND(SUM(CASE WHEN mes = '12' THEN receita END), 0) AS dez,
    ROUND(SUM(receita), 0)                               AS total
FROM receita_mes
GROUP BY ano
ORDER BY ano;