SELECT *
FROM PortfolioPoject..CovidDeaths$
ORDER BY 3,4;

SELECT *
FROM PortfolioPoject..CovidVaccinations$
ORDER BY 3,4;

--Select data that we goig to be using
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioPoject..CovidDeaths$
ORDER BY 1,2

--Looking at Total cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioPoject..CovidDeaths$
WHERE location like '%china'
AND continent is not null
ORDER BY 1,2

--looking at total cases vs population
-- shows what percentage of population get Covid
SELECT Location, date, total_cases, population, (total_cases/population)*100 AS Case_Percentage
FROM PortfolioPoject..CovidDeaths$
--WHERE location like '%states%'
WHERE continent is not null
ORDER BY 1,2

-- Looking at Countries with Highest infection rate compared to population
SELECT Location, population, MAX(total_cases) as HighestInfactionCount,  MAX((total_cases/population))*100 AS maxCase_Percentage
FROM PortfolioPoject..CovidDeaths$
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location, population
ORDER BY maxCase_Percentage DESC


-- SHOWING COUNTRIES WITH highest Death count per population
SELECT * FROM CovidDeaths$
WHERE continent is null
--location | population | total_deaths DESC
SELECT location,  max (cast(total_deaths as int)) AS max_totalDeaths
FROM CovidDeaths$
WHERE continent is not null

GROUP BY location
ORDER BY max_totalDeaths  DESC



-- let's break things down by continent
-- Showing the continent with the highest death count per population

SELECT continent,  max (cast(total_deaths as int)) AS max_totalDeaths
FROM CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY max_totalDeaths  DESC


-- Global numbers

SELECT  --date, 
	SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
		SUM(cast(New_deaths as int))/SUM(New_cases)*100 AS DeathPercentage
FROM PortfolioPoject..CovidDeaths$
--WHERE location like '%states%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

--looking at total population vs vaccinations
-- USE CTE
WITH PopvsVac (Continent, Location, Date, Population, 
	new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population,
	vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) 
	over (Partition by dea.location order by dea.location,
		dea.date) AS RollingPeopleVaccinated
		--, (RollingPeopleVaccinated/population) *100
FROM PortfolioPoject..CovidDeaths$ dea
JOIN PortfolioPoject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- TEMP TABLE


DROP TABLE IF exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population,
	vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) 
	over (Partition by dea.location order by dea.location,
		dea.date) AS RollingPeopleVaccinated
		--, (RollingPeopleVaccinated/population) *100
FROM PortfolioPoject..CovidDeaths$ dea
JOIN PortfolioPoject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3


SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Creating Viewto store data for later visulalisations

CREATE View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population,
	vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) 
	over (Partition by dea.location order by dea.location,
		dea.date) AS RollingPeopleVaccinated
		--, (RollingPeopleVaccinated/population) *100
FROM PortfolioPoject..CovidDeaths$ dea
JOIN PortfolioPoject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3


SELECT * 
FROM PercentPopulationVaccinated
