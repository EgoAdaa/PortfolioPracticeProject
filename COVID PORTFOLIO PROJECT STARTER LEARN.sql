
Select *
From Portfolio_project..CovidDeaths
Where continent is not null
Order By 3,4


--Select *
--From Portfolio_project..CovidVaccinations
--Order By 3,4


 Select location, date, total_cases,new_cases, total_deaths,population
 From Portfolio_Project..CovidDeaths
 Where continent is not null
 Order By 1,2

--Total deaths vs Total cases

Select location, date, total_cases,total_deaths,population, (total_deaths/total_cases)*100 as DeathPercentage
 From Portfolio_Project..CovidDeaths
 Order By 1,2

 -- Total case Vs Population i.e percentsage of population that has covid

 Select location, date, total_cases, population, (total_cases/population)*100  as InfectedPersonsPercent
 from Portfolio_Project..CovidDeaths
 Where location like '%states%'
 Order by 1,2

 -- Looking at countries with Higher population

 Select location, population, MAX(total_cases) as HighestInfectCount, MAX ((total_cases/population))*100 as InfectedPersonsPercent
 From Portfolio_Project..CovidDeaths
 Group By location, population
 Order By InfectedPersonsPercent desc
 
 -- This is ahowing countries with the highest death count per population

 Select location, MAX( cast (Total_deaths as int)) as TotalDeathCount
 From Portfolio_Project..CovidDeaths
 Where continent is not null
 Group by Location
 Order by TotalDeathCount desc

 -- Lets try continents

 Select location, MAX( cast (Total_deaths as int)) as TotalDeathCount
 From Portfolio_Project..CovidDeaths
 Where continent is null
 Group by location
 Order by TotalDeathCount desc

 
 Select continent, MAX( cast (Total_deaths as int)) as TotalDeathCount
 From Portfolio_Project..CovidDeaths
 Where continent is not null
 Group by continent
 Order by TotalDeathCount desc

 -- GLOBAL NUMBERS

 Select  date, SUM (new_cases) , SUM (cast (new_deaths as int)), SUM( cast( new_deaths as int)) / SUM (new_cases)*100 as DeathPercentage
 From Portfolio_Project..CovidDeaths
 Where continent is not null
 Group by date
 Order By 1,2

 -- Looking at total population Vs Vaccination

 Select*
 From Portfolio_Project..CovidDeaths dea
 Join Portfolio_Project..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date

  -- Here

  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 From Portfolio_Project..CovidDeaths dea
 Join Portfolio_Project..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
  Where dea.continent is not null
  Order by 2,3

  -- Rolling count. Sum of the new vaccation by their location.
  -- Had to convert to bigint as the sum value has exceeded 2,147,483,674
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
  ,SUM( cast (vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date)as RollingPeopleVaccinated
 From Portfolio_Project..CovidDeaths dea
 Join Portfolio_Project..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
  Where dea.continent is not null
  Order by 2,3

--USE CTE

with PopvsVac (Continient, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
  ,SUM( cast (vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date)as RollingPeopleVaccinated
 From Portfolio_Project..CovidDeaths dea
 Join Portfolio_Project..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
  Where dea.continent is not null
  -- Order by 2,3
  )
  Select*, (RollingPeopleVaccinated/population)*100
  from PopvsVac

  --Temp table

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

  insert into #PercentPopulationVaccinated
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
  ,SUM( cast (vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date)as RollingPeopleVaccinated
 From Portfolio_Project..CovidDeaths dea
 Join Portfolio_Project..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
  Where dea.continent is not null
  -- Order by 2,3

  Select*, (RollingPeopleVaccinated/population)*100
  from #PercentPopulationVaccinated

  --- Creating View To Store Data For Later Visualisation.

  Create View PercentPopulationVaccinated2 as
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
  ,SUM( cast (vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date)as RollingPeopleVaccinated
 From Portfolio_Project..CovidDeaths dea
 Join Portfolio_Project..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
  Where dea.continent is not null
  --Order by 2,3
