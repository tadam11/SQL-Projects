CREATE TABLE appleStore_description_combined AS

SELECT * FROM appleStore_description1

UNION ALL

SELECT * FROM appleStore_description2

UNION ALL

SELECT * FROM appleStore_description3

UNION ALL

SELECT * FROM appleStore_description4

**EDA**AppleStore
-- verify the number of unique apps is the same
SELECT COUNT(DISTINCT id) AS UniqueAppIDs
FROM appleStore_description_combined

SELECT COUNT(DISTINCT id) AS UniqueAppIDs
FROM appleStore

--Check for missing values

SELECT COUNT(*) AS MissingValues
FROM AppleStore
WHERE track_name IS null OR user_rating IS null OR prime_genre IS NULL
-- there is no missingness in appleStore

SELECT COUNT(*) AS MissingValues
FROM appleStore_description_combined
WHERE app_desc IS null
-- there are no missing app descriptions

--Number of apps per primary genre
SELECT prime_genre, COUNT(*) AS NumApps
FROM AppleStore
GROUP BY prime_genre
ORDER BY NumApps DESC

--Overview of app ratings
SELECT min(user_rating) AS MinRating,
	   max(user_rating) AS MaxRating,
       avg(user_rating) AS AvgRating
FROM AppleStore

--Distribution of Free vs. Paid appsAppleStore
WITH tempTable AS
  (SELECT COUNT(*) AS freeApps
  FROM AppleStore
  WHERE price = 0)
  SELECT CAST(freeApps as float)/COUNT(*)
  FROM AppleStore, tempTable
--56% of applications are free

**Analysis**AppleStore

--Do paid apps have higher ratings than free apps?AppleStore

SELECT CASE
			WHEN price > 0 THEN 'Paid'
            ELSE 'Free'
       END AS App_Type,
       avg(user_rating) AS Avg_Rating
FROM AppleStore
GROUP BY App_Type

--Do apps with more language support have higher ratings

SELECT CASE
			WHEN lang_num < 10 THEN '<10 languages'
            WHEN lang_num BETWEEN 10 AND 30 THEN '10-30 languages'
            ELSE '>30 languages'
       END AS language_bucket,
       avg(user_rating) AS Avg_Rating
FROM AppleStore
GROUP BY language_bucket
ORDER BY Avg_Rating DESC

--Check low rated genres

SELECT prime_genre,
	   avg(user_rating) AS Avg_Rating
FROM AppleStore
GROUP BY prime_genre
ORDER BY Avg_Rating ASC
LIMIT 10

--Is there correlation between length of app description and the rating?
SELECT CASE
			WHEN length(b.app_desc) < 500 THEN 'Short'
            WHEN length(b.app_desc) BETWEEN 500 AND 1000 THEN 'Medium'
            ELSE 'Long'
       END AS description_length_bucket,
       avg(a.user_rating) AS average_rating
FROM 
	AppleStore AS A
JOIN
	appleStore_description_combined AS b
ON
	a.id = b.id
GROUP BY description_length_bucket
ORDER BY average_rating DESC
-- Longer descriptions seem to have higher ratings than shorter ones

--Find the top rated apps with the most ratings for each genre

SELECT
	prime_genre,
    track_name,
    user_rating
FROM (
  	  SELECT
      prime_genre,
      track_name,
  	  user_rating,
      RANK() OVER (PARTITION BY prime_genre ORDER BY user_rating DESC, rating_count_tot DESC) AS rank
      FROM AppleStore
  	  )AS a
WHERE
a.rank = 1

