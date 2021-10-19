-- VIEW for Forestation

CREATE VIEW forestation
AS
SELECT f.country_code AS forest_country_code,
f.country_name AS forest_country_name,
f.year AS forest_area_year,
f.forest_area_sqkm,
l.country_code AS land_country_code,
l.country_name AS land_country_name,
l.year AS land_area_year,
(l.total_area_sq_mi * 2.59) AS total_area_sq_km,
((f.forest_area_sqkm/(l.total_area_sq_mi * 2.59) * 100)) AS percent_as_forest_area_sqkm,
r.country_name AS region_country_name,
r.country_code AS region_country_code,
r.region,
r.income_group
FROM forest_area f
JOIN land_area l
  ON f.year = l.year AND f.country_code = l.country_code
JOIN regions r
  ON r.country_code = l.country_code
;


-- GLOBAL SITUATION

--What was the total forest area (in sq km) of the world in 1990?
--Please keep in mind that you can use the country record denoted as “World" in the region table.

SELECT *
FROM forest_area
WHERE year = '1990' AND country_name = 'World'

--What was the total forest area (in sq km) of the world in 2016?
--Please keep in mind that you can use the country record in the table is denoted as “World.”

SELECT *
FROM forest_area
WHERE year = '2016' AND country_name = 'World'

--c. What was the change (in sq km) in the forest area of the world from 1990 to 2016?
--d. What was the percent change in forest area of the world between 1990 and 2016?

SELECT forest_area_sqkm
FROM forest_area
WHERE year = '1990' AND country_code = 'WLD';

SELECT forest_area_sqkm
FROM forest_area
WHERE year = '2016' AND country_code = 'WLD';

SELECT
  (SELECT forest_area_sqkm FROM forestation WHERE forest_area_year = '1990' AND forest_country_code = 'WLD')
- (SELECT forest_area_sqkm FROM forestation WHERE forest_area_year = '2016' AND forest_country_code = 'WLD') AS total_forest_area_decrease;
-- the answer is 1,324,449



SELECT
  (SELECT forest_area_sqkm FROM forestation WHERE forest_area_year = '1990' AND forest_country_code = 'WLD')
- (SELECT forest_area_sqkm FROM forestation WHERE forest_area_year = '2016' AND forest_country_code = 'WLD') AS difference;

SELECT
  ((SELECT forest_area_sqkm FROM forestation WHERE forest_area_year = '2016' AND forest_country_code = 'WLD')
-  (SELECT forest_area_sqkm FROM forestation WHERE forest_area_year = '1990' AND forest_country_code = 'WLD'))
    / (SELECT forest_area_sqkm FROM forestation WHERE forest_area_year = '1990' AND forest_country_code = 'WLD') * 100 AS percent_change;


--e. If you compare the amount of forest area lost between 1990 and 2016,
--to which country's total area in 2016 is it closest to?
SELECT forest_country_name, total_area_sq_km, ABS(total_area_sq_km - 1324449) absolute_difference
FROM forestation
WHERE forest_area_year = '2016'
ORDER BY 3
LIMIT 1
-- the answer is Peru
