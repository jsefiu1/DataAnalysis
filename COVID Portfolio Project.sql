
SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
order by 3,4

/*
SELECT *
FROM PortfolioProject..CovidVaccinations
order by 3,4
*/
-- Looking at Total Cases vs Total Deaths

-- Shows likehood of dying if you contact covid in your country
Select Location, date, total_cases, total_deaths,(total_deaths/total_cases) * 100 as DeathPercentage 
From PortfolioProject..CovidDeaths
where location like 'kos%'
order by 1, 2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid

Select Location, date, total_cases, Population, (total_cases/Population) * 100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
--where location like 'kos%'
order by 1, 2

-- Looking at countries iwth Highest Infection Rate compared to Population
Select Location, Population,MAX(total_cases) as HighestInfectionCount,  Max((total_cases/Population)) * 100 as PercentageOfPopulationInfected 
From PortfolioProject..CovidDeaths
--where location like 'kos%'
Group by Location, Population
order by PercentageOfPopulationInfected desc

-- Looking at countries iwth Highest Death Count per Population
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like 'kos%'
where continent is not null
Group by Location
order by TotalDeathCount 


-- Continent

-- Showing continents with highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like 'kos%'
where continent is not null
Group by continent
order by TotalDeathCount desc


-- GLOVAL NUMBERS


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage--total_cases, total_deaths,(total_deaths/total_cases) * 100 as DeathPercentage 
From PortfolioProject..CovidDeaths
--where location like 'kos%'
where continent is not null
--Group BY date
order by 1, 2

Select date, SUM(new_cases) as total_cases, SUM(CONVERT(int, new_deaths)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage--total_cases, total_deaths,(total_deaths/total_cases) * 100 as DeathPercentage 
From PortfolioProject..CovidDeaths
--where location like 'kos%'
where continent is not null
Group BY date
order by 1, 2

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.Location , 
dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN  PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1, 2, 3


-- USE CTE

With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.Location , 
dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN  PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1, 2, 3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopVsVac


-- TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
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
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.Location , 
dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN  PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1, 2, 3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Create View to store data for later visulisations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.Location , 
dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN  PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1, 2, 3


Select * From PercentPopulationVaccinated