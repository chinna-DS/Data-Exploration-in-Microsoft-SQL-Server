select *
from PortfolioProjects..CovidDeaths
where continent != '' 
order by 3,4
--select *
--from PortfolioProjects..CovidVaccinations
--order by 3,4
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProjects..CovidDeaths
order by 1,2

--Total cases Vs Total Deaths
select location, date, total_cases,total_deaths 
from PortfolioProjects..CovidDeaths
order by 1,2
alter table CovidDeaths alter column total_cases float
alter table CovidDeaths alter column total_Deaths float
--shows lkelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/nullif(total_cases,0))*100 as DeathPercentage
from PortfolioProjects..CovidDeaths
where location like '%india%'
order by 1,2
--Total cases Vs Population
--percentage of population who got covid
alter table CovidDeaths alter column population float
select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProjects..CovidDeaths
where location like '%india%'
order by 1,2
alter table CovidDeaths alter column date datetime
--looking at countries with highest infection rate compared to population
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/nullif(population,0)))*100 as PercentPopulationInfected
from PortfolioProjects..CovidDeaths
--where location like 'A%'
group by
location,population
order by PercentPopulationInfected desc
select location, max(cast (total_deaths as int)) as TotalDeathCount
from PortfolioProjects..CovidDeaths
--where location like 'A%'
where continent != ''
group by
location
order by TotalDeathCount desc
-- looking by Continent
-- showing continents with Highest Death count
select continent, max(cast (total_deaths as int)) as TotalDeathCount
from PortfolioProjects..CovidDeaths
--where location like 'A%'
where continent != ''
group by
continent
order by TotalDeathCount desc




-- Breaking Global Numbers
alter table CovidDeaths alter column new_cases float
alter table CovidDeaths alter column new_deaths nvarchar(255)

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(nullif(new_cases,0)) *100 as DeathPercentage
from PortfolioProjects..CovidDeaths
where continent != ''
group by date
order by 1,2

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(nullif(new_cases,0)) *100 as DeathPercentage
from PortfolioProjects..CovidDeaths
where continent != ''
--group by date
order by 1,2

alter table CovidVaccinations alter column date datetime
alter table CovidVaccinations alter column new_vaccinations float
alter table CovidDeaths alter column location nvarchar(255)
--update CovidVaccinations
--set date = convert(datetime,date,105)

--Total_Population Vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date 
where dea.continent != ''
order by 2,3

--USE CTE
with PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date 
where dea.continent != ''
)
--order by 2,3


select *,(RollingPeopleVaccinated/Population)*100 as PeopleVaccinatedPercentage
from PopVsVac

--Temp table
drop table if exists #PercentPeopleVaccinated
create table #PercentPeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPeopleVaccinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date 
--where dea.continent != ''

--order by 2,3

select *,(RollingPeopleVaccinated/nullif(Population,0))*100 as PeopleVaccinatedPercentage
from #PercentPeopleVaccinated

--creating view to store data for later visualizations
create view PercentPeopleVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date 
where dea.continent != ''

--order by 2,3

select * 
from PercentPeopleVaccinated