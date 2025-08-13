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

--Transform and Insert into Silver Layer
INSERT INTO silver.crm_cust_info(
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date)
SELECT
       [cst_id]
      ,[cst_key]
      ,TRIM([cst_firstname]) AS cst_firstname
      ,TRIM([cst_lastname]) AS cst_lastname
      ,CASE UPPER(TRIM([cst_marital_status]))
            WHEN 'M' THEN 'Married'
            WHEN 'S' THEN 'Single'
            ELSE 'n/a'
       END AS cst_marital_status
      ,CASE UPPER(TRIM([cst_gndr]))
            WHEN 'M' THEN 'Male'
            WHEN 'F' THEN 'Female'
            ELSE 'n/a'
       END AS cst_gndr
      ,[cst_create_date]
FROM
(
SELECT [cst_id]
      ,[cst_key]
      ,[cst_firstname]
      ,[cst_lastname]
      ,[cst_marital_status]
      ,[cst_gndr]
      ,[cst_create_date]
      ,ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS row_id
  FROM [Datawarehouse2].[bronze].[crm_cust_info])t
  WHERE row_id = 1

INSERT INTO silver.crm_prd_info(
	prd_id,
	cat_id,
	prd_key,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
)
SELECT
	prd_id,
	REPLACE(SUBSTRING(prd_key, 1, 5),'-', '_') AS cat_id,
	SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
	prd_nm,
	ISNULL(prd_cost, 0) AS prd_cost,
	CASE UPPER(TRIM(prd_line))
		WHEN 'R' THEN 'Road'
		WHEN 'M' THEN 'Road'
		WHEN 'S' THEN 'Other Sales'
		WHEN 'T' THEN 'Touring'
		ELSE 'n/a'
	END AS prd_line,
	CAST(prd_start_dt AS DATE) AS prd_start_dt,
	DATEADD(day, -1, LEAD(CAST(prd_start_dt AS DATE)) OVER(PARTITION BY prd_key ORDER BY prd_start_dt)) AS prd_end_dt
FROM bronze.crm_prd_info;

--CREATING SILVER LAYER TABLE
-- Create table cust_info
IF OBJECT_ID ('silver.crm_cust_info', 'U') IS NOT NULL
	DROP TABLE silver.crm_cust_info;
CREATE TABLE silver.crm_cust_info (
	cst_id INT,
	cst_key NVARCHAR(50),
	cst_firstname NVARCHAR(50),
	cst_lastname NVARCHAR(50),
	cst_marital_status NVARCHAR(50),
	cst_gndr NVARCHAR(50),
	cst_create_date DATE,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

-- Create table prd_info
IF OBJECT_ID ('silver.crm_prd_info', 'U') IS NOT NULL
	DROP TABLE silver.crm_prd_info;
CREATE TABLE silver.crm_prd_info (
	prd_id INT,
	cat_id NVARCHAR(50),
	prd_key NVARCHAR(50),
	prd_nm NVARCHAR(50),
	prd_cost INT,
	prd_line NVARCHAR(50),
	prd_start_dt DATE,
	prd_end_dt DATE,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

-- Create table sales_details
IF OBJECT_ID ('silver.crm_sales_details', 'U') IS NOT NULL
	DROP TABLE silver.crm_sales_details;
CREATE TABLE silver.crm_sales_details (
	sls_ord_num NVARCHAR(50),	
	sls_prd_key	NVARCHAR(50),
	sls_cust_id	INT,
	sls_order_dt DATE,	
	sls_ship_dt	DATE,
	sls_due_dt	DATE,
	sls_sales	INT,
	sls_quantity INT,	
	sls_price INT,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

-- Create Table cust_az12
IF OBJECT_ID ('silver.erp_cust_az12', 'U') IS NOT NULL
	DROP TABLE silver.erp_cust_az12;
CREATE TABLE silver.erp_cust_az12 (
	cid NVARCHAR(50),
	bdate DATE,
	gen NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

-- Create Table loc_a101
IF OBJECT_ID ('silver.erp_loc_a101', 'U') IS NOT NULL
	DROP TABLE silver.erp_loc_a101;
CREATE TABLE silver.erp_loc_a101 (
	cid NVARCHAR(50),
	cntry NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

-- Create Table px_cat_g1v2
IF OBJECT_ID ('silver.erp_px_cat_g1v2', 'U') IS NOT NULL
	DROP TABLE silver.erp_px_cat_g1v2;
CREATE TABLE silver.erp_px_cat_g1v2 (
	id NVARCHAR(50),
	cat NVARCHAR(50),
	subcat NVARCHAR(50),
	maintenance NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);


--Transform and Insert Into Silver Layer
INSERT INTO silver.crm_sales_details (
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt,
	sls_sales,
	sls_quantity,
	sls_price
)
SELECT
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	CASE WHEN sls_order_dt = 0 or LEN(sls_order_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE) 
	END AS sls_order_dt,
	CASE WHEN sls_ship_dt = 0 or LEN(sls_ship_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE) 
	END AS sls_ship_dt,
	CASE WHEN sls_due_dt = 0 or LEN(sls_due_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE) 
	END AS sls_due_dt,
	CASE WHEN sls_sales IS NULL or sls_sales <= 0 or sls_sales != sls_quantity * ABS(sls_price)
		THEN sls_quantity * ABS(sls_price)
	ELSE sls_sales
	END AS sls_sales,
	sls_quantity,
	CASE WHEN sls_price IS NULL or sls_price <= 0
		THEN sls_sales/NULLIF(sls_quantity,0)
	ELSE sls_price
	END AS sls_price
FROM bronze.crm_sales_details

-- Transform bronze.erp_cust_az12 and load it into silver.erp_cust_az12

INSERT INTO silver.erp_cust_az12(
cid,
bdate,
gen
)
SELECT
	CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
		ELSE cid
	END AS cid,
	CASE WHEN bdate > GETDATE() THEN NULL
		ELSE bdate 
	END AS bdate,
	CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
		 WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
		 ELSE 'n/a'
	END AS gen
FROM bronze.erp_cust_az12;


-- Transform bronze.erp_loc_a101 and insert into Silver Layer

INSERT INTO silver.erp_loc_a101(
cid,
cntry
)

SELECT 
	REPLACE(cid,'-','') AS cid,
	CASE WHEN UPPER(TRIM(cntry)) = 'DE' THEN 'Germany'
		 WHEN UPPER(TRIM(cntry)) IN ('US', 'USA') THEN 'United States'
		 WHEN UPPER(TRIM(cntry)) = '' OR UPPER(TRIM(cntry)) IS NULL THEN 'n/a'
		 ELSE TRIM(cntry)
	END AS cntry
FROM bronze.erp_loc_a101;

--Transform bronze.erp_px_cat_g1v2 and load to Silver Layer
INSERT INTO silver.erp_px_cat_g1v2(
	id,
	cat,
	subcat,
	maintenance
)
SELECT
	id,
	cat,
	subcat,
	maintenance
FROM bronze.erp_px_cat_g1v2;

-- STORED PROCEDURE TO LOAD SILVER LAYER
CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '==========================================';
		PRINT '>> Loading Silver Layer';
		PRINT '==========================================';

		PRINT '------------------------------------------';
		PRINT '>> Loading CRM Tables';
		PRINT '------------------------------------------';

		-- Loading silver.crm_cust_info
		SET @start_time = GETDATE();
		PRINT '******************************************';
		PRINT '>> Truncating Table: silver.crm_cust_info';
		PRINT '******************************************';
		TRUNCATE TABLE silver.crm_cust_info;
		PRINT '******************************************';
		PRINT '>> Inserting Data: silver.crm_cust_info';
		PRINT '******************************************';
			INSERT INTO silver.crm_cust_info(
				cst_id,
				cst_key,
				cst_firstname,
				cst_lastname,
				cst_marital_status,
				cst_gndr,
				cst_create_date)
			SELECT
					[cst_id]
					,[cst_key]
					,TRIM([cst_firstname]) AS cst_firstname
					,TRIM([cst_lastname]) AS cst_lastname
					,CASE UPPER(TRIM([cst_marital_status]))
						WHEN 'M' THEN 'Married'
						WHEN 'S' THEN 'Single'
						ELSE 'n/a'
					END AS cst_marital_status
					,CASE UPPER(TRIM([cst_gndr]))
						WHEN 'M' THEN 'Male'
						WHEN 'F' THEN 'Female'
						ELSE 'n/a'
					END AS cst_gndr
					,[cst_create_date]
			FROM
			(
			SELECT [cst_id]
					,[cst_key]
					,[cst_firstname]
					,[cst_lastname]
					,[cst_marital_status]
					,[cst_gndr]
					,[cst_create_date]
					,ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS row_id
			FROM [Datawarehouse2].[bronze].[crm_cust_info])t
			WHERE row_id = 1;
			SET @end_time = GETDATE();

			PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
			PRINT '-------------'

			-- Loading silver.crm_prd_info
			SET @start_time = GETDATE();
			PRINT '******************************************';
			PRINT '>> Truncating Table: silver.crm_prd_info';
			PRINT '******************************************';
			TRUNCATE TABLE silver.crm_prd_info;
			PRINT '******************************************';
			PRINT '>> Inserting Data: silver.crm_prd_info';
			PRINT '******************************************';
			INSERT INTO silver.crm_prd_info(
				prd_id,
				cat_id,
				prd_key,
				prd_nm,
				prd_cost,
				prd_line,
				prd_start_dt,
				prd_end_dt
			)
			SELECT
				prd_id,
				REPLACE(SUBSTRING(prd_key, 1, 5),'-', '_') AS cat_id,
				SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
				prd_nm,
				ISNULL(prd_cost, 0) AS prd_cost,
				CASE UPPER(TRIM(prd_line))
					WHEN 'R' THEN 'Road'
					WHEN 'M' THEN 'Road'
					WHEN 'S' THEN 'Other Sales'
					WHEN 'T' THEN 'Touring'
					ELSE 'n/a'
				END AS prd_line,
				CAST(prd_start_dt AS DATE) AS prd_start_dt,
				DATEADD(day, -1, LEAD(CAST(prd_start_dt AS DATE)) OVER(PARTITION BY prd_key ORDER BY prd_start_dt)) AS prd_end_dt
			FROM bronze.crm_prd_info;
			SET @end_time = GETDATE();

			PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
			PRINT '-------------'

			-- Loading silver.crm_sales_details
			SET @start_time = GETDATE();
			PRINT '******************************************';
			PRINT '>> Truncating Table: silver.crm_sales_details';
			PRINT '******************************************';
			TRUNCATE TABLE silver.crm_sales_details;
			PRINT '******************************************';
			PRINT '>> Inserting Data: silver.crm_sales_details';
			PRINT '******************************************';
			INSERT INTO silver.crm_sales_details (
				sls_ord_num,
				sls_prd_key,
				sls_cust_id,
				sls_order_dt,
				sls_ship_dt,
				sls_due_dt,
				sls_sales,
				sls_quantity,
				sls_price
			)
			SELECT
				sls_ord_num,
				sls_prd_key,
				sls_cust_id,
				CASE WHEN sls_order_dt = 0 or LEN(sls_order_dt) != 8 THEN NULL
					ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE) 
				END AS sls_order_dt,
				CASE WHEN sls_ship_dt = 0 or LEN(sls_ship_dt) != 8 THEN NULL
					ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE) 
				END AS sls_ship_dt,
				CASE WHEN sls_due_dt = 0 or LEN(sls_due_dt) != 8 THEN NULL
					ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE) 
				END AS sls_due_dt,
				CASE WHEN sls_sales IS NULL or sls_sales <= 0 or sls_sales != sls_quantity * ABS(sls_price)
					THEN sls_quantity * ABS(sls_price)
				ELSE sls_sales
				END AS sls_sales,
				sls_quantity,
				CASE WHEN sls_price IS NULL or sls_price <= 0
					THEN sls_sales/NULLIF(sls_quantity,0)
				ELSE sls_price
				END AS sls_price
			FROM bronze.crm_sales_details;
			SET @end_time = GETDATE();

			PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
			PRINT '-------------'

			PRINT '------------------------------------------';
			PRINT '>> Loading ERP Tables';
			PRINT '------------------------------------------';
			-- Loading silver.erp_cust_az12
			SET @start_time = GETDATE();
			PRINT '******************************************';
			PRINT '>> Truncating Table: silver.erp_cust_az12';
			PRINT '******************************************';
			TRUNCATE TABLE silver.erp_cust_az12;
			PRINT '******************************************';
			PRINT '>> Inserting Data: silver.erp_cust_az12';
			PRINT '******************************************';
			INSERT INTO silver.erp_cust_az12(
			cid,
			bdate,
			gen
			)
			SELECT
				CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
					ELSE cid
				END AS cid,
				CASE WHEN bdate > GETDATE() THEN NULL
					ELSE bdate 
				END AS bdate,
				CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
					 WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
					 ELSE 'n/a'
				END AS gen
			FROM bronze.erp_cust_az12;
			SET @end_time = GETDATE();

			PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
			PRINT '-------------'

			-- Loading silver.erp_loc_a101
			SET @start_time = GETDATE();
			PRINT '******************************************';
			PRINT '>> Truncating Table: silver.erp_loc_a101';
			PRINT '******************************************';
			TRUNCATE TABLE silver.erp_loc_a101;
			PRINT '******************************************';
			PRINT '>> Inserting Data: silver.erp_loc_a101';
			PRINT '******************************************';
			INSERT INTO silver.erp_loc_a101(
			cid,
			cntry
			)

			SELECT 
				REPLACE(cid,'-','') AS cid,
				CASE WHEN UPPER(TRIM(cntry)) = 'DE' THEN 'Germany'
					 WHEN UPPER(TRIM(cntry)) IN ('US', 'USA') THEN 'United States'
					 WHEN UPPER(TRIM(cntry)) = '' OR UPPER(TRIM(cntry)) IS NULL THEN 'n/a'
					 ELSE TRIM(cntry)
				END AS cntry
			FROM bronze.erp_loc_a101;
			SET @end_time = GETDATE();

			PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
			PRINT '-------------'

			-- Loading silver.erp_px_cat_g1v2
			SET @start_time = GETDATE();
			PRINT '******************************************';
			PRINT '>> Truncating Table: silver.erp_px_cat_g1v2';
			PRINT '******************************************';
			TRUNCATE TABLE silver.erp_px_cat_g1v2;
			PRINT '******************************************';
			PRINT '>> Inserting Data: silver.erp_px_cat_g1v2';
			PRINT '******************************************';

			INSERT INTO silver.erp_px_cat_g1v2(
				id,
				cat,
				subcat,
				maintenance
			)
			SELECT
				id,
				cat,
				subcat,
				maintenance
			FROM bronze.erp_px_cat_g1v2;
			SET @end_time = GETDATE();

			PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
			PRINT '-------------'
			PRINT '==========================================';
			PRINT '>> Silver Layer Loaded';
			PRINT '    - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
			PRINT '==========================================';

	END TRY
	BEGIN CATCH
		PRINT '==========================================';
		PRINT 'ERROR OCCURRED WHILE LOADING SILVER LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Number' + CAST(ERROR_MESSAGE() AS NVARCHAR);
		PRINT 'Error State' + CAST(ERROR_MESSAGE() AS NVARCHAR);
	END CATCH
END

CREATE VIEW gold.dim_customers AS
SELECT 
	ROW_NUMBER() OVER(ORDER BY ci.cst_id) AS customer_key,
	ci.cst_id AS customer_id,
	ci.cst_key AS customer_number,
	ci.cst_firstname AS firstname,
	ci.cst_lastname AS lastname,
	la.cntry AS country,
	ci.cst_marital_status AS marital_status,
	CASE WHEN ci.cst_gndr <> 'n/a' THEN ci.cst_gndr -- CRM is the Master for gender information
		 ELSE COALESCE(ca.gen, 'n/a')
	END AS gender,
	ca.bdate AS birthdate,
	ci.cst_create_date AS create_date
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
	ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 AS la
ON ci.cst_key = la.cid;
-- Explore All Objects in the Database
SELECT
	*
FROM INFORMATION_SCHEMA.TABLES;

-- Explore All  Columns in the Database
SELECT
	*
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers';

-- Explore All the Dimensions in Our Customers Table
SELECT 
	DISTINCT country
FROM gold.dim_customers;

-- Explore All the Categories "The Major Divisions"
SELECT 
	category,
	subcategory,
	product_name
FROM gold.dim_products;

-- Explore the Dates-Find the dates of the first and last order
SELECT
	MIN(order_date)
FROM gold.fact_sales;

-- Explore the Dates-Find the dates of the first and last order
SELECT
	MAX(order_date)
FROM gold.fact_sales;

-- Explore the Dates-Find the dates of the first and last order
SELECT
	DATEDIFF(year, MIN(order_date), MAX(order_date))
FROM gold.fact_sales;

--Find the youngest and oldest customer

SELECT 
	MAX(birthdate) AS yougest_dob,
	DATEDIFF(year, MAX(birthdate), GETDATE()) AS youngest_age,
	MIN(birthdate) AS oldest_dob,
	DATEDIFF(year, MIN(birthdate), GETDATE()) AS oldest_age
FROM gold.dim_customers;

-- Explore the Measures
-- Find the total sales
SELECT
	'Total Sales' AS [Measure Name],
	SUM(sales_amount) AS [Measure Value]
FROM gold.fact_sales
UNION
-- Find how many items were sold
SELECT
	'Total Quantity' AS Measures,
	SUM(quantity) AS [KPIs]
FROM gold.fact_sales
UNION
-- Find the average selling price
SELECT
	'Average Price' AS Measures,
	AVG(price) AS [KPIs]
FROM gold.fact_sales
UNION
-- Find the total number of orders
SELECT
	'Total Orders' AS Measures,
	COUNT(DISTINCT order_number) AS [KPIs]
FROM gold.fact_sales
UNION
-- Find the total number of products
SELECT
	'Total Products' AS Measures,
	COUNT(product_id) AS [KPIs]
FROM gold.dim_products
UNION
-- Find the total number of customers
SELECT
	'Total Customers' AS Measures,
	COUNT(customer_id) AS [KPIs]
FROM gold.dim_customers
UNION
-- Find the total number of customers that has placed an order
SELECT
	'Total Customers With Orders' AS Measures,
	COUNT(DISTINCT customer_key) AS [KPIs]
FROM gold.fact_sales

-- Find the total customers by coutries
SELECT
	country,
	COUNT(customer_number) AS [Total Customers]
FROM gold.dim_customers
GROUP BY country
UNION
SELECT
	'Grand Total',
	COUNT(customer_number)
FROM gold.dim_customers
ORDER BY COUNT(customer_number);

-- Find the total customers by gender
SELECT
	gender,
	COUNT(customer_number) AS [Total Customers]
FROM gold.dim_customers
GROUP BY gender;

-- Find the total products by category
SELECT
	category,
	COUNT(product_number) AS [Total Products]
FROM gold.dim_products
GROUP BY category;

-- What is the average cost in each category?
SELECT
	category,
	AVG(cost) AS [Average Cost]
FROM gold.dim_products
GROUP BY category;

-- What is the total revenue generated for each category?
SELECT
	ca.category,
	SUM(sa.sales_amount) AS [Total Revenue]
FROM gold.dim_products AS ca
LEFT JOIN gold.fact_sales AS sa
ON ca.product_key = sa.product_key 
GROUP BY category;

-- Find the total revenue generated by each customer
SELECT
	ca.customer_id,
	ca.firstname,
	ca.lastname,
	SUM(sa.sales_amount) AS [Total Revenue]
FROM gold.dim_customers AS ca
LEFT JOIN gold.fact_sales AS sa
ON ca.customer_key = sa.customer_key
GROUP BY ca.customer_id,
	ca.firstname,
	ca.lastname
ORDER BY SUM(sa.sales_amount * sa.quantity);

-- What is the distribution of sales across countries?
SELECT
	cu.country,
	SUM(sa.sales_amount) AS [Total Sales]
FROM gold.dim_customers AS cu
LEFT JOIN gold.fact_sales AS sa
ON cu.customer_key = sa.customer_key
GROUP BY country;
-- Which 5 products generates the highest revenue
SELECT TOP 5
p.product_name,
SUM(s.sales_amount) AS Total_Revenue
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
ON s.product_key = p.product_key
GROUP BY p.product_name
ORDER BY Total_Revenue DESC;

-- Which 5 products generates the highest revenue
SELECT *
FROM(
SELECT
p.product_name,
SUM(s.sales_amount) AS Total_Revenue,
RANK() OVER(ORDER BY SUM(s.sales_amount) DESC) AS p_rank
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
ON s.product_key = p.product_key
GROUP BY p.product_name)t
WHERE p_rank <= 5
-- Analyze sales performance over time
SELECT
	FORMAT(order_date, 'MMM, yyyy') AS order_date,
	SUM(sales_amount) AS total_sales,
	COUNT(DISTINCT customer_key) AS total_customers
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY FORMAT(order_date, 'MMM, yyyy');

-- Analyze cummulative sales performance over time
SELECT 
	order_year,
	order_date,
	total_sales,
	SUM(total_sales) OVER(ORDER BY order_year, order_date) AS cumulative_sales,
	SUM(total_customers) OVER(ORDER BY order_year, order_date) AS cumulative_customers
FROM
(
SELECT
	YEAR(order_date) AS order_year,
	MONTH(order_date) AS order_date,
	SUM(sales_amount) AS total_sales,
	COUNT(DISTINCT customer_key) AS total_customers
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date))t

-- Analyze cummulative sales performance over time
SELECT 
	order_year,
	order_date,
	total_sales,
	average_price,
	SUM(total_sales) OVER(PARTITION BY order_year ORDER BY order_year, order_date) AS cumulative_sales,
	SUM(total_customers) OVER(PARTITION BY order_year ORDER BY order_year, order_date) AS cumulative_customers,
	AVG(average_price) OVER(PARTITION BY order_year ORDER BY order_year, order_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS MMA
FROM
(
SELECT
	YEAR(order_date) AS order_year,
	MONTH(order_date) AS order_date,
	SUM(sales_amount) AS total_sales,
	COUNT(DISTINCT customer_key) AS total_customers,
	AVG(price) AS average_price
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date))t
/*Analyze the yearly performance of products
by comparing each product's sales to both its 
average sales performance and the previous year's sales
*/

SELECT 
	*,
	AVG(total_sales) OVER(PARTITION BY product_name) AS avgsales,
	LAG(total_sales) OVER(PARTITION BY product_name ORDER BY order_year) AS py_sales,
	total_sales - AVG(total_sales) OVER(PARTITION BY product_name) AS salesminusavg,
	FORMAT((total_sales - CAST(AVG(total_sales) OVER(PARTITION BY product_name) AS FLOAT))/CAST(AVG(total_sales) OVER(PARTITION BY product_name) AS FLOAT), 'P') AS salesvsavg,
	FORMAT((CAST(total_sales AS FLOAT) - LAG(total_sales) OVER(PARTITION BY product_name ORDER BY order_year))
	/LAG(total_sales) OVER(PARTITION BY product_name ORDER BY order_year), 'P') AS yoygrowth
FROM
(SELECT
	p.product_name,
	YEAR(s.order_date) AS order_year,
	SUM(s.sales_amount) AS total_sales,
	AVG(s.sales_amount) AS avg_sales
FROM gold.fact_sales AS s
LEFT JOIN gold.dim_products AS p
	ON s.product_key = p.product_key
WHERE order_date IS NOT NULL
GROUP BY p.product_name, YEAR(s.order_date))t
-- Which category contributes the most to the overall sales?
WITH category AS
(SELECT
	p.category,
	SUM(s.sales_amount) AS total_sales
FROM gold.fact_sales AS s
LEFT JOIN gold.dim_products AS p
	ON s.product_key = p.product_key
GROUP BY p.category)

SELECT 
*,
SUM(total_sales) OVER() AS g_total_sales,
FORMAT(CAST(total_sales AS FLOAT)/SUM(total_sales) OVER(), 'P') AS p_total
FROM category

--Method 2

SELECT SUM(sales_amount) FROM gold.fact_sales

SELECT
	p.category,
	SUM(s.sales_amount) AS total_sales,
	FORMAT(CAST(SUM(s.sales_amount) AS FLOAT)/ (SELECT SUM(sales_amount) FROM gold.fact_sales), 'P') AS p_total
FROM gold.fact_sales AS s
LEFT JOIN gold.dim_products AS p
	ON s.product_key = p.product_key
GROUP BY p.category
-- Segment products into cost ranges and count how many products fall into each segment
WITH product_table AS(
SELECT
	product_key,
	SUM(cost) AS total_price
FROM gold.dim_products
GROUP BY product_key)

SELECT 
	CASE 
		WHEN total_price < 100 THEN 'Low Cost'
		WHEN total_price >= 100 AND total_price < 500 THEN 'Medium Cost'
		ELSE 'High Cost'
	END AS price_cat,
	COUNT( DISTINCT product_key) product_count
FROM product_table
GROUP BY CASE 
		WHEN total_price < 100 THEN 'Low Cost'
		WHEN total_price >= 100 AND total_price < 500 THEN 'Medium Cost'
		ELSE 'High Cost'
	END
-- Group customers into three segments based on their spending behaviour
WITH customer AS (
SELECT
	customer_key,
	SUM(sales_amount) AS customer_spending,
	CASE WHEN SUM(sales_amount) < 5000 THEN '< 5,000'
		 WHEN SUM(sales_amount) BETWEEN 5000 AND 10000 THEN '5,000 - 10,000'
		 ELSE '> 10,000'
	END AS customer_spend
FROM gold.fact_sales
GROUP BY customer_key)

SELECT
	customer_spend,
	COUNT(DISTINCT customer_key) AS customer_count
FROM customer
GROUP BY customer_spend
ORDER BY COUNT(DISTINCT customer_key)

-- Group customers into three segments based on their spending behaviour
WITH customer AS (
SELECT
	customer_key,
	sales_amount,
	order_date,
	FIRST_VALUE(order_date) OVER (PARTITION BY customer_key ORDER BY order_date) AS first_order,
	FIRST_VALUE(order_date) OVER (PARTITION BY customer_key ORDER BY order_date DESC) AS last_order,
	DATEDIFF(month, FIRST_VALUE(order_date) OVER (PARTITION BY customer_key ORDER BY order_date), FIRST_VALUE(order_date) OVER (PARTITION BY customer_key ORDER BY order_date DESC)) AS history
FROM gold.fact_sales
WHERE order_date IS NOT NULL)
, customer_seg AS(
SELECT
	customer_key,
	SUM(sales_amount) AS customer_spend,
	history,
	CASE
		WHEN SUM(sales_amount) > 5000 AND history >= 12 THEN 'VIP'
		WHEN SUM(sales_amount) <= 5000 AND history >= 12 THEN 'Regular'
		ELSE 'New'
	END AS customer_category
FROM customer
GROUP BY customer_key, history)

SELECT 
	customer_category,
	COUNT(DISTINCT customer_key) total_customers
FROM customer_seg
GROUP BY customer_category;

-- Group customers into three segments based on their spending behaviour
WITH customer AS (
SELECT
	customer_key,
	sales_amount,
	order_date,
	FIRST_VALUE(order_date) OVER (PARTITION BY customer_key ORDER BY order_date) AS first_order,
	FIRST_VALUE(order_date) OVER (PARTITION BY customer_key ORDER BY order_date DESC) AS last_order,
	DATEDIFF(month, FIRST_VALUE(order_date) OVER (PARTITION BY customer_key ORDER BY order_date), FIRST_VALUE(order_date) OVER (PARTITION BY customer_key ORDER BY order_date DESC)) AS history
FROM gold.fact_sales)
, customer_seg AS(
SELECT
	customer_key,
	SUM(sales_amount) AS customer_spend,
	history,
	CASE
		WHEN SUM(sales_amount) > 5000 AND history >= 12 THEN 'VIP'
		WHEN SUM(sales_amount) <= 5000 AND history >= 12 THEN 'Regular'
		ELSE 'New'
	END AS customer_category
FROM customer
GROUP BY customer_key, history)

SELECT 
	customer_category,
	COUNT(DISTINCT customer_key) total_customers
FROM customer_seg
GROUP BY customer_category;
/*
================================================================================
Customer Report
================================================================================
Purpose:
	- This report consolidated key customer metrics and behaviours

Highlights:
	1. Gathers essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
	3. Aggregates customer-level metrics:
		- total orders
		- total sales
		- total quantity purchased
		- lifespan (in months)
	4. Calculates valuable KPIs:
		- recency (months since last order)
		- average order value
		- average monthly spend
================================================================================
*/

WITH base_query AS
/*------------------------------------------------------------------------------
1) Base Query: Retrieves core columns from tables
------------------------------------------------------------------------------*/
(SELECT
	s.order_number,
	s.product_key,
	s.order_date,
	s.sales_amount,
	s.quantity,
	c.customer_key,
	c.customer_number,
	CONCAT(c.firstname,' ', c.lastname) AS customer_name,
	DATEDIFF(year, c.birthdate, GETDATE()) AS age
FROM gold.fact_sales AS s
LEFT JOIN gold.dim_customers AS c
	ON s.customer_key = c.customer_key
WHERE order_date IS NOT NULL)

, customer_aggregation AS
/*------------------------------------------------------------------------------
1) Customer Aggregation: Aggregates customer-level metrics
------------------------------------------------------------------------------*/
(SELECT
	customer_key,
	customer_number,
	customer_name,
	age,
	COUNT(DISTINCT order_number) AS total_orders,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan,
	MAX(order_date) AS last_order_date
FROM base_query
GROUP BY 
	customer_key,
	customer_number,
	customer_name,
	age)

SELECT
	customer_key,
	customer_number,
	customer_name,
	age,
	CASE
		WHEN age < 20 THEN 'Under 20'
		WHEN age BETWEEN 20 AND 29 THEN '20-29'
		WHEN age BETWEEN 30 AND 39 THEN '30-39'
		WHEN age BETWEEN 40 AND 49 THEN '40-49'
		ELSE '50 and above'
	END AS age_group,
	CASE
		WHEN total_sales > 5000 AND lifespan >= 12 THEN 'VIP'
		WHEN total_sales <= 5000 AND lifespan >= 12 THEN 'Regular'
		ELSE 'New'
	END AS customer_category,
	total_orders,
	total_sales,
	total_quantity,
	lifespan,
	last_order_date
FROM customer_aggregation
GROUP BY 
	customer_key,
	customer_number,
	customer_name,
	age,
	total_orders,
	total_sales,
	total_quantity,
	lifespan,
	last_order_date
