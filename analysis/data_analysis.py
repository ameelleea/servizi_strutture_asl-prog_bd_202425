import pandas as pd
from sqlalchemy import create_engine

# Parametri di connessione
user = 'root'
password = ''
host = 'localhost'  # oppure IP del server
port = 3306
database = 'miei_dati'

# Crea l'engine SQLAlchemy
engine = create_engine(f'mysql+mysqlconnector://{user}:{password}@{host}:{port}/{database}')

# Legge una tabella intera in un DataFrame
df = pd.read_sql('SELECT * FROM utenti', con=engine)

# Mostra i primi risultati
print(df.head())

#Per usare query complesse
query = """
SELECT nome, COUNT(*) as occorrenze
FROM utenti
GROUP BY nome
ORDER BY occorrenze DESC
"""

df_query = pd.read_sql(query, con=engine)
print(df_query)

#Sicurezza e gestione errori
try:
    engine = create_engine(f'mysql+mysqlconnector://{user}:{password}@{host}:{port}/{database}')
    df = pd.read_sql('SELECT * FROM utenti', con=engine)
    print(df.describe())
except Exception as e:
    print("Errore durante la connessione o la query:", e)
