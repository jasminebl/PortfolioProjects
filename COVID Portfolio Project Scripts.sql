select * 
from covid_deaths
where continent is not null
order by 3,4


select location, case_date , total_cases, new_cases, total_deaths, population
	from covid_deaths
	order by 1,2
	
-- looking at the total cases vs total deaths
-- shows the likely of dying if you contract covid in your country

select location, case_date, total_cases, total_deaths ,(total_deaths::decimal / total_cases)*100 as deathpercentage
	from covid_deaths
	where location = 'United States'
	order by 1,2 
	
-- Looking at the Total Cases vs Population

select location, case_date, total_cases, population ,(total_cases::decimal / population)*100 as percentpopulationinfected
	from covid_deaths
	where location = 'United States'
	order by 1,2 
	
-- Looking at countries with the Hightest Infection Rate compared to Population

select location, population , MAX(total_cases) as highestinfectioncount, Max((total_cases::decimal/population))*100 as percentpopulationinfected
	from covid_deaths
	group by location, population
	order by percentpopulationinfected desc

-- Showing the countries with the highest death count per population

select location, MAX(total_deaths) as TotalDeathCount
	from covid_deaths
	where continent is not null
	group by location
	Having max(total_deaths) is not null
	order by TotalDeathCount desc

-- Broken down by continent 
-- Showing the continents with the highest death count per population

select continent, MAX(total_deaths) as TotalDeathCount
	from covid_deaths
	where continent is not null
	group by continent
	Having max(total_deaths) is not null
	order by TotalDeathCount desc
	limit 10
	
select location, MAX(total_deaths) as TotalDeathCount
	from covid_deaths
	where continent is null
	group by location
	order by TotalDeathCount desc
	limit 10


--GLOBAL NUMBERS
	
select case_date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(new_deaths)::decimal / sum(new_cases)) * 100 as deathpercentage
	from covid_deaths
	where continent is not NULL
	group by case_date
	having sum(total_deaths) is not NULL
	order by 1,2

select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(new_deaths)::decimal / sum(new_cases)) * 100 as deathpercentage
	from covid_deaths
	where continent IS NOT NULL
	having sum(total_deaths) is not NULL
	order by 1,2


-- Total Populations vs Vaccinations 

select * 
	from covid_deaths dea
	join covid_vaccinations vac
		on dea.location = vac.location
		and dea.case_date = vac.case_date

select dea.continent, dea.location, dea.case_date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.case_date) 
	as rollingpeoplevaccinated
--,(rollingpeoplevaccinated/population)*100	
	from covid_deaths dea
	join covid_vaccinations vac
		on dea.location = vac.location
		and dea.case_date = vac.case_date
		where dea.continent is not null 
		order by 2,3
		
--USE CTE

With PopvsVac (continent, location, case_date, population, new_vaccinations, rollingpeoplevaccinated ) 
as
(
select dea.continent, dea.location, dea.case_date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.case_date) 
	as rollingpeoplevaccinated
--,(rollingpeoplevaccinated/population)*100	
	from covid_deaths dea
	join covid_vaccinations vac
		on dea.location = vac.location
		and dea.case_date = vac.case_date
		where dea.continent is not null 
		--order by 2,3
)		
select *, (rollingpeoplevaccinated::decimal/population)*100
from PopvsVac

--TEMP TABLE
  --if needed to alter temp table use drop 
DROP table if exists percentpopulationvaccinated
create temporary table PercentPopulationVaccinated
(
Continent varchar(255),
Location varchar(255),
case_date timestamp,
population bigint, 
new_vaccinations int,
rollingpeoplevaccinated int
);	
	
insert into PercentPopulationVaccinated (continent, location, case_date, population, new_vaccinations, rollingpeoplevaccinated)
select dea.continent, dea.location, dea.case_date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.case_date) 
	as rollingpeoplevaccinated
--,(rollingpeoplevaccinated/population)*100	
	from covid_deaths dea
	join covid_vaccinations vac
		on dea.location = vac.location
		and dea.case_date = vac.case_date
		where dea.continent is not null 
		--order by 2,3
		
select *, (rollingpeoplevaccinated::decimal/population)*100
from PercentPopulationVaccinated


--creating view to store data for later visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.case_date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.case_date) 
	as rollingpeoplevaccinated
--,(rollingpeoplevaccinated/population)*100	
	from covid_deaths dea
	join covid_vaccinations vac
		on dea.location = vac.location
		and dea.case_date = vac.case_date
	where dea.continent is not null 
	--order by 2,3
	
select * from 
PercentPopulationVaccinated
