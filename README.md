# netflix_analysis_sql
# Netflix Movies and TV Shows Data Analysis using SQL

![](https://github.com/najirh/netflix_sql_project/blob/main/logo.png)

## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
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
```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
select 
	type,
	count(*) as Total_count
from 
	netflix_titles
group by 
	type
```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
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
```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
select 
	*
from 
	netflix_titles
where  
	type = 'Moive'
	and 
	release_year = 2020;
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
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
	
```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie

```sql
Swith MovieTbl as
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
	minutes desc```

**Objective:** Find the movie with the longest duration.

### 6. Find Content Added in the Last 5 Years

```sql

select 
	*
from 
	netflix_titles
where
	(date_added) >= DATEADD(year,-5,GETDATE())```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
select 
	*
from 
	netflix_titles
where 
	director like '%Rajiv Chilaka%'
```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 5 Seasons

```sql
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
```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
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
```

**Objective:** Count the number of content items in each genre.

### 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!

```sql
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


```

**Objective:** Calculate and rank years by the average number of content releases by India.

### 11. List All Movies that are Documentaries

```sql
select 
	title
from 
	netflix_titles
where
	type = 'Movie'
	and 
	listed_in like '%documentaries%'
```

**Objective:** Retrieve all movies classified as documentaries.

### 12. Find All Content Without a Director

```sql
select 
	* 
from 
	netflix_titles
where 
	director is null
```

**Objective:** List content that does not have a director.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
select * 
from 
	netflix_titles
where
	cast like '%Salman Khan%'
	and 
	year(date_added) >= DATEDIFF(year,10,date_added)
```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql

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
```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql

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
```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.



## Author - Mohd Arman Mansuri

This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles. If you have any questions, feedback, feel free to get in touch!

guthub = https://github.com/Arman0106/netflix_analysis_sql/new/main?readme=1
linkedin = www.linkedin.com/in/arman-mansuri-0a731a173

Thank you for your support, and I look forward to connecting with you!
