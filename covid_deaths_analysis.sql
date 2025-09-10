
--  1. DATA VALIDATION AND CLEANING
 SELECT COUNT(*) FROM covid_deaths;


WITH CTE AS(
    SELECT DISTINCT * FROM covid_deaths)
SELECT COUNT(*) FROM CTE;





SELECT COUNT(*) FROM covid_vaccinations; -o/p : 85171

SELECT COUNT(*) 
FROM 
    (SELECT DISTINCT * FROM covid_vaccinations) AS t2 --o/p : 85171 (No duplicates)

-- 1. total number of cases and deaths by country || united states has large number of cases and deaths
SELECT 
    [location],
    MAX(total_cases) AS total_cases,
    MAX(total_deaths) AS  total_deaths  
FROM
    covid_deaths
WHERE   
    continent IS  NOT NULL
GROUP BY
    [location]
ORDER BY
    2 DESC, 3 DESC;


-- 2. Total number of cases and deaths by continent
WITH total_cases AS (
    SELECT 
     [location],
     MAX(total_cases) AS total_cases,
     MAX(total_deaths) AS total_deaths
FROM
    covid_deaths
WHERE   
    continent IS NULL
    AND [location] NOT IN ('World', 'International')
GROUP BY
    [location],
    continent
)
SELECT *, ROUND((total_deaths/total_cases)*100, 2)AS death_percenatage
FROM    
    total_cases
ORDER BY
    2 DESC;

-- Deeper look into specific Values 
SELECT 
    location, continent, SUM(total_cases) AS total_cases, SUM(total_deaths) AS total_deaths
FROM 
    covid_deaths
WHERE
    continent = 'Europe'
GROUP BY    
    location, continent
ORDER BY 3 DESC,4 DESC;

-- total_cases and deaths 
SELECT MAX(total_cases) AS totalcases, MAX(total_deaths) AS total_deaths
FROM covid_deaths
WHERE 
    continent = 'Europe';


-- Showing total deaths in each country (the top -5 countries with highest number of deaths are US, Brazil, Mexico, India, UK)
SELECT  TOP 5
     [location],
     MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM
    covid_deaths
WHERE   
    continent IS NOT NULL
    AND [location] != 'World'
GROUP BY
    [location]
ORDER BY
    total_death_count DESC;


-- total_case V/s deaths || death_percentage indicates the chances of losing life at that time (date)
SELECT 
    [location], date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,2) AS death_percentage
FROM 
    covid_deaths
WHERE 
    location NOT IN ('World', 'International')
ORDER BY 
   1,3 DESC;


--Infection percentage vs population (United States example)
SELECT
    [location], date, [population], ROUND((total_cases/population) * 100 ,2)AS Infected_people_percentage
FROM
    covid_deaths
WHERE   
    [location] LIKE '%states%'
ORDER BY
    1,2;

-- total_case v/s popultaion shows what % of people got covid - by country
SELECT 
    [location],
    Infected_people_percentage
FROM 
    (SELECT [location], (COUNT(total_cases)/SUM(population)) Infected_people_percentage
     FROM covid_deaths
     GROUP BY 
        location
     ) AS t2
ORDER BY
    1,2;




SELECT 
    YEAR(date),SUM(total_cases) AS total_cases, SUM(total_deaths) AS total_deaths, 100 * (total_cases/SUM(total_cases)) AS total_cases_percenatge, 100 * (total_deaths/SUM(total_deaths)) AS death_percenatage
FROM 
    covid_deaths
GROUP BY YEAR(date)
ORDER BY
    YEAR(date) DESC;


-- What % overall population got affected by COVID ?
SELECT 
  total_cases, population, (total_cases/population) * 100 AS infected_by_covid  
FROM
    covid_deaths
ORDER BY
    infected_by_covid; 


-- 
SELECT
    [location], date, total_cases, population, (total_cases/population)*100 AS per
FROM
    covid_deaths
WHERE
    [location] = 'India'
ORDER BY
    [date];

-- -- countries with highest infection rate compared to population per country
SELECT
   [location], population, MAX(total_cases) AS highest_infecion_count, MAX((total_cases/population)*100) AS percenatge_infected
FROM
    covid_deaths
GROUP BY    
    [location],
    population
ORDER BY
     percenatge_infected DESC, highest_infecion_count DESC;


---- countries with highest death count 
SELECT  
    [location], MAX(CAST(total_deaths AS INT)) AS total_death_count -- varchar is inavlid to use MAX
FROM 
    covid_deaths
WHERE continent IS NOT NULL  -- eliminating continets (continets doesnt have any continents)
GROUP BY 
    [location]
ORDER BY
    2 DESC;


---  Breaking things by continent
-- Total deaths in each continent
SELECT 
    [location], MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM 
    covid_deaths
WHERE 
    continent IS NULL
    AND location NOT IN ('European Union', 'World', 'International')
GROUP BY 
    location
ORDER BY 
    2 DESC;


--global numbers
-- total cases, deaths
SELECT  
    SUM(total_cases) AS total_cases,
    SUM(total_deaths) AS total_deaths,
    SUM(total_cases)/SUM(total_deaths) AS death_percenatage
FROM
    covid_deaths
ORDER BY    
    3;

-- Global population vs infection rate
SELECT  
    [location], [population], MAX(total_cases) AS high_infecion_count, MAX(total_deaths/population)*100 AS population_infected_rate
FROM 
    covid_deaths
GROUP BY 
    [location], [population]
ORDER BY
    4 DESC;



-- continents
SELECT  
   continent, MAX(CAST(total_deaths AS INT)) AS total_death_count 
FROM 
    covid_deaths
WHERE continent IS NOT NULL 
GROUP BY 
   continent
ORDER BY
    2 DESC;


-- 

-- JOINS
-- total Populatiob V/S vaccination
SELECT 
    t1.continent, t1.location, t1.date, t1.population, t2.new_vaccinations
FROM 
    covid_deaths AS t1
    LEFT JOIN covid_vaccinations AS t2
    ON t1.location = t2.location
    AND t1.date = t2.date
WHERE 
    t1.continent IS NOT NULL
ORDER BY 
    5 DESC;


-- Cumulative vaccinations using window function
SELECT  
    t1.continent, t1.location, t1.date, t1.population, t2.new_vaccinations, SUM(CONVERT(int, t2.new_vaccinations)) OVER (PARTITION BY t1.location ORDER BY t1.date, t1.location) AS total_vaccinations
FROM 
    covid_deaths AS t1
    LEFT JOIN covid_vaccinations AS t2
    ON t1.location = t2.location
    AND t1.date = t2.date 
WHERE 
    t1.continent IS NOT NULL
ORDER BY 
    2,3;


-- CTE for rolling vaccination totals
WITH populationvsvaccinations AS
(
SELECT  
    t1.continent, t1.location, t1.date, t1.population, t2.new_vaccinations, SUM(CONVERT(int, t2.new_vaccinations)) OVER (PARTITION BY t1.location ORDER BY t1.date, t1.location) AS rolling_people_vaccinations
FROM 
    covid_deaths AS t1
    LEFT JOIN covid_vaccinations AS t2
    ON t1.location = t2.location
    AND t1.date = t2.date 
WHERE 
    t1.continent IS NOT NULL
)

SELECT *, (rolling_people_vaccinations/population) * 100 AS percentage_vcaccinated_people
FROM populationvsvaccinations; 

 

-- CREATING VIEW fro later visulaizations
CREATE VIEW vaccinated_population AS 
SELECT  
    t1.continent, t1.location, t1.date, t1.population, t2.new_vaccinations, SUM(CONVERT(int, t2.new_vaccinations)) OVER (PARTITION BY t1.location ORDER BY t1.date, t1.location) AS total_vaccinations
FROM 
    covid_deaths AS t1
    LEFT JOIN covid_vaccinations AS t2
    ON t1.location = t2.location
    AND t1.date = t2.date 
WHERE 
    t1.continent IS NOT NULL;
 

















