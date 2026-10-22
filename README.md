# Análise de e-commerce com SQL: Olist

Análise exploratória em SQL de cerca de 100 mil pedidos feitos entre 2016 e 2018 no marketplace brasileiro Olist. O foco são vendas, clientes, entregas e avaliações.

## Perguntas de negócio

1. Como a receita e o número de pedidos evoluíram mês a mês?
2. Quais estados e categorias concentram mais vendas?
3. Qual é o ticket médio e como os clientes pagam (cartão, boleto, parcelas)?
4. Atraso na entrega derruba a nota da avaliação?
5. Quanto dos clientes volta a comprar?

## Principais achados

**Definições:** receita = soma do valor dos produtos (`price`, sem frete), considerando só pedidos entregues (`delivered`, 97% do total).

- **Tamanho:** 96,5 mil pedidos entregues entre set/2016 e ago/2018, somando R$ 13,2 milhões em receita.
- **Quase ninguém volta a comprar:** foram 93,4 mil clientes únicos para 96,5 mil pedidos, ou 1,03 pedido por cliente.
- **Crescimento e Black Friday:** a receita mensal saiu de R$ 112 mil (jan/2017) para algo entre R$ 826 mil e R$ 978 mil em 2018. O pico foi nov/2017 (R$ 988 mil), mês da Black Friday. Os dados de 2016 são residuais.
- **Concentração no Sudeste:** SP responde por 38% da receita; SP, RJ e MG juntos, por 63%.
- **Ticket médio de R$ 137,04 por pedido.** A média por item é R$ 119,98: calcular o ticket com `AVG(price)` o subestimaria em 12%. SP tem o menor ticket (R$ 125) e os estados do Norte e do Nordeste, os maiores (PB, R$ 218). Hipótese: o frete mais caro leva a compras menos frequentes e de valor maior.
- **Receita x volume:** relógios e presentes faturam mais (R$ 1,17 milhão) que cama, mesa e banho (R$ 1,02 milhão), com 40% menos pedidos.

## Dados

[Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) (Kaggle, licença CC BY-NC-SA 4.0). São 9 tabelas ligadas por `order_id`, `customer_id`, `product_id` e `seller_id`.

Os arquivos não ficam neste repositório. Para reproduzir:

1. Baixe o dataset no link acima e descompacte os 9 CSVs em `data/`.
2. No DBeaver, crie uma conexão SQLite apontando para `data/olist.db` e importe os CSVs (uma tabela por arquivo).
3. Rode as consultas da pasta `queries/` na ordem numérica.

## Estrutura

```
sql-olist/
├── data/       # CSVs e banco SQLite (fora do Git)
├── queries/    # consultas SQL numeradas
└── README.md
```

## Ferramentas

SQL (SQLite) · DBeaver · Git/GitHub
