Select *
From PortfoliloProject..CovidDeaths
order by 3,4

--Select *
--From PortfoliloProject..CovidVacs
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfoliloProject..CovidDeaths
Order by 1,2

-- Looking for Total cases VS Total deaths
-- Shows the likelihood of dying if you if you got infected with covid in your country 

Select location, date, total_cases, total_deaths, (cast (total_deaths as float)/cast (total_cases as float))*100 as DeathPercentage
From PortfoliloProject..CovidDeaths
Where location like '%saudi%'
Order by 1,2

-- Looking at Total Cases vs Population
-- Shows what Percentage of Population got Covid

Select location, date, population, total_cases,  (total_cases/population)*100 as InfectionPercentage
From PortfoliloProject..CovidDeaths
Where location like '%saudi%'
Order by 1,2

-- Looking at countries	with Highest Infection Rate Compared to Population

Select location, population, Max(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as InfectionPercentage
From PortfoliloProject..CovidDeaths
Group by location, population
Order by InfectionPercentage Desc

-- Showing Countries with Highest Death Count Per Population 

Select location, population, Max(total_deaths) as HighestDeathCount,  Max((total_deaths/population))*100 as DeathPercentage
From PortfoliloProject..CovidDeaths
Group by location, population
Order by DeathPercentage Desc

-- Showing Countries with Highest Death Count Per Population
Select location, Max(cast(total_deaths as int)) as HighestDeathCount
From PortfoliloProject..CovidDeaths
Where continent is not null
Group by location
Order by HighestDeathCount Desc


-- Showing Countries with Highest Death Count Per Population

Select location, Max(cast(total_deaths as int)) as HighestDeathCount
From PortfoliloProject..CovidDeaths
Where continent is null
Group by location
Order by HighestDeathCount Desc

-- Daily Global Death Percentage 
Select date,  Sum(cast(new_cases as float)),Sum(cast(new_deaths as float)),
(Sum(cast(new_deaths as float))/Sum(cast(new_cases as float)))*100 as DeathPercentage
From PortfoliloProject..CovidDeaths
--Where location like '%saudi%'
Where continent is not null 
Group by date
Order by 1,2

-- Global Death Percentage
Select Sum(cast(new_cases as float)),Sum(cast(new_deaths as float)),
(Sum(cast(new_deaths as float))/Sum(cast(new_cases as float)))*100 as DeathPercentage
From PortfoliloProject..CovidDeaths
--Where location like '%saudi%'
Where continent is not null 
Order by 1,2


-- CTE to make vaccinationsCount/population 

with PopvsVac (continent, location, date, population, new_vaccinations, vaccinationsCount)
as
(
Select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as vaccinationsCount

From PortfoliloProject..CovidDeaths dea
Join PortfoliloProject..CovidVacs vac
	On dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3 
)
Select *, (vaccinationsCount/population)*100 as vaccinationPercentage 
From PopvsVac


-- TEMP TABLE

Drop table if exists #percentPopulationVaccinated 
create Table #percentPopulationVaccinated 
(
Continenet varchar(255),
Location varchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
vaccinationsCount numeric
)

insert into #percentPopulationVaccinated 
Select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as vaccinationsCount

From PortfoliloProject..CovidDeaths dea
Join PortfoliloProject..CovidVacs vac
	On dea.location = vac.location and dea.date = vac.date
--where dea.continent is not null
--order by 2,3 

Select *, (vaccinationsCount/population)*100 as vaccinationPercentage 
From #percentPopulationVaccinated 


-- Creating View to store data for later visulizations

Create View percentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as vaccinationsCount

From PortfoliloProject..CovidDeaths dea
Join PortfoliloProject..CovidVacs vac
	On dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3 

Select * 
from percentPopulationVaccinated
