-- Rappel CTE (WITH AS) / Subqueries (IN)
-- La table pour une CTE est temporaire et n'est pas stocké en mémoire 
-- Mais permet de simplifier la lecture de certaines query.
-- Syntax : 
-- WITH cte AS (
--     SELECT column1, column2
--     FROM table1
--     WHERE column3 = 'value'
-- )
-- SELECT *
-- FROM cte;

-- Objectif ici juste les runs pour comprendre que permet de décomposer les queries. 

-- Exemple simple pour commencer (Level 1)
WITH ProductCTE AS (
    SELECT ProductID,Name, ListPrice
    FROM SalesLT.Product
    WHERE Color = 'Red'
)
SELECT ProductID,Name,ListPrice
FROM ProductCTE;

-- Exemple plus complexe (level 2)
WITH RedProducts AS (
    SELECT ProductID, Name
    FROM SalesLT.Product
    WHERE Color = 'Red'
),
ProductSales AS (
    SELECT sod.ProductID,SUM(sod.OrderQty * sod.UnitPrice) AS TotalSales
    FROM  SalesLT.SalesOrderDetail sod
    GROUP BY sod.ProductID
)
SELECT rp.ProductID,rp.Name,ps.TotalSales
FROM RedProducts rp
INNER JOIN ProductSales ps ON rp.ProductID = ps.ProductID

-- Query equivalente sans CTE
SELECT 
    p.ProductID, 
    p.Name, 
    SUM(sod.OrderQty * sod.UnitPrice) AS TotalSales
FROM 
    SalesLT.Product AS p
JOIN 
    SalesLT.SalesOrderDetail AS sod ON p.ProductID = sod.ProductID
WHERE 
    p.Color = 'Red'
GROUP BY 
    p.ProductID, 
    p.Name;







-- Sous Query 1
SELECT c.CustomerID, c.CompanyName, SUM(sod.LineTotal) AS TotalSales
FROM SalesLT.Customer AS c
JOIN SalesLT.SalesOrderHeader AS soh ON c.CustomerID = soh.CustomerID
JOIN SalesLT.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY c.CustomerID, c.CompanyName; 

-- Sous Query 2
SELECT p.ProductID, p.Name, SUM(sod.LineTotal) AS TotalSales
FROM SalesLT.Product AS p
JOIN SalesLT.SalesOrderDetail AS sod ON p.ProductID = sod.ProductID
GROUP BY p.ProductID, p.Name;



-- Exemple 2 Commencer à présenter celui-la car c'est le plus simple
WITH CustomerSales AS
(
    SELECT c.CustomerID, c.CompanyName, SUM(sod.LineTotal) AS TotalSales
    FROM SalesLT.Customer AS c
    JOIN SalesLT.SalesOrderHeader AS soh ON c.CustomerID = soh.CustomerID
    JOIN SalesLT.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
    GROUP BY c.CustomerID, c.CompanyName
),
ProductSales AS
(
    SELECT p.ProductID, p.Name, SUM(sod.LineTotal) AS TotalSales
    FROM SalesLT.Product AS p
    JOIN SalesLT.SalesOrderDetail AS sod ON p.ProductID = sod.ProductID
    GROUP BY p.ProductID, p.Name
)

SELECT cs.CompanyName, ps.Name AS ProductName, cs.TotalSales
FROM CustomerSales AS cs
JOIN SalesLT.SalesOrderHeader AS soh ON cs.CustomerID = soh.CustomerID
JOIN SalesLT.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN ProductSales AS ps ON sod.ProductID = ps.ProductID
ORDER BY cs.CompanyName, ps.Name;


-- Exemple 1
WITH CategoryHierarchy (CategoryID, ParentCategoryID, Name, HierarchyLevel) AS (
    SELECT ProductCategoryID, ParentProductCategoryID, Name, 1
    FROM SalesLT.ProductCategory
    WHERE ParentProductCategoryID IS NULL

    UNION ALL

    SELECT pc.ProductCategoryID, pc.ParentProductCategoryID, pc.Name, ch.HierarchyLevel + 1
    FROM SalesLT.ProductCategory pc
    INNER JOIN CategoryHierarchy ch ON pc.ParentProductCategoryID = ch.CategoryID
)
SELECT ch.*, p.Name AS ProductName
FROM CategoryHierarchy ch
LEFT JOIN SalesLT.Product p ON ch.CategoryID = p.ProductCategoryID
ORDER BY ch.HierarchyLevel, ch.Name, p.Name;


--CategoryHierarchy table 
WITH CategoryHierarchy (CategoryID, ParentCategoryID, Name, HierarchyLevel) AS (
    SELECT ProductCategoryID, ParentProductCategoryID, Name, 1
    FROM SalesLT.ProductCategory
    WHERE ParentProductCategoryID IS NULL

    UNION ALL

    SELECT pc.ProductCategoryID, pc.ParentProductCategoryID, pc.Name, ch.HierarchyLevel + 1
    FROM SalesLT.ProductCategory pc
    INNER JOIN CategoryHierarchy ch ON pc.ParentProductCategoryID = ch.CategoryID
)
SELECT ch.*, p.Name AS ProductName
FROM CategoryHierarchy AS ch
LEFT JOIN SalesLT.Product p ON ch.CategoryID = p.ProductCategoryID
ORDER BY ch.HierarchyLevel, ch.Name, p.Name;



-- Exemple 3
WITH CustomerSales AS
(
    SELECT c.CustomerID, c.CompanyName, SUM(sod.LineTotal) AS TotalSales
    FROM SalesLT.Customer AS c
    JOIN SalesLT.SalesOrderHeader AS soh ON c.CustomerID = soh.CustomerID
    JOIN SalesLT.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
    GROUP BY c.CustomerID, c.CompanyName
),
ProductSales AS
(
    SELECT p.ProductID, p.Name, SUM(sod.LineTotal) AS TotalSales
    FROM SalesLT.Product AS p
    JOIN SalesLT.SalesOrderDetail AS sod ON p.ProductID = sod.ProductID
    GROUP BY p.ProductID, p.Name
),
AverageSalesPerOrder AS
(
    SELECT soh.SalesOrderID, AVG(sod.LineTotal) AS AverageSales
    FROM SalesLT.SalesOrderHeader AS soh
    JOIN SalesLT.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
    GROUP BY soh.SalesOrderID
)
SELECT cs.CompanyName, ps.Name AS ProductName, cs.TotalSales, aspo.AverageSales
FROM CustomerSales AS cs
JOIN SalesLT.SalesOrderHeader AS soh ON cs.CustomerID = soh.CustomerID
JOIN SalesLT.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN ProductSales AS ps ON sod.ProductID = ps.ProductID
JOIN AverageSalesPerOrder AS aspo ON soh.SalesOrderID = aspo.SalesOrderID
ORDER BY cs.CompanyName, ps.Name;

