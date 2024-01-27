--Selection queries to view table
select * from EUMRV.dbo.['annualMonitoring']

--Selection queries to view table
SELECT Name, [Ship type], [Annual average Fuel consumption per distance (kg / n mile)], [Annual average CO₂ emissions per distance (kg CO₂ / n mile)], [Time spent at sea (hours)]
from EUMRV.dbo.['averageEfficiency']

--Selection queries to view table
SELECT Name, [Ship type], [Total fuel consumption (m tonnes)], [Total CO₂ emissions (m tonnes)], [CO₂ emissions assigned to Freight transport (m tonnes)] ,[Annual Time spent at sea (hours)]
from EUMRV.dbo.['annualMonitoring']
order by Name, [Total fuel consumption (m tonnes)]

--Percentage of CO2 emission to fuel consumption
SELECT Name, [Ship type], [Total fuel consumption (m tonnes)], [Total CO₂ emissions (m tonnes)], ([Total fuel consumption (m tonnes)]/NULLIF([Total CO₂ emissions (m tonnes)], 0))*100 as fuelConsPercentage
from EUMRV.dbo.['annualMonitoring']
order by Name, [Total fuel consumption (m tonnes)]

--Show percentage of CO2 emission for voyages between Member State ports
SELECT Name, [Ship type], [Total fuel consumption (m tonnes)], [Total CO₂ emissions (m tonnes)], ([CO₂ emissions from all voyages between ports under a MS jurisdic]/NULLIF([Total CO₂ emissions (m tonnes)], 0))*100 as MSVoyageCO2Percentage
from EUMRV.dbo.['annualMonitoring']
where [Ship type] like '%Container%'
order by Name, [Total fuel consumption (m tonnes)]

--Port of registry with highest CO2 emission compared to time at sea
SELECT Name, [Ship type], [Port of Registry], [Annual Time spent at sea (hours)], MAX([Total CO₂ emissions (m tonnes)]) as highestCO2Emission,
MAX(([Total CO₂ emissions (m tonnes)]/NULLIF([Annual Time spent at sea (hours)], 0))) as CO2PerHourRatio
from EUMRV.dbo.['annualMonitoring']
where [Ship type] like '%Container%'
Group by Name, [Ship type], [Port of Registry], [Annual Time spent at sea (hours)]
order by CO2PerHourRatio DESC

--Port of registry with highest CO2 emission 
SELECT [Port of Registry], MAX([Total CO₂ emissions (m tonnes)]) as TotalEmission
from EUMRV.dbo.['annualMonitoring']
where [Port of Registry] is not null
Group by [Port of Registry]
order by TotalEmission DESC

--Ship type with highest CO2 emission 
SELECT [Ship type], MAX([Total CO₂ emissions (m tonnes)]) as TotalEmission
from EUMRV.dbo.['annualMonitoring']
where [Ship type] is not null
Group by [Ship type]
order by TotalEmission DESC

--Ship type with highest fuel consumption 
SELECT [Ship type], MAX([Total fuel consumption (m tonnes)]) as TotalFuelConsumption
from EUMRV.dbo.['annualMonitoring']
where [Ship type] is not null
Group by [Ship type]
order by TotalFuelConsumption DESC

--Global numbers
SELECT [Port of Registry], SUM([Total CO₂ emissions (m tonnes)]) as TotalCO2Emission, SUM([Total fuel consumption (m tonnes)]) as TotalFuelCons,
SUM([Total fuel consumption (m tonnes)])/SUM(NULLIF([Total CO₂ emissions (m tonnes)], 0))*100 as EmissionPercentage
from EUMRV.dbo.['annualMonitoring']
where [Ship type] is not null
and [Port of Registry] is not null
Group by [Port of Registry]
order by TotalCO2Emission DESC

--Global numbers v2
SELECT SUM([Total CO₂ emissions (m tonnes)]) as TotalCO2Emission, SUM([Total fuel consumption (m tonnes)]) as TotalFuelCons,
SUM([Total fuel consumption (m tonnes)])/SUM(NULLIF([Total CO₂ emissions (m tonnes)], 0))*100 as EmissionPercentage
from EUMRV.dbo.['annualMonitoring']
where [Ship type] is not null
and [Port of Registry] is not null
order by TotalCO2Emission DESC

--Look at total CO2 emission and Annual average CO₂ emissions per distance
SELECT am.Name, am.[Ship type], am.[Port of Registry], am.[Total CO₂ emissions (m tonnes)], ave.[Annual average CO₂ emissions per distance (kg CO₂ / n mile)]
From EUMRV.dbo.['annualMonitoring'] am
Join
EUMRV.dbo.['averageEfficiency'] ave
	On am.Name=ave.Name
	and am.[Ship type]=ave.[Ship type]
where am.[Port of Registry] is not null
order by 3, 4

--Rolling CO2 emissions
SELECT am.Name, am.[Ship type], am.[Port of Registry], am.[Total CO₂ emissions (m tonnes)]
, SUM(am.[Total CO₂ emissions (m tonnes)]) OVER (Partition by am.[Ship type] Order by am.[Ship type], am.[Port of Registry] ROWS UNBOUNDED PRECEDING) as rollingCO2Emission 
From EUMRV.dbo.['annualMonitoring'] am
Join
EUMRV.dbo.['averageEfficiency'] ave
	On am.Name=ave.Name
	and am.[Ship type]=ave.[Ship type]
where am.[Port of Registry] is not null
order by 2, 3

--Demonstrating CTE
With FuelvsCO2 ([Name], [Ship type], [Port of Registry], [Total CO₂ emissions (m tonnes)], [Total fuel consumption (m tonnes)], rollingCO2Emission)
as(
SELECT am.Name, am.[Ship type], am.[Port of Registry], am.[Total CO₂ emissions (m tonnes)], am.[Total fuel consumption (m tonnes)]
, SUM(am.[Total CO₂ emissions (m tonnes)]) 
OVER (Partition by am.[Ship type] Order by am.[Ship type], am.[Port of Registry] ROWS UNBOUNDED PRECEDING) as rollingCO2Emission 
From EUMRV.dbo.['annualMonitoring'] am
Join
EUMRV.dbo.['averageEfficiency'] ave
	On am.Name=ave.Name
	and am.[Ship type]=ave.[Ship type]
where am.[Port of Registry] is not null
)

Select *, (rollingCO2Emission/NULLIF(([Total fuel consumption (m tonnes)]), 0))
From FuelvsCO2


--Create view
Create View ShipTypeConsumption as 
SELECT [Ship type], MAX([Total fuel consumption (m tonnes)]) as TotalFuelConsumption
from EUMRV.dbo.['annualMonitoring']
where [Ship type] is not null
Group by [Ship type]

--Access the view creted
Select * from ShipTypeConsumption 
