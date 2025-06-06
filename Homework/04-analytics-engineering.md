# SETUP + QUIZ QUESTIONS

For this homework, you will need the following datasets:
* [Green Taxi dataset (2019 and 2020)](https://github.com/DataTalksClub/nyc-tlc-data/releases/tag/green)
* [Yellow Taxi dataset (2019 and 2020)](https://github.com/DataTalksClub/nyc-tlc-data/releases/tag/yellow)
* [For Hire Vehicle dataset (2019)](https://github.com/DataTalksClub/nyc-tlc-data/releases/tag/fhv)

### Before you start

1. Make sure you, **at least**, have them in GCS with a External Table **OR** a Native Table - use whichever method you prefer to accomplish that (Workflow Orchestration with [pandas-gbq](https://cloud.google.com/bigquery/docs/samples/bigquery-pandas-gbq-to-gbq-simple), [dlt for gcs](https://dlthub.com/docs/dlt-ecosystem/destinations/filesystem), [dlt for BigQuery](https://dlthub.com/docs/dlt-ecosystem/destinations/bigquery), [gsutil](https://cloud.google.com/storage/docs/gsutil), etc)
2. You should have exactly `7,778,101` records in your Green Taxi table
3. You should have exactly `109,047,518` records in your Yellow Taxi table
4. You should have exactly `43,244,696` records in your FHV table
5. Build the staging models for green/yellow as shown in [here](../../../04-analytics-engineering/taxi_rides_ny/models/staging/)
6. Build the dimension/fact for taxi_trips joining with `dim_zones`  as shown in [here](../../../04-analytics-engineering/taxi_rides_ny/models/core/fact_trips.sql)

**Note**: If you don't have access to GCP, you can spin up a local Postgres instance and ingest the datasets above


### Question 1: Understanding dbt model resolution

Provided you've got the following sources.yaml
```yaml
version: 2

sources:
  - name: raw_nyc_tripdata
    database: "{{ env_var('DBT_BIGQUERY_PROJECT', 'dtc_zoomcamp_2025') }}"
    schema:   "{{ env_var('DBT_BIGQUERY_SOURCE_DATASET', 'raw_nyc_tripdata') }}"
    tables:
      - name: ext_green_taxi
      - name: ext_yellow_taxi
```

with the following env variables setup where `dbt` runs:
```shell
export DBT_BIGQUERY_PROJECT=myproject
export DBT_BIGQUERY_DATASET=my_nyc_tripdata
```

What does this .sql model compile to?
```sql
select * 
from {{ source('raw_nyc_tripdata', 'ext_green_taxi' ) }}
```

### Answer

> Use the values of the the env variables exported

- `select * from myproject.my_nyc_tripdata.ext_green_taxi`

### Question 2: dbt Variables & Dynamic Models

Say you have to modify the following dbt_model (`fct_recent_taxi_trips.sql`) to enable Analytics Engineers to dynamically control the date range. 

- In development, you want to process only **the last 7 days of trips**
- In production, you need to process **the last 30 days** for analytics

```sql
select *
from {{ ref('fact_taxi_trips') }}
where pickup_datetime >= CURRENT_DATE - INTERVAL '30' DAY
```

What would you change to accomplish that in a such way that command line arguments takes precedence over ENV_VARs, which takes precedence over DEFAULT value?

### Answer

> declare a var("var_name") that overrides env_var(""), within the syntax provide n days and after parentheses specify value TYPE

- Update the WHERE clause to `pickup_datetime >= CURRENT_DATE - INTERVAL '{{ var("days_back", env_var("DAYS_BACK", "30")) }}' DAY`


### Question 3: dbt Data Lineage and Execution

Considering the data lineage below **and** that taxi_zone_lookup is the **only** materialization build (from a .csv seed file):

*Refer to (data-engineering-zoomcamp/cohorts/2025/04-analytics-engineering/homework_q2.png)*

Select the option that does **NOT** apply for materializing `fct_taxi_monthly_zone_revenue`:

### Answer

> fct_taxi_monthly_zone_revenue materialises from core path, therefore working through models/staging branches upstream means you do not trace lienage through core

- `dbt run --select models/staging/+`


### Question 4: dbt Macros and Jinja

Consider you're dealing with sensitive data (e.g.: [PII](https://en.wikipedia.org/wiki/Personal_data)), that is **only available to your team and very selected few individuals**, in the `raw layer` of your DWH (e.g: a specific BigQuery dataset or PostgreSQL schema), 

 - Among other things, you decide to obfuscate/masquerade that data through your staging models, and make it available in a different schema (a `staging layer`) for other Data/Analytics Engineers to explore

- And **optionally**, yet  another layer (`service layer`), where you'll build your dimension (`dim_`) and fact (`fct_`) tables (assuming the [Star Schema dimensional modeling](https://www.databricks.com/glossary/star-schema)) for Dashboarding and for Tech Product Owners/Managers

You decide to make a macro to wrap a logic around it:

```sql
{% macro resolve_schema_for(model_type) -%}

    {%- set target_env_var = 'DBT_BIGQUERY_TARGET_DATASET'  -%}
    {%- set stging_env_var = 'DBT_BIGQUERY_STAGING_DATASET' -%}

    {%- if model_type == 'core' -%} {{- env_var(target_env_var) -}}
    {%- else -%}                    {{- env_var(stging_env_var, env_var(target_env_var)) -}}
    {%- endif -%}

{%- endmacro %}
```

And use on your staging, dim_ and fact_ models as:
```sql
{{ config(
    schema=resolve_schema_for('core'), 
) }}
```

That all being said, regarding macro above, **select all statements that are true to the models using it**:

### Answer

> All the following statements below are true

- Setting a value for  `DBT_BIGQUERY_TARGET_DATASET` env var is mandatory, or it'll fail to compile
- Setting a value for `DBT_BIGQUERY_STAGING_DATASET` env var is mandatory, or it'll fail to compile
- When using `core`, it materializes in the dataset defined in `DBT_BIGQUERY_TARGET_DATASET`
- When using `stg`, it materializes in the dataset defined in `DBT_BIGQUERY_STAGING_DATASET`, or defaults to `DBT_BIGQUERY_TARGET_DATASET`
- When using `staging`, it materializes in the dataset defined in `DBT_BIGQUERY_STAGING_DATASET`, or defaults to `DBT_BIGQUERY_TARGET_DATASET`


## Serious SQL

Alright, in module 1, you had a SQL refresher, so now let's build on top of that with some serious SQL.

These are not meant to be easy - but they'll boost your SQL and Analytics skills to the next level.  
So, without any further do, let's get started...

You might want to add some new dimensions `year` (e.g.: 2019, 2020), `quarter` (1, 2, 3, 4), `year_quarter` (e.g.: `2019/Q1`, `2019-Q2`), and `month` (e.g.: 1, 2, ..., 12), **extracted from pickup_datetime**, to your `fct_taxi_trips` OR `dim_taxi_trips.sql` models to facilitate filtering your queries


### Question 5: Taxi Quarterly Revenue Growth

1. Create a new model `fct_taxi_trips_quarterly_revenue.sql`
2. Compute the Quarterly Revenues for each year for based on `total_amount`
3. Compute the Quarterly YoY (Year-over-Year) revenue growth 
  * e.g.: In 2020/Q1, Green Taxi had -12.34% revenue growth compared to 2019/Q1
  * e.g.: In 2020/Q4, Yellow Taxi had +34.56% revenue growth compared to 2019/Q4

***Important Note: The Year-over-Year (YoY) growth percentages provided in the examples are purely illustrative. You will not be able to reproduce these exact values using the datasets provided for this homework.***

Considering the YoY Growth in 2020, which were the yearly quarters with the best (or less worse) and worst results for green, and yellow

```sql
{{ config(materialized="table") }}

with
    trips_data as (select * from {{ ref("fact_trips") }}),
    quarterly_revenues as (
        select
            -- Revenue grouping 
            pickup_quarter as revenue_quarter,
            pickup_year as revenue_year,
            service_type,

            -- Revenue calculation 
            sum(total_amount) as total_quarter_revenue

        from trips_data
        where pickup_year between 2019 and 2020
        group by 1, 2, 3
    ),
    quarterly_yoy_growth as (
        select
            *,

            -- Quarterly YoY growth
            lag(total_quarter_revenue, 2) over (
                partition by revenue_quarter order by revenue_year, service_type
            ) as last_year_total_quarter_revenue,
            100 * (
                total_quarter_revenue / nullif(
                    lag(total_quarter_revenue, 2) over (
                        partition by revenue_quarter order by revenue_year, service_type
                    ),
                    0
                )
                - 1
            ) as quarterly_yoy_growth

        from quarterly_revenues
    )
select *
from quarterly_yoy_growth
order by revenue_quarter, revenue_year, service_type
```

### Answer

- green: {best: 2020/Q1, worst: 2020/Q2}, yellow: {best: 2020/Q1, worst: 2020/Q2}

### Question 6: P97/P95/P90 Taxi Monthly Fare

1. Create a new model `fct_taxi_trips_monthly_fare_p95.sql`
2. Filter out invalid entries (`fare_amount > 0`, `trip_distance > 0`, and `payment_type_description in ('Cash', 'Credit card')`)
3. Compute the **continous percentile** of `fare_amount` partitioning by service_type, year and and month

Now, what are the values of `p97`, `p95`, `p90` for Green Taxi and Yellow Taxi, in April 2020?

### Answer

```sql
{{ config(materialized="table") }}

with
    valid_trips as (
        select *
        from {{ ref("fact_trips") }}
        where
            fare_amount > 0
            and pickup_year in (2019, 2020)
            and trip_distance > 0
            and payment_type_description in ('Cash', 'Credit Card')
    ),
    continuous_percentiles as (
        select
            pickup_month,
            pickup_year,
            service_type,
            fare_amount,
            percentile_cont(fare_amount, 0.9) over (
                partition by pickup_month, pickup_year, service_type
            ) as p90,
            percentile_cont(fare_amount, 0.95) over (
                partition by pickup_month, pickup_year, service_type
            ) as p95,
            percentile_cont(fare_amount, 0.97) over (
                partition by pickup_month, pickup_year, service_type
            ) as p97
        from valid_trips
    )
select distinct (pickup_month), pickup_year, service_type, p90, p95, p97
from continuous_percentiles
order by pickup_month, pickup_year, service_type
```

- green: {p97: 28.0, p95: 23.0, p90: 18.0}, yellow: {p97: 32.0, p95: 26.0, p90: 19.5}

### Question 7: Top #Nth longest P90 travel time Location for FHV

Prerequisites:
* Create a staging model for FHV Data (2019), and **DO NOT** add a deduplication step, just filter out the entries where `where dispatching_base_num is not null`
* Create a core model for FHV Data (`dim_fhv_trips.sql`) joining with `dim_zones`. Similar to what has been done [here](../../../04-analytics-engineering/taxi_rides_ny/models/core/fact_trips.sql)
* Add some new dimensions `year` (e.g.: 2019) and `month` (e.g.: 1, 2, ..., 12), based on `pickup_datetime`, to the core model to facilitate filtering for your queries

Now...
1. Create a new model `fct_fhv_monthly_zone_traveltime_p90.sql`
2. For each record in `dim_fhv_trips.sql`, compute the [timestamp_diff](https://cloud.google.com/bigquery/docs/reference/standard-sql/timestamp_functions#timestamp_diff) in seconds between dropoff_datetime and pickup_datetime - we'll call it `trip_duration` for this exercise
3. Compute the **continous** `p90` of `trip_duration` partitioning by year, month, pickup_location_id, and dropoff_location_id

For the Trips that **respectively** started from `Newark Airport`, `SoHo`, and `Yorkville East`, in November 2019, what are **dropoff_zones** with the 2nd longest p90 trip_duration ?

### Answer

```sql
{{ config(materialized="table") }}

with
    trip_duration_calculated as (

        select
            pickup_locationid,
            pickup_zone,
            pickup_month,
            pickup_year,
            pickup_datetime,
            dropoff_datetime,
            dropoff_locationid,
            dropoff_zone,
            timestamp_diff(dropoff_datetime, pickup_datetime, second) as trip_duration

        from {{ ref("fact_fhv_trips") }}
        where
            pickup_zone in ('SoHo', 'Newark Airport', 'Yorkville East')
            and pickup_month = 11
            and pickup_year = 2019
    ),
    trip_duration_percentile as (

        select
            pickup_locationid,
            pickup_zone,
            pickup_month,
            pickup_year,
            dropoff_locationid,
            dropoff_zone,
            trip_duration,
            percentile_cont(trip_duration, 0.90) over (
                partition by
                    pickup_locationid, pickup_month, pickup_year, dropoff_locationid
            ) as trip_duration_p90

        from trip_duration_calculated
    ),
    trip_duration_ranking as (
        select
            pickup_locationid,
            pickup_zone,
            pickup_month,
            pickup_year,
            dropoff_locationid,
            dropoff_zone,
            trip_duration,
            trip_duration_p90,
            dense_rank() over (order by trip_duration_p90 desc) as p90_rank
        from trip_duration_percentile
    )
select *
from trip_duration_ranking
order by p90_rank

```

- LaGuardia Airport, Chinatown, Garment District


## Solution

Solution: 
