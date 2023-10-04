
-- first glance of data
select * from covid_deaths;

-- listing columns and data types
describe covid_deaths;

-- converting representation of date column
UPDATE covid_deaths
SET date = STR_TO_DATE(date, '%m/%d/%Y');

-- looking at data after sorting location and date column in ascending order
select * from covid_deaths order by 3, 4;

-- extracting data for analysis
select location, date, population, total_cases, new_cases, total_deaths from covid_deaths order by 1, 2;

-- start date and the last date in the data
SELECT MIN(date) AS first_date, MAX(date) AS last_date
FROM covid_deaths;

-- Death % in relation to total cases by date
select location, date, population, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS percentage_total_deaths from covid_deaths order by 1, 2;

-- Death % in relation to total cases by date for specific location
select location, date, population, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS percentage_total_deaths from covid_deaths where location = 'India' order by 1, 2;

-- Total cases % in relation to population by date for specific location
select location, date, population, total_cases, (total_cases / population) * 100 AS percentage_total_cases from covid_deaths where location like '%states%' order by 1, 2;

-- Highest infection rate for locations worldwide during the pendamic
select LOCATION, MAX(total_cases) AS HighestTotalCount, MAX(total_deaths) AS HighestTotalDeaths, max((total_cases / population)) * 100 AS PercentagePopulationInfected
from covid_deaths group by location ORDER BY 4 DESC;

-- Highest total death count for locations worldwide during the pendamic
select LOCATION, MAX(cast(Total_deaths as signed)) AS HighestTotalDeaths from covid_deaths WHERE continent <> '' AND continent IS NOT NULL group by location ORDER BY 2 DESC;

-- Highest total death count by continent based on column location
select location, MAX(cast(Total_deaths as signed)) AS HighestTotalDeaths from covid_deaths WHERE continent IS NULL OR continent = '' group by location ORDER BY 2 DESC;

-- Highest total death count by continent based on column continent
select continent, MAX(cast(Total_deaths as signed)) AS HighestTotalDeaths from covid_deaths WHERE continent <> '' AND continent IS NOT NULL group by continent ORDER BY 2 DESC;

-- Worldwide death % by date
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as signed)) as total_deaths, sum(cast(new_deaths as signed)) / sum(new_cases)*100 as DeathPercentage from covid_deaths
where continent is not null
group by date
order by 2;

-- joining covid_death and covid_vaccinations

-- listing columns and data types
describe covid_vaccinations;

-- -- converting representation of date column
UPDATE covid_vaccinations
SET date = STR_TO_DATE(date, '%m/%d/%Y');

-- Displaying data from both tables
select * from covid19_db.covid_deaths as dea
join covid19_db.covid_vaccinations as vac
	on dea.location = vac.location
    and dea.date = vac.date;

-- Percentage of total population vaccinated around the globe as per location
-- use CTE
    WITH PopvsVac (Continent, Location, Date, Population, NewVaccinations, RollingPeopleVaccinated)
AS
(
    SELECT
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
    FROM
        covid19_db.covid_deaths AS dea
    JOIN
        covid19_db.covid_vaccinations AS vac
        ON dea.location = vac.location AND dea.date = vac.date
    WHERE
        dea.continent IS NOT NULL
)
SELECT
    *,
    (RollingPeopleVaccinated / Population) * 100 AS PercentageVaccinated
FROM
    PopvsVac;

    
-- Creating Temporary Table from the above data

DROP TABLE IF EXISTS PercentPopulationVaccinated;

CREATE TEMPORARY TABLE PercentPopulationVaccinated
(
    Continent VARCHAR(255),
    Location VARCHAR(255),
    Date DATETIME,
    Population DECIMAL(18,2), 
    New_vaccinations DECIMAL(18,2) SIGNED, 
    RollingPeopleVaccinated DECIMAL(18,2) 
);

INSERT INTO PercentPopulationVaccinated
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    CASE
        WHEN vac.new_vaccinations REGEXP '^[0-9]+(\.[0-9]+)?$' THEN vac.new_vaccinations
        ELSE 0 -- or any default value you prefer
    END AS New_vaccinations,
    SUM(COALESCE(NULLIF(vac.new_vaccinations, ''), 0)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM
    covid19_db.covid_deaths AS dea
JOIN
    covid19_db.covid_vaccinations AS vac
    ON dea.location = vac.location AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL;

-- Select from the temporary table
SELECT
    *,
    (RollingPeopleVaccinated / Population) * 100 AS PercentageVaccinated
FROM
    PercentPopulationVaccinated;


-- Creating View from the above data
Create View PercentPopulationVaccinated as
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations as signed)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM
    covid19_db.covid_deaths AS dea
JOIN
    covid19_db.covid_vaccinations AS vac
    ON dea.location = vac.location AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL;
