/*
COVID-19 DATA EXPLORATION

Skills Used: Aggregate Functions, Windows Functions, Joins, CTE's, Converting Data Types, Creating Views
*/

Select *
From CovidProject..CovidDeaths
Where continent is not null
Order by 3, 4

Select *
From CovidProject..CovidVaccinations
Order by 3, 4

-- Selection of data to start with
Select location, date, total_cases, new_cases, total_deaths, population
From CovidProject..CovidDeaths
Order by 1, 2

-- Total Cases vs Total Deaths
-- Shows likelihood of individual dying if contracted covid in their country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidProject..CovidDeaths
Order by 1, 2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid-19
Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From CovidProject..CovidDeaths
Order by 1, 2

-- Countries with Highest Infection Rate compared to Population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From CovidProject..CovidDeaths
Group by location, Population
Order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc

-- NUMBERS BY CONTINENT
-- Shows Continents with Highest Death Count per Population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc

-- GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidProject..CovidDeaths
Where continent is not null
Order by 1, 2

-- Shows global numbers by date
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidProject..CovidDeaths
Where continent is not null
Group by date
Order by 1, 2


-- Looking at Total Population vs Vaccinations
-- Shows Percentage of Population that has received at least one COVID-19 Vaccine
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.date, cast(dea.date as nvarchar(128))) as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2, 3

-- Using CTE to perform Calculation on Partition By in previous query
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.date, cast(dea.date as nvarchar(128))) as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, cast(dea.date as nvarchar(128)), dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.date, cast(dea.date as nvarchar(128))) as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

-- Creating view to store for later visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, cast(dea.date as nvarchar(128))) as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *
From PercentPopulationVaccinated
