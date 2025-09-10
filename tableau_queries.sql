--Tableau
SELECT  
    SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, (SUM(CAST(total_deaths AS INT))/SUM(total_cases) * 100) AS death_percenatage
FROM 
    covid_deaths
WHERE 
    continent IS NOT NULL
ORDER BY    
    1,2;



SELECT  
    location, COALESCE(SUM(CAST(new_deaths AS INT)) ,0) AS total_death_count
FROM    
    covid_deaths
WHERE
    location NOT IN ('World', 'International', 'European Union')
    AND continent IS NULL
GROUP BY
    [location]
ORDER BY    
    total_death_count DESC;


--
SELECT
    [location], COALESCE([population],0)AS population,COALESCE(MAX(total_cases), 0) AS highest_infecion_count, COALESCE(MAX(total_cases/population)*100, 0) AS percent_population_infected
FROM    
    covid_deaths
WHERE location NOT IN ('world', 'International', 'Eurpoean Union')
GROUP BY    
    location, population
ORDER BY 
    percent_population_infected DESC;



--
SELECT  
    location, COALESCE(population,0)AS population, date, COALESCE(MAX(total_cases),0) AS highest_infection_count, COALESCE(MAX(total_cases/population)*100, 0) AS percent_population_infected
FROM    
   covid_deaths
GROUP BY 
    location, population, date
ORDER BY 
    percent_population_infected DESC;

