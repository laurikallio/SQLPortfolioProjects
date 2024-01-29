Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

--  Looking at total cases vs total deaths
-- Shows likelyhood of  dying if you contract covid in specific country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

-- Looking at total cases vs population
-- shows what percentage of population got covid

Select Location, date, total_cases, population, (total_cases/population)*100 as InfectedPerCapita
From PortfolioProject..CovidDeaths
--Where location like '%states%'
order by 1,2

-- looking at countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) as [Highest infection count], max((total_cases/population)*100) as PercentPopulationInfected
From PortfolioProject..CovidDeaths
group by location, population
order by PercentPopulationInfected DESC

-- showing countries with highest death count per population

Select Location, max(cast(total_deaths as int)) as TotalDeaths
From PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeaths desc


-- LET'S BREAK THING DOWN BY CONTINENT
-- showing the continents with the highest death counts

Select continent, max(cast(total_deaths as int)) as TotalDeaths
From PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeaths desc

-- global numbers

Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2


--looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths  dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use CTE

With PopVsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths  dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, RollingPeopleVaccinated/population*100 as VaccinatedPerPopulation
from PopVsVac



-- temp table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime, 
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths  dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100 as VaccinatedPerPopulation
from #PercentPopulationVaccinated


--creating view to store data for later visualizations

Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths  dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select *
from PercentPopulationVaccinated

-- lis‰‰ vaihtoehtoisia View
-- 1. COVID KUOLEMAT MAANOSITTAIN

Create View TotalDeathsByContinent as
Select location, max(cast(total_deaths as int)) as TotalDeaths
From PortfolioProject..CovidDeaths
where continent is null
group by location


Select *
from TotalDeathsByContinent
order by TotalDeaths DESC

-- 2. rokotetut Suomessa

Create View TotalVaccinatedFinland as
select dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths  dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.location = 'finland'
--order by 2,3

Select *
from TotalVaccinatedFinland