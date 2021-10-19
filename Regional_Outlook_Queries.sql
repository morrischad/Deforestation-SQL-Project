--Create a region_sums  table as reference for future questions/queries

WITH region_sums AS (SELECT r.region,
SUM(f.forest_area_sqkm) AS sum_forest_area,
SUM(l.total_area_sq_mi*2.59) AS sum_total_area
FROM forest_area f
JOIN land_area l
  ON f.year = l.year AND f.country_code = l.country_code
JOIN regions r
  ON r.country_code = l.country_code
GROUP BY 1)






SELECT
  r.region,
  ROUND(CAST((SUM(f.forest_area_sqkm)/SUM(l.total_area_sq_mi*2.59)) * 100 AS NUMERIC), 2) AS percent_forest_area
FROM forest_area f
JOIN land_area l
  ON f.year = l.year AND f.country_code = l.country_code
JOIN regions r
  ON r.country_code = l.country_code
WHERE f.year = '2016'
GROUP BY 1
ORDER BY 2 DESC;

SELECT
  r.region,
  ROUND(CAST((SUM(f.forest_area_sqkm)/SUM(l.total_area_sq_mi*2.59)) * 100 AS NUMERIC), 2) AS percent_forest_area
FROM forest_area f
JOIN land_area l
  ON f.year = l.year AND f.country_code = l.country_code
JOIN regions r
  ON r.country_code = l.country_code
WHERE f.year = '1990'
GROUP BY 1
ORDER BY 2 DESC;


SELECT DISTINCT region, (sum_forest_area/sum_total_area) * 100 AS percent_forest_area
FROM region_sums
GROUP BY 1,2 ;


--a. What was the percent forest of the entire world in 2016?
--Which region had the HIGHEST percent forest in 2016, and which had the LOWEST, to 2 decimal places?

SELECT ROUND(CAST(((sum_forest_area/sum_total_area) * 100) AS NUMERIC), 2) percent_forest_area
FROM region_percentages r
WHERE year = '2016' AND region = 'World';

SELECT ROUND(CAST(((sum_forest_area/sum_total_area) * 100) AS NUMERIC), 2) percent_forest_area
FROM region_percentages r
WHERE year = '2016'
ORDER BY percent_forest_area DESC;

SELECT ROUND(CAST(((sum_forest_area/sum_total_area) * 100) AS NUMERIC), 2) percent_forest_area
FROM region_percentages r
WHERE year = '2016'
ORDER BY percent_forest_area;



--b. What was the percent forest of the entire world in 1990?
--Which region had the HIGHEST percent forest in 1990, and which had the LOWEST, to 2 decimal places?

SELECT ROUND(CAST(((sum_forest_area/sum_total_area) * 100) AS NUMERIC), 2) percent_forest_area
FROM region_percentages r
WHERE year = '1990' AND region = 'World';

SELECT ROUND(CAST(((sum_forest_area/sum_total_area) * 100) AS NUMERIC), 2) percent_forest_area
FROM region_percentages r
WHERE year = '1990'
ORDER BY percent_forest_area DESC;

SELECT ROUND(CAST(((sum_forest_area/sum_total_area) * 100) AS NUMERIC), 2) percent_forest_area
FROM region_percentages r
WHERE year = '1990'
ORDER BY percent_forest_area;




--c. Based on the table you created,
--which regions of the world DECREASED in forest area from 1990 to 2016?
WITH region_percentages AS (SELECT r.region,
f.year AS year,
f.country_code,
SUM(f.forest_area_sqkm) AS sum_forest_area,
SUM(l.total_area_sq_mi*2.59) AS sum_total_area
FROM forest_area f
JOIN land_area l
  ON f.year = l.year AND f.country_code = l.country_code
JOIN regions r
  ON r.country_code = l.country_code
GROUP BY 1, 2, 3),

tbl2016 AS (SELECT r.*,
ROUND(CAST(((sum_forest_area/sum_total_area) * 100) AS NUMERIC), 2) percent_forest_area
FROM region_percentages r
WHERE year = '2016'),

tbl1990 AS (SELECT r.*,
ROUND(CAST(((sum_forest_area/sum_total_area) * 100) AS NUMERIC), 2) percent_forest_area
FROM region_percentages r
WHERE year = '1990')

SELECT DISTINCT t2016.region,
		t1990.sum_forest_area forest_area_1990,
    t2016.sum_forest_area forest_area_2016,
		t1990.percent_forest_area percent_forest_area_1990,
		t2016.percent_forest_area percent_forest_area_2016
FROM tbl1990 t1990
JOIN tbl2016 t2016
  ON t1990.country_code = t2016.country_code
WHERE t2016.percent_forest_area < t1990.percent_forest_area

SELECT DISTINCT t2016.region
FROM tbl1990 t1990
JOIN tbl2016 t2016
  ON t1990.country_code = t2016.country_code
WHERE t2016.percent_forest_area < t1990.percent_forest_area


-- Updated subquery for better, clearer more concise comparison between 1990 and 2016 forest
-- area percentage differences.
SELECT *,
  (forest_area2016.percent_forest_area_2016 - forest_area1990.percent_forest_area_1990) AS percentage_differential
FROM
    (SELECT
      r.region,
      ROUND(CAST((SUM(f.forest_area_sqkm)/SUM(l.total_area_sq_mi*2.59)) * 100 AS NUMERIC), 2) AS percent_forest_area_2016
    FROM forest_area f
    JOIN land_area l
      ON f.year = l.year AND f.country_code = l.country_code
    JOIN regions r
      ON r.country_code = l.country_code
    WHERE f.year = '2016'
    GROUP BY 1) forest_area2016
JOIN
    (SELECT
      r.region,
      ROUND(CAST((SUM(f.forest_area_sqkm)/SUM(l.total_area_sq_mi*2.59)) * 100 AS NUMERIC), 2) AS percent_forest_area_1990
    FROM forest_area f
    JOIN land_area l
      ON f.year = l.year AND f.country_code = l.country_code
    JOIN regions r
      ON r.country_code = l.country_code
    WHERE f.year = '1990'
    GROUP BY 1) forest_area1990
ON forest_area1990.region = forest_area2016.region
ORDER BY percentage_differential
