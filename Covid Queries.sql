--data about deaths by corona virus
select * 
from deaths


select location, date, total_cases, new_cases, total_deaths, population
from deaths
order by 1,2


-- looking at total covid cases vs total deaths
select location, date, total_cases, total_deaths, ((total_deaths/total_cases)*100) as DeathPercentage
from deaths
order by 1,2

-- shows liklyhood of dying if you contract covid in each country or your contry
select location, max(total_cases), max(total_deaths), (max(total_deaths)/max(total_cases))*100 as DeathPercentage
from deaths
group by location
order by 1

-- shows liklyhood of dying in IRAN
select location, max(total_cases), max(total_deaths), (max(total_deaths)/max(total_cases))*100 as DeathPercentage
from deaths
where location like '%Iran%'
group by location


-- looking at the total cases vs population
select location, date, population, total_cases, (total_cases/population)*100 as percentPopulationInfected
from deaths
order by 1,2 

-- looking at contries with the highest infection rate compared to the population
select location, population, max(total_cases) as HighestInfectionCount, 
       (max(total_cases)/population)*100 as percentPopulationInfected
from deaths
group by location, population
order by percentPopulationInfected desc
																		 
-- showing countries with the highest death count per population
select location, max(total_deaths) as HighestDeathCount 
from deaths
where continent is not null and total_deaths is not null
group by location
order by HighestDeathCount desc


-- LET'S Break Things Down By Continent
select location, max(total_deaths) as HighestDeathCount 
from deaths
where continent is null and total_deaths is not null
group by location
order by HighestDeathCount desc

--showing continents with highest death count per population
select location, max(total_deaths) as HighestDeathCount 
from deaths
where continent is null and total_deaths is not null
group by location
order by HighestDeathCount desc


--Global
select sum(new_cases)as total_cases, sum(new_deaths) as total_deaths,
       sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from deaths
where continent is not null
order by 1,2



-- data about vaccinations
-- looking at total population vs vaccination 

select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) OVER(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/dea.population)*100 ###
from deaths dea
join vaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null 
order by 2, 3

-- ### we can't use the column just created in selec so we have to : 
-- USE CTE
with PopvsVac (Continent, location, date, population, new_vaccination, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) OVER(partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
from deaths dea
join vaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null 
)
select *, (RollingPeopleVaccinated/population)*100 as PercentofVaccinated
from PopvsVac


--or Temp Table
Drop table if exists percentPeopleVaccinated

create temporary table percentPeopleVaccinated
(
continent text,
location text,
date date,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
);

select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
       sum(vac.new_vaccinations) OVER(partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
into Temp table percentPeopleVaccinated
from deaths dea
join vaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
-- where dea.continent is not null 
;
select *, (RollingPeopleVaccinated/population)*100 as PercentofVaccinated
from percentPeopleVaccinated


--creating view to store date for later visualization
create view percentPeopleVaccinated as
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
       sum(vac.new_vaccinations) OVER(partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
from deaths dea
join vaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null 
-- order by 2,3

select * 
from percentPeopleVaccinated