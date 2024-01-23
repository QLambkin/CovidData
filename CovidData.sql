select * 
from PortfolioProject..CovidDeaths
order by 3,4

-- Select Data that we are using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths)/nullif(convert(float, total_cases), 0))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
WHERE location like '%states%'
order by 1,2

-- Total Cases vs Population
-- What percentage of population got Covid

Select Location, date, total_cases, population, ((CONVERT(float, total_cases))/(convert(float, population)))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
WHERE location like '%Canada%'
order by 1,2

-- Countries with the highest infection rate

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX(CONVERT(float, total_cases)/NULLIF(CONVERT(FLOAT, population), 0))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by location, population
order by PercentPopulationInfected DESC

-- Countries with highest death count percentage

SELECT location, population, MAX(cast(total_deaths as int)) as TotalDeaths, MAX(CONVERT(float, total_deaths)/NULLIF(CONVERT(FLOAT, POPULATION), 0))*100 as PercentagePopulationDead
From PortfolioProject..CovidDeaths
Group by location, population
order by PercentagePopulationDead desc

SELECT location, population, MAX(cast(total_deaths as int)) as TotalDeaths, MAX(CONVERT(float, total_deaths)/NULLIF(CONVERT(FLOAT, POPULATION), 0))*100 as PercentagePopulationDead
From PortfolioProject..CovidDeaths
WHERE continent is not null
Group by location, population
order by TotalDeaths desc

-- LETS BREAK THINGS DOWN BY CONTINENT

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeaths, MAX(CONVERT(float, total_deaths)/NULLIF(CONVERT(FLOAT, POPULATION), 0))*100 as PercentagePopulationDead
From PortfolioProject..CovidDeaths
Group by continent
order by PercentagePopulationDead desc

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeaths, MAX(CONVERT(float, total_deaths)/NULLIF(CONVERT(FLOAT, POPULATION), 0))*100 as PercentagePopulationDead
From PortfolioProject..CovidDeaths
WHERE continent is not null
Group by continent
order by TotalDeaths desc

-- SHOWING CONTINENTS WIHT THE HGIHEST DEATH COUNT

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select date, SUM(convert(float, new_cases)) as TotalCases, sum(convert(float, new_deaths)) as TotalDeaths, 
sum(CONVERT(float, new_deaths))/nullif(SUM(convert(float, new_cases)), 0)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

-- Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

