--Theme 1: Combining Customer and Supplier Data
--Retrieve a list of all distinct cities from both Customers and Suppliers tables.
SELECT DISTINCT City FROM Customers
UNION
SELECT DISTINCT City FROM Suppliers;

---Retrieve the count of distinct countries from both the Customers and Suppliers tables.
SELECT COUNT(*)  AS Pays_clients_et_supply 
FROM  (
    SELECT DISTINCT Country FROM Customers
    UNION
    SELECT DISTINCT Country FROM Suppliers
) 
AS  Pays_clients_et_supply ;


--Retrieve a list of countries that are present in both the Customers and Suppliers tables.

SELECT DISTINCT Country FROM Customers
INTERSECT
SELECT DISTINCT Country FROM Suppliers;

--Theme 2: Analysing Employee Sales
--Retrieve a list of EmployeeIDs who has processed orders with Freight greater than or equal to 100.
-- le distinct assure aucun doublon dans la table
SELECT DISTINCT EmployeeID,  FROM Orders
WHERE Freight >= 100;

--5 Retrieve a list of EmployeeIDs who has processed orders with Freight
-- greater than or equal to 100 and with Freight less than or equal to 50.
SELECT DISTINCT EmployeeID FROM Orders
WHERE Freight >= 100
INTERSECT
SELECT DISTINCT EmployeeID FROM Orders
WHERE Freight <= 50;

-- 6 Retrieve a list of EmployeeIDs who have processed orders with shippers 
--having ShipperID 1 but not with shippers having ShipperID 4.

SELECT DISTINCT EmployeeID FROM Orders
WHERE ShipVia = 1
EXCEPT
SELECT DISTINCT EmployeeID FROM Orders
WHERE ShipVia = 4;

-- Theme 3: Comparing Product Categories
--7 Retrieve a list of distinct CategoryIDs for products that have a UnitPrice greater than or equal to 20 
--and those with a UnitPrice less than 10.

SELECT DISTINCT CategoryID FROM Products
WHERE UnitPrice >= 20
UNION
SELECT DISTINCT CategoryID FROM Products
WHERE UnitPrice < 10;

--8 Retrieve a list of CategoryIDs for products that have a UnitPrice greater than or equal to 20 and also have a UnitPrice less than 10.

SELECT DISTINCT CategoryID FROM Products
WHERE UnitPrice >= 20
INTERSECT
SELECT DISTINCT CategoryID FROM Products
WHERE UnitPrice < 10;

--9 Retrieve a list of CategoryIDs for products that have a UnitPrice greater than or equal to 20 but do not have a UnitPrice less than 10.

SELECT DISTINCT CategoryID FROM Products
WHERE UnitPrice >= 20
EXCEPT
SELECT DISTINCT CategoryID FROM Products
WHERE UnitPrice < 10;

10 -- Retrieve the number of distinct SupplierIDs for suppliers located in the USA but not in the UK.

SELECT COUNT(*) FROM (
    SELECT DISTINCT SupplierID FROM Suppliers
    WHERE Country = 'USA'
    EXCEPT
    SELECT DISTINCT SupplierID FROM Suppliers
    WHERE Country = 'UK'
) AS UniqueSuppliers;