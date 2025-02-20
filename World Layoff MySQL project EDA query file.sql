/* Exploratory Data Analysis */


Select * from 
layoffs_staging2;

/* QUES. What are the maximum laid off in total and percentage */

Select Max(total_laid_off), Max(percentage_laid_off)
from layoffs_staging2;

/* QUES. Which companies have laid off the most employees, 
and how many employees were let go by each company? */

Select company, Sum(total_laid_off)
from layoffs_staging2
group by company
order by 2 desc;

/* QUES. What is the date range covered by the layoffs data in the dataset? */

Select Min(`date`), Max(`date`)
from layoffs_staging2;

/* QUES. Which industries have experienced the highest number of layoffs, 
and how many employees were let go in each industry? */

Select industry, Sum(total_laid_off)
from layoffs_staging2
group by industry
order by 2 desc;

/* QUES. Which countries have experienced the highest number of layoffs, 
and how many employees were let go in each country? */

Select country, Sum(total_laid_off)
from layoffs_staging2
group by country
order by 2 desc;

/* QUES. How many employees were laid off each year, 
and which year had the highest number of layoffs? */

Select Year(`date`), Sum(total_laid_off)
from layoffs_staging2
group by Year(`date`)
order by 1 desc;

/* QUES. Which stages of the layoff process have resulted in the highest number of employees being let go, 
and how many employees were laid off in each stage? */

Select stage, Sum(total_laid_off)
from layoffs_staging2
group by stage
order by 2 desc;

/* QUES. How much does the companies raised funds on average */

Select company, Round(Avg(funds_raised_millions)) AS avg_funds_raised
from layoffs_staging2
group by company
order by avg_funds_raised desc;

/* QUES. Identify companies with fewer resources (less than $10 million raised) 
but still had to lay off more than 50 employees & order it by number of laid off. */

Select company, total_laid_off, funds_raised_millions, year(`date`)
from layoffs_staging2
where funds_raised_millions < 10 AND total_laid_off > 50
order by 2 desc;

/* QUES. Which companies laid off employees in multiple locations? */

Select company, COUNT(DISTINCT location) AS location_count, SUM(total_laid_off) AS total_layoffs
from layoffs_staging2
group by company
having location_count > 1
order by 3 desc;

/* QUES. Analyze if there is a significant relationship between 
the percentage of employees laid off and the total funds a company raised. */

Select percentage_laid_off, funds_raised_millions
from layoffs_staging2
where percentage_laid_off IS NOT NULL AND funds_raised_millions IS NOT NULL
order by 2 desc;

/* QUES. Which industries have experienced a higher average number of layoffs 
compared to the overall average? */

Select industry, avg(total_laid_off) as avg_laid_off
from layoffs_staging2
group by industry
having avg_laid_off > (Select avg(total_laid_off) from layoffs_staging2);

/* QUES.  Analyze layoffs by country and location to find out countries where layoffs are 
concentrated in one city. */

Select country, location, COUNT(*) AS location_count, SUM(total_laid_off) AS total_layoffs
from layoffs_staging2
where total_laid_off is not null
group by country, location
having location_count = 1
order by total_layoffs desc;

/* QUES. Identify companies that laid off employees multiple times within the same year. */

Select company, Year(`date`) as layoff_year, COUNT(*) as event_count, SUM(total_laid_off) AS total_layoffs
from layoffs_staging2
where total_laid_off is not null
group by company, layoff_year
having event_count > 1
order by 4 desc;

/* QUES. Which companies have laid off more than 10% of their workforce 
while raising over $50 million in funds? */

Select company, total_laid_off, percentage_laid_off, funds_raised_millions
from layoffs_staging2
where total_laid_off is not null
and percentage_laid_off > 0.10 
and funds_raised_millions > 50;

/* QUES. Rank companies by layoffs within their industry using a window function. */

With industry_ranking as
(
Select company, industry, total_laid_off, 
DENSE_RANK() OVER (PARTITION BY industry ORDER BY total_laid_off DESC) AS industry_rank
from layoffs_staging2
where industry is not null
and total_laid_off is not null
)
Select company, industry, total_laid_off,  industry_rank
from industry_ranking
where industry_rank  <=5 ;

/* QUES. How many employees were laid off in each industry each year? */

With year_layoffs as
(
SELECT industry, YEAR(`date`) AS yr, SUM(total_laid_off) AS total_year_layoffs
FROM layoffs_staging2
GROUP BY industry, yr
)
select * from 
year_layoffs
where yr is not null
order by 2 asc;

/* QUES. How many employees were laid off each month of each year */

Select substring(`date`,1,7) as `Month`,
sum(total_laid_off) 
from layoffs_staging2
where substring(`date`,1,7) is not null
group by `Month` 
order by 1 asc;

/* QUES. What is the running total of layoffs over time, month by month? */

With Rolling_Total as
(
Select substring(`date`,1,7) as `Month`,
sum(total_laid_off) as `Sum(Total_laid_off)`
from layoffs_staging2
where substring(`date`,1,7) is not null
group by `Month` 
order by 1 asc
)
Select `Month`, `Sum(Total_laid_off)`,
sum(`Sum(Total_laid_off)`) Over(order by `Month`) as rolling_total
from Rolling_Total;

/* QUES. Which companies have laid off the most employees each year, 
and how many employees were let go by each company in each year? */

Select company, Year(`date`),
Sum(total_laid_off)
from layoffs_staging2
group by company, Year(`date`)
order by 3 desc;

/* QUES.  Which companies have consistently been among the top 5 companies 
with the highest number of layoffs each year? */

With Company_by_year (company,years,total_laid_off) as
(
Select company, Year(`date`),
Sum(total_laid_off)
from layoffs_staging2
group by company, Year(`date`)
)
Select *,
dense_rank() over(partition by years order by total_laid_off desc) as Ranking
from Company_by_year
where years is not null;

/* QUES. Which companies have been among the top 5 companies 
with the highest number of layoffs each year? */

With Company_by_year (company,years,total_laid_off) as
(
Select company, Year(`date`),
Sum(total_laid_off)
from layoffs_staging2
group by company, Year(`date`)
),
Company_Year_Rank as
(
Select *,
dense_rank() over(partition by years order by total_laid_off desc) as Ranking
from Company_by_year
where years is not null
)
Select * 
from Company_Year_Rank
where ranking<=5
;