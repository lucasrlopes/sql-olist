-- Índices e desempenho: o que muda no tempo das consultas
-- Rodar em três momentos: sem índices, com a parte 2 e com a parte 3. Os testes da parte 1 se repetem em cada um.

-- 1) Testes
-- A) Itens de um pedido
SELECT order_item_id, product_id, price
FROM olist_order_items_dataset
WHERE order_id = '85144828ac9ae2c1f2bf87f032a33745';

-- B) Histórico de um cliente
SELECT o.order_id, o.order_purchase_timestamp
FROM olist_customers_dataset c
JOIN olist_orders_dataset o
    ON o.customer_id = c.customer_id
WHERE c.customer_unique_id = '3b2b9a48d63a20ea0711d8cc53234307';

-- C) Pedidos de um mês (Black Friday de 2017)
SELECT COUNT(*) AS pedidos
FROM olist_orders_dataset
WHERE order_purchase_timestamp >= '2017-11-01'
  AND order_purchase_timestamp <  '2017-12-01';

-- D) e E) são a consulta 03 (receita por estado) e a primeira do arquivo 08 (cohort), rodadas nos arquivos delas

-- Plano de execução: SCAN = lê a tabela inteira; SEARCH = vai direto às linhas pelo índice
-- COVERING INDEX = o índice já tem todas as colunas, nem precisa abrir a tabela
-- AUTOMATIC = o SQLite montou um índice temporário só para esta consulta
EXPLAIN QUERY PLAN
SELECT order_item_id, product_id, price
FROM olist_order_items_dataset
WHERE order_id = '85144828ac9ae2c1f2bf87f032a33745';

EXPLAIN QUERY PLAN
SELECT o.order_id, o.order_purchase_timestamp
FROM olist_customers_dataset c
JOIN olist_orders_dataset o
    ON o.customer_id = c.customer_id
WHERE c.customer_unique_id = '3b2b9a48d63a20ea0711d8cc53234307';

EXPLAIN QUERY PLAN
SELECT COUNT(*) AS pedidos
FROM olist_orders_dataset
WHERE order_purchase_timestamp >= '2017-11-01'
  AND order_purchase_timestamp <  '2017-12-01';

EXPLAIN QUERY PLAN
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
GROUP BY c.customer_state;

-- 2) Índices simples: uma coluna em cada, nas colunas de filtro e de JOIN
-- Sem índice em order_status: 'delivered' é 97% dos pedidos, então filtrar por ele quase não descarta linhas.
CREATE INDEX IF NOT EXISTS idx_items_pedido     ON olist_order_items_dataset (order_id);
CREATE INDEX IF NOT EXISTS idx_clientes_id      ON olist_customers_dataset (customer_id);
CREATE INDEX IF NOT EXISTS idx_clientes_unico   ON olist_customers_dataset (customer_unique_id);
CREATE INDEX IF NOT EXISTS idx_pedidos_cliente  ON olist_orders_dataset (customer_id);
CREATE INDEX IF NOT EXISTS idx_pedidos_data     ON olist_orders_dataset (order_purchase_timestamp);
CREATE INDEX IF NOT EXISTS idx_produtos_id      ON olist_products_dataset (product_id);

-- 3) Índices cobrindo: troca os três índices de JOIN por versões que já trazem as colunas usadas nas consultas de receita
DROP INDEX IF EXISTS idx_items_pedido;
DROP INDEX IF EXISTS idx_clientes_id;
DROP INDEX IF EXISTS idx_produtos_id;

CREATE INDEX IF NOT EXISTS idx_items_pedido_cobre   ON olist_order_items_dataset (order_id, price, product_id);
CREATE INDEX IF NOT EXISTS idx_clientes_id_cobre    ON olist_customers_dataset (customer_id, customer_state, customer_unique_id);
CREATE INDEX IF NOT EXISTS idx_produtos_id_cobre    ON olist_products_dataset (product_id, product_category_name);

-- 4) Conferência: índices que ficaram no banco
SELECT tbl_name AS tabela, name AS indice
FROM sqlite_master
WHERE type = 'index'
ORDER BY tabela, indice;
