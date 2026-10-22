-- Receita e pedidos por mês (pedidos entregues)
SELECT
    strftime('%Y-%m', o.order_purchase_timestamp) AS mes,
    COUNT(DISTINCT o.order_id)                    AS pedidos,
    ROUND(SUM(oi.price), 2)                       AS receita
FROM olist_orders_dataset o
JOIN olist_order_items_dataset oi
    ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY mes
ORDER BY mes;