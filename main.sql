CREATE TABLE appleStore_description_combined AS

SELECT * FROM appleStore_description1
-- COMBONES ALL THE FILES 
UNION ALL
SELECT * FROM appleStore_description2
UNION ALL
SELECT * FROM appleStore_description3
UNION ALL
SELECT * FROM appleStore_description4

-- * DATA ANALYSIS *
-- CHECK the number of unique apps in both tables AppleStore
SELECT COUNT(DISTINCT c1)UniqueAppIDS
FROM AppleStore

-- CHECK the number of unique apps in the combined table
SELECT COUNT(DISTINCT id) AS UniqueAppsIDS
FROM appleStore_description_combined;


-- CHECK for any missing values in AppleStore
SELECT COUNT(*) AS MissingData
FROM AppleStore
Where track_name IS NULL OR user_rating IS NULL or prime_genre IS NULL

--Check  appleStore_description_combined table if it has any null values
SELECT COUNT(*) AS MissingData
FROM appleStore_description_combined
Where app_desc IS NULL

-- find out Which genre has the most APPS (Games,Education,others)
SELECT prime_genre, COUNT(*) as NumApps
FROM AppleStore
GROUP BY prime_genre
ORDER BY NumApps DESC
-- MOST Apps(Games, Entertainment, Education, Photos&Vid, Etc)

-- Get an overview of the ratings of each app
SELECT min(user_rating) AS MinRating,
       max(user_rating) AS MaxRating,
       avg(user_rating) AS AvgRating
FROM AppleStore
-- AvgRating was aroud 3.5264

-- Get the distribution of app prices
SELECT
	(price / 2) * 2 AS PriceBinStart,
    ((price/2)*2) + 2 AS PriceBinEnd,
    COUNT(*) As NumApps
FROM AppleStore
GROUP BY PriceBinStart

-- Find which apps have higher ratings (Paid or Free)
SELECT CASE
      WHEN price > 0 THEN 'PAID'
      ELSE 'FREE'
      END AS App_Type,
      avg(user_rating) AS AvgRating
FROM AppleStore
GROUP BY App_Type
-- Paid app Have higher rating 

-- Check if apps that offer more langugages supported have higher ratingsAppleStore
SELECT CASE
	WHEN lang_num < 10 THEN 'less than 10 Langs'
    When lang_num BETWEEN 10 And 30 THEN '10-30 Langs'
    ELSE 'More than 30 Langs'
   End As language_bucket,
   avg(user_rating) AS Avg_Rating
FROM AppleStore
GROUP BY language_bucket
ORDER By Avg_Rating DESC

-- Ceck genres with low rating
SELECT prime_genre,
	 avg(user_rating) AS AVG_RATING
FROM AppleStore
GROUP BY prime_genre
ORDER BY AVG_RATING ASC
Limit 10
-- CATALOGS AND FINANCE HAS THE WORST RATINGS 
-- Good option to make an App in these Genres

-- Check if there is correlationg btw the length of app description & user ratingsAppleStore
SELECT CASE 
		WHEN length(b.app_desc) < 500 THEN 'SHORT'
        WHEN length(b.app_desc) BETWEEN 500 AND 1000 THEN 'MEDIUM'
        ELSE 'LONG'
      END AS description_length_bucket,
      avg(a.user_rating) AS average_rating
FROM 
	AppleStore AS A 
JOIN
	appleStore_description_combined as b
ON 
 	a.id = b.id
GROUP BY description_length_bucket
ORDER BY average_rating DESC

-- check for top rated apps from AppleStore
SELECT 
	prime_genre,
    track_name,
    user_rating
FROM (
  SELECT 
  prime_genre,
  track_name,
  user_rating,
  RANK() OVER(PARTITION BY prime_genre ORDER BY user_rating DESC, rating_count_tot DESC) as rank
  	FROM
  	appleStore
  	) as a 
    
WHERE
	a.rank = 1
