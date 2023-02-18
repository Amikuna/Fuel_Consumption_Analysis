USE db

SELECT * FROM fuel_Consumption_2000_2022

--Normalize data
UPDATE fuel_Consumption_2000_2022
SET MAKE = UPPER(MAKE), VEHICLE_ClASS = UPPER(VEHICLE_CLASS)

UPDATE fuel_Consumption_2000_2022
SET VEHICLE_CLASS = CASE SUBSTRING(VEHICLE_CLASS,1,3) WHEN 'SUV' THEN 'SUV'
WHEN 'VAN' THEN 'VAN'
ELSE VEHICLE_CLASS
END

UPDATE fuel_Consumption_2000_2022
SET VEHICLE_CLASS = CASE SUBSTRING(VEHICLE_CLASS,1,13) WHEN 'STATION WAGON' THEN 'STATION WAGON'
ELSE VEHICLE_CLASS
END

UPDATE fuel_Consumption_2000_2022
SET VEHICLE_CLASS = CASE SUBSTRING(VEHICLE_CLASS,1,12) WHEN 'PICKUP TRUCK' THEN 'PICKUP TRUCK'
ELSE VEHICLE_CLASS
END

--the most used fuel
SELECT FUEL, COUNT(FUEL) AS AMOUNT FROM fuel_Consumption_2000_2022
GROUP BY FUEL ORDER BY COUNT(FUEL)

UPDATE fuel_Consumption_2000_2022
SET FUEL = CASE FUEL WHEN 'X' THEN 'REGULAR'
WHEN 'Z' THEN 'PREMIUM'
WHEN 'D' THEN 'DIESEL'
WHEN 'E' THEN 'ETHANOL'
WHEN 'N' THEN 'NATURAL GAS'
END

SELECT FUEL FROM fuel_Consumption_2000_2022


--The most popular fuel by year

--calculate quantity of the each fuel appared in the table and save it in a temp table
WITH popular_fuel AS(
SELECT YEAR, FUEL, COUNT(FUEL) AS AMOUNT_OF_CARS FROM fuel_Consumption_2000_2022
GROUP BY YEAR, FUEL
)
SELECT * 
INTO #qt_cars_by_fuel
FROM popular_fuel

--calculate which fuel was used more per year and insert year and fuel quantity in a temp table
WITH pop_fuel AS(
SELECT YEAR, MAX(AMOUNT_OF_CARS) AS MAX_AMOUNT FROM #qt_cars_by_fuel
GROUP BY YEAR
)
SELECT YEAR, MAX_AMOUNT
INTO #MAX_PER_YEAR
FROM pop_fuel

-- add a columnt to a table where we will save fuel name
ALTER TABLE #MAX_PER_YEAR
ADD POPULAR_FUEL VARCHAR(50)

--update table with fuel name which quantity is same as max quantity of the year
UPDATE #MAX_PER_YEAR
SET POPULAR_FUEL = FUEL
FROM #qt_cars_by_fuel
WHERE #MAX_PER_YEAR.MAX_AMOUNT = #qt_cars_by_fuel.AMOUNT_OF_CARS


SELECT * FROM #MAX_PER_YEAR
ORDER BY YEAR

--car brands by combined fuel efficiency

SELECT YEAR, MAKE, ROUND(AVG(COMB),2) AS AVERAGE_CONSUMPTION FROM fuel_Consumption_2000_2022
GROUP BY YEAR,MAKE
ORDER BY AVG(COMB)


SELECT VEHICLE_CLASS, ROUND(AVG(FUEL_CONSUMPTION),2) AS AVG_CONSUMPTION FROM fuel_Consumption_2000_2022
GROUP BY VEHICLE_CLASS
