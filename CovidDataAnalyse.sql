--Queries using Trsact-SQL SSMS, prepare for Tableau viz

--STEP ONE: CREATE FOUR TABLES FOR TARGETED NUMBERS

-- #1. total_cases | total_deaths | DeathPercentage 
-- note: parts of the CovidDeaths$ Table organised by continent not countries, should be eliminated in this step

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%' --this is checking process, not used in the final report
where continent is not null 
--Group By date --this is checking process, not used in the final report
order by 1,2

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2

--#1 output: 
total_cases	total_deaths	DeathPercentage
236035422	4819522	        2.04186386905945



-- #2.  location | TotalDeathCount

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

--#2 Output:
location	TotalDeathCount
Europe	        1242961
South America	1149664
Asia		1137236
North America	1074474
Africa		212886
Oceania		2301


-- #3. location | population | HighestInfectionCount | PercentPopulationInfected


Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

--#3 Output (limit 6):
Location	Population	HighestInfectionCount	PercentPopulationInfected
Seychelles	98910		21626			21.8643210999899
Montenegro	628051		133767			21.2987480316089
Andorra		77354		15284			19.7585128112315
San Marino	34010		5460			16.0541017347839
Czechia		10724553	1696016			15.8143281123232
Bahrain		1748295		275394			15.7521470918809


-- #4. location | population | date | HighestInfectionCount | PercentPopulationInfected

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc

--#4 Output (limit 6):
Seychelles	98910	2021-10-06 00:00:00.000	21626	21.8643210999899
Seychelles	98910	2021-10-04 00:00:00.000	21556	21.7935496916389
Seychelles	98910	2021-10-05 00:00:00.000	21556	21.7935496916389
Seychelles	98910	2021-10-01 00:00:00.000	21507	21.7440097057931
Seychelles	98910	2021-10-02 00:00:00.000	21507	21.7440097057931
Seychelles	98910	2021-10-03 00:00:00.000	21507	21.7440097057931


--STEP TWO: CHECK AND CLEAN EXCEL TABLES
-- Save above info into Excel, and change #3 Null to 0, modify #4 date column into date type

--STEP THREE: IMPORT TABLES INTO TABLEAU
-- adding decimals to death percentage to make it more accurate

![image](https://user-images.githubusercontent.com/89245931/136658247-4bdab476-e9ac-4cee-8116-313e59f8f216.png)










----Below are orginally draft version, for checking the thinking process and other insights ----

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
