--SELECT *
--FROM Covid_Project..CovidDeaths
--ORDER BY 3,4

--SELECT *
--FROM Covid_Project..CovidVaccination
--ORDER BY 3,4

--Data I am going to use
Select Location, date, population, total_cases, new_cases, total_deaths
FROM Covid_Project..CovidDeaths
ORDER BY 1,2

--Total Cases vs Total Deaths 
--Calculating death_precentage 
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Precentage
FROM Covid_Project..CovidDeaths
ORDER BY 1,2

--Population Infected Precentage in the United States
Select Location, date, population, total_cases, (total_cases/population)*100 AS Population_Infected_Precentage
FROM Covid_Project..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

--Contries with hightest infection rate compare to population
Select Location, population, MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases/population))*100 AS Population_Infected_Precentage
FROM Covid_Project..CovidDeaths
GROUP BY Location, population
ORDER BY Population_Infected_Precentage DESC

--Contries with highest death count  
Select Location, MAX(CAST(total_deaths as int)) AS Total_Deaths_Count
FROM Covid_Project..CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY Total_Deaths_Count DESC

--Total deaths in each continent
Select continent, MAX(CAST(total_deaths as int)) AS Total_Deaths_Count
FROM Covid_Project..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY Total_Deaths_Count DESC

--Global numbers 
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) *100 as DeathPercentage
FROM Covid_Project..CovidDeaths
WHERE continent is not null


--Perecent population vaccinated
WITH Pop_Vs_Vac(continent, location, date, population, new_vaccinations, Total_People_Vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.date) as Total_People_Vaccinated
FROM Covid_Project..CovidDeaths dea
JOIN Covid_Project..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

)
SELECT *, (Total_People_Vaccinated/population)*100 as Precentage_People_Vaccinated
FROM Pop_Vs_Vac

--Creating a View 
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.date) as Total_People_Vaccinated
FROM Covid_Project..CovidDeaths dea
JOIN Covid_Project..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *
FROM PercentPopulationVaccinated