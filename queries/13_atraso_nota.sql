-- Atraso na entrega x nota da avaliação, por faixa de atraso
-- Atraso = data de entrega ao cliente menos a data prevista, em dias (date corta a hora)
-- Alguns pedidos têm duas avaliações, por isso a nota é a média por pedido
WITH notas AS (
    SELECT
        order_id,
        AVG(review_score) AS nota
    FROM olist_order_reviews_dataset
    GROUP BY order_id
),
pedidos AS (
    SELECT
        o.order_id,
        julianday(date(o.order_delivered_customer_date))
          - julianday(date(o.order_estimated_delivery_date)) AS dias_atraso,
        n.nota
    FROM olist_orders_dataset o
    JOIN notas n
        ON n.order_id = o.order_id
    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date <> ''
)
SELECT
    CASE
        WHEN dias_atraso <= 0  THEN 'no prazo'
        WHEN dias_atraso <= 3  THEN '1 a 3 dias'
        WHEN dias_atraso <= 7  THEN '4 a 7 dias'
        WHEN dias_atraso <= 14 THEN '8 a 14 dias'
        ELSE '15 dias ou mais'
    END                                                          AS atraso,
    COUNT(*)                                                     AS pedidos,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM pedidos), 1)  AS pct_pedidos,
    ROUND(AVG(nota), 2)                                          AS nota_media,
    ROUND(100.0 * SUM(nota <= 2) / COUNT(*), 1)                  AS pct_nota_1_ou_2
FROM pedidos
GROUP BY atraso
ORDER BY MIN(dias_atraso);

-- Resumo: no prazo x atrasado
WITH notas AS (
    SELECT
        order_id,
        AVG(review_score) AS nota
    FROM olist_order_reviews_dataset
    GROUP BY order_id
),
pedidos AS (
    SELECT
        o.order_id,
        julianday(date(o.order_delivered_customer_date))
          - julianday(date(o.order_estimated_delivery_date)) AS dias_atraso,
        n.nota
    FROM olist_orders_dataset o
    JOIN notas n
        ON n.order_id = o.order_id
    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date <> ''
)
SELECT
    CASE WHEN dias_atraso <= 0 THEN 'no prazo' ELSE 'atrasado' END AS situacao,
    COUNT(*)                                                       AS pedidos,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM pedidos), 1)    AS pct_pedidos,
    ROUND(AVG(nota), 2)                                            AS nota_media,
    ROUND(100.0 * SUM(nota <= 2) / COUNT(*), 1)                    AS pct_nota_1_ou_2
FROM pedidos
GROUP BY situacao
ORDER BY MIN(dias_atraso);