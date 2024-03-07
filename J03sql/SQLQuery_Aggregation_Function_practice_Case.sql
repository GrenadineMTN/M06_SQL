--1 Find the total revenue generated by the company.
SELECT SUM(OrderDetails.UnitPrice * OrderDetails.Quantity * (1 - OrderDetails.Discount)) as TotalRevenue
FROM OrderDetails ;


--2 Calculate the average revenue per order.
-- La sous-requête calcule d'abord le chiffre d'affaires total par commande.
-- Elle utilise une jointure entre les tables "Orders" et "OrderDetails" pour obtenir
-- les détails de chaque commande, calcule le chiffre d'affaires pour chaque ligne d'une
-- commande en multipliant le prix unitaire par la quantité et en soustrayant la remise,
-- puis agrège ces montants par  ID de commande à l'aide de la fonction SUM.
-- Ensuite, la requête principale calcule la moyenne de ces chiffres d'affaires
-- totaux par commande en utilisant la fonction AVG.

SELECT AVG(Sub.TotalRevenue) AS AverageRevenuePerOrder
FROM (
    SELECT SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalRevenue
    FROM Orders o
    JOIN OrderDetails od ON o.OrderID = od.OrderID
    GROUP BY o.OrderID
) AS Sub;

--3 Find the top 5 best-selling products (by quantity sold)


SELECT TOP 5 p.ProductID, p.ProductName, SUM(od.Quantity) as TotalQuantitySold
FROM Products as p
JOIN OrderDetails as od ON p.ProductID = od.ProductID
GROUP BY p.ProductID, p.ProductName
ORDER BY TotalQuantitySold DESC;

--- sans renommer mais au final plus pratique de renommer

SELECT TOP 5 Products.ProductID, Products.ProductName, SUM(OrderDetails.Quantity)  as Totalquantitévendue
FROM Products
JOIN OrderDetails ON Products.ProductID = OrderDetails.ProductID
GROUP BY Products.ProductID, Products.ProductName
ORDER BY Totalquantitévendue DESC;

-- 4 Display the total revenue generated per country, per customer, and also include a grand total

SELECT COALESCE(c.Country, 'Grand Total') as Country, COALESCE(c.CustomerID, 'Total') as CustomerID, COALESCE(c.CompanyName, 'All Customers') as CompanyName, SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) as TotalRevenue
FROM Customers as c
JOIN Orders as o ON c.CustomerID = o.CustomerID
JOIN OrderDetails as od ON o.OrderID = od.OrderID
GROUP BY ROLLUP (c.Country, c.CustomerID, c.CompanyName);