Select *
From PortfolioProject.dbo.CovidDeaths
where continent is not null
Order by 3,4

--Select *
--From PortfolioProject.dbo.CovidVaccinations
--Order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeaths
Order By 1,2

-- Exploring Total Cases vs Total Deaths
-- shows the likelihood of dying if you contract COVID in Australia

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
Where location like '%australia%'
Order By 1,2

-- Total Cases vs Population
-- shows the percentage of population who have contracted COVID

Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths
Where location like '%australia%'
Order By 1,2

-- Countries with Highest Infection Rate compared to population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as 
PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths
where continent is not null
Group By location, population
Order By PercentPopulationInfected desc

-- countries with Highest Death Count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
where continent is not null
Group By location
Order By TotalDeathCount desc


-- breaking things down by continent

-- continents with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
Group By continent
Order By TotalDeathCount desc

-- Global Numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
-- Where location like '%australia%'
Where continent is not null
Group By date
Order By 1,2

-- total population vs vaccinations



-- using CTE

With PopvsVac (Continent, Location, Date, Population, NewVaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) Over (Partition By dea.location Order By dea.location,
dea.date) as RollingVaccinated
--(RollingVaccinated/population)*100
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order By 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- temp table

Drop Table if exists #PercentPopulationVaccinated 
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) Over (Partition By dea.location Order By dea.location,
dea.date) as RollingVaccinated
--(RollingVaccinated/population)*100
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- creating views to store data for later visulisations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) Over (Partition By dea.location Order By dea.location,
dea.date) as RollingVaccinated
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order By 2,3

Select *
From PercentPopulationVaccinated