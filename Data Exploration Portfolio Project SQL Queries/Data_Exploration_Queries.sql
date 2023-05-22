-- SELECT Data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population 
	FROM CovidDeaths$
	WHERE continent IS NOT NULL
	ORDER BY 1,2

-- LET'S SEE DATA IN CANADA
-- Looking at Total Cases vs Total Deaths
-- Shows the chances of dying if you contract covid-19 in Canada
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
	FROM CovidDeaths$
	WHERE location = 'canada'
	ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Show what percentage of population got covid-19 in Canada
SELECT location, date, total_cases, population, (total_cases/population)*100 AS infected_percentage
	FROM CovidDeaths$
	WHERE location = 'canada'
	ORDER BY 1,2

-- LET'S SEE DATA BY CONTINENT
-- Looking the continents death count
SELECT continent, MAX(CAST(total_deaths AS INT))AS total_death_count
	FROM CovidDeaths$
	WHERE continent IS NOT NULL
	GROUP BY continent
	ORDER BY total_death_count DESC

-- LET'S SEE GLOBAL DATA
-- Looking at countries with highest infection rate compared to population
SELECT location, population, 
	   MAX(total_cases)AS highest_infection_count, 
	   MAX(total_cases/population)*100 AS percent_population_infected
	FROM CovidDeaths$
	GROUP BY location, population
	ORDER BY percent_population_infected DESC

-- Looking at countries with highest death count per population
SELECT location, MAX(CAST(total_deaths AS INT))AS total_death_count
	FROM CovidDeaths$
	WHERE continent IS NOT NULL
	GROUP BY location
	ORDER BY total_death_count DESC

SELECT date, SUM(CAST(total_cases AS INT)) AS global_cases, (SUM(total_cases)/SUM(population))*100 AS infected_percentage,  SUM(CAST(total_deaths AS INT)) AS global_deaths, (SUM(CAST(total_deaths AS INT))/SUM(population))*100 AS death_percentage
	FROM CovidDeaths$
	WHERE continent IS NOT NULL 
		AND total_cases IS NOT NULL
	GROUP BY date
	ORDER BY date ASC

-- CTE
WITH pop_vs_vac(continent, location, date, population, new_vaccinations, total_vaccinations_by_country)
AS(
-- Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS total_vaccinations_by_country
	FROM CovidDeaths$ AS dea
	JOIN CovidVaccinations$ AS vac
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
		AND new_vaccinations IS NOT NULL
)

SELECT *, 
	   (total_vaccinations_by_country/population)*100 AS percentage_of_people_vaccinated
	FROM pop_vs_vac


-- TEMP TABLE
DROP TABLE IF EXISTS PercentPopulationVaccinated

CREATE TABLE PercentPopulationVaccinated(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	total_vaccinations_by_country numeric
)

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
       SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS total_vaccinations_by_country
	FROM CovidDeaths$ AS dea
	JOIN CovidVaccinations$ AS vac
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
		AND new_vaccinations IS NOT NULL

SELECT *, (total_vaccinations_by_country/population)*100
FROM PercentPopulationVaccinated


-- Creating View to store data for later visualizations
CREATE VIEW PercentPopulationVaccinatedView AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as total_vaccinations_by_country
	FROM CovidDeaths$ AS dea
	JOIN CovidVaccinations$ AS vac
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
