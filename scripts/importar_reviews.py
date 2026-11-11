# Importa o CSV de avaliações para o olist.db.
# O DBeaver falha nesse arquivo porque alguns comentários têm quebra de linha
# dentro das aspas. O pandas lê esses campos corretamente.
# Rodar da pasta do projeto: python scripts/importar_reviews.py

import sqlite3
import pandas as pd

reviews = pd.read_csv("data/olist_order_reviews_dataset.csv")
print(f"Linhas lidas do CSV: {len(reviews)}")

con = sqlite3.connect("data/olist.db")
reviews.to_sql("olist_order_reviews_dataset", con, index=False, if_exists="fail")

total = con.execute("SELECT COUNT(*) FROM olist_order_reviews_dataset").fetchone()[0]
print(f"Linhas gravadas no banco: {total}")
con.close()