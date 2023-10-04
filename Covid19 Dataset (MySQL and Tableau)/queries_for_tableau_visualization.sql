
select sum(new_cases) as total_cases, sum(cast(new_deaths as signed)) as total_deaths, sum(cast(new_deaths as signed)) / sum(new_cases)*100 as DeathPercentage from covid_deaths
where continent is not null
-- group by date
order by 2;


Select location, sum(cast(new_deaths as signed)) as total_deaths
From covid_deaths
-- Where location like '%states%'
Where continent is null OR continent = ''
and location not in ('World', 'European Union', 'International')
Group by location
order by total_deaths desc;


select continent, MAX(cast(Total_deaths as signed)) AS HighestTotalDeaths from covid_deaths
 WHERE continent <> '' AND continent IS NOT NULL 
 group by continent 
 ORDER BY 2 DESC;


Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From covid_deaths
-- Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc;


Select Location, Population, date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From covid_deaths
-- Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc;