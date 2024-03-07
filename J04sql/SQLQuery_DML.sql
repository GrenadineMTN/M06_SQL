-- DML Course

-- INSERT syntax (Rappel car déjà vu en DDL)
-- INSERT INTO table_name (column1, column2, column3, ...)
-- VALUES (value1, value2, value3, ...);

-- Bien voir que lorsque l'on insère on ne spécifie pas de ID,
-- MySQLServer s'occupe de l'incrementer pour nous
-- Rappel ProductReviewID INT IDENTITY(1,1) PRIMARY KE
-- IDENTITY permet d'autoincrémenter la clé
-- First 1 represents the seed value
-- Second 1 represents the increment value.
SELECT TOP(20) * FROM SalesLT.Address

SELECT TOP(20) * FROM SalesLT.Address ORDER BY AddressID DESC;

INSERT INTO SalesLT.Address (AddressLine1, AddressLine2, City, StateProvince, CountryRegion, PostalCode)
VALUES ('8713 Yosemite Ct.', NULL, 'Bothell', 'Washington', 'United States', '98011');


INSERT INTO SalesLT.Address (AddressLine2, AddressLine1, City, StateProvince, CountryRegion, PostalCode)
VALUES (NULL,'8719 Yosemite Ct.','Bothell', 'Washington', 'United States', '98011');


INSERT INTO SalesLT.Address (AddressLine1, AddressLine2, City, StateProvince, CountryRegion, PostalCode, rowguid, ModifiedDate)
VALUES 
('123 Elm Street', NULL, 'Springfield', 'Illinois', 'United States', '62704', NEWID(), GETDATE()),
('456 Maple Avenue', NULL, 'Oakdale', 'Wisconsin', 'United States', '53156', NEWID(), GETDATE()),
('789 Pine Road', NULL, 'Pinecrest', 'Minnesota', 'United States', '55416', NEWID(), GETDATE());

-- UPDATE syntax 
-- UPDATE table_name
-- SET column1 = value1, column2 = value2, ...
-- WHERE condition;

SELECT TOP(20) * FROM SalesLT.Customer ORDER BY CustomerID; 


-- Exemple1 OK
UPDATE SalesLT.Customer
SET Phone = '123-456-7890'
WHERE CustomerID = 1;

-- Exemple2 Course example non valide car pas de colonne DiscountPercentage
-- Proposition de correction
UPDATE SalesLT.SalesOrderHeader
SET DiscountPercentage = 0.05
WHERE OrderDate < '2003-07-01'; 

SELECT * FROM SalesLT.SalesOrderHeader;

ALTER TABLE SalesLT.SalesOrderHeader
ADD DiscountPercentage DECIMAL(5, 2) NOT NULL CONSTRAINT DF_SalesOrderHeader_DiscountPercentage DEFAULT 0.02 WITH VALUES;

ALTER TABLE SalesLT.SalesOrderHeader
DROP COLUMN DiscountPercentage;

ALTER TABLE SalesLT.SalesOrderHeader
DROP DF_SalesOrderHeader_DiscountPercentage


-- If error pops when dropping
ALTER TABLE SalesLT.SalesOrderDetail
DROP CONSTRAINT FK_SalesOrderDetail_Product_ProductID;

SELECT * FROM SalesLT.SalesOrderHeader;

UPDATE SalesLT.SalesOrderHeader
SET DiscountPercentage = 0.05
WHERE SalesOrderID < 71900;

-- Exemple 3
SELECT * FROM SalesLT.Customer ORDER BY CustomerID;

UPDATE SalesLT.Customer
SET LastName = 'Smith', EmailAddress = 'jsmith@example.com'
WHERE CustomerID BETWEEN 5 AND 10;


-- Exemple 4 (Ne fonctionne pas) Demander aux élèves comment régler ce problème 
-- (2 causes à detecter)
SELECT * FROM SalesLT.Customer;
-- La correction nous donne (Non fonctionnel): 
UPDATE SalesLT.Customer
SET StateProvince = CA.StateProvince
FROM SalesLT.Customer AS C
INNER JOIN SalesLT.CustomerAddress AS CA ON C.CustomerID = CA.CustomerID;

-- Solution = Creation de colonne + Ajout d'un JOIN
ALTER TABLE SalesLT.Customer
ADD StateProvince NVARCHAR(50) NULL

UPDATE SalesLT.Customer
SET StateProvince = A.StateProvince
FROM SalesLT.Customer C
INNER JOIN SalesLT.CustomerAddress CA ON C.CustomerID = CA.CustomerID
INNER JOIN SalesLT.Address AS A ON CA.AddressID = A.AddressID;

-- Exemple 5
SELECT TOP(20) * FROM SalesLT.Product;

UPDATE SalesLT.Product
SET ListPrice = 1.2 * StandardCost
WHERE Color = 'Red';

-- Exemple 6 (Correction ne fonctionne pas)
-- Correction du cours : 
-- UPDATE SalesLT.SalesOrderHeader
-- SET Status = CASE
--     WHEN OrderDate < '2004-01-01' AND OrderQty >= 10 THEN 'Shipped'
--     ELSE 'Pending'
-- END;

SELECT * FROM SalesLT.SalesOrderHeader;

ALTER TABLE SalesLT.SalesOrderHeader
ADD ShippingStatus NVARCHAR(10) NULL;

UPDATE SalesLT.SalesOrderHeader
SET ShippingStatus = CASE
    WHEN CustomerID < 30000 AND SubTotal >= 1000 THEN 'Shipped'
    ELSE 'Pending'
END;

-- Exemple 7 Attention GETDATE() specifique à Microsoft SQL Server
SELECT * FROM SalesLT.Product;

UPDATE SalesLT.Product
SET ModifiedDate = GETDATE()
WHERE ListPrice >= 50.0;

-- DELETE Statement
-- SYNTAX : DELETE FROM table_name WHERE condition;

-- Exemple 1
SELECT * FROM SalesLT.SalesOrderDetail;

DELETE FROM SalesLT.SalesOrderDetail
WHERE SalesOrderID = 71774 AND ProductID = 822;

-- Exemple 2 Don't run correction where SalesOrderID > 43670 (sinon supprime tout le tableau)
DELETE FROM SalesLT.SalesOrderDetail
WHERE SalesOrderID > 71937;

-- Exemple 3
DELETE FROM SalesLT.SalesOrderDetail;


-- Exemple 4 (Delete with a subquery)
SELECT * FROM SalesLT.SalesOrderDetail;

DELETE FROM SalesLT.SalesOrderDetail
WHERE ProductID IN (
  SELECT ProductID FROM SalesLT.Product
  WHERE Color = 'Red');


-- Exemple 5 (Delete with a join)
SELECT * FROM SalesLT.Product;

DELETE sod
FROM SalesLT.SalesOrderDetail sod
JOIN SalesLT.Product p ON sod.ProductID = p.ProductID
WHERE p.DiscontinuedDate IS NOT NULL;


-- MERGE statement (perform both INSERT and UPDATE operations in a single statement)
-- SYNTAXE : 
-- MERGE INTO target_table AS target
-- USING source_table AS source
-- ON condition
-- WHEN MATCHED THEN
--    UPDATE SET target_col = source_col
-- WHEN NOT MATCHED THEN
--    INSERT (col1, col2, col3, ...) VALUES (value1, value2, value3, ...);``

-- Exemple 1
SELECT TOP(5) * FROM SalesLT.ProductModelProductDescription;
SELECT TOP(5) * FROM SalesLT.ProductDescription;

MERGE INTO SalesLT.ProductModelProductDescription AS target
USING SalesLT.ProductDescription AS source
ON target.ProductDescriptionID = source.ProductDescriptionID
WHEN MATCHED THEN
   UPDATE SET target.ModifiedDate = source.ModifiedDate
WHEN NOT MATCHED BY SOURCE THEN
   DELETE;

-- Exemple 2
SELECT * FROM SalesLT.ProductDescription ORDER BY ProductDescriptionID DESC;

MERGE INTO SalesLT.ProductDescription AS target
USING SalesLT.ProductCategory AS source
ON target.ProductDescriptionID = source.ProductCategoryID
WHEN NOT MATCHED THEN
   INSERT (Description, ModifiedDate)
   VALUES ('New Category', GETDATE())
WHEN MATCHED THEN
   UPDATE SET target.ModifiedDate = GETDATE();

SELECT * FROM SalesLT.ProductDescription ORDER BY ProductDescriptionID DESC;