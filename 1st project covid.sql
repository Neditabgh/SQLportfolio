select * 
from PortfolioProject..coviddeaths
where location='World'
order by 3,4

--select * 
--from PortfolioProject..covidvaccinations
--order by 3,4

--select Data that we are going to be using

select location, date, total_cases, new_cases,total_deaths, population
from PortfolioProject..coviddeaths
where continent is not null
order by 1,2

--Looking at Total cases vs Total deaths in US
--shows liklihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from PortfolioProject..coviddeaths
where location like '%state%'
order by 1,2

--Looking at the total cases vs population in US
select location, date, total_cases, population, (total_deaths/population)*100 as populationpercentage
from PortfolioProject..coviddeaths
where location like '%state%'
order by populationpercentage desc

--Looking at countries with highest infection rate compare to population
select location, population, max(total_cases) as highestinfectionarte, max((total_cases/population))*100 as percentpopulationinfected
from PortfolioProject..coviddeaths
where continent is not null
group by location, population
order by  percentpopulationinfected desc

--Showing the countries with the highest death count or population

select location, population, max(cast(total_deaths as int)) as highestdeathrate,
max((total_deaths/population))*100 as percentpopulationdeath
from PortfolioProject..coviddeaths
where continent is not null
group by location, population
order by  percentpopulationdeath desc

--Break things by continent
select continent,  max(cast(total_deaths as int)) as highestdeathrate,
max((total_deaths/population))*100 as percentpopulationdeath
from PortfolioProject..coviddeaths
where continent is not null 
group by continent
order by  percentpopulationdeath desc

-- Global Numbers by date
select  date, sum(new_cases) as totalcases, sum(cast(total_deaths as int)) as totaldeaths,
sum(cast(total_deaths as int))/sum(new_cases)*100 as deathpercentage
from PortfolioProject..coviddeaths
--where location like '%state%'
where continent  is not null
group by date
order by 1,2

--global number
select   sum(new_cases) as totalcases, sum(cast(total_deaths as int)) as totaldeaths,
sum(cast(total_deaths as int))/sum(new_cases)*100 as deathpercentage
from PortfolioProject..coviddeaths
--where location like '%state%'
where continent  is not null
order by 1,2

 
--Looking at toal population Vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by  dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 