--SELECT *
--FROM [Portfolio 1].DBO.CovidDeaths$
--ORDER BY 3,4 

--SELECT *
--FROM [Portfolio 1].DBO.CovidVaccinations$
--ORDER BY 3,4

--SELECTing DATA THAT WE ARE GOING TO USE

--SELECT location, date, total_cases, new_cases, total_deaths, population
--FROM [Portfolio 1].DBO.CovidDeaths$
--ORDER BY 1,2

-- looking at total_cases vs total_deaths
--shows the likelihood of dying if you get covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio 1].DBO.CovidDeaths$
--WHERE location like '%states%'
Where continent is not null
ORDER BY 1,2

--Looking at the total cases vs population
--shows what percentage of population gets covid
SELECT location, date, total_cases, population, (total_cases/population)*100 as PercentPoulationInfected
FROM [Portfolio 1].DBO.CovidDeaths$
--WHERE location like '%states%'
Where continent is not null
ORDER BY 1,2

--looking at countries with highest infection rates compared to population
SELECT location, max(total_cases) as HighestInfectionCount, population, Max((total_cases/population)*100) as PercentPoulationInfected
FROM [Portfolio 1].DBO.CovidDeaths$
--WHERE location like '%states%'
Where continent is not null
Group by location, population
ORDER BY PercentPoulationInfected desc

--showing countries with highest death counts per population
SELECT location, max(cast(total_deaths as int)) as TotalDeathCount
FROM [Portfolio 1].DBO.CovidDeaths$
--WHERE location like '%states%'
Where continent is not null
Group by location
ORDER BY TotalDeathCount desc

-- Lets break things down by continent
--showing the continents withhighest death count per population
SELECT continent, max(cast(total_deaths as int)) as TotalDeathCount
FROM [Portfolio 1].DBO.CovidDeaths$
--WHERE location like '%states%'
Where continent is not null
Group by continent
ORDER BY TotalDeathCount desc

--global numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM [Portfolio 1].dbo.CovidDeaths$
where continent is not null
Group by date
order by 1,2

--global number of total deaths
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM [Portfolio 1].dbo.CovidDeaths$
where continent is not null
--Group by date
order by 1,2

--looking at total population vsa vaccinaions

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated --(RollingPeopleVaccinated/dea.population)*100 
From [Portfolio 1].dbo.CovidDeaths$ dea
Join [Portfolio 1].dbo.CovidVaccinations$ vac
  On dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use CTE

With PopvsVAC (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated --(RollingPeopleVaccinated/dea.population)*100 
From [Portfolio 1].dbo.CovidDeaths$ dea
Join [Portfolio 1].dbo.CovidVaccinations$ vac
  On dea.location = vac.location
  and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
)
Select * , (RollingPeopleVaccinated/Population)*100
From PopvsVAC


--Temp Table

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated --(RollingPeopleVaccinated/dea.population)*100 
From [Portfolio 1].dbo.CovidDeaths$ dea
Join [Portfolio 1].dbo.CovidVaccinations$ vac
  On dea.location = vac.location
  and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating view to store date for visualisation

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated --(RollingPeopleVaccinated/dea.population)*100 
From [Portfolio 1].dbo.CovidDeaths$ dea
Join [Portfolio 1].dbo.CovidVaccinations$ vac
  On dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated