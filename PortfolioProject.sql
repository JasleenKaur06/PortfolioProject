select * from 
PortfolioProject..CovidDeaths 
order by 3,4;

select * from 
PortfolioProject.dbo.CovidVaccinations
order by 3,4;


--Selecting Fields that we're going to be using: 

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

--Total Cases vc Total Deaths:

select location, date, total_cases,total_deaths, round((total_deaths/total_cases)*100 ,2) as DeathPercentage  --for rounding up the decimal places
from PortfolioProject..CovidDeaths
order by 1,2;

--Estimate percentage of dying by the virus in my country:

select location, date, total_cases,total_deaths, round((total_deaths/total_cases)*100 ,2) as DeathPercentage  --for rounding up the decimal places
from PortfolioProject..CovidDeaths
where location= 'India'
order by 1,2;

-- What percentage of the total population got covid:

select location, date, total_cases, population, round((total_cases/population)*100,2) as PercentcasesPerPopulation
from PortfolioProject..CovidDeaths
where location= 'India'
order by 1,2;

--The above query, for all countries:
select location, date, total_cases,population, round((total_cases/population)*100,2) as PercentcasesPerPopulation
from PortfolioProject..CovidDeaths
order by 1,2;

--Countries with highest case rates compared to the population:

select distinct location, max(total_cases) as HighestInfectionCount, population , round(MAX((total_cases/population)*100),2) as PercentcasesPerPopulation
from PortfolioProject..CovidDeaths
group by location, population
order by 4 desc;


--Percentage of People who Died of the virus:

select location ,population, Max(cast(total_deaths as Int)) as TotalDeathCount, MAX((total_deaths/population)*100) as PercentDeathsPerPopulation
from PortfolioProject..CovidDeaths
where continent is not null --in the actual table, for some records, the continent is null and the location names are actual continent names.
group by location, population
order by 4 desc ;


--Breaking Things down by Continent for Vizualisation purposes:

select continent, location, Max(cast(total_deaths as Int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is null
group by continent, location
order by TotalDeathCount desc ;

-- the drill:
	--if we want to see the data Continent wise, we actually would want to prefer the *continent is null* data because that way, 
--the location names are the actual continent names and we get the cummulated data (as per table data),
--whereas, if we do it as *not null*, the locations would include all countries
--So since we do not want to deal with countries but continents, we would make continents as null and rather have them here in location (table data).


select continent, Max(cast(total_deaths as Int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc ;

--now, we did not take location in the select statement so as to avoid duplicate data in continent as well as location field.


_____________________________________________________________________________________________________________________________________________

--Continents with highest death count

select continent, max(cast(total_deaths as Int)) as HighestDeaths
from PortfolioProject..CovidDeaths
group by continent
order by HighestDeaths;


--Continents with highest death count per population
select continent, max(cast(total_deaths as Int)) as HighestDeathCount, max((total_deaths/population)*100) as deathsperpopulation
from PortfolioProject..CovidDeaths
group by continent
order by deathsperpopulation;


--Looking at total Deaths and Total Cases WorldWide:

select date, sum(cast(new_deaths as int)) as total_deaths, sum(new_cases) as Total_cases, sum(cast(new_deaths as int))/sum(new_cases)*100 as PercentDeaths 
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by PercentDeaths;

--sum function was used because we wanted to group our data by date and hence total_cases became sum(new_cases) and total_deaths became sum(new_deaths)

--the above query was for: total deaths per day globally

--for a general number worldwide, below query:

select sum(cast(new_deaths as int)) as total_deaths, sum(new_cases) as Total_cases, sum(cast(new_deaths as int))/sum(new_cases)*100 as PercentDeaths 
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by PercentDeaths;

______________________________________________________________________________________________________________________________________________________
______________________________________________________________________________________________________________________________________________________

--Total Population Vs Vaccinated population

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	ON dea.location=vac.location
	AND dea.date=vac.date
	where dea.continent is not null --all Locations of Africa except Africa location (whose continent is null) 
	order by 2,3



--To define the rolling vaccinations with each day (total vaccinated people per day in the world by country till date): we wont use total_vac column.

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)	as RollingPeopleVaccinted
--partition by location because we want to start over when a new loc is encountered ; 
--order by cz its auto populating last col
--above will keep adding "new vccinations" with each passing "date".
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	ON dea.location=vac.location
	AND dea.date=vac.date
	where dea.continent is not null --all Locations of Africa except Africa location (whose continent is null) 
	order by 2,3


--Now, have the MAXimum output of RollingPeoplevaccinated and divide it by population to see how many people in that country per tot pop are vaccinated
--1. 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)	as RollingPeopleVaccinated,
(RollingPeopleVaccinated/dea.population)*100       --simply using this will throw an error, use CTE.
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	ON dea.location=vac.location
	AND dea.date=vac.date
	where dea.continent is not null 


	--Use a CTE:
--2.
With PopvsVac (continent, location, date, population, New_vaccinations, RollingPeopleVaccinated )  --no. of columns should match the below query.
as
(
	select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)	as RollingPeopleVaccinated
--(RollingPeopleVaccinated/dea.population)*100   
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	ON dea.location=vac.location
	AND dea.date=vac.date
	where dea.continent is not null 
)
select *
from PopvsVac


--3.  Percent people Vaccinated per population by country.
With PopvsVac (continent, location, date, population, New_vaccinations, RollingPeopleVaccinated )  --no. of columns should match the below query.
as
(
	select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)	as RollingPeopleVaccinated
--(RollingPeopleVaccinated/dea.population)*100   
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	ON dea.location=vac.location
	AND dea.date=vac.date
	where dea.continent is not null 
)
select *, (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
from PopvsVac




--TEMP TABLE

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated 
(
Continent nvarchar (255), 
Location nvarchar (255), 
date datetime, 
population numeric, 
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)	as RollingPeopleVaccinated
--(RollingPeopleVaccinated/dea.population)*100   
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	ON dea.location=vac.location
	AND dea.date=vac.date
	where dea.continent is not null 

	select *, (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
from #PercentPopulationVaccinated



--CREATING A VIEW to STORE data for later vis in Tableau:

Create View PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)	as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	ON dea.location=vac.location
	AND dea.date=vac.date
	where dea.continent is not null 


select * from PercentPopulationVaccinated