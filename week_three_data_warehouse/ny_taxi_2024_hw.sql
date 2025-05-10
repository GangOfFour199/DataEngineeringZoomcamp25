-- Creating external table referring to gcs path
CREATE OR REPLACE EXTERNAL TABLE `project-id.db_name.2024_external_yellow_tripdata`
OPTIONS (
  format = 'PARQUET',
  uris = ['gs://your-bucket-name/yellow_tripdata_2024-*.parquet']
);

-- Check yellow trip data
SELECT * FROM project-id.db_name.2024_external_yellow_tripdata limit 10;

-- Create a non partitioned table from external table 
CREATE OR REPLACE TABLE project-id.db_name.2024_yellow_tripdata_materialised AS
SELECT * FROM project-id.db_name.2024_external_yellow_tripdata;

-- check materialised table 
SELECT * FROM project-id.db_name.2024_yellow_tripdata_materialised LIMIT 100;

-- Create a partitioned table from external table, processing refined data values
CREATE OR REPLACE TABLE project-id.db_name.2024_yellow_tripdata_partitioned
PARTITION BY
  DATE(tpep_dropoff_datetime) AS
SELECT * FROM project-id.db_name.2024_external_yellow_tripdata;

-- Creating a partition and cluster table
CREATE OR REPLACE TABLE project-id.db_name.2024_yellow_tripdata_partitioned_clustered
PARTITION BY DATE(tpep_dropoff_datetime)
CLUSTER BY VendorID AS
SELECT * FROM project-id.db_name.2024_external_yellow_tripdata;

-- check clustered schema
SELECT * FROM project-id.de_zoomcamp.2024_yellow_tripdata_partitioned_clustered LIMIT 1000;

