-- Receita por estado do cliente e participação no total (pedidos entregues)
SELECT
    c.customer_state           AS estado,
    COUNT(DISTINCT o.order_id) AS pedidos,
    ROUND(SUM(oi.price), 2)    AS receita,
    ROUND(100.0 * SUM(oi.price) / (
        SELECT SUM(oi2.price)
        FROM olist_orders_dataset o2
        JOIN olist_order_items_dataset oi2 ON oi2.order_id = o2.order_id
        WHERE o2.order_status = 'delivered'
    ), 1)                      AS pct_receita
FROM olist_orders_dataset o
JOIN olist_order_items_dataset oi
    ON oi.order_id = o.order_id
JOIN olist_customers_dataset c
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY receita DESC;