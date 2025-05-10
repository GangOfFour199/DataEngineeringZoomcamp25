# SETUP + QUIZ QUESTIONS

<b><u>Important Note:</b></u> <p> For this homework we will be using the Yellow Taxi Trip Records for **January 2024 - June 2024 NOT the entire year of data** 
Parquet Files from the New York
City Taxi Data found here: </br> https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page </br>

**Load Script:** You can manually download the parquet files and upload them to your GCS Bucket or you can use the linked script [here](./load_yellow_taxi_data.py):<br>
You will simply need to generate a Service Account with GCS Admin Priveleges or be authenticated with the Google SDK and update the bucket name in the script to the name of your bucket<br>
Nothing is fool proof so make sure that all 6 files show in your GCS Bucket before begining.</br><br>

<u>NOTE:</u> You will need to use the PARQUET option files when creating an External Table</br>

<b>BIG QUERY SETUP:</b></br>
Create an external table using the Yellow Taxi Trip Records. </br>
Create a (regular/materialized) table in BQ using the Yellow Taxi Trip Records (do not partition or cluster this table). </br>
</p>

## Question 1:
Question 1: What is count of records for the 2024 Yellow Taxi Data?

### Answer
```sql
SELECT COUNT(*) FROM aqueous-flames-458811-k1.de_zoomcamp.2024_yellow_tripdata_materialised
```

- 20,332,093

## Question 2:
Write a query to count the distinct number of PULocationIDs for the entire dataset on both the tables.</br> 
What is the **estimated amount** of data that will be read when this query is executed on the External Table and the Table?

### Answer
```sql
SELECT COUNT(DISTINCT PULocationID) FROM aqueous-flames-458811-k1.de_zoomcamp.2024_external_yellow_tripdata
SELECT COUNT(DISTINCT PULocationID) FROM aqueous-flames-458811-k1.de_zoomcamp.2024_yellow_tripdata_materialised
```

- External = 0MB
- Materialised = 155.12MB

## Question 3:
Write a query to retrieve the PULocationID from the table (not the external table) in BigQuery. Now write a query to retrieve the PULocationID and DOLocationID on the same table. Why are the estimated number of Bytes different?

```sql
SELECT PuLocationID FROM aqueous-flames-458811-k1.de_zoomcamp.2024_yellow_tripdata_materialised
SELECT PuLocationID, DOLocationID FROM aqueous-flames-458811-k1.de_zoomcamp.2024_yellow_tripdata_materialised
```

### Answer

- The required estimate MB to process the data doubled to 310.24MB. As we are retrieving an additional row of values it requires another 155.12MB to retrieve a further column of data.

## Question 4:
How many records have a fare_amount of 0?

```sql
SELECT COUNT(*) FROM aqueous-flames-458811-k1.de_zoomcamp.2024_yellow_tripdata_materialised
WHERE fare_amount = 0;
```
### Answer

- 8333 rows

## Question 6:
Write a query to retrieve the distinct VendorIDs between tpep_dropoff_datetime
2024-03-01 and 2024-03-15 (inclusive)</br>

Use the materialized table you created earlier in your from clause and note the estimated bytes. Now change the table in the from clause to the partitioned table you created for question 5 and note the estimated bytes processed. What are these values? </br>

Choose the answer which most closely matches.</br> 

### Answer
```sql

```

-

## Question 7: 
Where is the data stored in the External Table you created?

### Answer


## Question 8:
It is best practice in Big Query to always cluster your data:
- True
- False

### Answer

- 

## (Bonus: Not worth points) Question 9:
No Points: Write a `SELECT count(*)` query FROM the materialized table you created. How many bytes does it estimate will be read? Why?

### Answer
```sql

```

-
