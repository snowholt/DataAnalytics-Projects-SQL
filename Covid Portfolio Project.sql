-- test 
SELECT	
	*
FROM 
	PortfolioProject.dbo.CovidDeath
ORDER BY 
	3,4;

SELECT	
	*
FROM 
	PortfolioProject.dbo.CovidVaccinations
ORDER BY 
	3,4;



-- CovidDeath Table
-- Select the data that we are going to use.
SELECT 
	location, 
	date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	population
FROM 
	PortfolioProject.dbo.CovidDeath
ORDER BY 
	1,2;



-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying by covid infection in Iran
SELECT 
	location, 
	date, 
	total_cases,  
	total_deaths, 
	(total_deaths / total_cases) * 100 AS 'DeathRatioPercentage'
FROM 
	PortfolioProject.dbo.CovidDeath
WHERE 
	location = 'Iran'
ORDER BY 
	1,2;

-- Shows the latest statistic ratio of dying by covid in Iran 
SELECT location, 
	date, 
	total_cases,  
	total_deaths, 
(	total_deaths / total_cases) * 100 AS 'DeathRatioPercentage'
FROM 
	PortfolioProject.dbo.CovidDeath
WHERE 
	(location = 'Iran') AND 
	total_cases = (SELECT MAX(total_cases) FROM PortfolioProject..CovidDeath WHERE location = 'Iran' ) AND
	date = (SELECT MAX(date) FROM PortfolioProject..CovidDeath WHERE location = 'Iran' );




-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid
SELECT 
	location, 
	date, 
	total_cases,  
	population, 
	(total_cases / population) * 100 AS 'InfectionRatioPercentage'
FROM 
	PortfolioProject.dbo.CovidDeath
WHERE 
	location = 'Iran'
ORDER BY 
	1,2;


-- Shows the latest statistical ratio of infection with covid in Iran 
SELECT 
	location, 
	date, 
	total_cases,  
	population, 
	(total_cases / population) * 100 AS 'InfectionRatioPercentage'
FROM 
	PortfolioProject.dbo.CovidDeath
WHERE 
	location = 'Iran' AND
	total_cases = (SELECT MAX(total_cases) FROM PortfolioProject..CovidDeath WHERE location = 'Iran' ) AND
	date = (SELECT MAX(date) FROM PortfolioProject..CovidDeath WHERE location = 'Iran' );



-- Looking at Countries with Highest Infection Rate compared to Population
SELECT 
	location,
	population,
	MAX(total_cases) AS HighestInfectionCount,  
	MAX((total_cases / population) * 100) AS 'InfectionRatioPercentage'
FROM 
	PortfolioProject.dbo.CovidDeath
WHERE 
	continent IS NOT NULL
GROUP BY 
	location, 
	population
ORDER BY 
	InfectionRatioPercentage DESC;



-- Showing Countries with Highest Death Count per Population
SELECT 
	location,
	MAX(CAST (total_deaths AS int)) AS TotalDeathCount,  
	MAX((total_deaths / population) * 100) AS 'DeathRatioPercentage'
FROM 
	PortfolioProject.dbo.CovidDeath
WHERE 
	continent IS NOT NULL
GROUP BY 
	location
ORDER BY 
	TotalDeathCount DESC;



-- LET's BREAK THINGS DOWN BY CONTINENT
SELECT 
	location,
	MAX(CAST (total_deaths AS int)) AS TotalDeathCount
	
FROM 
	PortfolioProject.dbo.CovidDeath
WHERE 
	continent IS NULL
GROUP BY 
	location
ORDER BY 
	TotalDeathCount DESC;


-- Showing Continents With The Highest Death Count Per Population

SELECT 
	continent,
	MAX(CAST (total_deaths AS int)) AS TotalDeathCount
	
FROM 
	PortfolioProject.dbo.CovidDeath
WHERE 
	continent IS NOT NULL
GROUP BY 
	continent
ORDER BY 
	TotalDeathCount DESC;




-- GLOBAL NUMBERS
SELECT 
	--date, 
	SUM(new_cases) AS TotalNewCases,
	SUM(new_deaths) AS TotalNewDeaths,
	SUM(new_deaths) / NULLIF(SUM(new_cases), 0) * 100 AS NewDeathPercentage
FROM 
	PortfolioProject.dbo.CovidDeath
WHERE 
	continent IS NOT NULL
	--location = 'Iran'
--GROUP BY 
	--date
ORDER BY 
	1,2;



-- We Take These Out As They Are Not Included In The Above Quesries And Want To Stay Consistent  
SELECT 
	location, 
	SUM(CAST(new_deaths AS int)) AS TotalDeathCount

FROM 
	PortfolioProject..CovidDeath
WHERE 
	continent IS NULL AND
	location NOT IN ( 'World', 'European Union', 'International')
GROUP BY 
	location
ORDER BY
	TotalDeathCount DESC

-- Table 2 For Tableau
SELECT
	location, 
	population, 
	MAX(total_cases) AS HighestInfectionCount, 
	MAX(total_cases / population) * 100 AS PercentagePopulationInfected
FROM
	PortfolioProject..CovidDeath
GROUP BY 
	location, population
ORDER BY 
	PercentagePopulationInfected DESC




-- Looking at Total Population vs Vaccinations
SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(bigint,vac.new_vaccinations)) OVER( PARTITION BY dea.location ORDER BY dea.location, dea.date) AS 
		RollingPeopleVacinated
FROM
	PortfolioProject.dbo.CovidDeath dea
	JOIN
	PortfolioProject.dbo.CovidVaccinations vac
	ON
	dea.location = vac.location
	AND
	dea.date = vac.date
WHERE
	dea.continent IS NOT NULL
ORDER BY
	2,
	3;



-- USE CTE
WITH 
	PopvsVac (continent, location, date, population, new_vacination, RollingPeopleVacinated)
	AS
	(
	SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(bigint,vac.new_vaccinations)) OVER( PARTITION BY dea.location ORDER BY dea.location, dea.date) AS 
		RollingPeopleVacinated
FROM
	PortfolioProject.dbo.CovidDeath dea
	JOIN
	PortfolioProject.dbo.CovidVaccinations vac
	ON
	dea.location = vac.location
	AND
	dea.date = vac.date
WHERE
	dea.continent IS NOT NULL
--ORDER BY
	--2,
	--3
	)
SELECT 
	*,
	(RollingPeopleVacinated / population * 100) AS RPCRationPercentage
FROM
	PopvsVac;



-- Finding Max number of RPC per location.
WITH 
	PopvsVac (continent, location, date, population, new_vacination, RollingPeopleVacinated)
	AS
	(
	SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(bigint,vac.new_vaccinations)) OVER( PARTITION BY dea.location ORDER BY dea.location, dea.date) AS 
		RollingPeopleVacinated
FROM
	PortfolioProject.dbo.CovidDeath dea
	JOIN
	PortfolioProject.dbo.CovidVaccinations vac
	ON
	dea.location = vac.location
	AND
	dea.date = vac.date
WHERE
	dea.continent IS NOT NULL
--ORDER BY
	--2,
	--3
	)
SELECT 
	location,
	MAX(RollingPeopleVacinated),
	MAX(RollingPeopleVacinated / population * 100) AS RPCRationPercentage

FROM
	PopvsVac
GROUP BY
	location
ORDER By
	3 DESC;




-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	newVaccinations numeric,
	rollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
	SELECT
		dea.continent,
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM(CONVERT(bigint,vac.new_vaccinations)) OVER( PARTITION BY dea.location ORDER BY dea.location, dea.date) AS 
			RollingPeopleVacinated
	FROM
		PortfolioProject.dbo.CovidDeath dea
		JOIN
		PortfolioProject.dbo.CovidVaccinations vac
		ON
		dea.location = vac.location
		AND
		dea.date = vac.date
	WHERE
		dea.continent IS NOT NULL;


SELECT 
	*,
	(rollingPeopleVaccinated / population * 100) AS RPCRationPercentage
FROM #PercentPopulationVaccinated;
	



-- Creating View To Store Data For Later Visualization
USE PortfolioProject
GO
Create VIEW PercentPopulationVaccinated AS
	SELECT
		dea.continent,
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM(CONVERT(bigint,vac.new_vaccinations)) OVER( PARTITION BY dea.location ORDER BY dea.location, dea.date) AS 
			RollingPeopleVacinated
	FROM
		PortfolioProject.dbo.CovidDeath dea
		JOIN
		PortfolioProject.dbo.CovidVaccinations vac
		ON
		dea.location = vac.location
		AND
		dea.date = vac.date
	WHERE
		dea.continent IS NOT NULL;
	--ORDER BY
		--2,
		--3;

-- Test View Table
SELECT 
	*
FROM
	PercentPopulationVaccinated;