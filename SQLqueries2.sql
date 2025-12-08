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
