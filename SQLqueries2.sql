-- Find the average sales across all others
-- Find the average sales for each product and add additional details

SELECT 
	OrderID,
	Sales,
	ProductID,
	AVG(Sales) OVER() AS avgsales,
	AVG(Sales) OVER(PARTITION BY ProductID) AS avgsalesp
FROM Sales.Orders;
/*
Retrieve all data from customers and orders as separate results
*/
SELECT *
FROM SalesDB.Sales.Customers;
SELECT *
FROM SalesDB.Sales.Orders;

/*
Retrieve all data from customers that has a match in orders Table
*/
SELECT *
FROM SalesDB.Sales.Customers AS c
JOIN SalesDB.Sales.Orders AS o
ON c.CustomerID = o.CustomerID;

/*
Retrieve all data from customers that has whether or not they have a match in orders Table
*/
SELECT *
FROM SalesDB.Sales.Customers AS c
LEFT JOIN SalesDB.Sales.Orders AS o
ON c.CustomerID = o.CustomerID;

/*
Find orders with no customers and customers with no orders
*/
SELECT
*
FROM SalesDB.Sales.Customers AS c
FULL JOIN SalesDB.Sales.Orders AS o
	ON c.CustomerID = o.CustomerID
WHERE c.CustomerID IS NULL OR o.CustomerID IS NULL
/*
Find all customers along with their orders but only for customers with orders without using inner join
*/
SELECT
*
FROM SalesDB.Sales.Customers AS c
FULL JOIN SalesDB.Sales.Orders AS o
	ON c.CustomerID = o.CustomerID
WHERE NOT c.CustomerID IS NULL AND NOT o.CustomerID IS NULL;

--Using inner join
SELECT
*
FROM SalesDB.Sales.Customers AS c
JOIN SalesDB.Sales.Orders AS o
	ON c.CustomerID = o.CustomerID;
/*
Using SalesDB, Retrieve a list of all orders, along with the related customer, product, and employee details.
Fro each order, display:
- OrderID
- Customer's name
- Product name
- Sales amount
- Product price
- Salesperson's name
*/

SELECT
	o.OrderID,
	COALESCE(c.FirstName,'')+ ' ' +  COALESCE(c.LastName,'') AS CustomerName,
	p.Product,
	o.Sales,
	o.quantity,
	p.Price,
	COALESCE(e.FirstName,'')+ ' ' +  COALESCE(e.LastName,'') AS EmployeeName
FROM SalesDB.Sales.Orders AS o
JOIN SalesDB.Sales.Customers AS c
ON o.CustomerID = c.CustomerID
JOIN SalesDB.Sales.Products AS p
ON o.ProductID = p.ProductID
JOIN SalesDB.Sales.Employees AS e
ON o.SalesPersonID = e.EmployeeID;
--Combine the data from employees and customers into one table
SELECT
	FirstName,
	LastName
FROM SalesDB.Sales.Customers
UNION ALL
SELECT
	FirstName,
	LastName
FROM SalesDB.Sales.Employees;
SELECT
	e.FirstName,
	e.LastName
FROM SalesDB.Sales.Employees AS e
JOIN SalesDB.Sales.Customers AS c
ON e.FirstName = c.FirstName AND COALESCE(e.LastName,'') = COALESCE(c.LastName,'');
--Show as list of customers' first names together with their coutries in one column
SELECT
*,
CONCAT(FirstName,' ',Country) AS NameCountry,
FirstName+ ' ' + Country AS NameCountry2
FROM SalesDB.Sales.Customers

-- Transform the customer's first names to lowercase
SELECT
	*,
	LOWER(FirstName) FirstNameLower,
	UPPER(LastName) LastNameUpper,
	UPPER(LEFT(LOWER(FirstName),1))+SUBSTRING(FirstName,2,LEN(FirstName)) AS CapitalizedName
FROM SalesDB.Sales.Customers

--Checking for trailing and leading spaces
SELECT
FirstName
FROM SalesDB.Sales.Customers
WHERE LEN(FirstName) <> LEN(TRIM(FirstName))
--Show Creation Time using following format Day Wed Jan Q1 2025 12:34:56 PM
SELECT
	CreationTime,
	FORMAT(CreationTime, 'dd/MMM/yyyy') FULLDATE,
	'Day ' +FORMAT(CreationTime, 'ddd MMM ') + 'Q' 
	+TRIM(STR(DATEPART(quarter, CreationTime)))
	+FORMAT(CreationTime, ' yyyy HH:mm:ss tt') FULLDATE
FROM SalesDB.Sales.Orders;
-- Find the average shipping duration in days for each month
SELECT
	DATENAME(month, OrderDate) OrderMonth,
	AVG(DATEDIFF(day, OrderDate, ShipDate)) AvgShipDuration
FROM SalesDB.Sales.Orders
GROUP BY DATENAME(month, OrderDate)

-- Find the number of days between each order and the previous order
WITH DateTb AS
(
SELECT
	OrderID,
	OrderDate AS CurrentOrderDate,
	LAG(OrderDate) OVER(ORDER BY OrderDate) AS PrevOrderDate
FROM SalesDB.Sales.Orders)

SELECT
	*,
	DATEDIFF(day, PrevOrderDate, CurrentOrderDate) AS DaysB2Orders
FROM DateTb
-- Sort the customers score from the lowest to the highest with nulls appearing last
SELECT
	CustomerID,
	Score
FROM Sales.Customers
ORDER BY (CASE WHEN Score IS NULL THEN 1 ELSE 0 END), Score
-- Show a list of all details of customers who have not placed any orders

SELECT
*
FROM Sales.Customers AS c
LEFT JOIN Sales.Orders AS o
ON c.CustomerID = o.CustomerID
WHERE o.CustomerID IS NULL
WITH Orders AS
(
SELECT
1 AS id,
'A' AS Category

UNION 

SELECT
2,
NULL

UNION

SELECT
3,
''
UNION
SELECT
4,
'   '
)
SELECT
	*,
	DATALENGTH(Category),
	LEN(Category),
	NULLIF(TRIM(Category), ''),
	COALESCE(NULLIF(TRIM(Category), ''), 'n/a')
FROM Orders
/*
Generate a report showing the total sales for each category:
	- High: If the sales is higher than 50
	- Medium: If the sales is between 20 and 50
	- Low: If the sales is less than or equal to 20
Sort the result from lowest to highest
*/
SELECT
	SalesBucket,
	SUM(Sales) AS TotalSales
FROM
(
SELECT
	OrderID,
	Sales,
	CASE 
		WHEN Sales > 50 THEN 'High'
		WHEN Sales > 20 AND Sales <= 50 THEN 'Medium'
		ELSE 'Low'
	END AS SalesBucket
FROM SalesDB.Sales.Orders)t
GROUP BY SalesBucket
ORDER BY TotalSales


SELECT
	p.Category,
	SUM(Sales) AS TotalSales,
	CASE
		WHEN SUM(Sales) > 200 THEN 'High'
		ELSE 'Low'
	END AS SalesBucket
FROM SalesDB.Sales.Orders AS o
LEFT JOIN SalesDB.Sales.Products AS p
	ON o.ProductID = p.ProductID
GROUP BY Category
ORDER BY TotalSales
/*
Count the number of times each customer has made an order with sales greater than 30
*/
SELECT
	OrderID,
	CustomerID,
	Sales,
	CASE
		WHEN Sales > 30 THEN 1
		ELSE 0
	END AS OrdersAbove,
	SUM(CASE
		WHEN Sales > 30 THEN 1
		ELSE 0
	END) OVER(PARTITION BY CustomerID) AS TotalOrdersAbove
FROM SalesDB.Sales.Orders
ORDER BY CustomerID
-- Find the total sales accross all orders additionally, provide details such as order id & order date

SELECT
	OrderID,
	OrderDate,
	SUM(Sales) OVER() AS TotalSales
FROM Sales.Orders

-- Find the total sales for each product additionally, provide details such as order id & order date

SELECT
	ProductID,
	OrderID,
	OrderDate,
	SUM(Sales) OVER() AS TotalSales,
	SUM(Sales) OVER(PARTITION BY ProductID) AS ProductSales
FROM Sales.Orders

-- Find the total sales for each combination of product and order status additionally, provide details such as order id & order date

SELECT
	ProductID,
	OrderID,
	OrderDate,
	OrderStatus,
	Sales,
	SUM(Sales) OVER() AS TotalSales,
	SUM(Sales) OVER(PARTITION BY ProductID) AS ProductSales,
	SUM(Sales) OVER(PARTITION BY ProductID, OrderStatus) AS ProductSalesByStatus
FROM Sales.Orders

-- Rank each order based on their sales from the highest to the lowest. Additionally, provide details such as order id & order date
SELECT
	OrderID,
	OrderDate,
	Sales,
	ROW_NUMBER() OVER(ORDER BY Sales DESC) AS SalesRank1,
	RANK() OVER(ORDER BY Sales DESC) AS SalesRank2,
	DENSE_RANK() OVER(ORDER BY Sales DESC) AS SalesRank
FROM Sales.Orders
-- Find the total number of orders
-- Find the total number of orders for each customers
-- Additionally, provide details like order id, order date
SELECT
	OrderID,
	OrderDate,
	CustomerID,
	COUNT(OrderID) OVER() AS TotalOrders,
	COUNT(OrderID) OVER(PARTITION BY CustomerID) OrdersByCustomers
FROM Sales.Orders

-- Find the total number of customers
-- Find the total number of scores for the customers
-- Find the total scores for the customers
-- Additionally, provide customers details
SELECT
	FirstName,
	LastName,
	Score,
	COUNT(CustomerID) OVER() AS TotalCustomers,
	SUM(Score) OVER() AS TotalScores,
	COUNT(Score) OVER() AS TotalNumberScores
FROM Sales.Customers

-- Check out whether table orders contains any duplucate rows
SELECT
	OrderID,
	COUNT(OrderID) OVER(PARTITION BY OrderID) AS Checks
FROM Sales.Orders

-- Check out whether table orders contains any duplucate rows
SELECT
	OrderID,
	COUNT(OrderID) OVER(PARTITION BY OrderID) AS Checks
FROM Sales.OrdersArchive
-- Find the total sales accross all orders
-- Find the total sales for each products
-- Additionally, provide details like order id, order date
SELECT
	OrderID,
	OrderDate,
	ProductID,
	Sales,
	SUM(Sales) OVER() AS TotalSales,
	SUM(Sales) OVER(PARTITION BY ProductID) SalesByProduct,
	ROUND(SUM(CAST(Sales AS FLOAT)) OVER(PARTITION BY ProductID) / SUM(Sales) OVER() * 100, 2) ProdPercTotal
FROM Sales.Orders
-- Find all orders where the sales are higher than the average sales accross all orders
-- Additionally, provide details like order id, order date
SELECT
	OrderID,
	OrderDate,
	Sales,
	AVG(Sales) OVER() AS AvgSales,
	CASE 
		WHEN Sales > AVG(Sales) OVER() THEN OrderID
		ELSE NULL
	END AS CheckSales
FROM Sales.Orders
-- Calculate the moving average of sales for each products over time, including only the next order

SELECT
	ProductID,
	Sales,
	AVG(Sales) OVER(PARTITION BY ProductID ORDER BY OrderDate) AS ProductMA,
	AVG(Sales) OVER(PARTITION BY ProductID ORDER BY OrderDate ROWS BETWEEN CURRENT ROW AND 1 FOLLOWING) AS ProductMA1
FROM Sales.Orders
/*
SELECT 
	OrderID,
	Sales,
	ProductID,
	AVG(Sales) OVER() AS avgsales,
	AVG(Sales) OVER(PARTITION BY ProductID) AS avgsalesp
FROM Sales.Orders;
*/
-- Find the top sales for each products
SELECT
	*
FROM
(
SELECT
	ProductID,
	Sales,
	ROW_NUMBER() OVER(PARTITION BY ProductID ORDER BY Sales DESC) AS PrdRank2
FROM Sales.Orders)t
WHERE PrdRank2 = 1
-- Find the top lowest 2 customers based on their total sales
SELECT
	*
FROM
(
SELECT
	CustomerID,
	Sales,
	ROW_NUMBER() OVER(ORDER BY Sales) AS PrdRank2
FROM Sales.Orders)t
WHERE PrdRank2 <= 2
-- Find the top lowest 2 customers based on their total sales
SELECT
	*
FROM
(
SELECT
	CustomerID,
	SUM(Sales) TotalSales,
	ROW_NUMBER() OVER(ORDER BY SUM(Sales)) AS PrdRank2
FROM Sales.Orders
GROUP BY CustomerID
)t WHERE PrdRank2 <= 2

-- Analyze the MoM performance by finding the percentage change in the sales between the current and previous month

SELECT
	MONTH(OrderDate) OrderMonth,
	SUM(Sales) TotalSales,
	LAG(SUM(Sales), 1) OVER(ORDER BY MONTH(OrderDate)) PrevMonth,
	FORMAT((SUM(CAST(Sales AS FLOAT))/LAG(SUM(Sales), 1) OVER(ORDER BY MONTH(OrderDate)) - 1), 'P') AS MoMgrowth
FROM Sales.Orders
GROUP BY MONTH(OrderDate)
-- Analyze the MoM performance by finding the percentage change in the sales between the current and previous month
SELECT
	CustomerID,
	AVG(DaysBtOrders) DaysbtOrderAvg
FROM
(
SELECT
	CustomerID,
	OrderDate AS CurOrderDate,
	LEAD(OrderDate, 1) OVER(PARTITION BY CustomerID ORDER BY OrderDate) AS NextOrderDate,
	DATEDIFF(day, OrderDate, LEAD(OrderDate, 1) OVER(PARTITION BY CustomerID ORDER BY OrderDate)) AS DaysBtOrders
FROM Sales.Orders
)t
GROUP BY CustomerID
ORDER BY DaysbtOrderAvg

-- Find information about the metadata of our tabels 
SELECT
	*
FROM INFORMATION_SCHEMA.COLUMNS
-- Find information about the metadata of our tabels 
SELECT
	*
FROM INFORMATION_SCHEMA.COLUMNS
CREATE FUNCTION getNthHighestSalary(@N INT) RETURNS INT AS
BEGIN
    RETURN (
        /* Write your T-SQL query statement below. */
        SELECT
            salary AS getNthHighestSalary
        FROM
        (
        SELECT
            DISTINCT(salary) AS salary,
            DENSE_RANK() OVER(ORDER BY salary DESC) AS rnk
        FROM Employee)t
        WHERE rnk = @N
    );
END
/* Write your T-SQL query statement below */
WITH cte AS (
    SELECT
        num,
        LAG(num)  OVER (ORDER BY id) AS prev_num,
        LEAD(num) OVER (ORDER BY id) AS next_num
    FROM Logs
)
SELECT DISTINCT
    num AS ConsecutiveNums
FROM
    cte
WHERE
    num = prev_num
    AND num = next_num;
/* Write your T-SQL query statement below */
WITH session AS
(
SELECT
    player_id,
    event_date,
    LEAD(event_date) OVER(PARTITION BY player_id ORDER BY event_date) AS event_date_new,
    DATEDIFF(day, event_date, LEAD(event_date) OVER(PARTITION BY player_id ORDER BY event_date)) AS daysbetweengames
FROM Activity)
	/* Write your T-SQL query statement below */
WITH cte AS (
    SELECT
        num,
        LAG(num)  OVER (ORDER BY id) AS prev_num,
        LEAD(num) OVER (ORDER BY id) AS next_num
    FROM Logs
)
SELECT DISTINCT
    num AS ConsecutiveNums
FROM
    cte
WHERE
    num = prev_num
    AND num = next_num;

SELECT
    ROUND((COUNT( DISTINCT player_id) * 1.0)/(SELECT COUNT(DISTINCT player_id) FROM Activity), 2)  AS fraction
FROM session
WHERE daysbetweengames = 1;


/*
STEP 1: Find the total sales per customer
*/
WITH CTE_Total_Sales AS
(
SELECT
	CustomerID,
	SUM(Sales) AS TotalSales
FROM Sales.Orders
GROUP BY CustomerID
)
--STEP 2: Find the last order date for each customer
, CTE_Last_Order_Date AS
(
SELECT
	CustomerID,
	MAX(OrderDate) AS LOD
FROM Sales.Orders
GROUP BY CustomerID
)
--Rank the customers based on total sales per customer
, CTE_Customer_Rank AS
(
SELECT
	CustomerID,
	TotalSales,
	RANK() OVER(ORDER BY TotalSales DESC) AS CustomerRank
FROM CTE_Total_Sales
)
--Step 4: Segement customers based on their total sales
, CTE_Customer_Segment AS
(
SELECT
	CustomerID,
	TotalSales,
	CASE
		WHEN TotalSales > 100 THEN 'High'
		WHEN TotalSales < 100 AND TotalSales >= 90 THEN 'Medium'
		WHEN TotalSales < 90 THEN 'Low'
		ELSE 'Unknown'
	END AS CustomerSegement
FROM CTE_Total_Sales
)
--Main Query
SELECT 
	c.CustomerID,
	c.FirstName,
	c.LastName,
	s.TotalSales,
	l.LOD,
	r.CustomerRank,
	cs.CustomerSegement
FROM Sales.Customers AS c
LEFT JOIN CTE_Total_Sales AS s
ON c.CustomerID = s.CustomerID
LEFT JOIN CTE_Last_Order_Date AS l
ON c.CustomerID = l.CustomerID
LEFT JOIN CTE_Customer_Rank AS r
ON c.CustomerID = r.CustomerID
LEFT JOIN CTE_Customer_Segment AS cs
ON c.CustomerID = cs.CustomerID


WITH First_Number AS
(
	SELECT 1 AS Number
	UNION ALL
	--Recurssion
	SELECT
		Number + 1
	FROM First_Number
	WHERE Number < 10
)

SELECT 
	*
FROM First_Number
WITH First_Number AS
(
	SELECT 1 AS Number
	UNION ALL
	--Recurssion
	SELECT
		Number + 1
	FROM First_Number
	WHERE Number < 10
)

SELECT 
	*
FROM First_Number

IF OBJECT_ID('VeiwName', 'V') IS NOT NULL
DROP 'ViewName';
GO
CREATE VIEW 'ViewName' AS
(
	SELECT
		COLUMN1,
		COLUMN1,
		COLUMN1,
		COLUMNN
	FROM TableName
	WHERE CONDITIONS
)
/* Write your T-SQL query statement below */
SELECT 
    e.name AS Employee
FROM 
    Employee e
JOIN 
    Employee m ON e.managerId = m.id
WHERE 
    e.salary > m.salary;
/* Write your T-SQL query statement below */
SELECT 
    e.name AS Employee
FROM 
    Employee e
JOIN 
    Employee m ON e.managerId = m.id
WHERE 
    e.salary > m.salary;
/* Write your T-SQL query statement below */
SELECT
email AS Email
FROM
(
SELECT
    email,
    COUNT(email) AS EmailCount
FROM Person
GROUP BY email
HAVING COUNT(email) >= 2)t

SELECT
	e.emp_id,
	e.emp_name,
	e.manager_id,
	m.emp_name AS manager_name
FROM emp AS e
JOIN emp AS m
ON e.emp_id = m.emp_id

SELECT
	e.emp_id,
	e.emp_name,
	e.manager_id,
	m.emp_name AS manager_name
FROM emp AS e
JOIN emp AS m
ON e.emp_id = m.emp_id
