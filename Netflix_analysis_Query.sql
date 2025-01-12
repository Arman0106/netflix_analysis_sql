create database netflix_analysis
use netflix_analysis

create table Netflix(
show_id	varchar(10),
types varchar(15),
title varchar(150),
director varchar(220),
casts varchar(1000),
country varchar(150),
date_added varchar(50),
release_year INT,	
rating  varchar(15),
duration varchar(15),
listed_in varchar(100),
description varchar(500)
)

select * from netflix_titles

alter table netflix_titles
alter column date_added date

--15 Business problems and solutions

--1. Count the number of Movies vs TV Shows

select 
	type,
	count(*) as Total_count
from 
	netflix_titles
group by 
	type
	
--2. Find the most common rating for movies and TV shows

select *  
from 
(
	select
		type,
		rating,
		count(*) as total_rating,
		rank() over(partition by type order by count(*) desc) as rank
	from 
		netflix_titles 
	group by 
		type,
		rating
) as ABC
where rank = 1


--3. List all movies released in a specific year (e.g., 2020)

select 
	*
from 
	netflix_titles
where  
	type = 'Moive'
	and 
	release_year = 2020

--4. Find the top 5 countries with the most content on Netflix

select top 5
	country,
	count(*) as Total_content 
from
(
	select 
		show_id ,
		value as country
	from netflix_titles 
		cross apply string_split(country,',') --function to split by delimiter and arrange in rows 
) as ABC
group by
	country
order by
	count (*)desc
	
	
--5. Identify the longest movie

with MovieTbl as
(
select
	*,
	convert(int,left(duration,charindex(' ',duration))) as minutes
from 
	netflix_titles
where
	type = 'Movie'
)
select top 1 
	title ,
	minutes
from 
	MovieTbl
order by 
	minutes desc

--6. Find content added in the last 6 years

select 
	*
from 
	netflix_titles
where
	(date_added) >= DATEADD(year,-5,GETDATE())

--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

select 
	*
from 
	netflix_titles
where 
	director like '%Rajiv Chilaka%'

--8. List all TV shows with more than 5 seasons

with SeasonTbl as
(
select
	*,
	convert(int,left(duration,charindex(' ',duration))) as Seasons
from
	netflix_titles
where 
	type = 'TV Show'
)
select 
	title,
	type,
	Seasons
from 
	SeasonTbl
where 
	Seasons > 5
	

--9. Count the number of content items in each genre

select 
	genre,
	count(*) as Total_content
from
(
	select *, 
		value as genre
	from 
		netflix_titles	
			cross apply string_split(listed_in ,',')
)as GenreList
group by 
	genre
order by 
	count(*) desc

/*10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!*/

select Years,
	Total,
	(Total*100/(select count(*) from netflix_titles where country ='India')) as avgcontent
from
(select top 5
	year(date_added) as Years,
	count(*) as Total
from 
	netflix_titles
where
	country = 'India'
group by 
	year(date_added)
order by 
	count(*) desc
) as ABC


--11. List all movies that are documentaries

select 
	title
from 
	netflix_titles
where
	type = 'Movie'
	and 
	listed_in like '%documentaries%'

--12. Find all content without a director

select 
	* 
from 
	netflix_titles
where 
	director is null

--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!.

select * 
from 
	netflix_titles
where
	cast like '%Salman Khan%'
	and 
	year(date_added) >= DATEDIFF(year,10,date_added)

--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

select top 10
	actors,
	count(*) as Movie_acted
from
(
	select 
		value as actors
	from
		netflix_titles
			cross apply STRING_split(cast,',')
)as ABC
group by
	actors
order by 
	count(*) desc
/*15.
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.*/

select 
	Content,
	count(*) as Total_content
from
	(select 
		description,
		case
			when description like '%kill%' or description like '%violence%' then 'Bad Content'
			else 'Good Content'
		end as 'Content'
	from 
		netflix_titles
) as ABC
group by
	Content
	
