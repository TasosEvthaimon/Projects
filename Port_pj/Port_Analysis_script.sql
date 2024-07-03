--checking the data
select * from port_data pd 
limit 10

--Rename Column1
alter table port_data 
rename column "Column1" to "Port_Id"

--Creating a new table so as not to mess with the raw data
create table port_dt as
 (select * from port_data pd)
 
 --Drop a column that is not going to be used in the analysis
alter table port_dt 
 drop column "Also known as"

 --Replace " " with "_" in the column titles
 ALTER TABLE public.port_dt
RENAME COLUMN "Port Name" TO "Port_Name";

ALTER TABLE public.port_dt
RENAME COLUMN "Type" TO "Type_port";

ALTER TABLE public.port_dt
RENAME COLUMN "UN Code" TO "UN_Code";

ALTER TABLE public.port_dt
RENAME COLUMN "Vessels in Port" TO "Vessels_in_Port";

ALTER TABLE public.port_dt
RENAME COLUMN "Expected Arrivals" TO "Expected_Arrivals";

ALTER TABLE public.port_dt
RENAME COLUMN "Area Local" TO "Area_Local";

ALTER TABLE public.port_dt
RENAME COLUMN "Area Global" TO "Area_Global";

--Searching for duplicates
SELECT "Port_Id", "Country", "Port_Name", COUNT(*)
FROM public.port_dt
GROUP BY "Port_Id", "Country", "Port_Name"
HAVING COUNT(*) > 1;

select * from port_dt pd 

--Creating some performance metrics

--Created a view with the percentage_difference of Arrivals and Expected_Arrivals to find the least efficient ports

CREATE or REPLACE VIEW efficienty AS
SELECT 
    "Port_Id",
    "Port_Name",
    "Expected_Arrivals",
    "Arrivals(Last 24 Hours)" AS actual_arrivals,
    CASE
        WHEN "Expected_Arrivals" = 0 THEN NULL
        ELSE (("Arrivals(Last 24 Hours)" - "Expected_Arrivals")::float / "Expected_Arrivals") * 100
    END AS percentage_difference
FROM public.port_dt;




--Finding the least efficient ports

--Expected More (TOP 10)
select * from efficienty e 
order by percentage_difference 
limit 10

--Expected less (Top 10)
select * from efficienty e 
where "percentage_difference" is not null 
order by percentage_difference desc 
limit 10

--Not expected arrivals(Top 10)
select * from efficienty
where "percentage_difference" is null 
order by actual_arrivals desc
limit 10

--Finding the most efficient ports(Top 10)
create view Most_Ef_Ports as
SELECT 
    "Port_Id",
    "Port_Name",
    "Expected_Arrivals",
    "actual_arrivals",
    percentage_difference
FROM efficienty e 
WHERE percentage_difference IS NOT NULL
ORDER BY ABS(percentage_difference) ASC
LIMIT 10;

--And for those with no expected arrivals(Top 10)
SELECT 
    "Port_Id",
    "Port_Name",
    "Expected_Arrivals",
    "actual_arrivals",
    percentage_difference
FROM efficienty e 
WHERE percentage_difference IS  NULL
ORDER BY ABS(actual_arrivals) ASC
LIMIT 10;

--Geospatial Analysis, number of ports per country
create or replace view Ports_per_country as
SELECT
    "Country",
    COUNT("Port_Id") AS port_count1
FROM port_dt pd 
GROUP BY "Country" 
ORDER BY port_count1 DESC;


select count("Port_Id") from port_dt pd 
where "Country" = 'China' 

select count("Port_Id") from port_dt pd 

select * from port_dt pd 

--Ports per Area_Locale
SELECT 
    "Area_Local",
    COUNT(*) AS port_count2
FROM port_dt pd 
GROUP BY "Area_Local"
order by port_count2 desc ;

--Port count per Area Global
SELECT 
    "Area_Global",
    COUNT(*) AS port_count3
FROM port_dt pd 
GROUP BY "Area_Global"
order by port_count3 desc ;

select * from port_dt pd 

--Count of ports by Country and Area_Local
create view count_per_CAL as
SELECT 
    "Country",
    "Area_Local",
    COUNT(*) AS port_count4
FROM port_dt pd 
GROUP BY "Country", "Area_Local"
order by "port_count4" desc;

--Average vessels in port by Country and Area_Global
create view avg_vessels_CAG as
SELECT 
    "Country",
    "Area_Global",
    AVG("Vessels_in_Port") AS avg_vessels_in_port
FROM port_dt pd 
GROUP BY "Country", "Area_Global"
order by "avg_vessels_in_port" desc;


--Creating a view with the column names
CREATE VIEW port_data_columns AS
SELECT column_name
FROM information_schema.columns
WHERE table_schema = 'public'  
  AND table_name = 'port_dt'
ORDER BY ordinal_position;



--Analyze the distribution of port types (Type_port) and count the occurrences of each type
create view Port_types_count as
SELECT 
    "Type_port",
    COUNT(*) AS port_count5
FROM port_dt pd 
GROUP BY "Type_port";


--Create another view to compare the most efficient ports
create or replace view optimal_selection as
select  pd."Port_Name", pd."Vessels_in_Port" , mep."percentage_difference" from port_dt pd inner join most_ef_ports mep 
on pd."Port_Name" = mep."Port_Name" 
order by "Vessels_in_Port" desc

select * from optimal_selection
    


