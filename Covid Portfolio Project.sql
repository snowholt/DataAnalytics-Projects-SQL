-- Test 
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
	1,2 ;

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
	--total_cases = (SELECT MAX(total_cases) FROM PortfolioProject..CovidDeath WHERE location = 'Iran' ) AND
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
	1,2 DESC;


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
-- Table 1 Tableau
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





-- Tableau Tables - This results will be used for creating dashboard in Tableau! Updated Dataset (2023-04-28)

-- We Take These Out As They Are Not Included In The Above Quesries And Want To Stay Consistent  
-- Table 1 Tableau
SELECT 
	--date, 
	SUM(new_cases) AS TotalNewCases,
	SUM(new_deaths) AS TotalNewDeaths,
	SUM(new_deaths) / NULLIF(SUM(new_cases), 0) * 100 AS NewDeathPercentage
FROM 
	PortfolioProject.dbo.CovidData
WHERE 
	continent IS NOT NULL
	--location = 'Iran'
--GROUP BY 
	--date
ORDER BY 
	1,2;



-- Table 2 For Tableau
SELECT 
	location, 
	SUM(CAST(new_deaths AS int)) AS TotalDeathCount

FROM 
	PortfolioProject..CovidData
WHERE 
	continent IS NULL AND
	location NOT IN ( 'World', 'European Union', 'International')
GROUP BY 
	location
ORDER BY
	TotalDeathCount DESC;




-- Table 3 For Tableau
SELECT
	location, 
	population, 
	COALESCE(MAX(total_cases), 0) AS 'HighestInfectionCount', 
	COALESCE(MAX(total_cases / population) * 100, 0) AS 'PercentagePopulationInfected'
	 
FROM
	PortfolioProject..CovidData
GROUP BY 
	location, 
	population
ORDER BY 
	PercentagePopulationInfected DESC;




-- Table 4 Tableau
SELECT
	location, 
	population,
	date,
	COALESCE(MAX(total_cases), 0) AS 'HighestInfectionCount', 
	COALESCE(MAX(total_cases / population) * 100, 0) AS 'PercentagePopulationInfected'
	 
FROM
	PortfolioProject..CovidData
GROUP BY 
	location, 
	population,
	date
ORDER BY 
	PercentagePopulationInfected DESC;




-- Table 5 Tableau
SELECT
	location, 
	population,
	date,
	COALESCE(new_cases, 0) AS 'NewInfectionCount',
	COALESCE(new_deaths, 0) AS 'NewDeathCount'
FROM
	PortfolioProject..CovidData
WHERE 
	continent IS NULL AND
	location NOT IN ( 'World', 'European Union', 'International')
GROUP BY 
	location, 
	population,
	date,
	new_cases,
	new_deaths
ORDER BY 
	NewInfectionCount DESC;



-- To get better insights, I decided to Answer this questions: 
-- 1. How has the number of cases and deaths changed over time?
-- 2. How does the rate of new infections or deaths vary by location?
-- 3. Is there a relationship between population density and the spread of COVID?
-- 4. Are there any trends in the demographic characteristics of people who have been infected or died from COVID?
-- 5. What impact have public health interventions, such as lockdowns and vaccinations, had on the spread of COVID?

-- So, Calculating growth rates to identify the rate of increase in cases and deaths.
-- Table 6 Tableau
SELECT 
  date, 
  total_cases, 
  (total_cases - LAG(total_cases) OVER (ORDER BY date)) / LAG(total_cases) OVER (ORDER BY date) * 100 AS daily_growth_rate
FROM 
	PortfolioProject..CovidData
WHERE
	total_cases IS NOT NULL
ORDER BY 
	date;



-- Using moving averages to smooth out fluctuations and identify trends.
-- Table 7 Tableau
SELECT 
	date, 
	total_cases,
	AVG(total_cases) OVER (ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS '7_day_avg_total_cases'
FROM
	PortfolioProject..CovidData
WHERE
	total_cases IS NOT NULL
ORDER BY 
	date;


-- Comparing data across different regions or countries using per capita rates, calculates the total cases and deaths per 100,000 people using the population data.
-- Table 8 Tableau
SELECT 
  location, 
  date, 
  total_cases / population * 100000 AS cases_per_capita, 
  total_deaths / population * 100000 AS deaths_per_capita
FROM 
	PortfolioProject..CovidData
WHERE
	total_cases IS NOT NULL
ORDER BY 
	location,
	date;


-- Using statistical techniques, such as correlation analysis
-- Table 9 Tableau
SELECT 
	date,
	total_cases, 
	total_deaths
FROM 
	PortfolioProject..CovidData
WHERE
	total_cases IS NOT NULL AND total_deaths IS NOT NULL
ORDER BY 
	date;


