select * from Portfolio_project..CovidDeaths$
where continent IS NULL;

--select * from CovidVaccinations$;

-- select the data we will be using

select location, date, total_cases, new_cases, Total_deaths, population
from CovidDeaths$
order by 1,2;

--Looking at toal cases vs total deaths

select location, date, total_cases, Total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 As death_percentage  --changed the data type here using the cast operator because of the error 'Operand data type nvarchar is invalid for divide operator.'
from Portfolio_Project..CovidDeaths$
--where location = 'India'
order by 1,2;

--shows what percentage of people got covid

select location,date, total_cases, population, (total_cases/population)*100 as percent_population_infected
from Portfolio_Project..CovidDeaths$
Where location like '%States%'
order by 1,2;

--Looking at countries with highest infection rate compared to population

select location, population, MAX(total_cases) AS Highest_infection, 
MAX((total_cases/population)*100) as percent_population_infected
from Portfolio_Project..CovidDeaths$
GROUP BY location, population
order by percent_population_infected  DESC;

--Showing the countries with the highest death count per population
select location, MAX(CAST(total_deaths AS int)) AS Total_death_count 
from Portfolio_Project..CovidDeaths$
where continent IS NOT NULL
GROUP BY location
order by Total_death_count  DESC;

--Let's break things down by continent

select continent, MAX(CAST(total_deaths AS int)) AS Total_death_count 
from Portfolio_Project..CovidDeaths$
where continent IS NOT NULL
GROUP BY continent
order by Total_death_count  DESC;

--GLOBAL NUMBERS

select date, SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS int)) AS Total_Deaths, 
(SUM(new_deaths)/NULLIF(SUM(new_cases), 0)) *100 AS DeathPercentage
from Portfolio_Project..CovidDeaths$
--where location = 'India'
where continent IS NOT NULL
GROUP BY date
order by 1,2

select SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS int)) AS Total_Deaths, 
(SUM(new_deaths)/NULLIF(SUM(new_cases), 0)) *100 AS DeathPercentage
from Portfolio_Project..CovidDeaths$
--where location = 'India'
where continent IS NOT NULL
--GROUP BY date
order by 1,2

--this means arounf 1% od world's total population died because of COVID. Total cases recorded are around 70 Crore ~ 700 Million

SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(CONVERT(bigint, VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) AS RollingPeopleVaccinated
FROM Portfolio_Project..CovidDeaths$ DEA
JOIN Portfolio_Project..CovidVaccinations$ VAC
     ON DEA.location = VAC.location
     AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
ORDER BY 2,3


--USE CTE

WITH popVSvac(Continet, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(CONVERT(bigint, VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) AS RollingPeopleVaccinated
FROM Portfolio_Project..CovidDeaths$ DEA
JOIN Portfolio_Project..CovidVaccinations$ VAC
     ON DEA.location = VAC.location
     AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
--ORDER BY 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
from popVSvac

-- ~50% population in albania is vaccinated

--TEMP table

DROP TABLE IF EXISTS PercentPopulationVAccinated
CREATE TABLE PercentPopulationVAccinated
(
  Continent nvarchar(255),
  Location nvarchar(255),
  Date datetime,
  Population numeric,
  NewVaccination numeric,
  RollingPeopleVaccinated numeric
)
INSERT INTO PercentPopulationVAccinated
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(CONVERT(bigint, VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) AS RollingPeopleVaccinated
FROM Portfolio_Project..CovidDeaths$ DEA
JOIN Portfolio_Project..CovidVaccinations$ VAC
     ON DEA.location = VAC.location
     AND DEA.date = VAC.date
--WHERE DEA.continent IS NOT NULL
--ORDER BY 2,3

Select *, (RollingPeopleVaccinated/Population)*100
from PercentPopulationVAccinated

--Creating View to store data for visualization later

CREATE View Percent_Population_Vaccinated AS
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(CONVERT(bigint, VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) AS RollingPeopleVaccinated
FROM Portfolio_Project..CovidDeaths$ DEA
JOIN Portfolio_Project..CovidVaccinations$ VAC
     ON DEA.location = VAC.location
     AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
--ORDER BY 2,3