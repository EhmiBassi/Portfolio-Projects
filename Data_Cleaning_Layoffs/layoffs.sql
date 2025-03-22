-- DATA CLEANNG ON WORLD LAYOFF DATASET SHOWING THE COMPANY, LOCATION, TOTAL PEOPLE LAID OFF, % LAID OFF ...

SELECT *
FROM layoffs;

-- 1. REMOVE DUPLICATES
-- 2. STANDARDIZE THE DATA
-- 3. NULL/BLANK VALUES
-- 4. REMOVE UNNECESSARY COLUMS

-- Creating a duplicate table so the original table can be intact
CREATE TABLE layoffs_duplicate
LIKE layoffs; 

INSERT layoffs_duplicate
SELECT *
FROM layoffs;

-- Modify query to add row number() for easy data retrieva
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, 
percentage_laid_off, date, stage, country, funds_raised_millions
) AS row_num
FROM layoffs_duplicate;


-- Create a CTE for the query above and query for row_nums > 1
WITH duplicate_cte AS
(SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions) AS row_num
FROM layoffs_duplicate
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- This shows that company's like Cazoo have duplicate rows
SELECT *
FROM layoffs_duplicate
WHERE company = 'Cazoo';

-- create a duplicate table and add a column called row_num to help delete doplicate rows
CREATE TABLE `layoffs_duplicate2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- A new table has been created and updated with data from the reference table
SELECT *
FROM layoffs_duplicate2;

INSERT INTO layoffs_duplicate2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions) AS row_num
FROM layoffs_duplicate;

-- Delete rows with duplicates
DELETE
FROM layoffs_duplicate2
WHERE row_num >1;

-- All duplicate rows are now gone
SELECT *
FROM layoffs_duplicate2
WHERE row_num >1;

-- 2. Standardizing data
-- Trim column to clear white spaces
SELECT company, TRIM(company)
FROM layoffs_duplicate2;

UPDATE layoffs_duplicate2
SET company = TRIM(company);

-- With ordering by we see rows with null values 
-- Scan through to see inconsistencies in industry names, e.g crypto and cryptocurrency
SELECT DISTINCT industry
FROM layoffs_duplicate2
ORDER BY 1;

SELECT *
FROM layoffs_duplicate2
WHERE industry LIKE 'Crypto%';

-- Update Cryptocurrency to Crypto
UPDATE layoffs_duplicate2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%'; 

SELECT DISTINCT country
FROM layoffs_duplicate2
ORDER BY 1;

-- Standardize the country column, update United states. to United states
SELECT DISTINCT country
FROM layoffs_duplicate2
WHERE country LIKE 'United States%';

UPDATE layoffs_duplicate2
SET country = 'United States'
WHERE country LIKE 'United States%'; 

-- Update the date column from text to date type
SELECT date,
STR_TO_DATE(date, '%m/%d/%Y')
FROM layoffs_duplicate2;

UPDATE layoffs_duplicate2
SET date = STR_TO_DATE(date, '%m/%d/%Y');

-- Now that date has been converted from str to date, we'll alter table to change the datatype of the original table
ALTER TABLE layoffs_duplicate2
MODIFY COLUMN date DATE;

SELECT date
FROM layoffs_duplicate2;

-- 3. Remove null/blank values 
-- First update blank columns to Null
UPDATE layoffs_duplicate2
SET industry = NULL
WHERE industry = '';

-- Remove blanks and nulls from the industry (12 rows)
SELECT *
FROM layoffs_duplicate2
WHERE industry IS NULL;

-- We'll update the blank industry columns e.g Airbnb as travel (sseing it is a travel industry) using Self-Join
SELECT *
FROM layoffs_duplicate2
WHERE company = 'Airbnb';

SELECT t1.industry, t2.industry
FROM layoffs_duplicate2 t1
JOIN layoffs_duplicate2 t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

UPDATE layoffs_duplicate2 t1
JOIN layoffs_duplicate2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

SELECT *
FROM layoffs_duplicate2
WHERE industry IS NULL;

-- All nulls have been filled using self join except  Bally's Interactive which had just a null row
SELECT *
FROM layoffs_duplicate2
WHERE company LIKE 'Bally%';

-- Airbnb industry with null values has been filled with travel 
SELECT *
FROM layoffs_duplicate2
WHERE company = 'Airbnb';


SELECT *
FROM layoffs_duplicate2
WHERE total_laid_off  IS NULL
AND percentage_laid_off IS NULL;

-- Both total_laid_off and percentage_laid_off IS NULL making the data less trustworthy
DELETE
FROM layoffs_duplicate2
WHERE total_laid_off  IS NULL
AND percentage_laid_off IS NULL;


-- 4. Remove Unnecessary columns
SELECT *
FROM layoffs_duplicate2;

ALTER TABLE layoffs_duplicate2
DROP COLUMN row_num;

SELECT *
FROM layoffs_duplicate2;














