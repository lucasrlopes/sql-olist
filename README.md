# Análise de e-commerce com SQL: Olist

Análise exploratória em SQL de cerca de 100 mil pedidos feitos entre 2016 e 2018 no marketplace brasileiro Olist. O foco são vendas, clientes, entregas e avaliações.

## Perguntas de negócio

1. Como a receita e o número de pedidos evoluíram mês a mês?
2. Quais estados e categorias concentram mais vendas?
3. Qual é o ticket médio e como os clientes pagam (cartão, boleto, parcelas)?
4. Atraso na entrega derruba a nota da avaliação?
5. Quanto dos clientes volta a comprar?

## Principais achados

_Em construção._

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
