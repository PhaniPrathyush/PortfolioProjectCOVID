select *
from CovidProject..CovidDeaths
where continent is not null
order by 3,4
-- SELECTING THE DATA THAT WE ARE GOING TO USE 
select Location,date,total_cases,new_cases,total_deaths,population
from CovidProject..CovidDeaths
where continent is not null
order by 1,2

-- LOOKING AT TOTAL CASES VS TOTAL DEATHS 
-- THE CHANCES OF DEATH IF YOU GET DIAGNOSED COVID IN INDIA
select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from CovidProject..CovidDeaths
where continent is not null
where Location = 'India'
order by 1,2

-- LOOKING AT TOTAL CASES VS POPULATION
-- SHOWS WHAT ARE THE CHANCES OF GETTING COVID DIAGNOSED IN INDIA
select Location,date,population,total_cases,(total_cases/population)*100 as DiagnosePercentage
from CovidProject..CovidDeaths
where continent is not null
where Location = 'India'
order by 1,2

--WHICH COUNTRY HAS THE HIGHEST INFECTION RATE COMPARED TO POPULATION
select Location,population,MAX(total_cases) as HigestInfectionTotal,max((total_cases/population))*100 as PopualtionPercentageInfected
from CovidProject..CovidDeaths
where continent is not null
group by Location,population
order by PopualtionPercentageInfected desc

--SHOWS THE COUNTRIES WITH HIGHEST DEATHTOTAL BY POPULATION
select Location, MAX(cast(Total_deaths as int))as TotalDeathCount
from CovidProject..CovidDeaths
where continent is not null
group by Location
order by TotalDeathCount desc

--SHOWING CONTINENTS WITH HIGHEST DEATHTOTAL
select continent, MAX(cast(Total_deaths as int))as TotalDeathCount
from CovidProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS
select sum(new_cases) as total_cases,sum(cast (new_deaths as int)) as total_deaths,SUM(cast (new_deaths as int))/SUM(new_cases)*100 as Deathpercentage
from CovidProject..CovidDeaths
where continent is not null
--group by  date
order by 1,2

--TOTAL POPULATION VS THE VACCINATIONS
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date)
as TotalPeopleVaccinated
from CovidProject..CovidDeaths dea
join CovidProject..CovidVaccinations vac
on  dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3


-- USING CTE
 with PopvsVac(Continent, location,date,population,new_vaccinations,TotalPeopleVaccinated)
 as
 (
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date)
as TotalPeopleVaccinated
from CovidProject..CovidDeaths dea
join CovidProject..CovidVaccinations vac
on  dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *,(TotalPeopleVaccinated/population)*100
from PopvsVac


--TEMP TABLE
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
TotalPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date)
as TotalPeopleVaccinated
from CovidProject..CovidDeaths dea
join CovidProject..CovidVaccinations vac
on  dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3


select *,(TotalPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--CREATING VIEW

create view PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date)
as TotalPeopleVaccinated
from CovidProject..CovidDeaths dea
join CovidProject..CovidVaccinations vac
on  dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3

Select *
from
PercentPopulationVaccinated

