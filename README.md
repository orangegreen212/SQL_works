# Northwind Sales Analysis

This project explores product category performance in the **Northwind** database using **BigQuery SQL**.  
It calculates key sales metrics and helps identify which categories perform best.

---

## 🎯 Goal
To analyze sales and shipping performance across categories using simple and clear SQL logic.

---

## 📊 Key Metrics
- **Total Sales** — overall revenue per category  
- **Average Order Value** — revenue per order  
- **Average Time to Ship** — average shipping time in days  
- **Top 5 Ratio** — share of top 5 products in category sales  
- **Average Order Frequency** — number of orders per customer  

---

## 🛠 Tools
- **Google BigQuery**
- **SQL (CTEs, aggregation, ranking)**

---

## 🧮 Example Query
```sql
WITH OrderLineItems AS (
  SELECT
    c.CategoryName,
    p.ProductID,
    o.OrderID,
    o.CustomerID,
    o.OrderDate,
    o.ShippedDate,
    (od.UnitPrice * od.Quantity * (1 - od.Discount)) AS LineTotal
  FROM
    `northwind.Order_Details` AS od
  JOIN `northwind.Products` AS p ON od.ProductID = p.ProductID
  JOIN `northwind.Categories` AS c ON p.CategoryID = c.CategoryID
  JOIN `northwind.Orders` AS o ON od.OrderID = o.OrderID
  WHERE o.ShippedDate IS NOT NULL
)
SELECT
  CategoryName,
  ROUND(SUM(LineTotal), 2) AS TotalSales,
  ROUND(SAFE_DIVIDE(SUM(LineTotal), COUNT(DISTINCT OrderID)), 2) AS AverageOrderValue,
  ROUND(AVG(DATE_DIFF(ShippedDate, OrderDate, DAY)), 2) AS AverageTimeToShip,
  ROUND(SAFE_DIVIDE(COUNT(DISTINCT OrderID), COUNT(DISTINCT CustomerID)), 2) AS AverageOrderFrequency
FROM OrderLineItems
GROUP BY CategoryName
ORDER BY TotalSales DESC;
``` 
##  📈 Example Output
CategoryName	TotalSales	AvgOrderValue	AvgTimeToShip	Top5Ratio	AvgOrderFrequency
Beverages	125000.50	520.80	4.30	0.7120	2.45
Condiments	98000.20	495.10	3.95	0.6550	1.98
Seafood	76000.75	480.30	5.10	0.6780	2.10

##  ✅ Result

The analysis shows which categories generate the most revenue, how quickly they ship, and how concentrated their sales are among top products.
