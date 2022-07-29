select *
from CovidProject..[covid deaths]
order by 3,4

--select *
--from CovidProject..[covid vaccinations]
--order by 3,4

select Location, date, total_cases, new_cases, total_deaths, population
from CovidProject..[covid deaths]
order by 1,2

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from CovidProject..[covid deaths]
where location like '%brazil%'
order by 1,2

select Location, date, total_cases, population, (total_cases/population)*100 as casespercentage
from CovidProject..[covid deaths]
where location like '%brazil%'
order by 1,2

select Location, MAX(total_cases) as HighestInfectionCount, population, Max((total_cases/population))*100 as casespercentage
from CovidProject..[covid deaths]
group by location, population
order by casespercentage desc

select Location, MAX(cast(total_deaths as int)) as TotalDeathCount, population, Max((total_deaths/population))*100 as deathpercentage
from CovidProject..[covid deaths]
where continent is not null
group by location, population
order by TotalDeathCount desc

--select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
--from CovidProject..[covid deaths]
--where continent is not null
--group by continent
--order by TotalDeathCount desc

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidProject..[covid deaths]
where continent is null
group by location
order by TotalDeathCount desc


select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentage
from CovidProject..[covid deaths]
where continent is not null
group by date
order by 1,2

----

--select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--from CovidProject..[covid deaths] dea
--join CovidProject..[covid vaccinations] vac
--	on dea.location= vac.location
--	and dea.date= vac.date
--where dea.continent is not null
--order by 2,3

with Popvsvac (continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint, vac.new_vaccinations)) over (Partition by dea.location Order by dea.location, 
dea.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated

from CovidProject..[covid deaths] dea
join CovidProject..[covid vaccinations] vac
	on dea.location= vac.location
	and dea.date= vac.date
where dea.continent is not null
--order by 2,3
)
select * , (RollingPeopleVaccinated/Population)*100
from Popvsvac

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint, vac.new_vaccinations)) over (Partition by dea.location Order by dea.location, 
dea.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated

from CovidProject..[covid deaths] dea
join CovidProject..[covid vaccinations] vac
	on dea.location= vac.location
	and dea.date= vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint, vac.new_vaccinations)) over (Partition by dea.location Order by dea.location, 
dea.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated

from CovidProject..[covid deaths] dea
join CovidProject..[covid vaccinations] vac
	on dea.location= vac.location
	and dea.date= vac.date
where dea.continent is not null
--order by 2,3