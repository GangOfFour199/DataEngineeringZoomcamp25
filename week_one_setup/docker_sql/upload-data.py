import pandas as pd
# The next step uses sqlalchemy which has been downloaded. It contains a create_engine function
from sqlalchemy import create_engine

# with create_engine, need to specify in following format -> 'language://user:password@host:port/database_name'
# using create_engine converts variable types labelled REAL to DDL, transforming them into SQL stanadard data types (i.e FLOAT(n))
engine = create_engine('postgresql://root:root@localhost:5432/ny_taxi')

pd.__version__

df = pd.read_csv('yellow_tripdata_2021-01.csv.gz', nrows=1000)

pd.io.sql.get_schema(df, name='yellow_taxi_data_100')

# Pandas is unaware datetime var are not TEXT types, therefore use func to convert to to DATE types.

df.tpep_pickup_datetime = pd.to_datetime(df.tpep_pickup_datetime)
df.tpep_dropoff_datetime = pd.to_datetime(df.tpep_dropoff_datetime)

# chunksize breaks our dataset into given numerical amount, the iterator allows us to trvaerse each chunk 

df_iter = pd.read_csv('yellow_tripdata_2021-01.csv.gz', iterator=True, chunksize=10000)

df = next(df_iter)

df

len(df)

df.head(n=25)

# To insert each data chunk into our table, use to_sql() function below. specify table name and include the engine var as connection. Must account for case where table of same name already exists, in this instance use 'replace' which will drop the previosuly existing table and replace it with this new one.

# For this example, only replace the heading as we don't want to input any rows of data here.

df.head(n=0).to_sql(name='yellow_taxi_data_1000', con=engine, if_exists='replace')

# Now, remove the .head() func and change if_exists='replace' to 'append' in order to add data to our newly created table

df.to_sql(name='yellow_taxi_data_1000', con=engine, if_exists='append')


