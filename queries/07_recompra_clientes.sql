-- Recompra de clientes (pedidos entregues)
-- Recompra = comprar em outro DIA. A Olist divide um carrinho em vários pedidos (um por vendedor),
-- então contar pedidos trataria a mesma compra como recompra.

-- 1) Base: primeira compra de cada cliente e quantos dias diferentes ele comprou
WITH dias_compra AS (
    SELECT DISTINCT
        c.customer_unique_id             AS cliente,
        date(o.order_purchase_timestamp) AS dia
    FROM olist_orders_dataset o
    JOIN olist_customers_dataset c
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
),
compras AS (
    SELECT
        cliente,
        dia,
        ROW_NUMBER() OVER (PARTITION BY cliente ORDER BY dia) AS n_compra,
        COUNT(*)     OVER (PARTITION BY cliente)              AS total_compras
    FROM dias_compra
)
SELECT
    cliente,
    dia                    AS primeira_compra,
    strftime('%Y-%m', dia) AS mes_primeira_compra,
    total_compras
FROM compras
WHERE n_compra = 1
ORDER BY total_compras DESC, cliente;

-- 2) Taxa de recompra: clientes por número de compras
WITH dias_compra AS (
    SELECT DISTINCT
        c.customer_unique_id             AS cliente,
        date(o.order_purchase_timestamp) AS dia
    FROM olist_orders_dataset o
    JOIN olist_customers_dataset c
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
),
por_cliente AS (
    SELECT
        cliente,
        COUNT(*) AS total_compras
    FROM dias_compra
    GROUP BY cliente
)
SELECT
    CASE WHEN total_compras >= 3 THEN '3 ou mais'
         ELSE CAST(total_compras AS TEXT)
    END                                                 AS compras,
    COUNT(*)                                            AS clientes,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_clientes
FROM por_cliente
GROUP BY compras
ORDER BY compras;

-- 3) Tempo entre a primeira e a segunda compra, em faixas
WITH dias_compra AS (
    SELECT DISTINCT
        c.customer_unique_id             AS cliente,
        date(o.order_purchase_timestamp) AS dia
    FROM olist_orders_dataset o
    JOIN olist_customers_dataset c
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
),
compras AS (
    SELECT
        cliente,
        dia,
        ROW_NUMBER() OVER (PARTITION BY cliente ORDER BY dia) AS n_compra
    FROM dias_compra
),
intervalo AS (
    SELECT
        p.cliente,
        julianday(s.dia) - julianday(p.dia) AS dias
    FROM compras p
    JOIN compras s
        ON s.cliente = p.cliente
       AND s.n_compra = 2
    WHERE p.n_compra = 1
)
SELECT
    CASE WHEN dias <= 30  THEN '1) até 30 dias'
         WHEN dias <= 90  THEN '2) 31 a 90 dias'
         WHEN dias <= 180 THEN '3) 91 a 180 dias'
         WHEN dias <= 365 THEN '4) 181 a 365 dias'
         ELSE '5) mais de 1 ano'
    END                                                 AS faixa,
    COUNT(*)                                            AS clientes,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_clientes
FROM intervalo
GROUP BY faixa
ORDER BY faixa;