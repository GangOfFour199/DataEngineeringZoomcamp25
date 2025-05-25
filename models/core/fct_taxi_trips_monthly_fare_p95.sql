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
