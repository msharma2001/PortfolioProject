SELECT *
FROM CovidDeaths$;

SELECT *
FROM COVIDVACCINATIONS;

---SELECT THE DATA WE ARE GOING TO BE USING

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths$;

---TOTAL CASES VS TOTAL DEATHS
SELECT Location, total_cases, total_deaths, (total_deaths/ total_cases) *100 AS DeathPercentage
FROM CovidDeaths$
ORDER BY 1, 2;

---CHECK FOR CANADA---
SELECT Location, date, total_cases, total_deaths, (total_deaths/ total_cases) *100 AS DeathPercentage
FROM CovidDeaths$
WHERE Location = 'Canada'
ORDER BY 2;

----LOOKING AT TOTAL CASES VS POPULATION
SELECT Location, date, total_cases, total_deaths,population, (total_deaths/ population) *100 AS InfectedPopulation
FROM CovidDeaths$
WHERE Location = 'Canada'
ORDER BY 2;

------LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION
SELECT Location, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/ population)) *100 AS InfectedPopulation
FROM CovidDeaths$
GROUP BY Location, population
ORDER BY InfectedPopulation DESC; 

------LOOKING AT COUNTRIES WITH HIGHEST DEATH RATE COMPARED TO POPULATION
SELECT Location, MAX(CAST(total_deaths AS INT)) AS DeathCount
FROM CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY Location, population
ORDER BY DeathCount DESC; 


---BREAKING IT DOWN BY CONTINENTS----
SELECT continent, MAX(CAST(total_deaths AS INT)) AS DeathCount
FROM CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY DeathCount DESC; 


---- GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS Total_cases, SUM(CAST(new_deaths AS INT)) AS Total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases) * 100 as DeathPercentage--total_cases, total_deaths, (total_deaths/ total_cases) *100 AS DeathPercentage
FROM CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2;

-----LOOKING AT TOTAL POPULATION VS VACCINATIONS

SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations AS int)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
FROM CovidDeaths$ cd
JOIN Covidvaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE CD.continent IS NOT NULL
	ORDER BY 2,3;


----USE CTE

WITH PopvsVac
AS
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations AS int)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
FROM CovidDeaths$ cd
JOIN Covidvaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE CD.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population) * 100
FROM PopvsVac;


---USING TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations AS int)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
FROM CovidDeaths$ cd
JOIN Covidvaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE CD.continent IS NOT NULL;

SELECT *, (RollingPeopleVaccinated/ Population) * 100
FROM #PercentPopulationVaccinated;

---CREATE VIEW TO STORE DATA FOR LATER VISUALIZATION

CREATE VIEW PercentPopulationVaccinated AS

SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations AS int)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
FROM CovidDeaths$ cd
JOIN Covidvaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE CD.continent IS NOT NULL;

SELECT *
FROM PercentPopulationVaccinated
