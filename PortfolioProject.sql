SELECT * FROM 
PortfolioProject..CovidDeaths 
ORDER BY 3,4;

SELECT * FROM 
PortfolioProject.dbo.CovidVaccinations
ORDER BY 3,4;


--selecting Fields that we're going to be using: 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--Total Cases vc Total Deaths:

SELECT location, date, total_cases,total_deaths, round((total_deaths/total_cases)*100 ,2) AS DeathPercentage  --for rounding up the decimal places
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2;

--Estimate percentage of dying by the virus in my country:

SELECT location, date, total_cases,total_deaths, round((total_deaths/total_cases)*100 ,2) AS DeathPercentage  --for rounding up the decimal places
FROM PortfolioProject..CovidDeaths
WHERE location= 'India'
ORDER BY 1,2;

-- What percentage of the total population got covid:

SELECT location, date, total_cases, population, round((total_cases/population)*100,2) AS PercentcasesPerPopulation
FROM PortfolioProject..CovidDeaths
WHERE location= 'India'
ORDER BY 1,2;

--The above query, for all countries:
SELECT location, date, total_cases,population, round((total_cases/population)*100,2) AS PercentcasesPerPopulation
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2;

--Countries with highest case rates compared to the population:

SELECT distinct location, MAX(total_cases) as HighestInfectionCount, population , round(MAX((total_cases/population)*100),2) as PercentcasesPerPopulation
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY 4 desc;


--Percentage of People who Died of the virus:

SELECT location ,population, MAX(cast(total_deaths as Int)) as TotalDeathCount, MAX((total_deaths/population)*100) AS PercentDeathsPerPopulation
FROM PortfolioProject..CovidDeaths
WHERE continent is not null --in the actual table, for some records, the continent is null and the location names are actual continent names.
GROUP BY location, population
ORDER BY 4 desc ;


--Breaking Things down by Continent for Vizualisation purposes:

SELECT continent, location, MAX(cast(total_deaths as Int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null
GROUP BY continent, location
ORDER BY TotalDeathCount desc ;

-- the drill:
	--if we want to see the data Continent wise, we actually would want to prefer the *continent is null* data because that way, 
--the location names are the actual continent names and we get the cummulated data (as per table data),
--Whereas, if we do it as *not null*, the locations would include all countries
--So since we do not want to deal with countries but continents, we would make continents as null and rather have them here in location (table data).


SELECT continent, MAX(cast(total_deaths as Int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc ;

--now, we did not take location in the SELECT statement so as to avoid duplicate data in continent as well as location field.


_____________________________________________________________________________________________________________________________________________

--Continents with highest death count

SELECT continent, MAX(cast(total_deaths as Int)) as HighestDeaths
FROM PortfolioProject..CovidDeaths
GROUP BY continent
ORDER BY HighestDeaths;


--Continents with highest death count per population
SELECT continent, MAX(cast(total_deaths as Int)) as HighestDeathCount, MAX((total_deaths/population)*100) AS deathsperpopulation
FROM PortfolioProject..CovidDeaths
GROUP BY continent
ORDER BY deathsperpopulation;


--Looking at total Deaths and Total Cases WorldWide:

SELECT date, SUM(cast(new_deaths as int)) as total_deaths, SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as PercentDeaths 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY PercentDeaths;

--SUM function was used because we wanted to group our data by date and hence total_cases became SUM(new_cases) and total_deaths became SUM(new_deaths)

--the above query was for: total deaths per day globally

--for a general number worldwide, below query:

SELECT SUM(cast(new_deaths as int)) as total_deaths, SUM(new_cases) as Total_cases, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS PercentDeaths 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY PercentDeaths;

______________________________________________________________________________________________________________________________________________________
______________________________________________________________________________________________________________________________________________________

--Total Population Vs Vaccinated population

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location=vac.location
	AND dea.date=vac.date
	WHERE dea.continent is not null --all Locations of Africa except Africa location (whose continent is null) 
	ORDER BY 2,3



--To define the rolling vaccinations with each day (total vaccinated people per day in the world by country till date): we wont use total_vac column.

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)	AS RollingPeopleVaccinted
--partition by location because we want to start over when a new loc is encountered ; 
--ORDER BY cz its auto populating last col
--above will keep adding "new vccinations" with each passing "date".
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location=vac.location
	AND dea.date=vac.date
	WHERE dea.continent is not null --all Locations of Africa except Africa location (whose continent is null) 
	ORDER BY 2,3


--Now, have the MAXimum output of RollingPeoplevaccinated and divide it by population to see how many people in that country per tot pop are vaccinated
--1. 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)	AS RollingPeopleVaccinated,
(RollingPeopleVaccinated/dea.population)*100       --simply using this will throw an error, use CTE.
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location=vac.location
	AND dea.date=vac.date
	WHERE dea.continent is not null 


	--Use a CTE:
--2.
With PopvsVac (continent, location, date, population, New_vaccinations, RollingPeopleVaccinated )  --no. of columns should match the below query.
AS
(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)	AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/dea.population)*100   
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location=vac.location
	AND dea.date=vac.date
	WHERE dea.continent is not null 
)
SELECT *
FROM PopvsVac


--3.  Percent people Vaccinated per population by country.
With PopvsVac (continent, location, date, population, New_vaccinations, RollingPeopleVaccinated )  --no. of columns should match the below query.
AS
(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)	AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/dea.population)*100   
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location=vac.location
	AND dea.date=vac.date
	WHERE dea.continent is not null 
)
SELECT *, (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
FROM PopvsVac




--TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated 
(
Continent nvarchar (255), 
Location nvarchar (255), 
date datetime, 
population numeric, 
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)	AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/dea.population)*100   
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location=vac.location
	AND dea.date=vac.date
	WHERE dea.continent is not null 

	SELECT *, (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
FROM #PercentPopulationVaccinated



--CREATING A VIEW to STORE data for later vis in Tableau:

Create View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)	AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location=vac.location
	AND dea.date=vac.date
	WHERE dea.continent is not null 


SELECT * FROM PercentPopulationVaccinated
