-- View and review CovidDeaths table
SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

-- View and review CovidVaccinations table
SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

-- Selecting the data that will be used
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Analyzing Total Cases vs Total Deaths in the United States

SELECT location, date, total_cases,  total_deaths, (total_deaths / total_cases) * 100 AS death_percentage 
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

-- Total Cases vs Population
SELECT location, date, population, total_cases, total_deaths, (total_cases / population)*100 AS infection_rate
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

-- Countries with higest infection rate compared to population
SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX(total_cases / population)*100 AS infection_rate
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY infection_rate DESC

-- Highest death count per population (By Country)
SELECT location, MAX(CAST(total_deaths AS int)) AS highest_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY highest_death_count DESC

-- Highest death count (By continent)
SELECT location, MAX(CAST(total_deaths AS int)) AS highest_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent is null AND location <> 'World'
GROUP BY location
ORDER BY highest_death_count DESC

-- Total number of global cases, deaths, death percentage per day
SELECT date, SUM(new_cases) AS global_cases, SUM(CAST(new_deaths AS int)) AS global_deaths, (SUM(CAST(new_deaths AS int)) / SUM(new_cases))*100 AS global_death_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1

-- GLOBAL NUMBERS: Overall number of global cases, deaths, and global death percentage
SELECT SUM(new_cases) AS global_cases, SUM(CAST(new_deaths AS int)) AS global_deaths, (SUM(CAST(new_deaths AS int)) / SUM(new_cases))*100 AS global_death_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1

-- Rolling count of new vaccinations and new total number of vaccinations per day (By country)
SELECT  d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CAST(v.new_vaccinations AS int)) 
OVER (Partition By d.location ORDER BY d.location, d.date) AS rolling_vaccination_count
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
ON d.location = v.location AND d.date = v.date
WHERE d.continent is not null
ORDER BY 2,3

-- Using CTE (common table expression) to include column that queries rolling vaccination percentage

WITH Pop_VS_Vac (continent, location, date, population, new_vaccinations, rolling_vaccination_count)
AS 
(
SELECT  d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CAST(v.new_vaccinations AS int)) 
OVER (Partition By d.location ORDER BY d.location, d.date) AS rolling_vaccination_count
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
ON d.location = v.location AND d.date = v.date
WHERE d.continent is not null
)
SELECT *, (rolling_vaccination_count / population)*100 AS vaccination_percentage
FROM Pop_VS_Vac

-- TEMP TABLE 
DROP TABLE if exists PercentPopulationVaccinated
CREATE TABLE PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_Vaccination_Count numeric
)

INSERT INTO PercentPopulationVaccinated
SELECT  d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CAST(v.new_vaccinations AS int)) 
OVER (Partition By d.location ORDER BY d.location, d.date) AS rolling_vaccination_count
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
ON d.location = v.location AND d.date = v.date
WHERE d.continent is not null

SELECT *, (rolling_vaccination_count / population)*100 AS vaccination_percentage
FROM PercentPopulationVaccinated

-- Creating Views to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT  d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CAST(v.new_vaccinations AS int)) 
OVER (Partition By d.location ORDER BY d.location, d.date) AS rolling_vaccination_count
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
ON d.location = v.location AND d.date = v.date
WHERE d.continent is not null 

CREATE VIEW GlobalNumbers AS
SELECT SUM(new_cases) AS global_cases, SUM(CAST(new_deaths AS int)) AS global_deaths, (SUM(CAST(new_deaths AS int)) / SUM(new_cases))*100 AS global_death_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
