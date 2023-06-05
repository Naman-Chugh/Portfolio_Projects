SELECT *
FROM Covid_Deaths
ORDER BY location,date

SELECT *
FROM Covid_Vaccinations
ORDER BY location,date

--SELECT column_name, data_type
--FROM information_schema.columns
--WHERE table_name = 'Covid_Deaths'


-- TOTAL CASES VS POPULATION (WHAT PERCENTAGE OF PEOPLE GOT COVID?)
SELECT location, date, total_cases, population, (total_cases/population)*100 AS Percentage_Population_Infected
FROM Covid_Deaths
WHERE location LIKE 'India' 
ORDER BY location, date 


--TOTAL DEATH VS TOTAL CASES (WHAT PERCENTAGE OF PEOPLE WHO GOT COVID DIED?)
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM Covid_Deaths
WHERE location LIKE 'India'
ORDER BY location, date


--TOTAL CASES VS POPULATION (WHICH COUNTRIES HAD HIGHEST INFECTION RATE?)
SELECT location, MAX(total_cases) AS Highest_Infection_Count, population, MAX((total_cases/population))*100 as Max_Infection_Rate
FROM Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY Max_Infection_Rate DESC


--TOTAL DEATH VS POPULATION (WHAT PERCENTAGE OF COUNTRIES' POPULATION DIED?)
SELECT location, MAX(total_deaths) AS Highest_Death_Count, population, MAX((total_deaths/population))*100 as Max_Death_Rate
FROM Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY Max_Death_Rate DESC


--TOTAL CASES VS CONTINENT (WHICH CONTINENT HAS THE HIGHEST NUMBER OF CASES?)
SELECT location, MAX(total_cases) AS Total_Cases_Continent
FROM Covid_Deaths
WHERE continent IS NULL AND location NOT LIKE '%income'
GROUP BY location
ORDER BY Total_Cases_Continent DESC


--GLOBAL DATA 
SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths,
CASE
	WHEN SUM(new_cases)=0 THEN NULL
	ELSE (SUM(new_deaths)/SUM(new_cases))*100
END AS Death_Percentage
FROM Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY total_deaths DESC


--TOTAL POPULATION VS VACCINATION
SELECT Dth.continent, Dth.location, Dth.date, Dth.population, Vacc.new_vaccinations, SUM(CAST(Vacc.new_vaccinations AS float)) OVER (PARTITION BY Dth.location 
ORDER BY Dth.location, Dth.date) AS Rolling_People_Vaccinated
--,(Rolling_People_Vaccinated/population)*100
FROM Covid_Deaths AS Dth
JOIN Covid_Vaccinations AS Vacc
ON Dth.location = Vacc.location AND Dth.date = Vacc.date
WHERE Dth.continent IS NOT NULL
ORDER BY Dth.location, Dth.date


--USING CTE
WITH POP_VS_VACC(Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated)
AS
(
SELECT Dth.continent, Dth.location, Dth.date, Dth.population, Vacc.new_vaccinations, SUM(CAST(Vacc.new_vaccinations AS float)) OVER (PARTITION BY Dth.location 
ORDER BY Dth.location, Dth.date) AS Rolling_People_Vaccinated
--,(Rolling_People_Vaccinated/population)*100
FROM Covid_Deaths AS Dth
JOIN Covid_Vaccinations AS Vacc
ON Dth.location = Vacc.location AND Dth.date = Vacc.date
WHERE Dth.continent IS NOT NULL
)
SELECT *, (Rolling_People_Vaccinated/Population)*100 AS Percent_People_Vaccinated
FROM POP_VS_VACC