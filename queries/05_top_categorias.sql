-- Top 10 categorias por receita (pedidos entregues)
SELECT
    COALESCE(t.product_category_name_english,
             NULLIF(p.product_category_name, ''),
             'sem categoria')   AS categoria,
    COUNT(DISTINCT o.order_id)  AS pedidos,
    ROUND(SUM(oi.price), 2)     AS receita
FROM olist_orders_dataset o
JOIN olist_order_items_dataset oi
    ON oi.order_id = o.order_id
JOIN olist_products_dataset p
    ON p.product_id = oi.product_id
LEFT JOIN product_category_name_translation t
    ON t.product_category_name = p.product_category_name
WHERE o.order_status = 'delivered'
GROUP BY categoria
ORDER BY receita DESC
LIMIT 10;