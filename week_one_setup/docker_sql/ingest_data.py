# ***Note*** - NYC taxi files are PARQUET files

import os
import argparse 
import pandas as pd 

from time import time

# The next step uses sqlalchemy which has been downloaded. It contains a create_engine function
from sqlalchemy import create_engine

# with create_engine, need to specify in following format -> 'language://user:password@host:port/database_name'
# using create_engine converts variable types labelled REAL to DDL, transforming them into SQL stanadard data types (i.e FLOAT(n))

def main(params):

    user = params.user
    password = params.password
    host = params.host
    port = params.port
    db = params.db
    table_name = params.table_name
    url = params.url
    parquet_name = 'output.parquet'

    # download parquet file - look at pipeline.py test, here we want to get url of data then output will be a parquet file

    os.system(f"wget{url} -O {parquet_name}")

    print('Successfully downloaded parquet file')

    engine = create_engine('postgresql://{user}:{password}@{host}:{port}/{db}')

    t_start = time()

    df = pd.read_parquet(parquet_name)

    print('Succesfully connected to Postgres')

    # Pandas is unaware datetime var are not TEXT types, therefore use func to convert to to DATE types.

    df.tpep_pickup_datetime = pd.to_datetime(df.tpep_pickup_datetime)
    df.tpep_dropoff_datetime = pd.to_datetime(df.tpep_dropoff_datetime)

    df.head(n=0).to_sql(name=table_name, con=engine, if_exists='replace')

    print('Successfully created a table in Postgres')

    # Now, remove the .head() func and change if_exists='replace' to 'append' in order to add data to our newly created table

    df.to_sql(name=table_name, con=engine, if_exists='append')

    t_end = time()

    print(f'Successfully ingested data in {t_end - t_start} seconds')

# this is called main block of python, this helps with scope and encapsulates the code within the top level block
if __name__ == '__main__':
    # user, password, port, host, database-name, table name, url of csv
    parser = argparse.ArgumentParser(description='Ingest the CSV data to Postgres')

    parser.add_argument('--user', help='postgres user name required')
    parser.add_argument('--password', help='postgres user password required')
    parser.add_argument('--host', help='postgres host name required')
    parser.add_argument('--port', help='postgres user name required')
    parser.add_argument('--db', help='psostgres database name required')
    parser.add_argument('--table_name', help='name of table where data will be written into')
    parser.add_argument('--url', help='url of parquet file required')

    args = parser.parse_args()

    main(args)





