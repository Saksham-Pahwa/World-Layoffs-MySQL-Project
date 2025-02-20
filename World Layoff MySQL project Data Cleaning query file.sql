-- Data Cleaning


Select * from layoffs;

-- Things we'll do before starting the analysis :
-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null Values
-- 4. Remove any Columns or Rows (if required)


/* Performing Step 1 : Removing Duplicates */


Create Table layoffs_staging
Like layoffs; 

Insert layoffs_staging
Select * from layoffs;

Select * from layoffs_staging;

Select *,
ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, 
stage, country, funds_raised_millions) as row_numb
from layoffs_staging;

WITH duplicate_cte as
(
Select *,
ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, 
stage, country, funds_raised_millions) as row_numb
from layoffs_staging
)
Select * from duplicate_cte
where row_numb >1 ;

-- Verfing the results on the above basis 

Select * from layoffs_staging
where company = 'Casper' ;

-- Its clearly shows that this method works and gives our desired results we needed to find the duplicates

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row__numb` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

Select * from layoffs_staging2;

INSERT INTO layoffs_staging2
Select *,
ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, 
stage, country, funds_raised_millions) as row_numb
from layoffs_staging ;

SET SQL_SAFE_UPDATES = 0;

DELETE
from layoffs_staging2
where row__numb > 1 ;

Select * from layoffs_staging2
where row__numb > 1 ;

/* Performing Step 2 : that is Standardizing the data */


-- Triming the extra spaces from company column.

Select company, trim(company) from layoffs_staging2;

Update layoffs_staging2
set company = trim(company);

Select distinct industry
from layoffs_staging2
order by 1;

/* As we can see that crypto industry has three different types Crypto,Cryto Currrency, CryptoCurrency so we have 
to update this any one */

Select * from layoffs_staging2
where industry like 'Crypto%' ;

Update layoffs_staging2
set industry = 'Crypto'
where industry like 'Crypto%' ;

Select distinct industry
from layoffs_staging2;

-- Checking any other discrepancies in the location data like we did in industry & company

Select distinct location
from layoffs_staging2
order by 1;

-- By checking we got to see some of it and we'll fix these now

Select * from layoffs_staging2
where location like 'DÃ¼sseldorf%' ;

Update layoffs_staging2
set location = 'Düsseldorf'
where location like 'DÃ¼sseldorf%' ;

Select * from layoffs_staging2
where location like 'FlorianÃ³polis' ;

Update layoffs_staging2
set location = 'Florianópolis'
where location like 'FlorianÃ³polis' ;

Select * from layoffs_staging2
where location like 'MalmÃ¶' ;

Update layoffs_staging2
set location = 'Malmö'
where location like 'MalmÃ¶' ;

-- We managed to fix all the discrepancie we saw in the location

-- Now repeating the process for all the columns for standardizing

Select distinct country
from layoffs_staging2
order by 1;

Select * from layoffs_staging2
where country like 'United States%'
order by 1;

Select distinct country , Trim(Trailing '.' from country)
from layoffs_staging2
order by 1;

Update layoffs_staging2
set country = Trim(Trailing '.' from country)
where country like 'United States%' ;

/* Now we will address the issue of the date column being incorretly formatted as text. We'll convert it into the
appropriate date format to ensure accurate data analysis & time-based operations */

Select `date`,
str_to_date( `date` , '%m/%d/%Y')
from layoffs_staging2;

Update layoffs_staging2
set date = str_to_date( `date` , '%m/%d/%Y');

Alter table layoffs_staging2
Modify column `date` date;

/* Performing Step 3 : Handling Null Values */


Select * from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

Select distinct industry
from layoffs_staging2;

-- We have a null and missing values here

Select *
from layoffs_staging2
where industry  is null
or industry = '';

-- Now we'll set the blank values with null as its convenient to update them with desired values

Update layoffs_staging2
set industry = null
where industry = '';

Select * from layoffs_staging2
where company = 'Airbnb' ;

Select * from  layoffs_staging2 t1
JOIN layoffs_staging2 t2
	on t1.company = t2.company
where (t1.industry is null OR t1.industry = '')
AND t2.industry is not null;

Update layoffs_staging2 t1
JOIN layoffs_staging2 t2
	on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null
and t2.industry is not null;

/* Prforming Step 4 : Removing rows and columns that are not required  */

Select * from layoffs_staging2;

Select * from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

/* These values are null cant be filled with any replaceable values or can not be calculated  as nothing related 
to it given so we'll delete them */

Delete
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

-- Now deleting row_num column as its not of any use

Alter table 
layoffs_staging2
Drop column row__numb;

Select * from layoffs_staging2;