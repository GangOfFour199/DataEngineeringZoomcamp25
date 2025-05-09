-- Creating external table referring to gcs path
CREATE OR REPLACE EXTERNAL TABLE `project-id.db_name.external_yellow_tripdata`
OPTIONS (
  format = 'CSV',
  uris = ['gs://bucket-name/yellow_tripdata_2019-*.csv', 'gs://bucket-name/yellow_tripdata_2020-*.csv']
);

-- Check yellow trip data
SELECT * FROM project-id.db_name.external_yellow_tripdata limit 10;

-- Create a non partitioned table from external table, costlier as processing more data 
CREATE OR REPLACE TABLE project-id.db_name.yellow_tripdata_non_partitioned AS
SELECT * FROM project-id.db_name.external_yellow_tripdata;


-- Create a partitioned table from external table, processing refined data values
CREATE OR REPLACE TABLE project-id.db_name.yellow_tripdata_partitioned
PARTITION BY
  DATE(tpep_pickup_datetime) AS
SELECT * FROM project-id.db_name.external_yellow_tripdata;

-- Impact of partition
-- Scanning 1.62GB of data
SELECT DISTINCT(VendorID)
FROM project-id.db_name.yellow_tripdata_non_partitioned
WHERE DATE(tpep_pickup_datetime) BETWEEN '2019-06-01' AND '2019-06-30';

-- Scanning 105.91 MB of DATA
SELECT DISTINCT(VendorID)
FROM project-id.db_name.yellow_tripdata_partitioned
WHERE DATE(tpep_pickup_datetime) BETWEEN '2019-06-01' AND '2019-06-30';

-- Let's look into the partitions
SELECT table_name, partition_id, total_rows
FROM `db_name.INFORMATION_SCHEMA.PARTITIONS`
WHERE table_name = 'yellow_tripdata_partitioned'
ORDER BY total_rows DESC;

-- Creating a partition and cluster table
CREATE OR REPLACE TABLE project-id.db_name.yellow_tripdata_partitioned_clustered
PARTITION BY DATE(tpep_pickup_datetime)
CLUSTER BY PULocationID AS
SELECT * FROM project-id.db_name.external_yellow_tripdata;

-- Query scans 1.07 GB
SELECT count(*) as num_trips
FROM project-id.db_name.yellow_tripdata_partitioned
WHERE DATE(tpep_pickup_datetime) BETWEEN '2019-06-01' AND '2020-12-31'
  AND PULocationID=65;

-- Query scans 861 MB
SELECT count(*) as num_trips
FROM project-id.db_name.yellow_tripdata_partitioned_clustered
WHERE DATE(tpep_pickup_datetime) BETWEEN '2019-06-01' AND '2020-12-31'
  AND PULocationID = 65;
