select *
from PortofolioProject..CovidDeaths
order by 3,4

UPDATE PortofolioProject..CovidDeaths
SET continent = NULL
WHERE continent = ''

select location, date, total_cases, new_cases,total_deaths,population
from PortofolioProject..CovidDeaths
order by 1,2

SET ARITHABORT OFF
SET ANSI_WARNINGS OFF


-- Looking at total cases vs total deaths

select location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortofolioProject..CovidDeaths
order by 1,2


-- Looking at total cases vs Population in the USA

select location, date, total_cases,population,(total_cases/population)*100 as InfectionPercentage
from PortofolioProject..CovidDeaths
where location = 'United States'
order by 1,2

--Looking at countries with the highest infection rate compared to population

select location,MAX(total_cases)as HighestInfectionCount,population,max((total_cases/population))*100 as InfectionPercentage
from PortofolioProject..CovidDeaths
group by location,population
order by InfectionPercentage desc

-- Countries with highest death count per population

select location,max(total_deaths) as TotalDeathCount, population, (max(total_deaths)/population)*100 as DeathPercentage
from PortofolioProject..CovidDeaths
where continent is not null --removing entries where where countries where grouped by continent in the column location
group by location, population
order by DeathPercentage desc


--Lets break it down by continent (most deaths)

select location, max(total_deaths) as TotalDeathCount 
from PortofolioProject..CovidDeaths
where continent is  null 
group by location
order by TotalDeathCount desc


-- GLOBAL NUMBERS

select SUM(new_cases)as total_cases, SUM(new_deaths) as total_deaths, (sum(new_deaths)/sum(new_cases))*100 as DeathPercentage
from PortofolioProject..CovidDeaths
where continent is not null
order by 1,2



-- Looking at total population vs vaccinations
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 2,3

UPDATE PortofolioProject..CovidVaccinations
SET new_vaccinations = NULL
WHERE new_vaccinations = 0


-- use a CTE
with PopvsVac (continent,Location,date, population, new_vaccinations, RollingPeopleVaccinated) 
as
(
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 )
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


--Temp table
drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null

 select *,(RollingPeopleVaccinated/population)*100
 from #PercentPopulationVaccinated



 --Creating view to store date for later visualizations
 Use PortofolioProject
 go
 create view PercentPopulationVaccinated as
 select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null