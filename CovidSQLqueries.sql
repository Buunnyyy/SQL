Select *
from ProjectSQL..CovidDeaths
where continent is not null		
order by 3,4

--Select *
--from ProjectSQL..CovidVaccinations
--order by 3,4

--Selecting data we are going to use

Select Location, date, total_cases, new_cases, total_deaths, population
From ProjectSQL..CovidDeaths
order by 1,2

-- Total Cases vs Total Deaths
--Shows likelyhood of dying if you contract covid in UK

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From ProjectSQL..CovidDeaths
where location like '%kingdom%'
order by 1,2

--Total Cases vs Population
--Percentage of population got COVID

Select Location, date, Population, total_cases, (total_cases/population)*100 as Population_Percentage
From ProjectSQL..CovidDeaths
where location like '%kingdom%'
order by 1,2

--Countries with Highest Infection Rate vs Population

Select Location, Population, MAX(total_cases) as Highest_infection_count, MAX((total_cases/population))*100 as Population_Percentage
From ProjectSQL..CovidDeaths
--where location like '%kingdom%'
Group by location, Population
order by Population_Percentage desc

--Countries with Highest death count per Population

Select Location, MAX(cast(total_deaths as int)) as Death_count 
From ProjectSQL..CovidDeaths
--where location like '%kingdom%'
where continent is not null
Group by location
order by Death_count desc

--Breaking down Continents with highest death count per population


 
--Global Numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/Sum(new_cases)*100 as Death_percentage
From ProjectSQL..CovidDeaths
--where location like '%Kingdom%'
where continent is not null
Group by date
order by 1,2


--Total Population vs Vaccinations


Select cd.continent, cd.location, cd.date, cd.population, vc.new_vaccinations,
SUM(Convert(bigint, vc.new_vaccinations)) OVER (Partition by cd. Location Order by cd.location, cd.date) as RollingTotal
From ProjectSQL..CovidDeaths cd
Join ProjectSQL..CovidVaccinations vc
	On cd.location = vc.location
	and cd.date = vc.date
where cd.continent is not null
order by 2,3


--Using CTE

With PpvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingTotal)
as
(
Select cd.continent, cd.location, cd.date, cd.population, vc.new_vaccinations,
SUM(Convert(bigint, vc.new_vaccinations)) OVER (Partition by cd. Location Order by cd.location, cd.date) as RollingTotal
From ProjectSQL..CovidDeaths cd
Join ProjectSQL..CovidVaccinations vc
	On cd.location = vc.location
	and cd.date = vc.date
where cd.continent is not null
)
Select *,(RollingTotal/Population)*100 as Vac_Percentage
From PpvsVac


--Temp Table

DROP Table if exists #Per_Pop_Vaccinated
Create Table #Per_Pop_Vaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
New_vaccinations numeric,
RollingTotal numeric
)

Insert into #Per_Pop_Vaccinated
Select cd.continent, cd.location, cd.date, cd.population, vc.new_vaccinations,
SUM(Convert(bigint, vc.new_vaccinations)) OVER (Partition by cd. Location Order by cd.location, cd.date) as RollingTotal
From ProjectSQL..CovidDeaths cd
Join ProjectSQL..CovidVaccinations vc
	On cd.location = vc.location
	and cd.date = vc.date
where cd.continent is not null
order by 2,3


Select *, (RollingTotal/Population)*100 as Vac_Percentage
From #Per_Pop_Vaccinated



--Views to store data for later Visualisations


Create View Per_Pop_Vaccinated as
Select cd.continent, cd.location, cd.date, cd.population, vc.new_vaccinations,
SUM(Convert(bigint, vc.new_vaccinations)) OVER (Partition by cd. Location Order by cd.location, cd.date) as RollingTotal
From ProjectSQL..CovidDeaths cd
Join ProjectSQL..CovidVaccinations vc
	On cd.location = vc.location
	and cd.date = vc.date
where cd.continent is not null


Select * from Per_Pop_Vaccinated