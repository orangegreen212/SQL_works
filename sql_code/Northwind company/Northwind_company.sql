-- 1. Collect all necessary data in one place
WITH OrderLineItems AS (
  SELECT
    c.CategoryName,
    p.ProductID,
    p.ProductName,
    o.OrderID,
    o.CustomerID,
    o.OrderDate,
    o.ShippedDate,
    (od.UnitPrice * od.Quantity * (1 - od.Discount)) AS LineTotal
  FROM
    `northwind.Order_Details` AS od
  JOIN
    `northwind.Products` AS p ON od.ProductID = p.ProductID
  JOIN
    `northwind.Categories` AS c ON p.CategoryID = c.CategoryID
  JOIN
    `northwind.Orders` AS o ON od.OrderID = o.OrderID
  WHERE
    o.ShippedDate IS NOT NULL
),

-- 2. Calculate total and average order value by category
CategorySales AS (
  SELECT
    CategoryName,
    SUM(LineTotal) AS TotalSales,
    ROUND(SAFE_DIVIDE(SUM(LineTotal), COUNT(DISTINCT OrderID)), 2) AS AverageOrderValue
  FROM OrderLineItems
  GROUP BY CategoryName
),

-- 3. Calculate average shipping time (in days)
CategoryShipping AS (
  SELECT
    CategoryName,
    ROUND(AVG(DATE_DIFF(ShippedDate, OrderDate, DAY)), 2) AS AverageTimeToShip
  FROM OrderLineItems
  GROUP BY CategoryName
),

-- 4. Calculate number of orders per customer
CategoryFrequency AS (
  SELECT
    CategoryName,
    ROUND(SAFE_DIVIDE(COUNT(DISTINCT OrderID), COUNT(DISTINCT CustomerID)), 2) AS AverageOrderFrequency
  FROM OrderLineItems
  GROUP BY CategoryName
),

--  5. Calculate Top 5 ratio — total sales of top 5 products vs total sales
Top5Sales AS (
  SELECT
    CategoryName,
    SUM(LineTotal) AS TotalSales,
    SUM(CASE WHEN ProductRank <= 5 THEN LineTotal ELSE 0 END) AS Top5Sales
  FROM (
    SELECT
      CategoryName,
      ProductID,
      SUM(LineTotal) AS LineTotal,
      ROW_NUMBER() OVER(PARTITION BY CategoryName ORDER BY SUM(LineTotal) DESC) AS ProductRank
    FROM OrderLineItems
    GROUP BY CategoryName, ProductID
  )
  GROUP BY CategoryName
)

-- 6. Combine all metrics into one final table
SELECT
  cs.CategoryName,
  ROUND(cs.TotalSales, 2) AS TotalSales,
  cs.AverageOrderValue,
  csh.AverageTimeToShip,
  ROUND(SAFE_DIVIDE(t.Top5Sales, t.TotalSales), 4) AS Top5Ratio,
  cf.AverageOrderFrequency
FROM CategorySales AS cs
LEFT JOIN CategoryShipping AS csh ON cs.CategoryName = csh.CategoryName
LEFT JOIN CategoryFrequency AS cf ON cs.CategoryName = cf.CategoryName
LEFT JOIN Top5Sales AS t ON cs.CategoryName = t.CategoryName
ORDER BY TotalSales DESC;
