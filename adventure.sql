                                                --Performance Analysis of Adventure Works

--DATA EXPLORATION
select top 5 * from newadventureworks..Product
select top 5 * from newadventureworks..Region
select top 5 * from newadventureworks..Reseller
select top 5 * from newadventureworks..sales
select top 5 * from newadventureworks..Salesperson
select top 5 * from newadventureworks..SalespersonRegion
select top 5 * from newadventureworks..Targets

--                                                              Data Cleaning

--For Table Product
-- Checking for duplicate values
select count(*)
from newadventureworks..product
group by productkey
having count(*) >1

-- Checking for Null Values
select *
from newadventureworks..Product
where ProductKey is null or Product is null or standardcost is null or color is null or Subcategory is null
or Category is null or backgroundcolorformat is null or fontcolorformat is null

--Replacing null Values with default Values
Update newadventureworks..Product
set color='Unknown'
where color is null
_____________________________________________________

--For table Region
select count(*)
from newadventureworks..Region
group by SalesTerritoryKey
having count(*) >1

-- Checking for Null Values
select *
from newadventureworks..Region
where SalesTerritoryKey is null or Region is null or Country is null or [group] is null
_______________________________

-- For table Reseller
-- Checking for Duplicates
select count (*)
from newadventureworks..Reseller
group by ResellerKey
having count(*) >1

--Checking for null values
 select *
 from newadventureworks..Reseller
 where ResellerKey is null or businesstype is null or reseller is null or city is null or StateProvince is null or CountryRegion is null 
 _____________________________

-- For table sales
--checking for duplicates
 select salesordernumber,OrderDate,ProductKey,ResellerKey,EmployeeKey,SalesTerritoryKey,Quantity,UnitPrice,sales,Cost,count(*)
 from newadventureworks..sales
 group by salesordernumber,OrderDate,ProductKey,ResellerKey,EmployeeKey,SalesTerritoryKey,Quantity,UnitPrice,sales,Cost
 having count(*) >1

  --checking for null values
 select *
 from newadventureworks..sales
 where salesordernumber is null or OrderDate is null or ProductKey is null or ResellerKey is null or EmployeeKey is null or SalesTerritoryKey is null or 
  Quantity is null or UnitPrice is null or sales is null or Cost is null
  
  --Correcting SalesDate column
  alter table newadventureworks..sales
  add properdate date
  update newadventureworks..sales
  set properdate= cast(substring (orderdate,charindex (',',orderdate)+2,100) as date)
   __________________________

  --For table salespersonregion
  --Checking For duplicates
  select employeekey,SalesTerritoryKey,count(*)
  from newadventureworks..SalespersonRegion
  group by EmployeeKey, SalesTerritoryKey
  having count(*) >1
  -- Checking fro null vales 
  select *
  from newadventureworks..SalespersonRegion
  where EmployeeKey is null or SalesTerritoryKey is null
  ______________________________________________

  --Correcting date format for table Targets
  alter table newadventureworks..targets
  add targetdate  date
  update newadventureworks..targets
  set targetdate=cast(substring (TargetMonth,charindex(',',TargetMonth)+2,100) as date)
  _________________________________________
   --Same procedure for other tables for checking nulls and duplicates
  __________________________________________
 
 
 --                                                                Analysis

  --Top Performing Products on the Basis of Revenue
  select top 10 p.product,round(sum(s.sales),2) as Sales
  from newadventureworks..sales s
  join newadventureworks..Product p on s.productkey=p.productkey
  group by p.product
  order by sales desc
  ________________________________________

  --Top performing products on the basis of Quantity
  select top 10 p.product,sum(s.quantity) as Quantity
  from newadventureworks..sales s
  join newadventureworks..Product p on s.productkey=p.productkey
  group by p.product
  order by quantity desc
  ________________________________________

  --Top performing regions on the basis of revenue generated as well as Quantity sold
  select top 10 r.region,r.country,sum(s.sales)as Sale
  from newadventureworks..sales s
  join newadventureworks..Region r on r.salesterritorykey=s.salesterritorykey
  group by r.region,r.Country
  order by sale desc

  select top 10 r.region,r.country,sum(s.quantity)as Sale
  from newadventureworks..sales s
  join newadventureworks..Region r on r.salesterritorykey=s.salesterritorykey
  group by r.region,r.Country
  order by sale desc
  __________________________________________

  --Categorizing regions on the basis on region performance

 select r.region,r.country,sum(s.sales) as Sales,
  case when sum(s.sales) >6000000 then 'HighPerforming'
  when sum(s.sales) between 3000000 and 6000000 then 'Goodperforming'
  else 'LowPerforming' end as RegionPerformance
 from newadventureworks..sales s
 join newadventureworks..Region r on s.SalesTerritoryKey=r.SalesTerritoryKey
 group by r.Region,r.Country
 ______________________________________________

 --Number of resellers per State
select count(reseller) as ResellerCount,StateProvince
from newadventureworks..Reseller
group by StateProvince
order by ResellerCount desc
   _____________________________________

   --Checking for Quarterly Sales

	SELECT 
    YEAR(s.ProperDate) AS Year,
    DATEPART(QUARTER, s.ProperDate) AS Quarter,
    SUM(s.sales) AS TotalSales
FROM 
    newadventureworks..sales s
GROUP BY 
    YEAR(s.ProperDate),
    DATEPART(QUARTER, s.ProperDate)
ORDER BY 
    Year, Quarter
	____________________________________

 --Top Performing products in in different regions
WITH ProductPerformance AS (
    SELECT 
        r.Region, 
        p.Product,
        p.Category, 
        SUM(s.sales) AS TotalSales
    FROM 
        newadventureworks..sales s
    JOIN 
        newadventureworks..Product p ON s.ProductKey = p.ProductKey
    JOIN 
        newadventureworks..Region r ON s.SalesTerritoryKey = r.SalesTerritoryKey
    GROUP BY 
        r.Region, p.Product, p.Category 
),
RankedProducts AS (
    SELECT 
        Region, 
        Product, 
        Category, 
        TotalSales,
        ROW_NUMBER() OVER (PARTITION BY Region ORDER BY TotalSales DESC) AS Rank
    FROM 
        ProductPerformance
)
SELECT 
    Region, 
    Product, 
    Category, 
    TotalSales,
    Rank
FROM 
    RankedProducts
WHERE 
    Rank <= 10
ORDER BY 
    Region, Rank
	______________________________________________

-- Least Performing products in different regions
WITH ProductPerformance AS (
    SELECT 
        r.Region, 
        p.Product,
        p.Category, 
        SUM(s.sales) AS TotalSales
    FROM 
        newadventureworks..sales s
    JOIN 
        newadventureworks..Product p ON s.ProductKey = p.ProductKey
    JOIN 
        newadventureworks..Region r ON s.SalesTerritoryKey = r.SalesTerritoryKey
    GROUP BY 
        r.Region, p.Product, p.Category 
),
RankedProducts AS (
    SELECT 
        Region, 
        Product, 
        Category, 
        TotalSales,
        ROW_NUMBER() OVER (PARTITION BY Region ORDER BY TotalSales Asc) AS Rank
    FROM 
        ProductPerformance
)
SELECT 
    Region, 
    Product, 
    Category, 
    TotalSales,
    Rank
FROM 
    RankedProducts
WHERE 
    Rank <= 10
ORDER BY 
    Region, Rank;

 ______________________________________

 --Most selling Category
 select p.category, sum(s.quantity) as Totalquantity
 from newadventureworks..product p
 left join newadventureworks..sales s on p.productkey=s.productkey
 group by p.category
 order by TotalQuantity desc

 --Most revenue generating category
 select p.category, sum(s.sales) as TotalSales
 from newadventureworks..product p
 left join newadventureworks..sales s on p.productkey=s.productkey
 group by p.category
 order by TotalSales desc

  --Which color is most preferred on products on the basis of revenue
 select p.color,sum(s.sales) as sales
 from newadventureworks..product p
 left join newadventureworks..sales s on p.productkey=s.productkey
 group by p.color
 order by sales desc

 --Most Preferred color on Categories
 select p.category,p.color,sum(s.quantity) as Quantity
 from newadventureworks..product p
 left join newadventureworks..sales s on p.productkey=s.productkey
 group by p.category,p.color
 order by quantity desc 

  --Most revenue generating color on categories
 select p.category,p.color,sum(s.sales) as Sale
 from newadventureworks..product p
 left join newadventureworks..sales s on p.productkey=s.productkey
 group by p.category,p.color
 order by sale desc 
  _____________________________________
  --Analyzing trends in sales performance

 SELECT 
    MONTH(s.ProperDate) AS Month,
    p.Product AS Product,
	sum(case when year(s.properdate) = 2017 then s.sales else 0 end) as sales_2017,
    SUM(CASE WHEN YEAR(s.ProperDate) = 2018 THEN s.Sales ELSE 0 END) AS Sales_2018,
    SUM(CASE WHEN YEAR(s.ProperDate) = 2019 THEN s.Sales ELSE 0 END) AS Sales_2019
FROM 
    newadventureworks..sales s
LEFT JOIN 
    newadventureworks..product p
ON 
    p.ProductKey = s.ProductKey
GROUP BY 
    MONTH(s.ProperDate), 
    p.Product
ORDER BY 
    Month, Product
	__________________________________

	--Analyzing which product has the most profit margin

SELECT DISTINCT 
    p.Product AS ProductName,
    p.StandardCost,
    s.UnitPrice,
    (s.UnitPrice - p.StandardCost) AS GrossProfitPerUnit,
   ((s.UnitPrice - p.StandardCost) / s.UnitPrice) * 100
     AS ProfitMarginPercentagePerUnit
FROM 
    newadventureworks..sales s
JOIN 
    newadventureworks..Product p ON s.ProductKey = p.ProductKey
ORDER BY 
    ProfitMarginPercentagePerUnit DESC;

--Since we just found out that same product is showing different gross profit it indicates that it could be due to discounts offered or different pricing strategies
--for different regions or different prices at different time in a year or it could also mean our cogs have went up.

	_______________________________________

    -- Checking whether our employees are meeting the targets or not
	select sa.employeekey,sa.salesperson,t.target,sum(s.sales) as sales,month(t.targetdate) as month,
	case when sum(s.sales)>= t.target then 'TargetMet' else 'TargetNotMet' end as MetOrNOt
	from newadventureworks..sales s
	left join newadventureworks..salesperson sa on s.employeekey=sa.employeekey
	left join newadventureworks..targets t on t.employeeid=sa.employeeid
	group by sa.employeekey,t.target,sa.salesperson,month(t.targetdate)
	order by sa.employeekey
	--Employee 277 has no data in sales table 
	______________________________________

	--Ranking employees on the basis of performane
	SELECT 
    sa.salesperson,
    SUM(s.sales) AS TotalSales,
    RANK() OVER (ORDER BY SUM(s.sales) DESC) AS SalesRank
   FROM 
    newadventureworks..sales s
   LEFT JOIN 
    newadventureworks..salesperson sa ON s.employeekey = sa.employeekey
   GROUP BY 
    sa.salesperson
   ORDER BY 
    SalesRank;

   --Contribution of products towards revenue

SELECT 
    p.Product, 
    SUM(s.Sales) AS Sales, 
    (SUM(s.Sales) / (SELECT SUM(sales) FROM newadventureworks..sales) * 100) AS ContributionPercentage
FROM 
    newadventureworks..sales s
LEFT JOIN 
    newadventureworks..product p ON s.ProductKey = p.ProductKey
GROUP BY 
    p.Product
ORDER BY 
    ContributionPercentage DESC;
	___________________________________

	--Checking for YOY Change

	WITH YearlySales AS (
    SELECT 
        YEAR(s.ProperDate) AS Year,
        SUM(s.sales) AS TotalSales
    FROM 
        newadventureworks..sales s
    GROUP BY 
        YEAR(s.ProperDate)
)
SELECT 
    Year,
    TotalSales AS Sales_Current_Year,
    LAG(TotalSales) OVER (ORDER BY Year) AS Sales_Previous_Year,
    -- YoY Growth Calculation: 
    CASE 
        WHEN LAG(TotalSales) OVER (ORDER BY Year) IS NULL THEN NULL
        ELSE (TotalSales - LAG(TotalSales) OVER (ORDER BY Year)) / LAG(TotalSales) OVER (ORDER BY Year) * 100
    END AS YoY_Growth_Percentage
FROM 
    YearlySales
ORDER BY 
    Year;

