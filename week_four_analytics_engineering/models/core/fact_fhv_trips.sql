{{ config(materialized="table") }}

with
    fhv_data as (select * from {{ ref("stg_fhv_tripdata") }}),

    dim_zones as (select * from {{ ref("dim_zones") }} where borough != 'Unknown')
select
    fhv_data.tripid,
    fhv_data.vendorid,
    fhv_data.pickup_locationid,
    pickup_zone.borough as pickup_borough,
    pickup_zone.zone as pickup_zone,
    fhv_data.dropoff_locationid,
    dropoff_zone.borough as dropoff_borough,
    dropoff_zone.zone as dropoff_zone,
    fhv_data.pickup_datetime,
    extract(month from fhv_data.pickup_datetime) as pickup_month,
    extract(year from fhv_data.pickup_datetime) as pickup_year,
    fhv_data.dropoff_datetime,
    fhv_data.sr_flag
from fhv_data
inner join
    dim_zones as pickup_zone on fhv_data.pickup_locationid = pickup_zone.locationid
inner join
    dim_zones as dropoff_zone on fhv_data.dropoff_locationid = dropoff_zone.locationid
