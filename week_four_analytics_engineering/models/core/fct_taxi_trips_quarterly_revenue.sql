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
