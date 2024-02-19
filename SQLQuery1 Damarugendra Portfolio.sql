Select *
From [Portfolio Project]..CovidDeaths
where continent is not null
order by 3,4

--select * 
--from [Portfolio Project]..CovidVaccinations
--order by 3, 4

--Select data that we are going to be using

Select Location,date,total_cases,new_cases,total_deaths,population
From [Portfolio Project]..CovidDeaths
order by 1,2

--looking at total cases vs total deaths
--shows likelihood of dying if u contract avoid in ur country

Select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
where location like '%states%'
order by 1,2

---looking at Total cases vs population
--shows what percentage of population got covid

Select Location,date,total_cases,population,(total_cases/population)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
where location like '%states%'
order by 1,2

--looking at countries with highest infection rate compared to population

Select Location,Population,MAX(total_cases) as HighestInfectionCount,MAX(total_cases/population)*100 as
 PercentageofpopulationInfected
From [Portfolio Project]..CovidDeaths
--where location like '%states%'
Group by Location,population
order by PercentageofpopulationInfected desc

--showing countries with highest death count per population

Select Location,MAX(total_cases) as TotalDeathcount
From [Portfolio Project]..CovidDeaths
--where location like '%states%'
where continent is not null
Group by Location
order by TotalDeathcount desc

---LET'S BREAK THINGS DOWN BY CONTINENET

--showing continents with the highest death count per population

Select continent,MAX(total_cases) as TotalDeathcount
From [Portfolio Project]..CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathcount desc

--GLOBAL NUMBERS

Select date,SUM(new_cases)as total_cases,sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/SUM(new_cases)*100 as Deathpercentage
From [Portfolio Project]..CovidDeaths
--where location like '%states%'
where continent is not null
Group by date
order by 1,2

--Looking at total population vs vaccination

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int))over (partition by dea.location order by dea.location,dea.date)
as Rollingpeoplevaccinated
from [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3


---TEMP TABLE
create Table #Percentpopulationvaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
Rollingpeoplevaccinated numeric
)

Insert into #Percentpopulationvaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int))over (partition by dea.location order by dea.location,dea.date)
as Rollingpeoplevaccinated
from [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

select *,(Rollingpeoplevaccinated/population)*100
from #Percentpopulationvaccinated

--USE CTE
with popvsvac(continent,location,date,population,New_vaccinations,Rollingpeoplevaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int))over (partition by dea.location order by dea.location,dea.date)
as Rollingpeoplevaccinated
from [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *,(Rollingpeoplevaccinated/population)*100
from popvsvac

---creating view to store data for later visualization


create view percentpopulationvaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int))over (partition by dea.location order by dea.location,dea.date)
as Rollingpeoplevaccinated
from [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select top(1000)[continent]
	,[location]
	,[date]
	,[population]
	,[new_vaccinations]
	,[Rollingpeoplevaccinated]
 from[Portfolio Project].[dbo].[percentpopulationvaccinated]


 select*
 from percentpopulationvaccinated


