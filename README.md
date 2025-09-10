# covid19-trends-visualization 
[View Tableau Dashboard](https://public.tableau.com/app/profile/mansa.chepuri/viz/covid_data_analysis_17574570006320/Dashboard1)
This analysis provides a comprehensive overview of COVID-19 cases, deaths, and vaccination trends globally.
The year 2021 experienced the highest surge in infections and fatalities, with the United States, India, Brazil, Mexico, and the UK being the most affected countries.
An interactive dashboard was developed to visualize key metrics, including case counts, death rates, infection percentages, and vaccination progress over time.

### Data Validation & Cleaning
1. Total number of cases and deaths by country || united states has large number of cases and deaths
``` sql
SELECT 
     [location],
     SUM(total_cases) AS total_cases,
     SUM(total_deaths) AS total_deaths
FROM
    covid_deaths
WHERE   
    continent IS  NOT NULL
GROUP BY
    [location],
    continent
ORDER BY
    total_cases DESC,
    total_deaths DESC; 
```

### cases and deaths by country/continent
2. Total number of cases and deaths by continent  
``` sql
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
```

- Deeper look into specific Values 
``` sql 
SELECT 
    location, continent, SUM(total_cases) AS total_cases, SUM(total_deaths) AS total_deaths
FROM 
    covid_deaths
WHERE
    continent = 'Europe'
GROUP BY    
    location, continent
ORDER BY 3 DESC,4 DESC; 
```

- total_cases and deaths 
``` sql 
SELECT MAX(total_cases) AS totalcases, MAX(total_deaths) AS total_deaths
FROM covid_deaths
WHERE 
    continent = 'Europe';
```


### Top countries by cases, deaths, infection_rate
3. Showing total deaths in each country (the top -5 countries with highest number of deaths are US, Brazil, Mexico, India, UK)
``` sql 
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
``` 

4. total_case V/s deaths || dCase vs Death ratio (Death percentage by date per country)
``` sql
SELECT 
    [location], date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,2) AS death_percentage
FROM 
    covid_deaths
WHERE 
    location NOT IN ('World', 'International')
ORDER BY 
   1,3 DESC;
```


6. Countries with highest infection rates
``` sql
SELECT
   [location], population, MAX(total_cases) AS highest_infecion_count, MAX((total_cases/population)*100) AS percenatge_infected
FROM
    covid_deaths
GROUP BY    
    [location],
    population
ORDER BY
     percenatge_infected DESC, highest_infecion_count DESC;
```

8. Countries with highest death count
``` sql
SELECT  
    [location], MAX(CAST(total_deaths AS INT)) AS total_death_count -- varchar is inavlid to use MAX
FROM 
    covid_deaths
WHERE continent IS NOT NULL  
    [location]
ORDER BY
    2 DESC;
```


### VACCINATION ANALYSIS
- Cumulative vaccinations 
``` sql
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
```


> For detailed queries and data exploration, please refer to the accompanying .sql file.

