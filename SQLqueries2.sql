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
