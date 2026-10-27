-- Receita por estado do cliente e participação no total (pedidos entregues)
WITH receita_estado AS (
    SELECT
        c.customer_state           AS estado,
        COUNT(DISTINCT o.order_id) AS pedidos,
        SUM(oi.price)              AS receita
    FROM olist_orders_dataset o
    JOIN olist_order_items_dataset oi
        ON oi.order_id = o.order_id
    JOIN olist_customers_dataset c
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_state
),
total AS (
    SELECT SUM(receita) AS receita_total
    FROM receita_estado
)
SELECT
    estado,
    pedidos,
    ROUND(receita, 2)                         AS receita,
    ROUND(100.0 * receita / receita_total, 1) AS pct_receita
FROM receita_estado
CROSS JOIN total
ORDER BY receita DESC;