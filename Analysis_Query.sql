-- In this Table information about Covid Cases and Deaths

SELECT * FROM dbo.CovidDeath
select * From .dbo.CovidVaccination

--Delete Continent Where is NULL

DELETE From dbo.CovidDeath
Where continent IS NULL;

-- Data Exploration ( Select Important Columns )

SELECT location, date, new_cases, total_cases, total_deaths, population
From dbo.CovidDeath
Order By 1,2

-- How Much Percentage of Total Death on Total Cases in India

SELECT location, date, new_cases, total_cases, total_deaths, deathpct = CAST(total_deaths as float) / CAST(total_cases as float)*100 ,population
From dbo.CovidDeath
Where location LIKE '%India%'
Order By deathpct desc

-- How Much Percentage of Total Cases on Total Population in India

SELECT location, date, new_cases, total_cases, total_deaths, casespct = CAST(total_cases as float) / CAST(population as float)*100 ,population
From dbo.CovidDeath
Where location LIKE '%India%'
Order By casespct desc

--In Which Country is Highest Covid Cases Infected Percentage
--In Which Country is Highest Covid Deaths Infected Percentage

Select location, MAX(total_cases)/population*100 As HighestCases, population
From dbo.CovidDeath
Group By location, population
Order By HighestCases desc

Select location, MAX(total_deaths)/population*100 As HighestDeaths, population
From dbo.CovidDeath
Group By location, population
Order By HighestDeaths desc

-- Day Wise Total No. of New Cases and Deaths

Select location, date, SUM(new_cases) As New_Cases_per_Day, SUM(new_deaths) As New_Deaths_per_Day, population
From dbo.CovidDeath
Group By date, location, population
Order By date

-- In Which Day Highest Percentage Death Ratio 

Select date, SUM(new_deaths) As New_death_perday, SUM(new_cases) New_Cases_perday,
CASE
	When SUM(new_cases) != 0
	Then CAST(SUM(new_deaths) as float)/CAST(SUM(new_cases) as float)*100
	Else 0
END Ratio_of_Death_Per_day
From dbo.CovidDeath
Where continent IS NOT Null
Group By Date
Order By Ratio_of_Death_Per_day DESC

-- Join Both Tables Covid Death and Covid Vaccines

Select *
From dbo.CovidDeath As CD
Join dbo.CovidVaccination As CV
on CD.date = CV.date and CD.location = CV.location

-- New Vaccination Data of India

Select cd.date, cd.location, cd.continent, cv.new_vaccinations, cd.population
From dbo.CovidDeath As cd
Join dbo.CovidVaccination As cv
on cd.date = cv.date and cd.location = cv.location
Where cd.location like '%india%'

-- Rolling Up Count of New Vaccination

Select cd.date, cd.location, cv.new_vaccinations, SUM(convert(bigint,cv.new_vaccinations)) Over (Partition By cd.location order by cd.location, cd.date) As Rolling_Count, cd.population
From dbo.CovidDeath As cd
Join dbo.CovidVaccination As cv
on cd.date = cv.date and cd.location = cv.location
order by 2,1

-- How many Percentage vaccination completed in which location

Select cd.date, cd.location, cv.new_vaccinations, cv.total_vaccinations, CAST(cv.total_vaccinations as float) / CAST(cd.population as float) *100 As PCT_Vaccine, cd.population
From dbo.CovidDeath As cd
Join dbo.CovidVaccination As cv
on cd.date = cv.date and cd.location = cv.location
Where cd.location Like '%India%'
Order By PCT_Vaccine DESC

-- using CTE

With vaccine (date, location, new_vaccinations, total_vaccinations, population)
as
(
Select cd.date, cd.location, cv.new_vaccinations, cv.total_vaccinations, cd.population
From dbo.CovidDeath As cd
Join dbo.CovidVaccination As cv
on cd.date = cv.date and cd.location = cv.location
)
Select *, CAST(vaccine.total_vaccinations as float) / CAST(vaccine.population as float) *100 As PCT_Vaccine
From vaccine
Where vaccine.location Like '%India%'
Order By PCT_Vaccine DESC