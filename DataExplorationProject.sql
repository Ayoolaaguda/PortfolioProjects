SELECT *
FROM PortflioProject..CovidDeaths
Where continent is not Null
ORDER BY 3,4


--SELECT *
--FROM PortflioProject..CovidVaccinations
--ORDER BY 3,4

--SELCTING DATA TO BE USED
SELECT location, date, total_cases, new_cases,total_deaths, population
FROM PortflioProject..CovidDeaths
Order by 1,2


--TOTAL CASES VS TOTAL DEATHS (In percentage)
--Shows likelihood of dying if one contracts covid in your country
SELECT location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as PercentageDeath
FROM PortflioProject..CovidDeaths
Where location = 'Nigeria'
Order by 1,2


--TOTAL CASES VS THE POPULATION
--Shows what Percentage of population got covid
SELECT location, date, total_cases,population,(total_cases/population)*100 as PercentagePolutionInfected
FROM PortflioProject..CovidDeaths
Where location = 'Nigeria'
Order by 1,2



--COUNTRIES WITH THE HIGHEST INFECTION RATE COMPARED TO POPULATION
SELECT location, population,MAX(total_cases) AS HighestInfectionCount, Max(total_cases/population)*100 as PercentagePolutionInfected
FROM PortflioProject..CovidDeaths
--Where location = 'Nigeria'
Group by location, population
Order by PercentagePolutionInfected desc




--COUNTRIES WITH THE HIGHEST DEATH COUNT PER POPULATION
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortflioProject..CovidDeaths
--Where location = 'Nigeria'
Where continent is not Null
Group by location
Order by TotalDeathCount desc


--BY CONTINENT
--CONTINENT WITH HIGHEST DEATH COUNT PER POPULATION 
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount --use for view
FROM PortflioProject..CovidDeaths
--Where location = 'Nigeria'
Where continent is not  Null
Group by continent
Order by TotalDeathCount desc --north america doesnt include canada


SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortflioProject..CovidDeaths
--Where location = 'Nigeria'
Where continent is  Null
Group by location
Order by TotalDeathCount desc --north america includes canada



--GLOBAL NUMBERS
SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths,
Isnull((SUM(new_deaths)/Nullif (SUM(new_cases),0)*100),0) as GlobalPercentageDeath --Solving Divide by Zero error using Isnull
FROM PortflioProject..CovidDeaths
--Where location = 'Nigeria'
Where continent is not null
Group by date
Order by 1,2


SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths,
Isnull((SUM(new_deaths)/Nullif (SUM(new_cases),0)*100),0) as GlobalPercentageDeath --Solving Divide by Zero error using Isnull
FROM PortflioProject..CovidDeaths
--Where location = 'Nigeria'
Where continent is not null
--Group by date
Order by 1,2


--TOTAL POPULATION VS VACCINATION
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
FROM PortflioProject..CovidDeaths dea
JOIN PortflioProject..CovidVaccinations vac
on dea.location =vac.location
and dea.date = vac.date
Where dea.continent IS NOT NULL
Order by 2,3

--ROLLING COUNT OF TOTAL POPULATION VS VACCINATION
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER(Partition by dea.location order by dea.location,
	dea.date) AS RollingPeopleVaccinated
FROM PortflioProject..CovidDeaths dea
JOIN PortflioProject..CovidVaccinations vac
on dea.location =vac.location
and dea.date = vac.date
Where dea.continent IS NOT NULL
Order by 2,3



--USE CTE
With PopVsVac (Continent, location, date, population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER(Partition by dea.location order by dea.location,
	dea.date) AS RollingPeopleVaccinated
FROM PortflioProject..CovidDeaths dea
JOIN PortflioProject..CovidVaccinations vac
on dea.location =vac.location
and dea.date = vac.date
Where dea.continent IS NOT NULL
)
Select*, (RollingPeopleVaccinated/population)*100
From PopVsVac



--USING TEMP TABLE
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into  #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER(Partition by dea.location order by dea.location,
	dea.date) AS RollingPeopleVaccinated
FROM PortflioProject..CovidDeaths dea
JOIN PortflioProject..CovidVaccinations vac
on dea.location =vac.location
and dea.date = vac.date
Where dea.continent IS NOT NULL
Order by 2,3

Select*, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated



--CRAETING VIEWS FOR VISUALIZATION
Create view PercenPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER(Partition by dea.location order by dea.location,
	dea.date) AS RollingPeopleVaccinated
FROM PortflioProject..CovidDeaths dea
JOIN PortflioProject..CovidVaccinations vac
on dea.location =vac.location
and dea.date = vac.date
Where dea.continent IS NOT NULL




Select*
From PercenPopulationVaccinated
