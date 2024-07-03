--checking the data and how they connect
select * from city c 

select * from customer c 

select * from driver d 

select * from shipment s 

select * from truck

--Providing the column names to chat gpt for faster results
SELECT column_name
FROM information_schema.columns
WHERE table_name = 'city' AND table_schema = 'public';

SELECT column_name
FROM information_schema.columns
WHERE table_name = 'customer' AND table_schema = 'public';

SELECT column_name
FROM information_schema.columns
WHERE table_name = 'driver' AND table_schema = 'public';

SELECT column_name
FROM information_schema.columns
WHERE table_name = 'shipment' AND table_schema = 'public';

SELECT column_name
FROM information_schema.columns
WHERE table_name = 'truck' AND table_schema = 'public';

--We select the distinct years to explore the data for potential trend analysis
--We tranformed the date column as date cause the type wasnt correct
SELECT DISTINCT EXTRACT(YEAR FROM CAST(ship_date AS DATE)) AS shipment_year
FROM shipment
ORDER BY shipment_year;

-- Check for Missing Values from shipment table
SELECT
  COUNT(*) - COUNT(ship_id) AS missing_ship_id,
  COUNT(*) - COUNT(cust_id) AS missing_cust_id,
  COUNT(*) - COUNT(weight) AS missing_weight,
  COUNT(*) - COUNT(truck_id) AS missing_truck_id,
  COUNT(*) - COUNT(driver_id) AS missing_driver_id,
  COUNT(*) - COUNT(city_id) AS missing_city_id,
  COUNT(*) - COUNT(ship_date) AS missing_ship_date
FROM shipment;


-- Check for Missing Values from city table
SELECT
  COUNT(*) - COUNT(city_id) AS missing_city_id,
  COUNT(*) - COUNT(city_name) AS missing_city_name,
  COUNT(*) - COUNT(state) AS missing_state,
  COUNT(*) - COUNT(population) AS missing_population,
  COUNT(*) - COUNT(area) AS missing_area
FROM city;

select * from shipment_v sv 
where cust_id = 193

select * from customer c 
where cust_id = 193


-- Check for Missing Values from customer table
SELECT
  COUNT(*) - COUNT(cust_id) AS missing_cust_id,
  COUNT(*) - COUNT(cust_name) AS missing_cust_name,
  COUNT(*) - COUNT(annual_revenue) AS missing_annual_revenue,
  COUNT(*) - COUNT(cust_type) AS missing_cust_type,
  COUNT(*) - COUNT(address) AS missing_address,
  COUNT(*) - COUNT(city) AS missing_city,
  COUNT(*) - COUNT(state) AS missing_state,
  COUNT(*) - COUNT(zip) AS missing_zip,
  COUNT(*) - COUNT(phone) AS missing_phone
FROM customer;


-- Check for Missing Values from driver table
SELECT
  COUNT(*) - COUNT(driver_id) AS missing_driver_id,
  COUNT(*) - COUNT(first_name) AS missing_first_name,
  COUNT(*) - COUNT(last_name) AS missing_last_name,
  COUNT(*) - COUNT(address) AS missing_address,
  COUNT(*) - COUNT(city) AS missing_city,
  COUNT(*) - COUNT(state) AS missing_state,
  COUNT(*) - COUNT(zip_code) AS missing_zip_code,
  COUNT(*) - COUNT(phone) AS missing_phone
FROM driver;

-- Check for Missing Values from truck table
SELECT
  COUNT(*) - COUNT(truck_id) AS missing_truck_id,
  COUNT(*) - COUNT(make) AS missing_make,
  COUNT(*) - COUNT(model_year) AS missing_model_year
FROM truck;

--Cheking for duplicates

--For city table:
SELECT city_id, COUNT(*)
FROM city
GROUP BY city_id
HAVING COUNT(*) > 1;

--For customer table:
SELECT cust_id, COUNT(*)
FROM customer
GROUP BY cust_id
HAVING COUNT(*) > 1;

--For driver table:
SELECT driver_id, COUNT(*)
FROM driver
GROUP BY driver_id
HAVING COUNT(*) > 1;

--For shipment table:
SELECT ship_id, COUNT(*)
FROM shipment
GROUP BY ship_id
HAVING COUNT(*) > 1;

--For truck table:
SELECT truck_id, COUNT(*)
FROM truck
GROUP BY truck_id
HAVING COUNT(*) > 1;

--After checking the database's schema we validate data types
--Converting ship_date to Date Data Type:

--Created a view so not to mess with the raw data of the database
CREATE VIEW shipment_v AS
SELECT
    ship_id,
    cust_id,
    weight,
    truck_id,
    driver_id,
    city_id,
    TO_DATE(ship_date, 'YYYY-MM-DD') AS ship_date
FROM shipment;

select * from driver

--Checking for Outliers:
--In Weight
SELECT *
FROM shipment_v
WHERE weight > (SELECT AVG(weight) + 3 * STDDEV(weight) FROM shipment_v)
   OR weight < (SELECT AVG(weight) - 3 * STDDEV(weight) FROM shipment_v);
  
--In customer's annual_revenue
 SELECT *
FROM customer
WHERE annual_revenue > (SELECT AVG(annual_revenue) + 3 * STDDEV(annual_revenue) FROM customer)
   OR annual_revenue < (SELECT AVG(annual_revenue) - 3 * STDDEV(annual_revenue) FROM customer);
--In the population of a city
SELECT *
FROM city
WHERE population > (SELECT AVG(population) + 3 * STDDEV(population) FROM city)
   OR population < (SELECT AVG(population) - 3 * STDDEV(population) FROM city);
  
--In the model_year of the trucks  
SELECT *
FROM truck
WHERE model_year < (SELECT AVG(model_year) - 3 * STDDEV(model_year) FROM truck)
   OR model_year > (SELECT AVG(model_year) + 3 * STDDEV(model_year) FROM truck);
  
select * from truck t 
  
select ship_date from shipment_v
order by ship_date
limit 1

select ship_date from shipment_v
order by ship_date desc
limit 1

--We find the number of shipments per year and create a view
create view nb_ship_py as
SELECT
    EXTRACT(YEAR FROM ship_date) AS shipment_year,
    COUNT(*) AS num_shipments
FROM shipment_v
WHERE EXTRACT(YEAR FROM ship_date) IN (2016, 2017)
GROUP BY EXTRACT(YEAR FROM ship_date)
ORDER BY shipment_year;

select * from nb_ship_py

--We find the avg_weight_per_month
SELECT
    TO_CHAR(ship_date, 'MM-YYYY') AS month,
    ROUND(AVG(weight)::numeric, 0) AS avg_weight_per_month
FROM shipment_v
GROUP BY TO_CHAR(ship_date, 'MM-YYYY')
ORDER BY month;

--avg_weight_per_year
create view avg_weight_py as
SELECT
    EXTRACT(YEAR FROM ship_date) AS year,
    ROUND(AVG(weight)::numeric, 0) AS avg_weight_per_year
FROM shipment_v
GROUP BY EXTRACT(YEAR FROM ship_date)
ORDER BY year;

--Total revenue per year
create view totar_rev_py as
SELECT
    EXTRACT(YEAR FROM sv.ship_date) AS year,
    SUM(c.annual_revenue) AS total_annual_revenue
FROM
    shipment_v sv
JOIN
    customer c ON sv.cust_id = c.cust_id
GROUP BY EXTRACT(YEAR FROM sv.ship_date)
ORDER BY year;

select * from totar_rev_py

--Total monthly revenue per year (But it's wrong)
SELECT
    EXTRACT(YEAR FROM sv.ship_date) AS year,
    EXTRACT(MONTH FROM sv.ship_date) AS month,
    SUM(c.annual_revenue) AS total_monthly_revenue
FROM
    shipment_v sv
JOIN
    customer c ON sv.cust_id = c.cust_id
GROUP BY 
    EXTRACT(YEAR FROM sv.ship_date), 
    EXTRACT(MONTH FROM sv.ship_date)
ORDER BY 
    year, 
    month;
   



--Finding the use of truck models
SELECT
    truck_model,
    COUNT(*) AS shipment_count
FROM
    (
        SELECT
            s.ship_id,
            t.model_year || ' ' || t.make AS truck_model
        FROM
            shipment_v s
            JOIN truck t ON s.truck_id = t.truck_id
    ) AS shipment_trucks
GROUP BY
    truck_model
ORDER BY
    shipment_count desc
    
    
--Number of shipments per Driver
    create view num_ship_per_driver as
SELECT
    s.driver_id,
    d.first_name || ' ' || d.last_name AS driver_name,
    COUNT(*) AS num_shipments
FROM
    shipment_v s
    INNER JOIN driver d ON s.driver_id = d.driver_id
GROUP BY
    s.driver_id, driver_name
ORDER BY
    num_shipments desc
    
--The busiest cities in terms of shipments
SELECT
    c.city_id,
    c.city_name,
    COUNT(*) AS num_shipments
FROM
    shipment_v s
    INNER JOIN city c ON s.city_id = c.city_id
GROUP BY
    c.city_id, c.city_name
ORDER BY
    num_shipments DESC;
    
-- We now analyze how shipment volume varies across different state
   create view state_num_ship as
   SELECT
    c.state,
    COUNT(*) AS num_shipments
FROM
    shipment_v s
    INNER JOIN city c ON s.city_id = c.city_id
GROUP BY
    c.state
ORDER BY
    num_shipments DESC;
    
--We could use python to find the correlation between population and num_shipments if we exported the following
   SELECT
    c.city_name,
    c.population,
    COUNT(*) AS num_shipments
FROM
    shipment_v s
    INNER JOIN city c ON s.city_id = c.city_id
GROUP BY
    c.city_name, c.population
ORDER BY
    c.population DESC;
   
--Finding the annual revenue per city and state
   create view annual_rev_per_cs as
SELECT
    ci.city_id,
    ci.city_name,
    ci.state,
    SUM(c.annual_revenue) AS total_annual_revenue
FROM
    shipment_v s
    INNER JOIN customer c ON s.cust_id = c.cust_id
    INNER JOIN city ci ON s.city_id = ci.city_id
GROUP BY
    ci.city_id, ci.city_name, ci.state
ORDER BY
    total_annual_revenue DESC;
    
--Finding the best customers
   create view best_customers as
   SELECT
    cust_id,
    cust_name,
    annual_revenue
FROM
    customer
ORDER BY
    annual_revenue DESC
limit 15;

--Finding the worst customers
create view worst_cust as
 SELECT
    cust_id,
    cust_name,
    annual_revenue
FROM
    customer
ORDER BY
    annual_revenue 
limit 15

drop view combined_customers 

--Combined best and worst customers
SELECT
    'Best' AS category,
    cust_id,
    cust_name,
    annual_revenue
FROM
    best_customers
UNION ALL
SELECT
    'Worst' AS category,
    cust_id,
    cust_name,
    annual_revenue
FROM
    worst_cust;

--Finding the number of customers per customer type
SELECT
    cust_type,
    COUNT(*) AS num_customers
FROM
    customer
GROUP BY
    cust_type;
    
   
--How annual revenue varies across different customer types
   create view rev_per_cust_type as
SELECT
    cust_type,
    SUM(annual_revenue) AS total_annual_revenue
FROM
    customer
GROUP BY
    cust_type
ORDER BY
    total_annual_revenue DESC;
    
--Average Shipment Size per customer type
SELECT
    c.cust_type,
    ROUND(AVG(s.weight)) AS avg_shipment_size
FROM
    shipment_v s
    INNER JOIN customer c ON s.cust_id = c.cust_id
GROUP BY
    c.cust_type;