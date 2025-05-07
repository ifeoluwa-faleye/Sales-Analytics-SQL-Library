# 📊 Sales Analytics SQL Library

A comprehensive collection of **T‑SQL** snippets that answer common business questions for a fictional sales organisation.  
The code base focuses on **sales performance, customer behaviour, product profitability, employee metrics, and time‑series trends**.  
Every query has been **battle‑tested in Microsoft SQL Server 2019**, but should work with any engine that supports ANSI window functions.

---

## Table of Contents
1. [Introduction](#introduction)
2. [Problem Statement](#problem-statement)
3. [Project Structure](#project-structure)
4. [Getting Started](#getting-started)
5. [Analysis Notebook](#analysis-notebook)
   - [A. Core KPIs](#a-core-kpis)
   - [B. Product Performance](#b-product-performance)
   - [C. Customer Insights](#c-customer-insights)
   - [D. Order Intelligence](#d-order-intelligence)
   - [E. Advanced Windows & Ranking](#e-advanced-windows--ranking)
   - [F. Data Quality & Governance](#f-data-quality--governance)
   - [G. Time‑Series & Trend Analysis](#g-time-series--trend-analysis)
   - [H. Miscellaneous Utilities](#h-miscellaneous-utilities)
6. [Conclusion & Next Steps](#conclusion--next-steps)
7. [Contributing](#contributing)
8. [License](#license)

---

## Introduction<a name="introduction"></a>

Modern sales teams generate vast amounts of data—**orders, customers, products, shipping, employees**—yet raw tables rarely provide the answers leadership needs.  
This repository condenses the most frequently requested ad‑hoc reports into **readable, reusable SQL scripts**, allowing analysts to:

* calculate organisation‑wide sales KPIs in seconds;
* investigate outliers (top products, lowest‑performing customers, etc.);
* benchmark month‑over‑month (MoM) growth and customer loyalty; and
* enforce data‑quality rules before insights reach decision‑makers.

---

## Problem Statement<a name="problem-statement"></a>

> _“How can we transform transactional data in the `Sales` schema into actionable business insights **without** building a full BI stack?”_

Specifically, stakeholders asked for:

| # | Theme | Key Questions |
|---|-------|---------------|
| 1 | **Global KPIs** | What are total sales? How many orders & customers do we serve? |
| 2 | **Product Analysis** | Which products drive revenue? What percent of total sales does each contribute? |
| 3 | **Customer Behaviour** | Who are our most/least valuable customers? How often do they order? |
| 4 | **Temporal Trends** | Are we growing month‑over‑month? Which months ship fastest? |
| 5 | **Data Hygiene** | Do `Orders` & `OrdersArchive` contain duplicates? Are foreign‑key relationships intact? |

---

## Project Structure<a name="project-structure"></a>

```
├── README.md              ← **This** documentation
├── sales_analytics.sql    ← Master script (all queries below in one file)
└── LICENSE
```

*Feel free to split queries into separate files (`/sql/…`) or refactor into views/stored procedures.*

---

## Getting Started<a name="getting-started"></a>

1. **Clone** the repository  

   ```bash
   git clone https://github.com/your‑org/sales‑analytics‑sql.git
   cd sales‑analytics‑sql
   ```

2. **Open** `sales_analytics.sql` in SSMS / Azure Data Studio / DBeaver.

3. **Point** the connection to the database that contains the **`Sales`** schema (tables: `Orders`, `Products`, `Customers`, `Employees`, `OrdersArchive`).

4. **Execute** sections as needed.  
   All scripts are _read‑only_ except where explicitly labelled `CREATE VIEW`, `INTO`, or `DROP TABLE`.

> **Tip:** Run inside a transaction if you want a quick rollback for the table‑creation demo.

---

## Analysis Notebook<a name="analysis-notebook"></a>

Below is an **annotated catalogue** of every query contained in `sales_analytics.sql`.  
Copy/paste directly from any code block 🔽 to your SQL editor.

---

### A. Core KPIs<a name="a-core-kpis"></a>

<details>
<summary>🏷️ Total Sales &amp; Orders</summary>

```sql
-- Total sales across all orders
SELECT SUM(Sales) AS TotalSales
FROM Sales.Orders;

-- Total number of orders
SELECT COUNT(*) AS TotalOrders
FROM Sales.Orders;
```

*Insight → Track company‑wide revenue and order volume in real time.*
</details>

<details>
<summary>🏷️ Totals by Product &amp; Customer</summary>

```sql
-- Total sales for each product
SELECT ProductID,
       SUM(Sales) AS TotalSales
FROM   Sales.Orders
GROUP  BY ProductID;

-- Total orders per customer
SELECT CustomerID,
       COUNT(OrderID) AS OrdersPerCustomer
FROM   Sales.Orders
GROUP  BY CustomerID;
```

*Insight → Identify high‑performing SKUs and customer segments.*
</details>

---

### B. Product Performance<a name="b-product-performance"></a>

<details>
<summary>📈 Sales Contribution &amp; Price Outliers</summary>

```sql
/* Percentage contribution of each product to total sales */
SELECT ProductID,
       Sales,
       SUM(Sales) OVER ()                         AS TotalSales,
       ROUND(CAST(Sales AS FLOAT)
             / SUM(Sales) OVER () * 100, 1) AS PctOfTotal
FROM   Sales.Orders;

/* Products priced above the overall average */
SELECT ProductID, Product, Category, Price
FROM   Sales.Products
WHERE  Price > (SELECT AVG(Price) FROM Sales.Products);
```
</details>

<details>
<summary>🎯 Top‑N &amp; Bottom‑N Products</summary>

```sql
-- Highest sale per product (dense‑rank)
SELECT OrderID, ProductID, Sales
FROM (
        SELECT OrderID, ProductID, Sales,
               DENSE_RANK() OVER (PARTITION BY ProductID
                                  ORDER BY Sales DESC) AS r
        FROM   Sales.Orders
     ) x
WHERE  r = 1;   -- top sale for every product
```
</details>

---

### C. Customer Insights<a name="c-customer-insights"></a>

<details>
<summary>🏆 Customer Ranking by Sales</summary>

```sql
SELECT CustomerID,
       SUM(Sales)         AS TotalSales,
       RANK() OVER (ORDER BY SUM(Sales) DESC) AS SalesRank
FROM   Sales.Orders
GROUP  BY CustomerID;
```
</details>

<details>
<summary>🔄 Loyalty – Average Days Between Orders</summary>

```sql
WITH OrdersCTE AS (
  SELECT CustomerID,
         OrderDate,
         LEAD(OrderDate) OVER (PARTITION BY CustomerID ORDER BY OrderDate)
           AS NextOrderDate
  FROM   Sales.Orders
)
SELECT CustomerID,
       AVG(DATEDIFF(day, OrderDate, NextOrderDate)) AS AvgDaysBetween,
       DENSE_RANK() OVER (ORDER BY AVG(DATEDIFF(day, OrderDate, NextOrderDate)))
         AS LoyaltyRank
FROM   OrdersCTE
GROUP  BY CustomerID;
```
</details>

---

### D. Order Intelligence<a name="d-order-intelligence"></a>

<details>
<summary>⏰ Month‑over‑Month (MoM) Growth</summary>

```sql
WITH Monthly AS (
  SELECT MONTH(OrderDate) AS OrderMonth,
         SUM(Sales)       AS TotalSales
  FROM   Sales.Orders
  GROUP  BY MONTH(OrderDate)
)
SELECT *,
       ROUND(
         (TotalSales - LAG(TotalSales) OVER (ORDER BY OrderMonth))
         / NULLIF(LAG(TotalSales) OVER (ORDER BY OrderMonth), 0) * 100, 1) AS MoMGrowth
FROM   Monthly;
```
</details>

<details>
<summary>🚚 Average Shipping Duration per Month</summary>

```sql
SELECT DATENAME(month, OrderDate) AS MonthName,
       AVG(DATEDIFF(day, OrderDate, ShipDate)) AS AvgShipDays
FROM   Sales.Orders
GROUP  BY DATENAME(month, OrderDate);
```
</details>

---

### E. Advanced Windows & Ranking<a name="e-advanced-windows--ranking"></a>

| Technique | Demo Query |
|-----------|------------|
| **Running totals / moving averages** | `AVG(Sales) OVER (PARTITION BY ProductID ORDER BY OrderDate)` |
| **NTILE bucketing** | Segment orders into *High / Medium / Low* sales tiers. |
| **CUME_DIST / PERCENT_RANK** | Identify top 40 % priced products. |
| **FIRST_VALUE / LAST_VALUE** | Fetch min/max sales **without** self‑joins. |

<details>
<summary>Full snippet</summary>

```sql
SELECT OrderDate,
       ProductID,
       Sales,
       AVG(Sales) OVER (PARTITION BY ProductID
                        ORDER BY OrderDate) AS MovingAvg,
       NTILE(3) OVER (ORDER BY Sales DESC)  AS SalesTier,
       CUME_DIST() OVER (ORDER BY Price DESC) * 100 AS Percentile
FROM   Sales.Orders
JOIN   Sales.Products USING (ProductID);
```
</details>

---

### F. Data Quality & Governance<a name="f-data-quality--governance"></a>

*Duplicate detection, archive validation, union vs union‑all pitfalls.*

```sql
-- Does Orders contain duplicate primary keys?
SELECT OrderID, COUNT(*) AS RowCount
FROM   Sales.Orders
GROUP  BY OrderID
HAVING COUNT(*) > 1;

-- Clean OrdersArchive (deduplicate)
WITH Ranked AS (
  SELECT *, ROW_NUMBER() OVER (
           PARTITION BY ProductID, CustomerID, OrderDate
           ORDER BY CreationTime DESC) AS rn
  FROM   Sales.OrdersArchive
)
DELETE FROM Ranked WHERE rn > 1;
```

---

### G. Time‑Series & Trend Analysis<a name="g-time-series--trend-analysis"></a>

```sql
-- Orders per year and per month
SELECT YEAR(OrderDate)  AS YearOfOrder,
       COUNT(DISTINCT OrderID) AS OrdersPerYear
FROM   Sales.Orders
GROUP  BY YEAR(OrderDate);

SELECT MONTH(OrderDate) AS MonthNo,
       DATENAME(month, OrderDate) AS MonthName,
       COUNT(DISTINCT OrderID) AS OrdersPerMonth
FROM   Sales.Orders
GROUP  BY MONTH(OrderDate), DATENAME(month, OrderDate)
ORDER  BY MonthNo;
```

*Combine with charting tools (Power BI / Tableau) for interactive dashboards.*

---

### H. Miscellaneous Utilities<a name="h-miscellaneous-utilities"></a>

* Age calculation for employees  
* Dynamic date‑time formatting  
* Recursive CTE number generator (`1 … 20`)  
* UNION / INTERSECT / EXCEPT set ops to compare `Employees` & `Customers` lists  
* View definitions (`V_Order_Details`, `V_Order_Details_EU`)  
* Quick‑and‑dirty table creation: `Sales.MonthlyOrders` (demo)

---

## Conclusion & Next Steps<a name="conclusion--next-steps"></a>

These scripts provide an **out‑of‑the‑box analytics toolkit** for any sales database that matches the schema below:

```
Sales
├── Orders            (OrderID, ProductID, CustomerID, …)
├── OrdersArchive
├── Products
├── Customers
└── Employees
```

Key take‑aways:

* **Window functions** unlock powerful calculations (running totals, moving averages, percentiles) with a single SELECT.
* **Data quality** checks prevent misleading insights—always validate duplicates and orphaned keys.
* **CTEs & views** modularise logic; downstream dashboards need only read‑access to secure objects.
* Further opportunities include:
  * Parameterising scripts into stored procedures for scheduled ETL.
  * Materialising heavy queries into indexed views for faster BI consumption.
  * Integrating row‑level security to restrict sensitive employee data.

---

## Contributing<a name="contributing"></a>

1. Fork → Create branch → Commit changes → Open PR  
2. Follow the **[SQL Style Guide](https://www.sqlstyle.guide/)** (uppercase keywords, singular table names, 4‑space indents).  
3. Document _why_ a query is needed, not just _what_ it does.

---

## License<a name="license"></a>

This project is licensed under the **MIT License** – see [`LICENSE`](LICENSE) for details.
