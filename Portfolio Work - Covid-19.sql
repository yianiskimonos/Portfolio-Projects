-- Covid-19 Data Exploration

-- An Overview of Covid-19

SELECT *
FROM 
	Covid19.dbo.CovidDeaths
WHERE 
	continent is not null

-- Select Data that we are going to be starting with

SELECT 
	Location, 
	Date, 
	total_cases, 
	total_deaths, 
	(total_deaths/total_cases)*100 as DeathPercentage
FROM 
	Covid19.dbo.CovidDeaths
WHERE 
	continent is not null

-- A comparison of the Total Deaths VS Total Cases Worldwide
--Shows the Risk of Fatality Upon contracting COVID-19

SELECT 
	Location, 
	Date, 
	total_cases, 
	total_deaths, 
	(total_deaths/total_cases)*100 as DeathPercentage
FROM 
	Covid19.dbo.CovidDeaths
Where 
	continent is not null

-- Check a specific country; UK

SELECT 
	Location, 
	Date, 
	total_cases, 
	total_deaths, 
	(total_deaths/total_cases)*100 as DeathPercentage
FROM 
	Covid19.dbo.CovidDeaths
Where 
	location like '%United kingdom%' and continent is not null

-- A comparison of the Total Cases vs Population 
-- Shows the percentage of the population that got Covid-19 overtime in the UK

SELECT 
	Location, 
	Date, 
	Population, 
	total_cases, 
	(total_cases/Population)*100 as PercentPopulationInfected
FROM 
	Covid19.dbo.CovidDeaths

-- Check a specific country; UK

SELECT 
	Location, 
	Date, 
	Population, 
	total_cases, 
	(total_cases/Population)*100 as PercentPopulationInfected
FROM 
	Covid19.dbo.CovidDeaths
Where 
	location like '%United kingdom%'

-- Countries with the Highest Infection Rate compared to Population

SELECT 
	Location, 
	Population, 
	MAX(total_cases) as HighestInfectionCount, 
	MAX((total_cases/Population))*100 as PercentPopulationInfected
FROM 
	Covid19.dbo.CovidDeaths
--Where location like '%United kingdom%'
Group by 
	Location, 
	Population
Order by 
	PercentPopulationInfected DESC

-- Countries with Highest Death Count per Population

SELECT 
	Location, 
	MAX(cast(total_deaths as int)) as TotalDeathCount
FROM 
	Covid19.dbo.CovidDeaths
--Where location like '%United kingdom%'
WHERE 
	continent is not null
Group by 
	Location, 
	Population
Order by 
	TotalDeathCount DESC

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population

SELECT 
	continent, 
	MAX(cast(total_deaths as int)) as TotalDeathCount
FROM 
	Covid19.dbo.CovidDeaths
WHERE 
	continent is not null
Group by 
	continent
order by 
	TotalDeathCount DESC

-- GLOBAL NUMBERS 

SELECT 
	date, 
	SUM(new_cases)  as total_cases, 
	SUM(cast(new_deaths as int)) as total_deaths, 
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 as GlobalDeathPercentage
FROM 
	Covid19.dbo.CovidDeaths
--Where location like '%United kingdom%'
Where 
	continent is not null
Group by 
	date

-- Total Population VS Vacciantions
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(Cast(vac.new_vaccinations as int))
OVER 
	(Partition by dea.location order by dea.location, dea.date) as CumulativeSumOfVaccinated
FROM 
	Covid19.dbo.CovidDeaths dea
JOIN 
	Covid19.dbo.CovidVaccinations vac
	On 
		dea.location = vac.location
	and 
		dea.date = vac.date
Where 
	dea.continent is not null
Order by 
	2,3

-- Using CTE to perform Calculations on Partition By in previous query

With PopvsVac (Continent, 
				Location, 
				Date, 
				Population, 
				New_vaccinations, 
				CumulativeSumOfVaccinated)
as
(
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(Cast(vac.new_vaccinations as int)) 
OVER 
	(Partition by dea.location order by dea.location, dea.date) as CumulativeSumOfVaccinated
FROM 
	Covid19.dbo.CovidDeaths dea
JOIN 
	Covid19.dbo.CovidVaccinations vac
	On 
		dea.location = vac.location
	and 
		dea.date = vac.date
Where 
	dea.continent is not null
)
SELECT *, 
		(CumulativeSumOfVaccinated/Population)*100
FROM 
	PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
CumulativeSumOfVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.Date) as CumulativeSumOfVaccinated
FROM 
	Covid19.dbo.CovidDeaths dea
JOIN 
	Covid19.dbo.CovidVaccinations vac
	On 
		dea.location = vac.location
	and 
		dea.date = vac.date
--Where dea.continent is not null

SELECT *, (CumulativeSumOfVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--Creating View to store data for later visualisations

Create View PercentPopulationVaccinated as
SELECT
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.Date) as CumulativeSumOfVaccinated
FROM 
	Covid19.dbo.CovidDeaths dea
JOIN 
	Covid19.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

-- A look at UK Covid-19 rate vs US Covid-19 rate
-- Shows the percentage of each country over time that has contracted Covid-19

SELECT
    UK.Location AS UK_Location,
    UK.Date AS UK_Date,
    UK.Population AS UK_Population,
    UK.total_cases AS UK_TotalCases,
    (UK.total_cases / UK.Population) * 100 AS UK_PercentPopulationInfected,
    US.Location AS US_Location,
    US.Date AS US_Date,
    US.Population AS US_Population,
    US.total_cases AS US_TotalCases,
    (US.total_cases / US.Population) * 100 AS US_PercentPopulationInfected
FROM
    (
        SELECT
            Location,
            Date,
            Population,
            total_cases
        FROM
            Covid19.dbo.CovidDeaths
        WHERE
            Location LIKE '%United Kingdom%'
    ) AS UK
JOIN
    (
        SELECT
            Location,
            Date,
            Population,
            total_cases
        FROM
            Covid19.dbo.CovidDeaths
        WHERE
            Location LIKE '%United States%'
    ) AS US ON UK.Date = US.Date;

-- A look at the Death rate UK vs US

SELECT
    UK.Location AS UK_Location,
    UK.Date AS UK_Date,
    UK.total_cases AS UK_TotalCases,
    UK.total_deaths AS UK_TotalDeaths,
    (UK.total_deaths / UK.total_cases) * 100 AS UK_DeathPercentage,
    US.Location AS US_Location,
    US.Date AS US_Date,
    US.total_cases AS US_TotalCases,
    US.total_deaths AS US_TotalDeaths,
    (US.total_deaths / US.total_cases) * 100 AS US_DeathPercentage
FROM
    (
        SELECT
            Location,
            Date,
            total_cases,
            total_deaths
        FROM
            Covid19.dbo.CovidDeaths
        WHERE
            Location LIKE '%United Kingdom%'
    ) AS UK
JOIN
    (
        SELECT
            Location,
            Date,
            total_cases,
            total_deaths
        FROM
            Covid19.dbo.CovidDeaths
        WHERE
            Location LIKE '%United States%'
    ) AS US ON UK.Date = US.Date;

-- The total death count in UK vs US

SELECT
    UK.Location AS UK_Location,
    UK.Date AS UK_Date,
    UK.total_deaths AS UK_TotalDeaths,
    US.Location AS US_Location,
    US.Date AS US_Date,
    US.total_deaths AS US_TotalDeaths
FROM
    (
        SELECT
            Location,
            Date,
            total_deaths
        FROM
            Covid19.dbo.CovidDeaths
        WHERE
            Location LIKE '%United Kingdom%'
    ) AS UK
JOIN
    (
        SELECT
            Location,
            Date,
            total_deaths
        FROM
            Covid19.dbo.CovidDeaths
        WHERE
            Location LIKE '%United States%'
    ) AS US ON UK.Date = US.Date;

-- The Percentage of the population that died through time UK vs US
SELECT
    UK.Location AS UK_Location,
    UK.Date AS UK_Date,
    UK.total_deaths AS UK_TotalDeaths,
    UK.Population AS UK_Population,
    (UK.total_deaths / UK.Population) * 100 AS UK_PercentPopulationDeaths,
    US.Location AS US_Location,
    US.Date AS US_Date,
    US.total_deaths AS US_TotalDeaths,
    US.Population AS US_Population,
    (US.total_deaths / US.Population) * 100 AS US_PercentPopulationDeaths
FROM
    (
        SELECT
            Location,
            Date,
            total_deaths,
            Population
        FROM
            Covid19.dbo.CovidDeaths
        WHERE
            Location LIKE '%United Kingdom%'
    ) AS UK
JOIN
    (
        SELECT
            Location,
            Date,
            total_deaths,
            Population
        FROM
            Covid19.dbo.CovidDeaths
        WHERE
            Location LIKE '%United States%'
    ) AS US ON UK.Date = US.Date;





















