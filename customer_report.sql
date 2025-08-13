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
CREATE VIEW gold.report_customers AS
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
	last_order_date,
	DATEDIFF(month, last_order_date, GETDATE()) AS recency,
	CASE WHEN total_orders = 0 THEN 0
		 ELSE total_sales/total_orders 
	END AS avg_order_value,
	CASE WHEN lifespan = 0 THEN total_sales
		 ELSE total_sales/lifespan 
	END AS avg_monthly_spend
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
