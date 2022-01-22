select * 
from PortfolioProject..covidDeaths
--Because Some of the data present in the dataset have no continent
Where continent is not null
order by 3,4;

--select * 
--from PortfolioProject..covidVaccination
--order by 3,4;

--selecting data that need to be used

select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..covidDeaths
Where continent is not null
order by 1,2;

--Looking at the death percentage

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..covidDeaths
order by 1,2;

--Looking at the death percentage in India

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..covidDeaths
Where location='India' and continent is not null
order by 1,2;

--Looking at total cases vs total population
--Shows what percentage of population got Covid

select location,date,total_cases,population,(total_cases/population)*100 as TotalCasePercentage
from PortfolioProject..covidDeaths
order by 1,2;

--Shows what percentage of population got Covid in India

select location,date,total_cases,population,(total_cases/population)*100 as TotalCasePercentage
from PortfolioProject..covidDeaths
where location = 'India' and continent is not null
order by 1,2;


--Looking at countries with highest infection rate as compared to  population

select location,population,MAX(total_cases) as HighestInfected,MAX((total_cases/population))*100 as InfectionRate
from PortfolioProject..covidDeaths
Group by location,population
order by InfectionRate desc;

--Showing countries with highest Death Count per population

select location , MAX(CAST(total_deaths as INT)) as DeathCount
from PortfolioProject..covidDeaths
Where continent is not null
Group by location
order by DeathCount desc;

--Showing Countries with highest Death Percentage

select location,population,MAX(CAST(total_deaths as INT)) as HighestDeath,MAX((total_deaths/population))*100 as DeathRate
from PortfolioProject..covidDeaths
Where continent is not null
Group by location,population
order by DeathRate desc; 

--Breaking down data by continent

--Showing Continents with highest Death count per population

select continent , MAX(CAST(total_deaths as INT)) as DeathCount
from PortfolioProject..covidDeaths
Where continent is not null
Group by continent
order by DeathCount desc;

--Global Numbers

--Showing total cases , deaths  and death percentage by date

select cast(PortfolioProject..covidDeaths.date as date) as Date,SUM(new_cases) as TotalCasesByDate,SUM(cast(new_deaths as int)) as TotalDeathsByDate, (SUM(cast(new_deaths as int))/SUM(new_cases)*100) as TotalDeathPercent
from PortfolioProject..covidDeaths
Where continent is not null
Group by date
order by 1;

--Showing total numbers 

select SUM(new_cases) as TotalCases,SUM(cast(new_deaths as int)) as TotalDeath, (SUM(cast(new_deaths as int))/SUM(new_cases)*100) as TotalDeathPercent
from PortfolioProject..covidDeaths
Where continent is not null
;

--Looking at Total population vs vaccinations

Select cd.continent, cd.location, cd.population ,cast(cd.date as date) as Date, cv.new_vaccinations 
From PortfolioProject..covidDeaths cd
join PortfolioProject..covidVaccination cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
Order by 2,3; 

 --Showing Rolling sum of people vaccinated in a location

Select cd.continent, cd.location, cd.population ,cast(cd.date as date), cv.new_vaccinations
 ,SUM(cast(cv.new_vaccinations as bigint)) over(Partition by cd.location Order by cd.location, cd.date) as RollingPeopleVaccinated
From PortfolioProject..covidDeaths cd
join PortfolioProject..covidVaccination cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
Order by 2,3;

--Using CTE


with popvsvac(Continent, location, population, Date,new_vaccination,RollingPeopleVaccinated)
as
(
Select cd.continent, cd.location, cd.population ,cd.date as date, cv.new_vaccinations
 ,SUM(cast(cv.new_vaccinations as bigint)) over(Partition by cd.location Order by cd.location, cd.date) as RollingPeopleVaccinated
From PortfolioProject..covidDeaths cd
join PortfolioProject..covidVaccination cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
)
Select *,(RollingPeopleVaccinated/population)*100 as RollingPercentage
from popvsvac
;

--Using Temp Table

Drop table if exists #percentPopulationVaccinated
Create Table #percentPopulationVaccinated
(Continent nvarchar(255),
 Location nvarchar(255),
 population numeric,
 date datetime,
 new_vaccinations numeric,
 RollingPeopleVaccinated  numeric
 );
Insert into #percentPopulationVaccinated
Select cd.continent, cd.location, cd.population ,cd.date, cv.new_vaccinations
 ,SUM(cast(cv.new_vaccinations as bigint)) over(Partition by cd.location Order by cd.location, cd.date) as RollingPeopleVaccinated
From PortfolioProject..covidDeaths cd
join PortfolioProject..covidVaccination cv
	on cd.location = cv.location
	and cd.date = cv.date
	where cd.continent is not null;

Select *,(RollingPeopleVaccinated/population)*100 as RollingPercentage
from #percentPopulationVaccinated;


--Cerating view to store data for later data visuaalization

Create View percentPopulationVaccinated as
Select cd.continent, cd.location, cd.population ,cd.date, cv.new_vaccinations
 ,SUM(cast(cv.new_vaccinations as bigint)) over(Partition by cd.location Order by cd.location, cd.date) as RollingPeopleVaccinated
From PortfolioProject..covidDeaths cd
join PortfolioProject..covidVaccination cv
	on cd.location = cv.location
	and cd.date = cv.date
	where cd.continent is not null;








 


