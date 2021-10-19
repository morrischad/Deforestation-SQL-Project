--Create a table for 1990 and 2016 and join them
--Subtract forest in 1990 from 2016 to see positive and negative differences in newly joined table
--Display country_name, difference_sqkm_1990-2016

WITH forest_area_sqkm_1990 AS (SELECT
  country_code,
  country_name,
  forest_area_sqkm,
  year year_1990
FROM forest_area
WHERE year = '1990'),

forest_area_sqkm_2016 AS (SELECT
  country_code,
  country_name,
  forest_area_sqkm,
  year year_2016
FROM forest_area
WHERE year = '2016')



--a. Which 5 countries saw the largest amount decrease in forest area from 1990 to 2016?
--What was the difference in forest area for each?

--Self-join to compare rows within the same table
SELECT
  (t1.forest_area_sqkm - t2.forest_area_sqkm) AS forest_area_sqkm_diff,
  t1.country_code as t1_country_code,
  t1.country_name AS t1_country_name,
  t1.year AS t1_year,
  t1.forest_area_sqkm AS t1_forest_area_sqkm_1990,
  t2.country_code as t2_country_code,
  t2.country_name AS t2_country_name,
  t2.year AS t2_year,
  t2.forest_area_sqkm AS t2_forest_area_sqkm_2016
FROM forest_area t1
JOIN forest_area t2
  ON t1.country_code = t2.country_code
  AND t1.country_name = t2.country_name
  AND t1.forest_area_sqkm > t2.forest_area_sqkm
  AND t1.year = '1990'
  AND t2.year = '2016'
ORDER BY 1 DESC
LIMIT 6

--b. Which 5 countries saw the largest percent decrease in forest area from 1990 to 2016?
--What was the percent change to 2 decimal places for each?

SELECT
  t1_country_name,
  ROUND(CAST(((t1_forest_area_sqkm_1990 - t2_forest_area_sqkm_2016)/t1_forest_area_sqkm_1990) * 100 AS NUMERIC), 2) AS forest_areasqkm_percent_decrease
FROM difference_table
ORDER BY 2 DESC

--c. If countries were grouped by percent forestation in quartiles,
--which group had the most countries in it in 2016?


WITH percentage_reference AS (SELECT
  f.country_name,
  SUM(f.forest_area_sqkm) sum_forest_area_sqkm,
  SUM(l.total_area_sq_mi * 2.59) AS sum_total_area_sqkm,
  (SUM(f.forest_area_sqkm) / (SUM(l.total_area_sq_mi * 2.59))) * 100 AS percent_forest_area
FROM forest_area f
JOIN land_area l
  ON f.country_name = l.country_name
  AND f.country_code = l.country_code
WHERE f.year = '2016'
GROUP BY 1)

SELECT DISTINCT (quartile_range), COUNT(country_name)
FROM (SELECT
  country_name,
  percent_forest_area, CASE
  WHEN percent_forest_area BETWEEN 0 AND 25 THEN '1st Quartile'
  WHEN percent_forest_area BETWEEN 25 AND 50 THEN '2nd Quartile'
  WHEN percent_forest_area BETWEEN 50 AND 75 THEN '3rd Quartile'
  WHEN percent_forest_area > 75-100 THEN '4th Quartile'
ELSE 'N/A' END as quartile_range
FROM percentage_reference
WHERE percent_forest_area IS NOT NULL AND country_name != 'World'
GROUP BY 1, 2) t1

GROUP BY 1
ORDER BY 2 DESC


--d. List all of the countries that were in the 4th quartile (percent forest > 75%) in 2016.

WITH ref_table AS(SELECT *,
  NTILE (4) OVER (ORDER BY percent_forest_area) AS NTILE_ranking
FROM percent_forest_area_sqkm)

SELECT *
FROM ref_table
WHERE NTILE_ranking = 4

--e. How many countries had a percent forestation higher than the United States in 2016?

SELECT COUNT(*)
FROM percent_forest_area_sqkm
WHERE percent_forest_area >
(SELECT percent_forest_area
FROM percent_forest_area_sqkm
WHERE country_name = 'United States')



--Revised my queries to make better make use of a subquery that seems to require less steps/requires
-- to answer most of the country level questions.
SELECT
  country_code_1990 AS country_code,
  country_name_1990 AS country_name,
  year_1990,
  forest_area_sqkm1990,
  year_2016,
  forest_area_sqkm2016,
  (forest_area_sqkm2016 - forest_area_sqkm1990) AS forest_area_diff_1990_to_2016,
  ROUND(CAST((forest_area_sqkm2016 - forest_area_sqkm1990)/forest_area_sqkm1990 * 100 AS NUMERIC), 2) AS percentage_diff_1990_to_2016
FROM
	 (SELECT
      forest_1990.country_code country_code_1990,
      forest_1990.country_name country_name_1990,
      forest_1990.year year_1990,
      forest_1990.forest_area_sqkm forest_area_sqkm1990
    FROM forest_area forest_1990
    WHERE year = '1990') forest_1990
JOIN
    (SELECT
      forest_2016.country_code country_code_2016,
      forest_2016.country_name country_name_2016,
      forest_2016.year year_2016,
      forest_2016.forest_area_sqkm forest_area_sqkm2016
    FROM forest_area forest_2016
    WHERE year = '2016') forest_2016
ON forest_2016.country_code_2016 = forest_1990.country_code_1990
ORDER BY 8 DESC


-- The following query was used to retrieve the top countries by difference of forest area from forest_area_diff_1990_to_2016
SELECT
  country_code_1990 AS country_code,
  country_name_1990 AS country_name,
  year_1990,
  forest_area_sqkm1990,
  year_2016,
  forest_area_sqkm2016,
  (forest_area_sqkm2016 - forest_area_sqkm1990) AS forest_area_diff_1990_to_2016,
  ROUND(CAST((forest_area_sqkm2016 - forest_area_sqkm1990)/forest_area_sqkm1990 * 100 AS NUMERIC), 2) AS percentage_diff_1990_to_2016,
  regions.region
FROM
	 (SELECT
      forest_1990.country_code country_code_1990,
      forest_1990.country_name country_name_1990,
      forest_1990.year year_1990,
      forest_1990.forest_area_sqkm forest_area_sqkm1990
    FROM forest_area forest_1990
    WHERE year = '1990') forest_1990
JOIN
    (SELECT
      forest_2016.country_code country_code_2016,
      forest_2016.country_name country_name_2016,
      forest_2016.year year_2016,
      forest_2016.forest_area_sqkm forest_area_sqkm2016
    FROM forest_area forest_2016
    WHERE year = '2016') forest_2016
  ON forest_2016.country_code_2016 = forest_1990.country_code_1990
JOIN regions
  ON regions.country_code = forest_2016.country_code_2016
ORDER BY 7
