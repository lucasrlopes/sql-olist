-- Window functions sobre a receita mensal (pedidos entregues)

-- 1) Receita acumulada: soma do primeiro mês até o mês da linha
WITH receita_mensal AS (
    SELECT
        strftime('%Y-%m', o.order_purchase_timestamp) AS mes,
        SUM(oi.price)                                 AS receita
    FROM olist_orders_dataset o
    JOIN olist_order_items_dataset oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY mes
)
SELECT
    mes,
    ROUND(receita, 2)                          AS receita,
    ROUND(SUM(receita) OVER (ORDER BY mes), 2) AS receita_acumulada
FROM receita_mensal
ORDER BY mes;

-- 2) Média móvel de 3 meses: média do mês da linha e dos 2 meses anteriores
WITH receita_mensal AS (
    SELECT
        strftime('%Y-%m', o.order_purchase_timestamp) AS mes,
        SUM(oi.price)                                 AS receita
    FROM olist_orders_dataset o
    JOIN olist_order_items_dataset oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY mes
)
SELECT
    mes,
    ROUND(receita, 2) AS receita,
    ROUND(AVG(receita) OVER (
        ORDER BY mes
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2)             AS media_movel_3m
FROM receita_mensal
ORDER BY mes;

-- 3) Variação MoM: receita do mês contra a do mês anterior, em %
WITH receita_mensal AS (
    SELECT
        strftime('%Y-%m', o.order_purchase_timestamp) AS mes,
        SUM(oi.price)                                 AS receita
    FROM olist_orders_dataset o
    JOIN olist_order_items_dataset oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY mes
),
com_anterior AS (
    SELECT
        mes,
        receita,
        LAG(mes)     OVER (ORDER BY mes) AS mes_anterior,
        LAG(receita) OVER (ORDER BY mes) AS receita_anterior
    FROM receita_mensal
)
SELECT
    mes,
    ROUND(receita, 2)                                                 AS receita,
    mes_anterior,
    ROUND(receita_anterior, 2)                                        AS receita_anterior,
    ROUND(100.0 * (receita - receita_anterior) / receita_anterior, 2) AS variacao_mom_pct
FROM com_anterior
ORDER BY mes;

-- 4) Variação YoY: receita do mês contra a do mesmo mês do ano anterior, em %
WITH receita_mensal AS (
    SELECT
        strftime('%Y-%m', o.order_purchase_timestamp) AS mes,
        SUM(oi.price)                                 AS receita
    FROM olist_orders_dataset o
    JOIN olist_order_items_dataset oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY mes
),
com_ano_anterior AS (
    SELECT
        mes,
        receita,
        LAG(mes)     OVER (PARTITION BY substr(mes, 6, 2) ORDER BY mes) AS mes_ano_anterior,
        LAG(receita) OVER (PARTITION BY substr(mes, 6, 2) ORDER BY mes) AS receita_ano_anterior
    FROM receita_mensal
)
SELECT
    mes,
    ROUND(receita, 2)                                                         AS receita,
    mes_ano_anterior,
    ROUND(receita_ano_anterior, 2)                                            AS receita_ano_anterior,
    ROUND(100.0 * (receita - receita_ano_anterior) / receita_ano_anterior, 2) AS variacao_yoy_pct
FROM com_ano_anterior
ORDER BY mes;
