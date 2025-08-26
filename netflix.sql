DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);

SELECT * FROM netflix;
--1. Count the number of Movies vs TV Shows
SELECT type,COUNT(*) AS differnt_type
FROM netflix
GROUP BY type;

--2.Find the most common rating for movies and TV shows
SELECT type,rating
FROM
(
SELECT type,rating,
COUNT(*),
DENSE_RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
FROM netflix
GROUP BY type,rating
) AS t1
WHERE ranking=1;

--3.list all movies released in a specific year (eg.2020)
SELECT *
FROM netflix
WHERE release_year=2020 AND type='Movie';

--4.find the top 5 countries with the most content on Netflix
SELECT new_country,
COUNT(*) AS total_shows
FROM
(SELECT 
UNNEST(STRING_TO_ARRAY(country,',')) AS new_country
FROM netflix) AS t1
GROUP BY new_country 
ORDER BY COUNT(*) DESC LIMIT 5;
--5.identify the longest movie
SELECT 
  title, 
  CAST(REPLACE(duration, ' min', '') AS INTEGER) AS duration_minutes
FROM netflix 
WHERE type = 'Movie'
  AND duration IS NOT NULL
ORDER BY duration_minutes DESC
LIMIT 1;


  --6.find content added in the last 5 years
  SELECT * 
  FROM netflix
  WHERE TO_DATE(date_added,'Month DD,YYYY') >= CURRENT_DATE-INTERVAL '5 years'

  --7.find all the movies/TV shows by director 'Rajiv Chilaka'
  SELECT * 
  FROM netflix
  WHERE director ILIKE '%Rajiv Chilaka%'
  --for making like non-casesensitive use I before like
--8.list all TV shows with more than 5 seasons
  SELECT * FROM netflix
  WHERE type='TV Show'
  AND SPLIT_PART(duration,' ',1)::numeric>5

--9.count the number of content items in each genre
  SELECT new_listing,COUNT(*) FROM (
   SELECT UNNEST(STRING_TO_ARRAY(listed_in,',')) AS new_listing FROM netflix
  ) AS t1
  GROUP BY new_listing

  SELECT UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
       COUNT(show_id) AS total_content
FROM netflix
GROUP BY genre;

--10.find each year and the average numbers of content release in India on netflix.
--return top 5 year with highest avg content release!
  SELECT
  EXTRACT(YEAR FROM TO_DATE(date_added,'Month DD,YYYY')) AS yearly_content,
  COUNT(*),
ROUND(COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country='India')::numeric * 100,2) AS avg_content_per_year
  FROM netflix 
  WHERE country='India'
  GROUP BY 1

--11.list all movies that are documentries.
  SELECT * FROM netflix
WHERE listed_in LIKE '%Documentaries'

--12.find all content without a director
 SELECT * FROM netflix
WHERE director IS NULL

--13.Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT * FROM netflix
WHERE 
	casts LIKE '%Salman Khan%'
	AND 
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10

 --14.Find the top 10 actors who have appeared in the highest number of movies produced in India.
  SELECT 
	UNNEST(STRING_TO_ARRAY(casts, ',')) as actor,
	COUNT(*)
FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10

--15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
--the description field. Label content containing these keywords as 'Bad' and all other 
--content as 'Good'. Count how many items fall into each category.
 SELECT 
    category,
	TYPE,
    COUNT(*) AS content_count
FROM (
    SELECT 
		*,
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY 1,2
ORDER BY 2

--End of reports