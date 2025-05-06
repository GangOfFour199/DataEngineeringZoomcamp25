# QUIZ QUESTIONS

## Question 1

Within the execution for `Yellow` Taxi data for the year `2020` and month `12`: what is the uncompressed file size (i.e. the output file `yellow_tripdata_2020-12.csv` of the `extract` task)?

### Answer 

> *Uncompressed* file size located in Kestra. **Pathway**: executions -> details of file listed above -> outputs -> extract -> click file -> preview

- 128.3 MiB

> *Compressed* file size located in Google Cloud Platform. **Pathway**: cloud storage -> buckets -> click bucket name -> locate file above and read MB

- 134.5MB

## Question 2

What is the rendered value of the variable `file` when the inputs `taxi` is set to `green`, `year` is set to `2020`, and `month` is set to `04` during execution?

### Answer

- `green_tripdata_2020-04.csv`

## Question 3 

How many rows are there for the `Yellow` Taxi data for all CSV files in the year 2020?

### Answer
```sql
SELECT COUNT(*) 
FROM `your_project_id.databse_name.yellow_tripdata` 
WHERE EXTRACT(YEAR FROM tpep_pickup_datetime) = 2020
AND EXTRACT(YEAR FROM tpep_dropoff_datetime) = 2020;
```
- 24,648,473

## Question 4

How many rows are there for the `Green` Taxi data for all CSV files in the year 2020?

### Answer

```sql
SELECT COUNT(*) 
FROM `your_project_id.databse_name.green_tripdata` 
WHERE EXTRACT(YEAR FROM tpep_pickup_datetime) = 2020
AND EXTRACT(YEAR FROM tpep_dropoff_datetime) = 2020;
```
- 1,734,026

## Question 5

How many rows are there for the `Yellow` Taxi data for the March 2021 CSV file?

### Answer

```sql
SELECT COUNT(1) 
FROM `your_project_id.database_name.yellow_tripdata_2021_03`;
```
- 1,925,152

## Question 6

How would you configure the timezone to New York in a Schedule trigger?

> Within the Kestra flow, where trigger and *type: io.kestra.plugin.core.trigger.Schedule* is declared
> 
> Include a **timezone** property
> 
> Automatically sets to *UTC*, so can use *UTC +-*
> 
> Or can specify location

### Answer

- Add a `timezone` property set to `America/New_York` in the `Schedule` trigger configuration
- Add a `timezone` property set to `UTC-5` in the `Schedule` trigger configuration

[*LINK TO HOMEWORK*](https://github.com/DataTalksClub/data-engineering-zoomcamp/edit/main/cohorts/2025/02-workflow-orchestration/homework.md 
)

