/*

Queries used for Tableau Project

*/

--1.

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM [Portfolio 1].dbo.CovidDeaths$
where continent is not null
order by 1,2

--2.

--We take these out as they are not included in the above queries and want to stay consistent
--European Union is part of Europe

SELECT location, sum(cast(total_deaths as int)) as TotalDeathCount
FROM [Portfolio 1].DBO.CovidDeaths$
Where continent is null
and location not in ('World', 'European Union', 'International')
Group by location
ORDER BY TotalDeathCount desc


--3.

SELECT location, max(total_cases) as HighestInfectionCount, population, Max((total_cases/population)*100) as PercentPoulationInfected
FROM [Portfolio 1].DBO.CovidDeaths$
Group by location, population
ORDER BY PercentPoulationInfected desc

--4.

SELECT location, max(total_cases) as HighestInfectionCount, population, Max((total_cases/population)*100) as PercentPoulationInfected
FROM [Portfolio 1].DBO.CovidDeaths$
Group by location, population, date
ORDER BY PercentPoulationInfected desc

