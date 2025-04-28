## Question 1. Understanding docker first run 

Run docker with the `python:3.12.8` image in an interactive mode, use the entrypoint `bash`.
What's the version of `pip` in the image?

### Answer 
- 24.3.1

## Question 2. Understanding Docker networking and docker-compose

### Answers

- postgres:5432
- db:5432

## Question 3. Trip Segmentation Count

During the period of October 1st 2019 (inclusive) and November 1st 2019 (exclusive), how many trips, **respectively**, happened:
1. Up to 1 mile
2. In between 1 (exclusive) and 3 miles (inclusive),
3. In between 3 (exclusive) and 7 miles (inclusive),
4. In between 7 (exclusive) and 10 miles (inclusive),
5. Over 10 miles

### Answer
```sql
select
    case
        when trip_distance <= 1 then 'Up to 1 mile'
        when trip_distance > 1 and trip_distance <= 3 then 'Between 1 and 3 miles'
        when trip_distance > 3 and trip_distance <= 7 then 'Between 3 and 7 miles'
        when trip_distance > 7 and trip_distance <= 10 then 'Between 7 and 10 miles'
        else 'Over 10 miles'
    end as journey_distance,
    to_char(count(1), '999,999') as number_trips
from
    green_taxi_trips
where
    lpep_pickup_datetime >= '2019-10-01'
    and lpep_pickup_datetime < '2019-11-01'
    and lpep_dropoff_datetime >= '2019-10-01'
    and lpep_dropoff_datetime < '2019-11-01'
group by
    1
```
```
"journey_distance"	"number_trips"
Up to 1 mile		78,964
Over 10 miles		32,294
Between 3 and 7 miles	90,020
Between 1 and 3 miles	150,850
Between 7 and 10 miles 	24,074
```

## Question 4. Longest trip for each day

Which was the pick up day with the longest trip distance?
Use the pick up time for your calculations.

Tip: For every day, we only care about one single trip with the longest distance. 

- 2019-10-11
- 2019-10-24
- 2019-10-26
- 2019-10-31

### Answer

```sql
select
    lpep_pickup_datetime::DATE AS date,
	MAX(trip_distance) AS longest_daily_journey
from
    green_taxi_trips
where
	lpep_pickup_datetime::DATE = '2019-10-31'
GROUP BY 1
ORDER BY 2 DESC;
```
```
"date"	"longest_daily_journey"
2019-10-31	515.89
```
## Question 5. Three biggest pickup zones

Which were the top pickup locations with over 13,000 in
`total_amount` (across all trips) for 2019-10-18?

Consider only `lpep_pickup_datetime` when filtering by date.

### Answer

```sql
SELECT "Zone", ROUND(SUM(gt.total_amount)::NUMERIC, 2) AS total_money
FROM green_taxi_trips gt
INNER JOIN green_taxi_zones gz
ON gt."PULocationID" = gz."LocationID"
WHERE gt.lpep_pickup_datetime::DATE = '2019-10-18'
GROUP BY 1
HAVING ROUND(SUM(gt.total_amount)::NUMERIC, 3) > 13000
LIMIT 3;
```
```
"Zone"			"total_money"
East Harlem North	18686.68
East Harlem South	16797.26
Morningside Heights	13029.79
```

## Question 6. Largest tip

For the passengers picked up in October 2019 in the zone
named "East Harlem North" which was the drop off zone that had
the largest tip?

Note: it's `tip` , not `trip`

We need the name of the zone, not the ID.

### Answer
```sql
SELECT puz."Zone" AS pickup_zone,
doz."Zone" AS dropoff_zone,
gt.tip_amount AS biggest_tip
FROM green_taxi_trips gt
INNER JOIN green_taxi_zones puz
ON gt."PULocationID" = puz."LocationID"
INNER JOIN green_taxi_zones doz
ON gt."DOLocationID"= doz."LocationID"
WHERE puz."Zone" = 'East Harlem North'
ORDER BY 3 DESC
LIMIT 1;
```
```
"pickup_zone"		"dropopff_zone"		"biggest_tip"
East Harlem North	JFK Airport		87.3
```
## Question 7. Terraform Workflow

Which of the following sequences, **respectively**, describes the workflow for: 
1. Downloading the provider plugins and setting up backend,
2. Generating proposed changes and auto-executing the plan
3. Remove all resources managed by terraform`

### Answer

- terraform init, terraform apply -auto-approve, terraform destroy
