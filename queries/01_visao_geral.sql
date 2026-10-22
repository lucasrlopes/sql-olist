-- Visão geral: total de pedidos e período coberto pelos dados
SELECT
    COUNT(*)                      AS total_pedidos,
    MIN(order_purchase_timestamp) AS primeira_compra,
    MAX(order_purchase_timestamp) AS ultima_compra
FROM olist_orders_dataset;

-- Pedidos por status: mostra por que filtramos só os entregues
SELECT
    order_status,
    COUNT(*) AS pedidos
FROM olist_orders_dataset
GROUP BY order_status
ORDER BY pedidos DESC;

-- Receita total (soma de price) dos pedidos entregues
SELECT
    COUNT(DISTINCT o.order_id) AS pedidos,
    COUNT(*)                   AS itens,
    ROUND(SUM(oi.price), 2)    AS receita
FROM olist_orders_dataset o
JOIN olist_order_items_dataset oi
    ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered';

-- Clientes: customer_id muda a cada pedido; customer_unique_id é a pessoa
SELECT
    COUNT(DISTINCT c.customer_id)        AS customer_ids,
    COUNT(DISTINCT c.customer_unique_id) AS clientes_unicos
FROM olist_orders_dataset o
JOIN olist_customers_dataset c
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered';
