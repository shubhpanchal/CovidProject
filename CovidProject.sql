select *
from ProjectPortfolio..CovidDeaths
order by 3,4

select *
from ProjectPortfolio..CovidVaccinations
order by 3,4

select location,date,total_cases, new_cases, total_deaths, population
from ProjectPortfolio..CovidDeaths
order by 1,2

--Looking at Total Cases VS Total Deaths in India
select location, date , total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentages
from ProjectPortfolio..CovidDeaths
where location like '%India%'
order by location, date

--Looking at Total Cases Vs Population
select location, date, total_cases, population, (total_cases/population)*100 as PercentageInfected
from ProjectPortfolio..CovidDeaths
--where location like '%India%'
order by location, date

--Looking at countries with Highest Infection Rate compared to population
select location, population,max(total_cases) as HighestInfectionCount,
max((total_cases/population)*100) as HighestInfectionRate
from ProjectPortfolio..CovidDeaths
group by location, population
order by HighestInfectionRate desc

-- Looking at countries with Highest Death Count per population
select location, max(cast(total_deaths as int)) as DeathCount
from ProjectPortfolio..CovidDeaths
where continent is not null
group by location
order by DeathCount desc

--Lets Breat things down by region
select continent ,max(cast(total_deaths as int)) as DeathCounts
from ProjectPortfolio..CovidDeaths
where continent is not null
group by continent
order by DeathCounts desc

--Global Numbers
select date, sum(new_cases)as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from ProjectPortfolio..CovidDeaths
where continent is not null
Group by date
order by 1,2

select *
from ProjectPortfolio..CovidVaccinations

--Looking at Vaccinations vs Population
With PopvsVac (Continent, Location, Date, Population, NewVaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,Sum(Convert(int, vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
From ProjectPortfolio..CovidDeaths dea
Join ProjectPortfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *,(RollingPeopleVaccinated/Population)*100 as PercentVaccinated
from PopvsVac


-- Temp Table
Drop table if exists PercentPopulationVaccinated
Create Table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) Over (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
From ProjectPortfolio..CovidDeaths dea
join ProjectPortfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100 as PercentVaccinated
from PercentPopulationVaccinated

-- Creating view to store data for later visualizations.
Create View PercentPopulationVaccinated# as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int, vac.new_vaccinations)) Over (Partition by dea.location order by dea.location,
dea.date)as RollingPeopleVaccinated
From ProjectPortfolio..CovidDeaths dea
join ProjectPortfolio..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3