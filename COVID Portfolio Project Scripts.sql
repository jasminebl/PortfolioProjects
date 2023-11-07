-- Table creation for dataset in Postgresql 

create table covid_deaths (
	  iso_code varchar (255)
	, continent varchar (255)
	, location varchar (255)
	, case_date DATE
	, total_cases int 
	, new_cases int
	, new_cases_smoothed decimal 
	, total_deaths int
	, new_deaths int
	, new_deaths_smoothed decimal
	, total_cases_per_million decimal
	, new_cases_per_million decimal
	, new_cases_smoothed_per_million decimal
	, total_deaths_per_million decimal
	, new_deaths_per_million decimal
	, new_deaths_smoothed_per_million decimal
	, reproduction_rate decimal
	, icu_patients decimal
	, icu_patients_per_million decimal
	, hosp_patients int
	, hosp_patients_per_million decimal
	, weekly_icu_admissions decimal
	, weekly_icu_admissions_per_million decimal
	, weekly_hosp_admissions decimal
	, weekly_hosp_admissions_per_million decimal
	, new_tests int
	, total_tests int
	, total_tests_per_thousand decimal
	, new_tests_per_thousand decimal
	, new_tests_smoothed int
	, new_tests_smoothed_per_thousand decimal
	, positive_rate decimal
	, tests_per_case decimal
	, tests_units varchar (255)
	, total_vaccinations int
	, people_vaccinated int
	, people_fully_vaccinated int
	, new_vaccinations int
	, new_vaccinations_smoothed int
	, total_vaccinations_per_hundred decimal
	, people_vaccinated_per_hundred decimal
	, people_fully_vaccinated_per_hundred decimal
	, new_vaccinations_smoothed_per_million int
	, stringency_index decimal
	, population bigint
	, population_density decimal
	, median_age decimal
	, aged_65_older decimal
	, aged_70_older decimal
	, gdp_per_capita decimal
	, extreme_poverty decimal
	, cardiovasc_death_rate decimal
	, diabetes_prevalence decimal
	, female_smokers decimal
	, male_smokers decimal
	, handwashing_facilities decimal
	, hospital_beds_per_thousand decimal
	, life_expectancy decimal 
	, human_development_index decimal
);


create table covid_vaccinations (
	 iso_code varchar (255)
	, continent varchar (255)
	, location varchar (255)
	, case_date DATE
	, new_tests int
	, total_tests int 
	, total_tests_per_thousand decimal 
	, new_tests_per_thousand decimal
	, new_tests_smoothed int
	, new_tests_smoothed_per_thousand decimal
	, positive_rate decimal
	, tests_per_case decimal
	, tests_units varchar (255)
	, total_vaccinations int
	, people_vaccinated int
	, people_fully_vaccinated int
	, new_vaccinations int
	, new_vaccinations_smoothed int
	, total_vaccinations_per_hundred decimal
	, people_vaccinated_per_hundred decimal
	, people_fully_vaccinated_per_hundred decimal
	, new_vaccinations_smoothed_per_million int
	, stringency_index decimal
	, population_density decimal
	, median_age decimal
	, aged_65_older decimal
	, aged_70_older decimal
	, gdp_per_capita decimal
	, extreme_poverty decimal
	, cardiovasc_death_rate decimal
	, diabetes_prevalence decimal
	, female_smokers decimal
	, male_smokers decimal
	, handwashing_facilities decimal
	, hospital_beds_per_thousand decimal
	, life_expectancy decimal
	, human_development_index decimal
);





select * 
from covid_deaths
where continent is not null
order by 3,4


select location, case_date , total_cases, new_cases, total_deaths, population
	from covid_deaths
	order by 1,2
	
-- looking at the total cases vs total deaths
-- shows the likelyhood of dying if you contract covid in your country

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

-- Percentof deaths after vaccination

select dea.continent, dea.location, dea.case_date, dea.population, vac.people_vaccinated, dea.total_deaths
, SUM(vac.people_vaccinated) OVER (Partition by dea.location Order by dea.location, dea.case_date) 
	as totalrollingpeoplevaccinated
--,(totalrollingpeoplevaccinated/total_deaths)*100	
	from covid_deaths dea
	join covid_vaccinations vac
		on dea.location = vac.location
		and dea.case_date = vac.case_date
		where dea.continent is not null 
		order by 2,3

--USE CTE
with peoplevaccinatedvstotaldeaths (continent, location, date, population, totalrollingpeoplevaccinated, total_deaths, people_vaccinated)
as
 (select dea.continent, dea.location, dea.case_date, dea.population, vac.people_vaccinated, dea.total_deaths
, SUM(vac.people_vaccinated) OVER (Partition by dea.location Order by dea.location, dea.case_date) 
	as totalrollingpeoplevaccinated
--,(totalrollingpeoplevaccinated/total_deaths)*100	
	from covid_deaths dea
	join covid_vaccinations vac
		on dea.location = vac.location
		and dea.case_date = vac.case_date
		where dea.continent is not null
	 	--order by 2,3
)
select *, (total_deaths - totalrollingpeoplevaccinated)::decimal / total_deaths * 100 as vac_death_percentage
from peoplevaccinatedvstotaldeaths

select case_date, location, aged_65_older 
from covid_deaths

