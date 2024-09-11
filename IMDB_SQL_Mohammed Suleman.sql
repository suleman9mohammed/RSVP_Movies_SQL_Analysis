USE imdb;

/* Now that you have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/



-- Segment 1:




-- Q1. Find the total number of rows in each table of the schema?
-- Type your code below:

SELECT table_name, table_rows from INFORMATION_SCHEMA.tables
WHERE TABLE_SCHEMA = 'imdb';

-- OUTPUT

-- TABLE_NAME			TABLE_ROWS
-- director_mapping	3867
-- genre				14662
-- movie				7401
-- names				21171
-- ratings				7927
-- role_mapping		15155




-- Q2. Which columns in the movie table have null values?
-- Type your code below:

 SELECT 
		SUM(IF(id IS NULL,1,0)) AS ID_null, 
		SUM(IF(title IS NULL,1,0)) AS title_null, 
		SUM(IF(year IS NULL,1,0)) AS year_null,
		SUM(IF(date_published IS NULL,1,0)) AS date_published_null,
		SUM(IF(duration IS NULL,1,0)) AS duration_null,
		SUM(IF(country IS NULL,1,0)) AS country_null,
		SUM(IF(worlwide_gross_income IS NULL,1,0)) AS worlwide_gross_income_null,
		SUM(IF(languages IS NULL,1,0)) AS languages_null,
		SUM(IF(production_company IS NULL,1,0)) AS production_company_null

FROM movie;

-- Columns with null values are (country, worlwide_gross_income, languages, production_company)



-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 
-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)

/* Output format for the first part:

+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	2134			|
|	2018		|		.			|
|	2019		|		.			|
+---------------+-------------------+


Output format for the second part of the question:
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+----------------
|	1			|	 134			|
|	2			|	 231			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

-- FIRST PART
SELECT YEAR, COUNT(ID) NO_OF_MOVIES
FROM MOVIE
GROUP BY YEAR
ORDER BY YEAR;

-- OUTPUT

-- YEAR    NO_OF_MOVIES
-- 2017	3052
-- 2018	2944
-- 2019	2001

-- SECOND PART

SELECT MONTH(DATE_PUBLISHED) AS MONTH_NUM, COUNT(ID) AS NO_OF_MOVIES
FROM MOVIE
GROUP BY MONTH_NUM
ORDER BY MONTH_NUM;

-- OUTPUT

-- MONTH_NUM   NO_OF_MOVIES
-- 1			804
-- 2			640
-- 3			824
-- 4			680
-- 5			625
-- 6			580
-- 7			493
-- 8			678
-- 9			809
-- 10			801
-- 11			625
-- 12			438




/*The highest number of movies is produced in the month of March.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- Q4. How many movies were produced in the USA or India in the year 2019??
-- Type your code below:

SELECT COUNTRY, COUNT(ID) COUNT_OF_MOVIES, YEAR 
FROM MOVIE
WHERE COUNTRY = 'USA' OR COUNTRY = 'India'
GROUP BY COUNTRY, YEAR
HAVING YEAR = '2019';

-- OUTPUT

-- India	295		2019
-- USA		592		2019




/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/

-- Q5. Find the unique list of the genres present in the data set?
-- Type your code below:

SELECT DISTINCT GENRE FROM GENRE;

-- TOTAL 13 UNIQUE GENRES ARE THERE




/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below:

SELECT G.GENRE, COUNT(M.ID) COUNT_MOVIES
FROM MOVIE M, GENRE G
WHERE G.MOVIE_ID = M.ID
GROUP BY G.GENRE
ORDER BY COUNT_MOVIES DESC
LIMIT 1;

-- OUTPUT

-- Drama is the genre which produced highest number of movies overall which count is 4285




/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?
-- Type your code below:

SELECT COUNT(CNT_GENRE.MOVIE_ID) NO_OF_MOVIES
FROM (SELECT MOVIE_ID, COUNT(GENRE) number_of_genre_movies
FROM GENRE
GROUP BY MOVIE_ID
HAVING number_of_genre_movies = 1) CNT_GENRE;

-- OUTPUT 
-- 3289





/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/

-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)


/* Output format:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT G.GENRE, ROUND(AVG(M.DURATION),2) AVG_DURATION
FROM MOVIE M, GENRE G 
WHERE M.ID = G.MOVIE_ID
GROUP BY G.GENRE
ORDER BY AVG_DURATION DESC;

-- OUTPUT

-- GENRE 		AVG_DURATION
-- Action		112.88
-- Romance		109.53
-- Crime		107.05
-- Drama		106.77
-- Fantasy		105.14
-- Comedy		102.62
-- Adventure	101.87
-- Mystery		101.80
-- Thriller		101.58
-- Family		100.97
-- Others		100.16
-- Sci-Fi		97.94
-- Horror		92.72

-- INSIGHTS
-- drama movies produced a lot but action movies have highest avergae duration.





/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)


/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

WITH summary AS
(
	SELECT 
		genre,
		COUNT(movie_id) AS movie_count,
		RANK () OVER (ORDER BY COUNT(movie_id) DESC) AS genre_rank
	FROM
		genre
	GROUP BY genre
)
SELECT 
    *
FROM
    summary
WHERE
    lower(genre) = 'thriller';


-- OUTPUT

-- GENRE		MOVIE_COUNT		GENRE_RANK
-- Thriller    	1484					3





/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/




-- Segment 2:




-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/
-- Type your code below:


SELECT 

	ROUND(MIN(avg_rating)) AS min_avg_rating,
    ROUND(MAX(avg_rating)) AS max_avg_rating,
	MIN(total_votes) AS min_total_votes,
    MAX(total_votes) AS max_total_votes,
	MIN(median_rating) AS min_median_rating,
    MAX(median_rating) AS max_median_rating 
    
FROM ratings;

/* OUTPUT
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		1		|			10		|	       100		  |	   100	    		 |		1	       |	10			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/


    

/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

-- Q11. Which are the top 10 movies based on average rating?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
-- It's ok if RANK() or DENSE_RANK() is used too

SELECT M.TITLE, R.AVG_RATING, DENSE_RANK() OVER(ORDER BY R.AVG_RATING DESC) MOVIE_RANK
FROM MOVIE M, RATINGS R 
WHERE M.ID = R.MOVIE_ID
LIMIT 10;

-- OUTPUT 

	-- TITLE						AVG_RATING	MOVIE_RANK
	-- Kirket							10.0	1
	-- Love in Kilnerry					10.0	1
	-- Gini Helida Kathe				 9.8	2
	-- Runam							 9.7	3
	-- Fan								 9.6	4
	-- Android Kunjappan Version5.25	 9.6	4
	-- Yeh Suhaagraat Impossible		 9.5	5
	-- Safe								 9.5	5
	-- The Brighton Miracle				 9.5	5
	-- Shibu							 9.4	6






/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
-- Order by is good to have

SELECT MEDIAN_RATING, COUNT(MOVIE_ID) MOVIE_COUNT
FROM RATINGS
GROUP BY MEDIAN_RATING
ORDER BY MEDIAN_RATING;

-- OUTPUT 
-- RATING	MOVIE_COUNT
	-- 1		94
	-- 2		119
	-- 3		283
	-- 4		479
	-- 5		985
	-- 6		1975
	-- 7		2257
	-- 8		1030
	-- 9		429
	-- 10		346




/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/
-- Type your code below:

SELECT M.PRODUCTION_COMPANY, COUNT(M.TITLE) MOVIE_COUNT, DENSE_RANK() OVER (ORDER BY COUNT(M.TITLE) DESC) PROD_COMPANY_RANK
FROM MOVIE M, RATINGS R 
WHERE M.ID = R.MOVIE_ID
AND M.PRODUCTION_COMPANY IS NOT NULL
AND R.AVG_RATING > 8
GROUP BY M.PRODUCTION_COMPANY;

-- OUTPUT

--	PRODUCTION_COMPANY 		 COUNT  RANK
-- Dream Warrior Pictures		3	1
-- National Theatre Live		3	1







-- It's ok if RANK() or DENSE_RANK() is used too
-- Answer can be Dream Warrior Pictures or National Theatre Live or both

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:



SELECT 	G.GENRE, COUNT(M.TITLE) MOVIE_COUNT
FROM 	GENRE G, MOVIE M, RATINGS R 
WHERE 	G.MOVIE_ID = M.ID
AND 	M.ID = R.MOVIE_ID
AND		M.YEAR = 	2017
AND		monthname(M.DATE_PUBLISHED) = 'MARCH'
AND		R.TOTAL_VOTES > 1000
AND		M.COUNTRY = 'USA'
GROUP BY G.GENRE
ORDER BY MOVIE_COUNT DESC;





-- Lets try to analyse with a unique problem statement.
-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:



SELECT M.TITLE, R.AVG_RATING, G.GENRE
FROM 	GENRE G, MOVIE M, RATINGS R 
WHERE	G.MOVIE_ID = M.ID
AND		M.ID = R.MOVIE_ID
AND		UPPER(SUBSTR(M.TITLE,1,3)) = 'THE'
AND 	R.AVG_RATING > 8
ORDER BY G.GENRE;



-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.
-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below:

SELECT COUNT(M.TITLE) movie_count
FROM MOVIE M, RATINGS R 
WHERE M.ID = R.MOVIE_ID
AND R.MEDIAN_RATING = 8
AND DATE_PUBLISHED  BETWEEN '2018-04-01' AND '2019-04-01';

-- movie_count
-- 361





-- Once again, try to solve the problem given below.
-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- Type your code below:


with german_summary AS (
SELECT SUM(r.total_votes) AS german_total_votes,
RANK() OVER(ORDER BY SUM(r.total_votes)) AS unique_id
FROM movie AS m
INNER JOIN ratings AS r
ON m.id=r.movie_id
WHERE m.languages LIKE '%German%'
), italian_summary AS (
SELECT SUM(r.total_votes) AS italian_total_votes,
RANK() OVER(ORDER BY sum(r.total_votes)) AS unique_id
FROM movie AS m
INNER JOIN ratings AS r
ON m.id=r.movie_id
WHERE m.languages LIKE '%Italian%'
) SELECT *,
CASE
	WHEN german_total_votes > italian_total_votes THEN 'Yes' ELSE 'No'
    END AS 'German_Movie_Is_Popular_Than_Italian_Movie'
FROM german_summary
INNER JOIN
italian_summary
USING(unique_id);   


-- output
-- German_Movie_Is_Popular_Than_Italian_Movie
-- YES


-- Answer is Yes

/* Now that you have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/




-- Segment 3:



-- Q18. Which columns in the names table have null values??
/*Hint: You can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:


SELECT COUNT(*)-COUNT(name) AS name_nulls, 
		COUNT(*)-COUNT(height) AS height_nulls, 
		COUNT(*)-COUNT(date_of_birth) AS date_of_birth_nulls, 
		COUNT(*)-COUNT(known_for_movies) AS known_for_movies_nulls
FROM names; 

-- output

/*
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			17335	|	       13431	  |	   15226	    	 |
+---------------+-------------------+---------------------+----------------------+*/



/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
/* Output format:

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

WITH top_3_genre as
(Select g.genre, count(g.movie_id) movie_count
from genre g, ratings r
where g.movie_id = r.movie_id
and r.avg_rating > 8
group by genre
order by movie_count desc
limit 3)
Select n.name director_name, count(m.title) movie_count
from director_mapping d, names n, movie m, genre g, ratings r
where m.id = d.movie_id
and d.name_id = n.id
and m.id = r.movie_id
and m.id = g.movie_id
and g.genre in (Select genre from top_3_genre)
and r.avg_rating > 8
group by director_name
order by movie_count desc
limit 3;

/* Output :

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
| James Mangold	|		4			|
| Joe Russo		|		3 			|
| Anthony Russo	|		3 			|
+---------------+-------------------+ */





/* James Mangold can be hired as the director for RSVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:


SELECT	N.NAME ACTOR_NAME, COUNT(R.MOVIE_ID) MOVIE_COUNT
FROM ROLE_MAPPING RM, RATINGS R, NAMES N 
WHERE RM.MOVIE_ID = R.MOVIE_ID
AND   RM.NAME_ID = N.ID
AND	  UPPER(CATEGORY) = 'ACTOR'
AND   R.MEDIAN_RATING >= 8
GROUP BY ACTOR_NAME
ORDER BY MOVIE_COUNT DESC
LIMIT 2;

-- OUTPUT
-- Mammootty	8
-- Mohanlal	    5




/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 
RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

SELECT M.PRODUCTION_COMPANY, SUM(R.TOTAL_VOTES) VOTE_COUNT, RANK() OVER (ORDER BY SUM(R.TOTAL_VOTES) DESC) PROD_COMP_BANK
FROM MOVIE M, RATINGS R 
WHERE M.ID = R.MOVIE_ID
AND M.PRODUCTION_COMPANY IS NOT NULL
GROUP BY M.PRODUCTION_COMPANY
LIMIT 3;

-- OUTPUT

-- Marvel Studios			2656967		1
-- Twentieth Century Fox	2411163		2
-- Warner Bros.				2396057		3





/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

SELECT name  actor_name, 
		SUM(total_votes) TOTAL_VOTES,
		COUNT(m.TITLE) AS movie_count,
		ROUND(SUM(avg_rating*total_votes)/SUM(total_votes),2) AS actor_avg_rating,
		RANK() OVER(ORDER BY  ROUND(SUM(avg_rating*total_votes)/SUM(total_votes),2) DESC) AS actor_rank		
FROM movie AS m 
INNER JOIN ratings AS r 
ON m.id = r.movie_id 
INNER JOIN role_mapping AS rm 
ON m.id=rm.movie_id 
INNER JOIN names AS nm 
ON rm.name_id=nm.id
WHERE category='actor' AND country= 'India'
GROUP BY actor_name
HAVING movie_count>=5
ORDER BY actor_avg_rating DESC;

-- OUTPUT

-- Vijay Sethupathi		23114	5	8.42	1
-- Fahadh Faasil		13557	5	7.99	2
-- Yogi Babu			8500	11	7.83	3







-- Top actor is Vijay Sethupathi

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

SELECT 	nm.name  actress_name, 
		SUM(r.total_votes) TOTAL_VOTES,
		COUNT(m.TITLE) AS movie_count,
		ROUND(SUM(r.avg_rating*r.total_votes)/SUM(r.total_votes),2) AS actor_avg_rating,
		RANK() OVER(ORDER BY  ROUND(SUM(r.avg_rating*r.total_votes)/SUM(r.total_votes),2) DESC) AS actress_rank		
FROM 	movie m, ratings r, role_mapping rm, names nm
where 	m.id = r.movie_id
and		m.id=rm.movie_id
and		rm.name_id=nm.id
and		rm.category='actress'	
and 	m.country like '%India%'
and		m.languages like '%Hindi%'
GROUP BY 	actress_name
HAVING 		movie_count>=3
ORDER BY 	actor_avg_rating DESC
LIMIT 5;

-- output

-- Taapsee Pannu		18061	3	7.74	1
-- Kriti Sanon			21967	3	7.05	2
-- Divya Dutta			8579	3	6.88	3
-- Shraddha Kapoor		26779	3	6.63	4
-- Kriti Kharbanda		2549	3	4.80	5



/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
-- Type your code below:


Select	m.title movie_name, g.genre, r.avg_rating,
		(case
			when r.avg_rating > 8 then 'Superhit Movies'
            when r.avg_rating between 7 and 8 then 'Hit Movies'
            when r.avg_rating between 5 and 7 then 'One-time-watch Movies'
            else 'Flop Movies'
		end) Classify
from movie m, genre g, ratings r 
where m.id = g.movie_id
and	  m.id = r.movie_id
and   g.genre = 'thriller'
order by r.avg_rating desc;

-- output

-- Safe					Thriller	9.5	Superhit Movies
-- Digbhayam			Thriller	9.2	Superhit Movies
-- Dokyala Shot			Thriller	9.2	Superhit Movies
-- Abstruse				Thriller	9.0	Superhit Movies
-- Kaithi				Thriller	8.9	Superhit Movies
-- Raju Gari Gadhi 3	Thriller	8.8	Superhit Movies
-- Lost Angelas			Thriller	8.8	Superhit Movies
--	..
--	..
--	..
--	..
--	..
-- Cradle Robber		Thriller	5.0	One-time-watch Movies
-- Lie Low				Thriller	5.0	One-time-watch Movies
-- Les fauves			Thriller	5.0	One-time-watch Movies
-- Mikhael				Thriller	5.0	One-time-watch Movies
-- Fahrenheit 451		Thriller	4.9	Flop Movies
-- Angelica				Thriller	4.9	Flop Movies
-- Stockholm			Thriller	4.9	Flop Movies
-- Paralytic			Thriller	4.9	Flop Movies
-- Night Pulse			Thriller	4.9	Flop Movies
-- Baadshaho			Thriller	4.9	Flop Movies
-- Perfect sãnãtos		Thriller	4.9	Flop Movies
-- The Child Remains	Thriller	4.9	Flop Movies
-- M/M					Thriller	4.9	Flop Movies




/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/

-- Segment 4:

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:


SELECT genre,
	ROUND(AVG(duration))  avg_duration,
	SUM(ROUND(AVG(duration),2)) OVER(ORDER BY genre ROWS UNBOUNDED PRECEDING)  running_total_duration,
	ROUND(AVG(ROUND(AVG(duration),2)) OVER(ORDER BY genre ROWS 10 PRECEDING),2)  moving_avg_duration
FROM movie  m 
INNER JOIN genre  g 
ON m.id= g.movie_id
GROUP BY genre
ORDER BY genre;

-- output

	-- genre	avg_duration	running_total_duration	moving_avg_duration
	-- Action		113			112.88					112.88
	-- Adventure	102			214.75					107.38
	-- Comedy		103			317.37					105.79
	-- Crime		107			424.42					106.11
	-- Drama		107			531.19					106.24
	-- Family		101			632.16					105.36
	-- Fantasy		105			737.30					105.33
	-- Horror		93			830.02					103.75
	-- Mystery		102			931.82					103.54
	-- Others		100			1031.98					103.20
	-- Romance		110			1141.51					103.77
	-- Sci-Fi		 98			1239.45					102.42
	-- Thriller		102			1341.03					102.39






-- Round is good to have and not a must have; Same thing applies to sorting


-- Let us find top 5 movies of each year with top 3 genres.

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

-- Top 3 Genres based on most number of movies



WITH top_3_genre AS
( 	
	SELECT genre, COUNT(movie_id) AS number_of_movies
    FROM genre AS g
    INNER JOIN movie AS m
    ON g.movie_id = m.id
    GROUP BY genre
    ORDER BY COUNT(movie_id) DESC
    LIMIT 3
),

top_5 AS
(
	SELECT genre,
			year,
			title AS movie_name,
			worlwide_gross_income,
			DENSE_RANK() OVER(PARTITION BY year ORDER BY worlwide_gross_income DESC) AS movie_rank
        
	FROM movie AS m 
    INNER JOIN genre AS g 
    ON m.id= g.movie_id
	WHERE genre IN (SELECT genre FROM top_3_genre)
)

SELECT *
FROM top_5
WHERE movie_rank<=5;


-- output

	-- genre		year	movie_name					worlwide_gross_income	movie_rank

	-- Drama		2017	Shatamanam Bhavati			INR 530500000				1
	-- Drama		2017	Winner						INR 250000000				2
	-- Drama		2017	Thank You for Your Service	$ 9995692					3
	-- Comedy		2017	The Healer					$ 9979800					4
	-- Drama		2017	The Healer					$ 9979800					4
	-- Thriller		2017	Gi-eok-ui bam				$ 9968972					5

	-- Thriller		2018	The Villain					INR 1300000000				1
	-- Drama		2018	Antony & Cleopatra			$ 998079					2
	-- Comedy		2018	La fuitina sbagliata		$ 992070					3
	-- Drama		2018	Zaba						$ 991						4
	-- Comedy		2018	Gung-hab					$ 9899017					5

	-- Thriller		2019	Prescience					$ 9956						1
	-- Thriller		2019	Joker						$ 995064593					2
	-- Drama		2019	Joker						$ 995064593					2
	-- Comedy		2019	Eaten by Lions				$ 99276						3
	-- Comedy		2019	Friend Zone					$ 9894885					4
	-- Drama		2019	Nur eine Frau				$ 9884						5



-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

SELECT production_company ,count(m.id)AS movie_count, 
RANK() OVER(ORDER BY count(id) DESC) AS prod_comp_rank
FROM movie AS m
INNER JOIN ratings AS r
ON m.id=r.movie_id
WHERE median_rating>=8 
AND production_company IS NOT NULL 
AND position(',' IN languages)>0
GROUP BY production_company
LIMIT 2;


-- output

-- Star Cinema				7	1
-- Twentieth Century Fox	4	2



-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language


-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

SELECT name, SUM(total_votes) AS total_votes,
		COUNT(rm.movie_id) AS movie_count,
		avg_rating actress_avg_rating,
        DENSE_RANK() OVER(ORDER BY avg_rating DESC) AS actress_rank
FROM names AS n
INNER JOIN role_mapping AS rm
ON n.id = rm.name_id
INNER JOIN ratings AS r
ON r.movie_id = rm.movie_id
INNER JOIN genre AS g
ON r.movie_id = g.movie_id
WHERE category = 'actress' 
AND avg_rating > 8 
AND genre = 'Drama'
GROUP BY name, avg_rating
LIMIT 3;

-- output

-- Sangeetha Bhat	1010	1	9.6		1
-- Fatmire Sahiti	3932	1	9.4		2
-- Adriana Matoshi	3932	1	9.4		2




/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/
-- Type you code below:


WITH next_date_published_summary AS
(
           SELECT     d.name_id,
                      NAME,
                      d.movie_id,
                      duration,
                      r.avg_rating,
                      total_votes,
                      m.date_published,
                      Lead(date_published,1) OVER(partition BY d.name_id ORDER BY date_published,movie_id ) AS next_date_published
           FROM       director_mapping                                                                      AS d
           INNER JOIN names                                                                                 AS n
           ON         n.id = d.name_id
           INNER JOIN movie AS m
           ON         m.id = d.movie_id
           INNER JOIN ratings AS r
           ON         r.movie_id = m.id ), top_director_summary AS
(
       SELECT *,
              Datediff(next_date_published, date_published) AS date_difference
       FROM   next_date_published_summary )
SELECT   name_id                       AS director_id,
         NAME                          AS director_name,
         Count(movie_id)               AS number_of_movies,
         Round(Avg(date_difference),2) AS avg_inter_movie_days,
         Round(Avg(avg_rating),2)               AS avg_rating,
         Sum(total_votes)              AS total_votes,
         Min(avg_rating)               AS min_rating,
         Max(avg_rating)               AS max_rating,
         Sum(duration)                 AS total_duration
FROM     top_director_summary
GROUP BY director_id
ORDER BY Count(movie_id) DESC limit 9;

