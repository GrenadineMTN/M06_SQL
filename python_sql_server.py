
"""
# Connect to an Azure Database with Python
# https://docs.microsoft.com/en-us/azure/sql-database/sql-database-connect-query-python

import pyodbc
from dotenv import find_dotenv
from dotenv import load_dotenv
import os


load_dotenv(find_dotenv())
USER_DB = os.environ["USER_DB"]
PASSWORD_DB = os.environ["PASSWORD_DB"]
HOST_DB = os.environ["HOST_DB"]
PORT_DB = os.environ["PORT_DB"]
DATABASE = 'test3'


server = HOST_DB
database = DATABASE
username = USER_DB
password = PASSWORD_DB
driver= '{ODBC Driver 17 for SQL Server}'

with pyodbc.connect('DRIVER='+driver+';SERVER=tcp:'+server+';PORT=1433;DATABASE='+database+';UID='+username+';PWD='+ password) as conn:
    with conn.cursor() as cursor:
        cursor.execute("SELECT * FROM SalesLT.Customer")
        row = cursor.fetchall()
print(row)

"""


import psycopg2
from dotenv import find_dotenv
from dotenv import load_dotenv
import pandas as pd
import os


load_dotenv(find_dotenv()) 
USER_DB = os.environ["USER_DB"]
PASSWORD_DB = os.environ["PASSWORD_DB"]
HOST_DB = os.environ["HOST_DB"]
PORT_DB = os.environ["PORT_DB"]

# Connect to the database and create the cursor
connexion = psycopg2.connect(
    database=USER_DB,
    user=USER_DB,
    password=PASSWORD_DB,
    host=HOST_DB,
    port=PORT_DB,
)
cursor = connexion.cursor()
cursor.execute("DROP TABLE IF EXISTS tvs")
cursor.execute(
    """
    CREATE TABLE tvs (
        insee VARCHAR(255) PRIMARY KEY,
        departement VARCHAR(255),
        commune VARCHAR(255),
        tvs VARCHAR(255),
        region VARCHAR(255)
)
"""
)
cursor.execute("SELECT * FROM tvs")
result = cursor.fetchall()
cursor.execute("INSERT INTO tvs VALUES ('12345', 'Paris', 'Paris', '100', 'Ile-de-France')")
cursor.execute("SELECT * FROM tvs")
result = cursor.fetchall()
# Load a dataframe in the database 
file_path = "correspondance-tvs-communes-2018.csv"
df = pd.read_csv(file_path, sep=";")
sql_query = """
    INSERT INTO tvs (insee, departement, commune, tvs, region)
    VALUES (%(insee)s, %(departement)s, %(commune)s, %(tvs)s, %(region)s)
"""
for _, rows in df.iterrows():
    cursor.execute(sql_query, rows.to_dict())
    print(f" Successfully inserted {rows['insee']}")
# Save changes and close the connection
connexion.commit()
connexion.close()

# Query example on database
# Count city that have 63 as departement
sql_query = "SELECT COUNT(*) FROM tvs WHERE departement = '63'"

# Count number of city into each department 
sql_query = "SELECT departement, COUNT(*) FROM tvs GROUP BY departement ORDER BY departement"
cursor.execute(sql_query)
result = cursor.fetchall()