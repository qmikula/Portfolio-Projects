SELECT *
FROM CovidDeaths$
WHERE continent is NOT NULL
ORDER BY 3, 4

--SELECT *
--FROM CovidVaccinations$
--ORDER BY 3, 4


-- Select data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths$
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
-- Filtering down to only include the United States

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths$
WHERE location like '%states%'
ORDER BY 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid

SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentPopulationInfected
FROM CovidDeaths$
--WHERE location like '%states%'
ORDER BY 1,2


-- Looking at Countries with Highest Infection Rate compared to Population
-- Created aggregate functions to see the max cases and max % of cases.
-- Andorra had the highest % infected at just over 17% compared to the USA at just short of 10%.

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM CovidDeaths$
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths$
--WHERE location like '%states%'
WHERE continent is NOT NULL
GROUP BY location
ORDER BY TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT
-- Europe had the most deaths from covid at just over 1 million.

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths$
--WHERE location like '%states%'
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc


-- Showing continents with highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths$
--WHERE location like '%states%'
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc


-- GLOBAL NUMBERS
-- Created three aggregated functions to get the sum of new cases, sum of total deaths, and sum of new deaths / sum of new cases to get a death percentage.

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths$
--WHERE location like '%states%'
WHERE continent is NOT NULL
GROUP BY date
ORDER BY 1,2


-- Looking at Total Population vs Vaccinations
-- Converted the aggregate function to an integer rather than casting it as an integer.

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
   ON dea.location = vac.location
   and dea.date = vac.date
 WHERE dea.continent is NOT NULL
 ORDER BY 2,3


 -- USE CTE
 -- Cannot use a column that you just created to create another column, so using a CTE to summarize the whole query.

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
   ON dea.location = vac.location
   and dea.date = vac.date
 WHERE dea.continent is NOT NULL
 --Order By 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
   ON dea.location = vac.location
   and dea.date = vac.date
 WHERE dea.continent is NOT NULL
 --Order By 2,3

 SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
   ON dea.location = vac.location
   and dea.date = vac.date
 WHERE dea.continent is NOT NULL
 --ORDER BY 2,3


-- Using View to quickly query the data

SELECT *
FROM PercentPopulationVaccinated
