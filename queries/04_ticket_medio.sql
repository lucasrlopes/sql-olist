-- Ticket médio por pedido x média por item (o erro comum)
SELECT
    ROUND(SUM(oi.price) / COUNT(DISTINCT o.order_id), 2) AS ticket_medio,
    ROUND(AVG(oi.price), 2)                              AS media_por_item
FROM olist_orders_dataset o
JOIN olist_order_items_dataset oi
    ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered';

-- Ticket médio por estado, calculado em duas etapas com CTE
WITH pedidos AS (
    SELECT
        o.order_id,
        c.customer_state,
        SUM(oi.price) AS valor_pedido
    FROM olist_orders_dataset o
    JOIN olist_order_items_dataset oi
        ON oi.order_id = o.order_id
    JOIN olist_customers_dataset c
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY o.order_id, c.customer_state
)
SELECT
    customer_state              AS estado,
    COUNT(*)                    AS pedidos,
    ROUND(AVG(valor_pedido), 2) AS ticket_medio
FROM pedidos
GROUP BY customer_state
ORDER BY ticket_medio DESC;

-- Validação: a média dos pedidos (CTE) tem que bater com receita / pedidos
WITH pedidos AS (
    SELECT
        o.order_id,
        SUM(oi.price) AS valor_pedido
    FROM olist_orders_dataset o
    JOIN olist_order_items_dataset oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY o.order_id
)
SELECT ROUND(AVG(valor_pedido), 2) AS ticket_medio
FROM pedidos;