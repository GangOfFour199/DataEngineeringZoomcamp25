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
