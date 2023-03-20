select * from PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

--select * from PortfolioProject..CovidVaccinations$
--order by 3,4

select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths$
order by 1, 2


--1) Analysis: Total cases vs Total Deaths
--shows likelihood of dying if you contract covid in your country
select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercent
from PortfolioProject..CovidDeaths$
where location like '%India%'
order by 1, 2

--2) Total cases VS Population
--Sshows what % of population got Covid
select location,date,total_cases,population, (total_cases/population)*100 as PercentofPopulationInfected
from PortfolioProject..CovidDeaths$
where location like '%India%'
order by 1, 2

--3) Looking at coun tries with highest infection  rate compared to population

select location,population,Max(total_cases) as highestInfectionCount, Max((total_cases/population))*100 as PercentofPopulationInfected
from PortfolioProject..CovidDeaths$
group by location,population
order by 4 desc

--4) showing the countries with highest death count per population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null
group by location
order by 2 Desc

--5) lets break it by continent


--showing continents with the highest death count per population

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null
group by continent
order by 2 Desc

--Global Numbers


select sum(new_cases) as total_cases,sum(cast(new_deaths as int))as total_deaths, sum(cast(new_deaths as int))/Sum(New_cases)*100 as  DeathPercentage
from PortfolioProject..CovidDeaths$
--where location like '%India%'
where continent is not null
--group by date
order by 1, 2

	--Looking at total population vs vaccinations
	select cd.continent,cv.location,cd.date,cd.population,cv.new_vaccinations,sum(convert(int,cv.new_vaccinations)) over (Partition by cd.location order by cd.location,cd.date)
	as RollingPeopleVaccinated, --(RollingPeopleVaccinated/population)*100
	from PortfolioProject..CovidDeaths$ cd
	join PortfolioProject..CovidVaccinations$ cv
		on cd.location=cv.location
		and cd.date=cv.date
	where cd.continent is not null
	order by 1,2,3

	--USe CTE
	with PopvsVac (Continent, location,date,population, new_vaccinations,RollingPeopleVaccinated)
	as
	(
		--Looking at total population vs vaccinations
	select cd.continent,cv.location,cd.date,cd.population,cv.new_vaccinations,sum(convert(int,cv.new_vaccinations)) over (Partition by cd.location order by cd.location,cd.date)
	as RollingPeopleVaccinated --(RollingPeopleVaccinated/population)*100
	from PortfolioProject..CovidDeaths$ cd
	join PortfolioProject..CovidVaccinations$ cv
		on cd.location=cv.location
		and cd.date=cv.date
	where cd.continent is not null
	--order by 2,3
	)
	select *,(RollingPeopleVaccinated/population)*100
	from PopvsVac
	--where location like'%Albania%'



---Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select cd.continent,cv.location,cd.date,cd.population,cv.new_vaccinations,sum(convert(int,cv.new_vaccinations)) over (Partition by cd.location order by cd.location,cd.date)
	as RollingPeopleVaccinated --(RollingPeopleVaccinated/population)*100
	from PortfolioProject..CovidDeaths$ cd
	join PortfolioProject..CovidVaccinations$ cv
		on cd.location=cv.location
		and cd.date=cv.date
	--where cd.continent is not null
	--order by 2,3

	select *,(RollingPeopleVaccinated/population)*100
	from #PercentPopulationVaccinated
	--where location like'%Albania%'


	--Creating a view to store data for later Visualizations

	Create view PercentPopulationVaccinated as
	select cd.continent,cv.location,cd.date,cd.population,cv.new_vaccinations,sum(convert(int,cv.new_vaccinations)) over (Partition by cd.location order by cd.location,cd.date)
	as RollingPeopleVaccinated --(RollingPeopleVaccinated/population)*100
	from PortfolioProject..CovidDeaths$ cd
	join PortfolioProject..CovidVaccinations$ cv
		on cd.location=cv.location
		and cd.date=cv.date
	where cd.continent is not null
	--order by 2,3

	select *
	from PercentPopulationVaccinated