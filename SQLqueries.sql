--Find the total sales across all orders

SELECT
	SUM(Sales) AS Total_sales
FROM Sales.Orders;

--Find the total sales for each product

SELECT
	ProductID,
	SUM(Sales) Total_sales
FROM Sales.Orders
GROUP BY ProductID;

--Find the total sales for each product. Additionally, provide details such as order id & order date

SELECT
	OrderID,
	OrderDate,
	ProductID,
	SUM(Sales) OVER(PARTITION BY ProductID) AS Total_sales_by_product
FROM Sales.Orders;

--Find the total sales across all orders. Additionally, provide details such as order id & order date

SELECT
	OrderID,
	OrderDate,
	SUM(Sales) OVER() Total_sales
FROM Sales.Orders;

--Rank each order based on their sales from the highest to the lowest.

SELECT 
	OrderID,
	Sales,
	RANK() OVER(ORDER BY Sales DESC) AS Sales_rank
FROM Sales.Orders

--Rank the customers based on their total sales

SELECT
	CustomerID,
	SUM(Sales) AS Total_sales_by_customer,
	RANK() OVER(ORDER BY SUM(Sales) DESC) AS Sales_rank_by_customer
FROM Sales.Orders
GROUP BY CustomerID;

--Find the total number of orders

SELECT 
	COUNT(*) Total_orders
FROM Sales.Orders;

/*Find the total number of orders
Provide details such as order id and order date
*/

SELECT 
	OrderID,
	OrderDate,
	COUNT(*) OVER() Total_orders
FROM Sales.Orders;

-- Find the total number of orders for each customer

SELECT 
	CustomerID,
	COUNT(OrderID) OVER(PARTITION BY CustomerID) AS Sales_by_customer
FROM Sales.Orders;

/*Find the total number of customers
Additionally, provide all customer's details
*/

SELECT
	FirstName,
	LastName,
	Country,
	COUNT(*) OVER() Total_number_of_customers
FROM Sales.Customers;

--Find the total number of scores for customers

SELECT
	COUNT(Score) AS Customer_score_count
FROM Sales.Customers;

-- Check whether the table 'orders' contains any duplicate rows

SELECT
	OrderID,
	COUNT(*) AS CheckPK
FROM Sales.Orders
GROUP BY OrderID;

SELECT
	OrderID,
	COUNT(*) AS CheckPK
FROM Sales.OrdersArchive
GROUP BY OrderID;

/*Find the total sales accross all orders
and the total sales for each product
Additionally, provide details such as order id and order date*/

SELECT
	OrderID,
	OrderDate,
	ProductID,
	SUM(Sales) OVER(PARTITION BY ProductID) AS Sale_by_product,
	SUM(Sales) OVER() AS Total_sales
FROM Sales.Orders;

--Find the percentage contribution of each product's sales to the total sales

SELECT
	*,
	ROUND(CAST(Sales AS FLOAT)/Total_sales * 100.0, 0) AS Pecentage_of_total
FROM
(
SELECT
	ProductID,
	Sales,
	SUM(Sales) OVER() AS Total_sales
FROM Sales.Orders
)t
/* Find the average sales across all orders
and the average sales for each product.
Additionally, provide details such as order id and order date.*/

SELECT
	OrderID,
	OrderDate,
	ProductID,
	AVG(Sales) OVER() AS AvgSalesAllOrders,
	AVG(Sales) OVER(PARTITION BY ProductID) AvgSalesByProduct
FROM Sales.Orders;

/* Find the average scores of customers.
Additionally, provide details such as customer Id and Last Name.*/

SELECT
	CustomerID,
	LastName,
	Score,
	AVG(Score) OVER() AS AvgScoresWithNull,
	AVG(COALESCE(Score, 0)) OVER() AS AvgScores
FROM Sales.Customers;

/* Find all orders where the sales
are higher than the average sales across all orders*/

SELECT * 
FROM
(
	SELECT 
		OrderID,
		Sales,
		AVG(Sales) OVER() AvgSales
	FROM Sales.Orders
)t
WHERE Sales > AvgSales;
/* Find the highest and lowest sales across all orders
and the highest and lowest sales for each product.
Additionally, provide details such as order id and order date.*/

SELECT
	OrderID,
	OrderDate,
	Sales,
	ProductID,
	MIN(Sales) OVER(PARTITION BY ProductID) AS MinSalesByProduct,
	MAX(Sales) OVER(PARTITION BY ProductID) AS MaxSalesByProduct,
	MIN(Sales) OVER() AS MinSalesOverall,
	MAX(Sales) OVER() AS MaxSalesOverall
FROM Sales.Orders;

--Show the employees with the highest salaries

SELECT
	*
FROM
(
	SELECT 
		*,
		MAX(Salary) OVER() AS HighestSalary
	FROM Sales.Employees
)t
WHERE Salary = HighestSalary;

-- Find the deviation of each sale from the minimum and the maximum sales amount

SELECT
	OrderID,
	OrderDate,
	Sales,
	ProductID,
	MIN(Sales) OVER(PARTITION BY ProductID) AS MinSalesByProduct,
	MAX(Sales) OVER(PARTITION BY ProductID) AS MaxSalesByProduct,
	MIN(Sales) OVER() AS MinSalesOverall,
	MAX(Sales) OVER() AS MaxSalesOverall,
	Sales - MIN(Sales) OVER() AS DevFromMin,
	Sales - MAX(Sales) OVER() AS DevFromMax
FROM Sales.Orders;

--Calculate the moving average of sales for each product over time

SELECT
	OrderDate,
	ProductID,
	Sales,
	AVG(Sales) OVER(PARTITION BY ProductID ORDER BY OrderDate) AS AvgSalesOverTime
FROM Sales.Orders;

--Calculate the moving average of sales for each product over time including only the next order.

SELECT
	OrderDate,
	ProductID,
	Sales,
	AVG(Sales) OVER(PARTITION BY ProductID ORDER BY OrderDate) AS AvgSalesOverTime,
	AVG(Sales) OVER(PARTITION BY ProductID ORDER BY OrderDate ROWS BETWEEN CURRENT ROW AND 1 FOLLOWING) AS AvgSalesOverTime2
FROM Sales.Orders;

--Rank the orders based on their sales from the highest to the lowest

SELECT
	OrderID,
	Sales,
	ROW_NUMBER() OVER(ORDER BY Sales DESC) SalesRank
FROM Sales.Orders;

--Rank the orders based on their sales from the highest to the lowest using the rank function

SELECT
	OrderID,
	Sales,
	RANK() OVER(ORDER BY Sales DESC) SalesRank
FROM Sales.Orders;

--Rank the orders based on their sales from the highest to the lowest using the dense rank function

SELECT
	OrderID,
	Sales,
	DENSE_RANK() OVER(ORDER BY Sales DESC) SalesRank
FROM Sales.Orders;

--Find the top highest sales for each product

SELECT *
FROM
(
	SELECT
		OrderID,
		ProductID,
		Sales,
		DENSE_RANK() OVER(PARTITION BY ProductID ORDER BY Sales DESC) RankbyProduct
	FROM Sales.Orders
)t
WHERE RankbyProduct = 1;

--Find the lowest 2 customers based on their total sales

SELECT
	*
FROM
(
	SELECT
		c.FirstName,
		c.LastName,
		c.CustomerID,
		SUM(COALESCE(o.Sales, 0)) AS TotalSales,
		RANK() OVER(ORDER BY SUM(COALESCE(o.Sales, 0))) AS TSalesRank
	FROM Sales.Orders AS o
		FULL JOIN Sales.Customers AS c
			ON o.CustomerID = c.CustomerID
	GROUP BY c.FirstName, c.LastName, c.CustomerID
)t

WHERE TSalesRank <=2;

/*Identify duplicate rows in the table 'Orders Archive'
and return a clean result without duplicates*/

SELECT *
FROM
(
SELECT 
	ROW_NUMBER() OVER(PARTITION BY ProductID, CustomerID, OrderDate ORDER BY CreationTime DESC) AS UniqueID,
	*
FROM Sales.OrdersArchive
)t
WHERE UniqueID = 1;

--Segment all orders into 3 categories: high, medium, and low sales.

SELECT
	*,
	CASE
		WHEN SalesBucket = 1 THEN 'High Sales'
		WHEN SalesBucket = 2 THEN 'Medium Sales'
		WHEN SalesBucket = 3 THEN 'Low Sales'
	END AS SalesCategory
FROM
(
	SELECT
		OrderID,
		Sales,
		NTILE(3) OVER(ORDER BY Sales DESC) AS SalesBucket
	FROM Sales.Orders
)t
-- Find the products that fall within the highest 40% of prices
SELECT
	Product,
	Price,
	PercentRank 
FROM
(
SELECT 
	Product,
	Price,
	CUME_DIST() OVER(ORDER BY Price DESC) * 100 AS PercentRank
FROM Sales.Products
)t
WHERE PercentRank <= 40;
--Analyze MoM performance
SELECT
	*,
	COALESCE(ROUND(((CAST(TotalSales AS FLOAT) - PrevMonthSales)/PrevMonthSales) * 100,1), 0) AS MoMGrowth
FROM
(
SELECT
	MONTH(OrderDate) AS PMonth,
	SUM(Sales) AS TotalSales,
	LAG(SUM(Sales)) OVER(ORDER BY MONTH(OrderDate)) AS PrevMonthSales
FROM Sales.Orders
GROUP BY MONTH(OrderDate)
)t

--Analyze customer loyalty by ranking customers based on the average number of days between orders

SELECT
	*,
	DENSE_RANK() OVER(ORDER BY AvgDaystoOrder) AS AvgDaysRank
FROM
(
	SELECT
		*,
		DATEDIFF(day, OrderDate, NextOrderDate) AS DaysTillNextOrder,
		AVG(DATEDIFF(day, OrderDate, NextOrderDate)) OVER(PARTITION BY CustomerID) AS AvgDaystoOrder
	FROM
	(
		SELECT
			CustomerID,
			OrderDate,
			LEAD(OrderDate) OVER(PARTITION BY CustomerID ORDER BY OrderDate) AS NextOrderDate
		FROM Sales.Orders
)t)w

--Analyze customer loyalty by ranking customers based on the average number of days between orders

SELECT
	*,
	DENSE_RANK() OVER(ORDER BY COALESCE(AvgDaystoOrder, 9999)) AS AvgDaysRank
FROM
(
	SELECT
		*,
		DATEDIFF(day, OrderDate, NextOrderDate) AS DaysTillNextOrder,
		AVG(DATEDIFF(day, OrderDate, NextOrderDate)) OVER(PARTITION BY CustomerID) AS AvgDaystoOrder
	FROM
	(
		SELECT
			CustomerID,
			OrderDate,
			LEAD(OrderDate) OVER(PARTITION BY CustomerID ORDER BY OrderDate) AS NextOrderDate
		FROM Sales.Orders
)t)w

--Find the lowest and highest sales for each product

SELECT
	ProductID,
	Sales,
	MAX(Sales) OVER(PARTITION BY ProductID) AS MaxSales,
	MIN(Sales) OVER(PARTITION BY ProductID) AS MinSales,
	FIRST_VALUE(Sales) OVER(PARTITION BY ProductID ORDER BY Sales DESC) AS MaxSalesF,
	LAST_VALUE(Sales) OVER(PARTITION BY ProductID ORDER BY Sales DESC ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS MinSalesL
FROM Sales.Orders;
--Combine the data from employees and customers into one table including duplicates.

SELECT
	FirstName,
	LastName
FROM Sales.Employees
	UNION ALL
SELECT
	FirstName,
	LastName
FROM Sales.Customers;

--Find the employees who are not customers at the same time.

SELECT
	FirstName,
	LastName
FROM Sales.Employees
	EXCEPT
SELECT
	FirstName,
	LastName
FROM Sales.Customers;

--Find the employees who are also customers at the same time.

SELECT
	FirstName,
	LastName
FROM Sales.Employees
	INTERSECT
SELECT
	FirstName,
	LastName
FROM Sales.Customers;

--Orders are stored in separate tables(Orders and OrderArchive). Combine all orders into one report without duplicates.

SELECT
	[OrderID]
      ,[ProductID]
      ,[CustomerID]
      ,[SalesPersonID]
      ,[OrderDate]
      ,[ShipDate]
      ,[OrderStatus]
      ,[ShipAddress]
      ,[BillAddress]
      ,[Quantity]
      ,[Sales]
      ,[CreationTime]
FROM Sales.Orders
	UNION
SELECT
	[OrderID]
      ,[ProductID]
      ,[CustomerID]
      ,[SalesPersonID]
      ,[OrderDate]
      ,[ShipDate]
      ,[OrderStatus]
      ,[ShipAddress]
      ,[BillAddress]
      ,[Quantity]
      ,[Sales]
      ,[CreationTime]
FROM Sales.OrdersArchive;

/* Generate a report showing the sales for each category:
	-High: If the sales are higher than 50
	-Medium: If the sales are between 20 and 50
	-Low: If the sales are equal to or lower than 20
Sort the result from lowest to highest. */

SELECT
	ProductID,
	Sales,
	CASE	
		WHEN Sales > 50 THEN 'High'
		WHEN Sales >= 20 AND Sales < 50 THEN 'Medium'
		ELSE 'Low'
	END AS SalesBucket
FROM Sales.Orders
ORDER BY Sales;

/* Generate a report showing the total sales for each category:
	-High: If the sales are higher than 50
	-Medium: If the sales are between 20 and 50
	-Low: If the sales are equal to or lower than 20
Sort the result from lowest to highest. */

SELECT
	SalesBucket,
	SUM(Sales) AS TotalSalesByBucket
FROM
(
SELECT
	ProductID,
	Sales,
	CASE	
		WHEN Sales > 50 THEN 'High'
		WHEN Sales >= 20 AND Sales < 50 THEN 'Medium'
		ELSE 'Low'
	END AS SalesBucket
FROM Sales.Orders
)t
GROUP BY SalesBucket
ORDER BY TotalSalesByBucket;

--Find the average scores of customers and treat NULLS as 0
--Additionally, provide details such as Customer ID and LastName

SELECT
	CustomerID,
	LastName,
	Score,
	CASE 
		WHEN Score IS NULL THEN 0
		ELSE Score
	END AS ScoreNoNull,
	AVG(Score) OVER() AS AvgScore,
	AVG(COALESCE(Score,0)) OVER() AS AvgScore2

FROM Sales.Customers;

--Count how many times each customer has made an order with sales greater than 30

SELECT
	CustomerID,
	SUM(CASE
		WHEN Sales > 30 THEN 1 
		ELSE 0
	END) AS SalesBucketCount
FROM Sales.Orders
GROUP BY CustomerID;

--Display the full names of customers in a single field by merging their first name and last names and add 10 bonus points for each customers

SELECT
	CustomerID,
	CONCAT(ISNULL(FirstName,''),' ', ISNULL(LastName,'')) AS FullName,
	ISNULL(Score,0) AS NewScore,
	ISNULL(Score,0) + 10 AS UpgradedScore
FROM Sales.Customers;

--How many orders were placed each year?

SELECT
	YEAR(OrderDate) AS YearOfOrder,
	COUNT (DISTINCT(OrderID)) AS TotalOrders
FROM Sales.Orders
GROUP BY YEAR(OrderDate);

--How many orders were placed each month?

SELECT
	MONTH(OrderDate) AS MonthOfOrder,
	DATENAME(month, OrderDate) AS MonthOfOrderN,
	COUNT (DISTINCT(OrderID)) AS TotalOrders
FROM Sales.Orders
GROUP BY MONTH(OrderDate),
	DATENAME(month, OrderDate)
ORDER BY MONTH(OrderDate);
--Show creation time using the following format
-- Day Wed Jan Q1 2025 12:34:56 PM

SELECT
	OrderID,
	CreationTime,
	'Day ' + FORMAT(CreationTime, 'ddd MMM') +
	' Q'+ DATENAME(quarter, CreationTime)+ ' ' + FORMAT(CreationTime, 'yyyy hh:mm:ss tt') AS newtime
FROM Sales.Orders;

--Calculate the age of employees

SELECT
	EmployeeID,
	FirstName +' '+ LastName AS FullName,
	DATEDIFF(year, BirthDate, GETDATE()) AS Age
	
FROM Sales.Employees;
--Find the average shipping duration in days for each month.

SELECT
	DATENAME(month, OrderDate) AS OrderDate,
	AVG(DATEDIFF(day, OrderDate, ShipDate)) AS AvgDeliveryDuration
FROM Sales.Orders
GROUP BY DATENAME(month, OrderDate);

--Find the number of days between each order and the previous order.

SELECT
	OrderID,
	OrderDate,
	LAG(OrderDate) OVER(ORDER BY OrderDate) PrevOrderDate,
	DATEDIFF(day, LAG(OrderDate) OVER(ORDER BY OrderDate), OrderDate) DaysBetweenOrders
FROM Sales.Orders;

--Find the products that have a price higher than the average price of all products

SELECT
[ProductID]
      ,[Product]
      ,[Category]
      ,[Price]
FROM Sales.Products 
WHERE Price > (SELECT AVG(Price) FROM Sales.Products);

--Rank the customers based on their total amount of sales
SELECT
	*,
	DENSE_RANK() OVER(ORDER BY TotalSales DESC) AS SalesRank
FROM
	(
	SELECT
		c.CustomerID,
		SUM(o.Sales) AS TotalSales
	FROM Sales.Customers AS c
	LEFT JOIN Sales.Orders AS o
	ON c.CustomerID = o.CustomerID
	GROUP BY c.CustomerID
	)t
--Show the details of orders made by customers in Germany

SELECT 
	*
FROM Sales.Orders
WHERE CustomerID IN (SELECT CustomerID FROM Sales.Customers WHERE Country = 'Germany')

--Show the details sof orders made by customers not in Germany

SELECT 
	*
FROM Sales.Orders
WHERE CustomerID IN (SELECT CustomerID FROM Sales.Customers WHERE Country != 'Germany')

--Show the details sof orders made by customers not in Germany

SELECT 
	*
FROM Sales.Orders
WHERE CustomerID NOT IN (SELECT CustomerID FROM Sales.Customers WHERE Country = 'Germany')

--Step 1. Find the total Sales Per Customer using CTE
--Step 2. Find the last order date for each customer
WITH SalesTable AS
(SELECT
	CustomerID,
	SUM(Sales) AS TotalSales
FROM Sales.Orders
GROUP BY CustomerID),

OrdersTable AS
(
SELECT
	CustomerID,
	MAX(OrderDate) AS LastOrderDate
FROM Sales.Orders
GROUP BY CustomerID
)

SELECT
	c.CustomerID,
	c.FirstName,
	c.LastName,
	t.TotalSales,
	o.LastOrderDate
FROM Sales.Customers AS c
LEFT JOIN SalesTable AS t
ON c.CustomerID = t.CustomerID
LEFT JOIN OrdersTable AS o
ON c.CustomerID = o.CustomerID;

--Generate a series of numbers between 1 to 20

WITH Series AS 
(
SELECT
	1 AS MyNum
UNION ALL
SELECT
	MyNum + 1
FROM Series
WHERE MyNum <= 20
)
SELECT
	*
FROM Series;
--Provide a view that combines details from orders, products, customers, and employees

	SELECT
		o.OrderID,
		o.OrderDate,
		p.Product,
		p.Category,
		COALESCE(c.FirstName,'') +' '+ COALESCE(c.LastName,'') AS CustomerName,
		c.Country,
		e.Department,
		o.Sales,
		o.Quantity
	FROM Sales.Orders AS o
	LEFT JOIN Sales.Products AS p
	ON o.ProductID = p.ProductID
	LEFT JOIN Sales.Customers AS c
	ON o.CustomerID = c.CustomerID
	LEFT JOIN Sales.Employees AS e
	ON o.SalesPersonID = e.EmployeeID
	)
--Provide a view that combines details from orders, products, customers, and employees for EU Sales team
--And excludes data related to the US

CREATE VIEW Sales.V_Order_Details_EU AS
(
	SELECT
		o.OrderID,
		o.OrderDate,
		p.Product,
		p.Category,
		COALESCE(c.FirstName,'') +' '+ COALESCE(c.LastName,'') AS CustomerName,
		c.Country,
		e.Department,
		o.Sales,
		o.Quantity
	FROM Sales.Orders AS o
	LEFT JOIN Sales.Products AS p
	ON o.ProductID = p.ProductID
	LEFT JOIN Sales.Customers AS c
	ON o.CustomerID = c.CustomerID
	LEFT JOIN Sales.Employees AS e
	ON o.SalesPersonID = e.EmployeeID
	WHERE c.Country != 'USA'
	)
--Create new table for monthly orders
SELECT
	DATENAME(month, OrderDate) AS OrderMonth,
	COUNT(OrderID) AS TotalOrders
	INTO Sales.MonthlyOrders
FROM Sales.Orders
GROUP BY DATENAME(month, OrderDate)

IF OBJECT_ID('Sales.MonthlyOrders', 'U') IS NOT NULL
	DROP TABLE Sales.MonthlyOrders
GO
SELECT
	DATENAME(month, OrderDate) AS OrderMonth,
	COUNT(OrderID) AS TotalOrders
INTO Sales.MonthlyOrders
FROM Sales.Orders
GROUP BY DATENAME(month, OrderDate)

--Find the highest and lowest sales across all orders
--and the highest and the lowest sales for each product
--Additionally, provide details such as order ID and order date.

SELECT
	OrderID,
	ProductID,
	Sales,
	MAX(Sales) OVER() AS HighestSales,
	MIN(Sales) OVER() AS LowestSales,
	MAX(Sales) OVER(PARTITION BY ProductID) AS HighestSalesProduct,
	MIN(Sales) OVER(PARTITION BY ProductID) AS LowestSalesProduct
FROM Sales.Orders;

--Show the employees who has the highest salaries
SELECT
	*
FROM
(
SELECT
	EmployeeID,
	Salary,
	MAX(Salary) OVER() AS HighestSalary
FROM 
	Sales.Employees)t
WHERE Salary = HighestSalary;

--Find the deviation of each sales from the minimum and maximum sales 
SELECT
	OrderID,
	ProductID,
	Sales,
	MAX(Sales) OVER() AS HighestSales,
	Sales - MAX(Sales) OVER() AS DevFromMax,
	MIN(Sales) OVER() AS LowestSales,
	Sales - MIN(Sales) OVER() AS DevFromMin
FROM Sales.Orders;

--Calculate the moving average of sales for each period over time

SELECT
	OrderDate,
	Sales,
	AVG(Sales) OVER(ORDER BY OrderDate) AS MASales
FROM Sales.Orders

--Rank the orders based on their sales from the highest to the lowest

SELECT
	OrderID,
	Sales,
	RANK() OVER(ORDER BY Sales DESC) AS OrdersRank,
	ROW_NUMBER() OVER(ORDER BY Sales DESC) AS RowNumberRank,
	DENSE_RANK() OVER(ORDER BY Sales DESC) AS DenseRank
FROM Sales.Orders

--Find the top n highest sales for each product

SELECT
	ProductID,
	Sales,
	ROW_NUMBER() OVER(PARTITION BY ProductID ORDER BY Sales DESC) AS TopSales
FROM Sales.Orders

--Find the lowest 2 customers based on their total sales
SELECT
	*
FROM
(
	SELECT
		CustomerID,
		SUM(Sales) AS TotalSales,
		ROW_NUMBER() OVER(ORDER BY SUM(Sales)) AS SalesRankAsc
	FROM 
		Sales.Orders
	GROUP BY CustomerID)t
WHERE SalesRankAsc <= 2;

--Assign unique IDs for the rows of the 'Orders Archive' Table

SELECT
	ROW_NUMBER() OVER(ORDER BY OrderDate) UniqueID,
	*
FROM Sales.OrdersArchive;
--Identify duplicate rows in the table 'Orders Archive'
-- and return a clean result without duplicate
SELECT
*
	FROM
	(
	SELECT
		ROW_NUMBER() OVER(PARTITION BY OrderID ORDER BY CreationTime DESC) UniqueID,
		*
FROM Sales.OrdersArchive)t
WHERE UniqueID = 1;

-- In order to export the data, divide the orders into 2 groups.
SELECT 
	*,
	NTILE(2) OVER(ORDER BY CreationTime) AS TwoBucket
FROM Sales.Orders

--Analyze the mom performance by finding the percentage change in sales between the current month and the previous month

WITH SalesTable AS
(SELECT
	MONTH(OrderDate) AS ReportMonth,
	SUM(Sales) AS TotalSales
FROM 
	Sales.Orders
GROUP BY MONTH(OrderDate)
)

SELECT
	*,
	LAG(s.TotalSales) OVER(ORDER BY ReportMonth) AS PrevSales,
	ROUND(((CAST(s.TotalSales AS FLOAT)/LAG(s.TotalSales) OVER(ORDER BY ReportMonth))-1) * 100,1) AS PercGroth
FROM SalesTable AS s

--In order to analyze customer loyalty,
--rank customers based on the average days between their orders

SELECT
	CustomerID,
	OrderDate,
	FIRST_VALUE(OrderDate) OVER(PARTITION BY CustomerID ORDER BY OrderDate) FirstOrder,
	FIRST_VALUE(OrderDate) OVER(PARTITION BY CustomerID ORDER BY OrderDate DESC) LastOrder,
	DATEDIFF(day, FIRST_VALUE(OrderDate) OVER(PARTITION BY CustomerID ORDER BY OrderDate), FIRST_VALUE(OrderDate) OVER(PARTITION BY CustomerID ORDER BY OrderDate DESC)) AS Bdate
FROM Sales.Orders

--In order to analyze customer loyalty,
--rank customers based on the average days between their orders
SELECT
	*,
	DENSE_RANK() OVER(ORDER BY AvgDaysBTOrders) DaysRank
FROM(
SELECT
		*,
		AVG(COALESCE(DaysBTOrders,0)) OVER(PARTITION BY CustomerID) AS AvgDaysBTOrders
	FROM
	(
		SELECT
			CustomerID,
			OrderDate,
			LEAD(OrderDate) OVER(PARTITION BY CustomerID ORDER BY OrderDate) PrevOrder,
			DATEDIFF(day, OrderDate, LEAD(OrderDate) OVER(PARTITION BY CustomerID ORDER BY OrderDate)) AS DaysBTOrders
		FROM Sales.Orders
)t
)tt

--Find all the customers who haven't placed any orders

SELECT
	c.*,
	o.*
FROM Sales.Customers AS c
LEFT JOIN Sales.Orders AS o
ON c.CustomerID = o.CustomerID
WHERE o.CustomerID IS NULL;

/*Using SalesDB, retrieve a list of all orders, along with the related customer, product, and employee details
and for each order, display OrderID, Customer's name, Product Name, Sales Amount, Product Price, Salesperson's Name */

SELECT
	*
FROM Sales.Orders;

SELECT
	*
FROM Sales.Customers;

SELECT
	*
FROM Sales.Employees;

SELECT
	o.OrderID,
	COALESCE(c.FirstName, '') +' '+ COALESCE(c.LastName, '') AS CustomersName,
	p.Product,
	o.Sales,
	p.Price,
	COALESCE(e.FirstName, '') +' '+ COALESCE(e.LastName, '') AS SalesPersonsName
FROM Sales.Orders AS o
LEFT JOIN Sales.Customers AS c
ON o.CustomerID = c.CustomerID
LEFT JOIN Sales.Employees AS e
ON o.SalesPersonID = e.EmployeeID
LEFT JOIN Sales.Products AS p
ON o.ProductID = p.ProductID;
--Show all customer details and find the total orders for each customers
SELECT *
FROM Sales.Orders;

SELECT c.FirstName,
c.LastName,
COUNT(o.OrderID) AS TotalOrders
FROM Sales.Customers AS c
LEFT JOIN Sales.Orders AS o
ON c.CustomerID = o.CustomerID
GROUP BY c.FirstName,
c.LastName;

--Find the total sales per customer 
WITH CTE_TotalSales AS
(
SELECT
	CustomerID,
	SUM(Sales) AS totalsales
FROM Sales.Orders
GROUP BY CustomerID
),
--Find the last order date for each customer
CTE_LastOrderDate AS
(
SELECT
	CustomerID,
	MAX(OrderDate) AS LastOrderDate
FROM Sales.Orders
GROUP BY CustomerID
)
--Main Query
SELECT c.*,
	t.totalsales,
	l.LastOrderDate
FROM Sales.Customers AS c
LEFT JOIN CTE_TotalSales AS t
ON c.CustomerID = t.CustomerID
LEFT JOIN CTE_LastOrderDate l
ON c.CustomerID = l.CustomerID;

-- ----------------------------------------------------------
-- Rank the customers based on the total sales per customers
-- ----------------------------------------------------------
WITH CustomerTable AS
(
SELECT
	CustomerID,
	SUM(Sales) TotalSales
FROM Sales.Orders
GROUP BY CustomerID
)
SELECT *,
RANK() OVER(ORDER BY TotalSales DESC) AS TopCustomers
FROM CustomerTable;

-- ----------------------------------------------------
-- Generate a sequence of numbers from 1 to 20
-- ----------------------------------------------------
WITH Series AS(
-- Anchor Query
SELECT 
	1 AS ID
UNION ALL
--Recurssion
SELECT
	ID + 1
FROM Series
WHERE ID <= 19
)

-- Main Query
SELECT 
	*
FROM Series

-- ----------------------------------------------
-- Find the running total of sales for each month
-- ----------------------------------------------

SELECT 
	DATENAME(month, OrderMonth),
	SUM(TotalSales) OVER(ORDER BY OrderMonth)
FROM
(
SELECT
	DATETRUNC(month, OrderDate) OrderMonth,
	SUM(Sales) TotalSales
FROM 
	Sales.Orders
GROUP BY
DATETRUNC(month, OrderDate))t

-- ------------------------------------------------------------------------------------
-- Provide a view that combines details from orders, products, customers, and employees
-- ------------------------------------------------------------------------------------
IF OBJECT_ID('Sales.V_Enriched_Sales','V') IS NOT NULL
	DROP VIEW Sales.V_Enriched_Sales
GO
CREATE VIEW V_Enriched_Sales AS
(
SELECT
	o.OrderID,
	p.ProductID,
	p.Category,
	p.Product,
	c.CustomerID,
	COALESCE(c.FirstName, '') + ' ' + COALESCE(c.LastName, '') AS CustomerName,
	c.Country,
	c.Score,
	p.Price,
	e.EmployeeID,
	e.FirstName
FROM Sales.Orders AS o
FULL JOIN Sales.Products AS p
ON o.ProductID = p.ProductID
FULL JOIN Sales.Customers AS c
ON o.CustomerID = c.CustomerID
LEFT JOIN Sales.Employees AS e
ON o.SalesPersonID = e.EmployeeID
)

-- Copy the data in Sales.Customers into a new table with no clusters
SELECT *
INTO Sales.DBCustomers
FROM Sales.Customers

-- Create a clustered index on Sales.DBCustomers table on the CustomerID

CREATE CLUSTERED INDEX idx_DBCustomers_CustomerID 
ON Sales.DBCustomers (CustomerID)

-- ------------------------------------------
-- Creating a stored procedure to be updated
-- ------------------------------------------

ALTER PROCEDURE newprod @Country NVARCHAR(50) = 'USA'
AS
BEGIN 
	DECLARE @TotalOrder INT, @AvgScore FLOAT
		SELECT
			@TotalOrder = COUNT(CustomerID),
			@AvgScore = AVG(Score)
		FROM Sales.Customers
		WHERE Country = @Country
	PRINT('Total order in' +' '+ @Country + ' is ' + CAST(@TotalOrder AS NVARCHAR))
	PRINT('Average Score in' +' '+ @Country + ' is ' + CAST(@AvgScore AS NVARCHAR))
END

-- Execue the Stored Procedure
EXEC newprod @Country = 'USA' 

-- ------------------------------------------
-- Creating a stored procedure to be updated
-- ------------------------------------------

ALTER PROCEDURE newprod @Country NVARCHAR(50) = 'USA'
AS
BEGIN 

DECLARE @TotalOrder INT, @AvgScore FLOAT;

-- Prepare the data and clean up
	IF EXISTS (SELECT 1 FROM Sales.Customers WHERE Score IS NULL)
		
		BEGIN
			UPDATE Sales.Customers
			SET Score = 0
			WHERE Score IS NULL AND Country = @Country;
		PRINT('Score contains nulls for ' + @Country)
		PRINT('>>> Updating nulls to 0')
		END


	ELSE
		BEGIN
			PRINT('No Nulls in Scores for ' + @Country)
		END;

		-- Generating Reports
		PRINT('=================================================')
		SELECT
			@TotalOrder = COUNT(CustomerID),
			@AvgScore = AVG(Score)
		FROM Sales.Customers
		WHERE Country = @Country
		PRINT('Total order in' +' '+ @Country + ' is ' + CAST(@TotalOrder AS NVARCHAR))
		PRINT('Average Score in' +' '+ @Country + ' is ' + CAST(@AvgScore AS NVARCHAR))
		PRINT('=================================================')
END

-- Execue the Stored Procedure
EXEC newprod @Country = 'Germany' 

-- =========================================
-- Turning the query into a stored procedure
-- =========================================

ALTER PROCEDURE GetCustomerSummary @Country NVARCHAR(30) = 'USA' AS 
BEGIN
	BEGIN TRY
		DECLARE @TotalCustomers INT, @AvgScore FLOAT, @TotalOrders INT, @TotalSales INT;
		-- =========================================
		-- Step 1: Prepare and clean up data
		-- =========================================
			IF EXISTS (SELECT 1 FROM Sales.Customers WHERE Score IS NULL AND Country = @Country)
			BEGIN
				PRINT ('*************************************');
				PRINT ('Null Value(s) found and updated to 0');
				PRINT ('*************************************');
				UPDATE Sales.Customers
				SET Score = 0
				WHERE Score IS NULL AND Country = @Country
			END

			ELSE

			BEGIN
				PRINT ('*************************************');
				PRINT ('No Null Value(s) found');
				PRINT ('*************************************');
			END;

		-- =========================================
		-- Step 2: Generating report
		-- =========================================
			SELECT 
				@TotalCustomers = COUNT(*),
				@AvgScore = AVG(Score)
			FROM Sales.Customers
			WHERE Country = @Country;

			PRINT 'Total customers from ' + @Country +':'+ CAST(@TotalCustomers AS NVARCHAR);
			PRINT 'Average Score from ' + @Country + ':' + CAST(@AvgScore AS NVARCHAR);

			PRINT ('**************************')
			PRINT ('Generating second query')
			PRINT ('**************************')
		-- ===============================================
		-- Find the total number of orders and total sales
		-- ===============================================
			SELECT 
				@TotalOrders = COUNT(o.OrderID),
				@TotalSales = SUM(o.Sales)
			FROM Sales.Orders AS o
			JOIN Sales.Customers AS c
			ON o.CustomerID = c.CustomerID
			WHERE COUNTRY = @Country;

	
			PRINT 'Total Orders from ' + @Country +':'+ CAST(@TotalOrders AS NVARCHAR);
			PRINT 'Total Sales from ' + @Country + ':' + CAST(@TotalSales AS NVARCHAR);
	END TRY
	-- =========================================
	-- Error handling
	-- =========================================
	BEGIN CATCH
		PRINT('An error occured.');
		PRINT('Error Message: ' + ERROR_MESSAGE());
		PRINT('Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR));
		PRINT('Error Line: ' + CAST(ERROR_LINE() AS NVARCHAR));
		PRINT('Error Procedure: ' + ERROR_PROCEDURE());
	END CATCH
END

-- =========================================
-- Execute the stored procedure
-- =========================================

EXEC GetCustomerSummary;



-- Create table cust_info
IF OBJECT_ID ('bronze.crm_cust_info', 'U') IS NOT NULL
	DROP TABLE bronze.crm_cust_info;
CREATE TABLE bronze.crm_cust_info (
	cst_id INT,
	cst_key NVARCHAR(50),
	cst_firstname NVARCHAR(50),
	cst_lastname NVARCHAR(50),
	cst_marital_status NVARCHAR(50),
	cst_gndr NVARCHAR(50),
	cst_create_date DATE
);

-- Create table prd_info
IF OBJECT_ID ('bronze.crm_prd_info', 'U') IS NOT NULL
	DROP TABLE bronze.crm_prd_info;
CREATE TABLE bronze.crm_prd_info (
	prd_id INT,
	prd_key NVARCHAR(50),
	prd_nm NVARCHAR(50),
	prd_cost INT,
	prd_line NVARCHAR(50),
	prd_start_dt DATETIME,
	prd_end_dt DATETIME
);

-- Create table sales_details
IF OBJECT_ID ('bronze.crm_sales_details', 'U') IS NOT NULL
	DROP TABLE bronze.crm_sales_details;
CREATE TABLE bronze.crm_sales_details (
	sls_ord_num NVARCHAR(50),	
	sls_prd_key	NVARCHAR(50),
	sls_cust_id	INT,
	sls_order_dt INT,	
	sls_ship_dt	INT,
	sls_due_dt	INT,
	sls_sales	INT,
	sls_quantity INT,	
	sls_price INT
);

-- Create Table cust_az12
IF OBJECT_ID ('bronze.erp_cust_az12', 'U') IS NOT NULL
	DROP TABLE bronze.erp_cust_az12;
CREATE TABLE bronze.erp_cust_az12 (
	cid NVARCHAR(50),
	bdate DATE,
	gen NVARCHAR(50)
);

-- Create Table loc_a101
IF OBJECT_ID ('bronze.erp_loc_a101', 'U') IS NOT NULL
	DROP TABLE bronze.erp_loc_a101;
CREATE TABLE bronze.erp_loc_a101 (
	cid NVARCHAR(50),
	cntry NVARCHAR(50)
);

-- Create Table px_cat_g1v2
IF OBJECT_ID ('bronze.erp_px_cat_g1v2', 'U') IS NOT NULL
	DROP TABLE bronze.erp_px_cat_g1v2;
CREATE TABLE bronze.erp_px_cat_g1v2 (
	id NVARCHAR(50),
	cat NVARCHAR(50),
	subcat NVARCHAR(50),
	maintenance NVARCHAR(50)
);

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @Start_time DATETIME, @End_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '=================================================';
		PRINT '###            Loading Bronze Layer           ###';
		PRINT '=================================================';

		PRINT '*************************************************';
		PRINT '>>> Loading CRM Tables >>>';
		PRINT '*************************************************';
		
		SET @Start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_cust_info';
		TRUNCATE TABLE bronze.crm_cust_info;

		PRINT '>> Inserting Data Into: bronze.crm_cust_info';
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\Ifeoluwa Faleye\OneDrive - Prunedge\Desktop\Data Analysis Projects\SQL\End-to-End DataWarehouse Project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @End_time = GETDATE();
		PRINT '>> Loading Duration: ' + CAST(DATEDIFF(second, @Start_time, @End_time) AS NVARCHAR) + ' seconds';
		PRINT '-------------------';

		SET @Start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_prd_info';
		TRUNCATE TABLE bronze.crm_prd_info;

		PRINT '>> Inserting Data Into: bronze.crm_prd_info';
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Users\Ifeoluwa Faleye\OneDrive - Prunedge\Desktop\Data Analysis Projects\SQL\End-to-End DataWarehouse Project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @End_time = GETDATE();
		PRINT '>> Loading Duration: ' + CAST(DATEDIFF(second, @Start_time, @End_time) AS NVARCHAR) + ' seconds';
		PRINT '-------------------';

		SET @Start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details;

		PRINT '>> Inserting Data Into: bronze.crm_sales_details';
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\Ifeoluwa Faleye\OneDrive - Prunedge\Desktop\Data Analysis Projects\SQL\End-to-End DataWarehouse Project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @End_time = GETDATE();
		PRINT '>> Loading Duration: ' + CAST(DATEDIFF(second, @Start_time, @End_time) AS NVARCHAR) + ' seconds';
		PRINT '-------------------';


		PRINT '*************************************************';
		PRINT '>>> Loading ERP Tables >>>';
		PRINT '*************************************************';

		SET @Start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_cust_az12';
		TRUNCATE TABLE bronze.erp_cust_az12;

		PRINT '>> Inserting Data Into: bronze.erp_cust_az12';
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\Users\Ifeoluwa Faleye\OneDrive - Prunedge\Desktop\Data Analysis Projects\SQL\End-to-End DataWarehouse Project\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @End_time = GETDATE();
		PRINT '>> Loading Duration: ' + CAST(DATEDIFF(second, @Start_time, @End_time) AS NVARCHAR) + ' seconds';
		PRINT '-------------------';

		SET @Start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_loc_a101';
		TRUNCATE TABLE bronze.erp_loc_a101;

		PRINT '>> Inserting Data Into: bronze.erp_loc_a101';
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\Users\Ifeoluwa Faleye\OneDrive - Prunedge\Desktop\Data Analysis Projects\SQL\End-to-End DataWarehouse Project\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @End_time = GETDATE();
		PRINT '>> Loading Duration: ' + CAST(DATEDIFF(second, @Start_time, @End_time) AS NVARCHAR) + ' seconds';
		PRINT '-------------------';

		SET @Start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2';
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;

		PRINT '>> Inserting Data Into: bronze.erp_px_cat_g1v2';
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\Users\Ifeoluwa Faleye\OneDrive - Prunedge\Desktop\Data Analysis Projects\SQL\End-to-End DataWarehouse Project\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @End_time = GETDATE();
		PRINT '>> Loading Duration: ' + CAST(DATEDIFF(second, @Start_time, @End_time) AS NVARCHAR) + ' seconds';
		PRINT '-------------------';

		SET @batch_end_time = GETDATE();
		PRINT '===============================================';
		PRINT 'LOADING BRONZE LAYER COMPLETED';
		PRINT '>> Batch Loading Duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '===============================================';

	END TRY
	BEGIN CATCH
		PRINT '=================================================';
		PRINT 'ERROR OCCURRED DURING LOADING BRONZE LAYER';
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Number' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT '=================================================';
	END CATCH
END
