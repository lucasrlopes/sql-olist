-- Formas de pagamento dos pedidos entregues: pedidos e valor por forma
-- Um pedido pode ter mais de uma forma, por isso a soma dos % de pedidos passa de 100
WITH pagamentos AS (
    SELECT
        p.order_id,
        p.payment_type,
        p.payment_installments,
        p.payment_value
    FROM olist_order_payments_dataset p
    JOIN olist_orders_dataset o
        ON o.order_id = p.order_id
    WHERE o.order_status = 'delivered'
)
SELECT
    payment_type                                                   AS forma,
    COUNT(DISTINCT order_id)                                       AS pedidos,
    ROUND(100.0 * COUNT(DISTINCT order_id)
          / (SELECT COUNT(DISTINCT order_id) FROM pagamentos), 1)  AS pct_pedidos,
    ROUND(SUM(payment_value), 2)                                   AS valor,
    ROUND(100.0 * SUM(payment_value)
          / (SELECT SUM(payment_value) FROM pagamentos), 1)        AS pct_valor
FROM pagamentos
GROUP BY payment_type
ORDER BY pedidos DESC;

-- Parcelas no cartão de crédito, em faixas, com o valor médio de cada faixa
WITH cartao AS (
    SELECT
        p.payment_installments AS parcelas,
        p.payment_value        AS valor
    FROM olist_order_payments_dataset p
    JOIN olist_orders_dataset o
        ON o.order_id = p.order_id
    WHERE o.order_status = 'delivered'
      AND p.payment_type = 'credit_card'
)
SELECT
    CASE
        WHEN parcelas <= 1 THEN '1x'
        WHEN parcelas <= 3 THEN '2 a 3x'
        WHEN parcelas <= 6 THEN '4 a 6x'
        ELSE '7x ou mais'
    END                                                      AS faixa,
    COUNT(*)                                                 AS pagamentos,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM cartao), 1) AS pct,
    ROUND(AVG(valor), 2)                                     AS valor_medio
FROM cartao
GROUP BY faixa
ORDER BY MIN(parcelas);

-- Média de parcelas no cartão
SELECT ROUND(AVG(p.payment_installments), 1) AS media_parcelas
FROM olist_order_payments_dataset p
JOIN olist_orders_dataset o
    ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
  AND p.payment_type = 'credit_card';
