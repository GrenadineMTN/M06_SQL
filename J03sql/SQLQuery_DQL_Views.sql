-- VIEWS
-- Exemple 1
-- Une fois lancé aller voir l'onglet Views de la base de données
CREATE VIEW ProductDetails AS
SELECT p.ProductID, p.Name, pd.Description, pc.Name as Category
FROM SalesLT.Product p
JOIN SalesLT.ProductModelProductDescription pm
  ON p.ProductModelID = pm.ProductModelID
JOIN SalesLT.ProductDescription pd
  ON pm.ProductDescriptionID = pd.ProductDescriptionID
JOIN SalesLT.ProductCategory pc
  ON p.ProductCategoryID = pc.ProductCategoryID;

SELECT TOP(5) * FROM dbo.ProductDetails;

--Exemple 2
CREATE VIEW CustomerSpendings AS
SELECT c.CustomerID, c.FirstName, c.LastName, SUM(sod.LineTotal) as TotalSpending
FROM SalesLT.Customer c
JOIN SalesLT.SalesOrderHeader soh
  ON c.CustomerID = soh.CustomerID
JOIN SalesLT.SalesOrderDetail sod
  ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY c.CustomerID, c.FirstName, c.LastName

SELECT TOP(5) * FROM dbo.CustomerSpendings;

-- Grant access to the view
GRANT SELECT, INSERT, DELETE ON ProductDetails TO SalesRep;
