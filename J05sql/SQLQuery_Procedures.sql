-- Syntax
-- CREATE PROCEDURE procedure_name
--     [ { @parameter [ type_schema_name. ] data_type } 
--         [ VARYING ] [ = default ] [ OUT | OUTPUT | [READONLY] ]
--     ]
--     [,...n]
-- AS
--     { sql_statement [;] [ ...n ] | 
--       EXTERNAL NAME <method specifier [;]> 
--     }
--     [;]

-- SQL Injection courses
-- Exemple du cours
SELECT ProductID, Name, Color, Size, Weight
FROM SalesLT.Product
WHERE Name = '' OR 1=1; DROP TABLE SalesLT.Product --'

-- Exemple perso 1 Connexion avec le compte admin 
-- The SQL query to authenticate on a website
SELECT * FROM users WHERE username = '$username' AND password = '$password';
-- Hacker insert username "admin'-- " & password "whatever"
SELECT * FROM users WHERE username = 'admin'-- ' AND password = 'whatever';
-- Then the application checks if any rows were returned to determine if the login was successful.
-- If at least one row is returned, the application give access to the admin account.

-- Exemple perso 2 Drop table in a database
-- The SQL query to search book on a website
SELECT * FROM books WHERE title LIKE '%$searchTerm%';
-- Normal user query
SELECT * FROM books WHERE title LIKE '%Harry Potter%';
-- Hacker query with the following research : ' UNION SELECT username, password FROM users -- 
SELECT * FROM books WHERE title LIKE '%' UNION SELECT username, password FROM users -- '


-- DROP Procedures
DROP PROCEDURE IF EXISTS SearchProducts;

-- Exemple 1 (voir que l'on crée bien une procédure dans DB / Programmability / Stored Procedure)
CREATE PROCEDURE SearchProducts
    @ProductName nvarchar(50)
AS
BEGIN
    -- SET NOCOUNT ON;
    IF EXISTS (SELECT * FROM SalesLT.Product WHERE Name = @ProductName)
    BEGIN
        SELECT ProductID, Name, Color, Size, Weight
        FROM SalesLT.Product
        WHERE Name = @ProductName;
    END
    ELSE
    BEGIN
        RAISERROR('Product not found', 16, 1);
    END
END

EXEC SearchProducts @ProductName = 'Road-650 Red, 52';

-- Exemple 2
CREATE PROCEDURE GetCustomerByID
    @CustomerID INT
AS
BEGIN
    SELECT *
    FROM SalesLT.Customer
    WHERE CustomerID = @CustomerID
END
-- Manual Execution of the procedure
EXEC GetCustomerByID @CustomerID = 1;

-- Exemple 3
CREATE PROCEDURE GetOrdersByCustomerNameAndDateRange
    @CustomerName NVARCHAR(50),
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SELECT soh.SalesOrderID, sod.ProductID, sod.UnitPrice, sod.OrderQty, sod.LineTotal
    FROM SalesLT.Customer c
    JOIN SalesLT.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
    JOIN SalesLT.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
    WHERE c.FirstName + ' ' + c.LastName = @CustomerName
    AND soh.OrderDate BETWEEN @StartDate AND @EndDate
END
-- Manual Execution of the procedure
EXEC GetOrdersByCustomerNameAndDateRange @CustomerName = 'Raja Venugopal', @StartDate = '2000-01-01', @EndDate = '2010-12-31';


-- Exemple 4 
CREATE PROCEDURE CalculateTotalSalesByProductCategoryAndDateRange
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SELECT pc.Name AS ProductCategoryName, SUM(sod.LineTotal) AS TotalSales
    FROM SalesLT.ProductCategory pc
    JOIN SalesLT.Product p ON pc.ProductCategoryID = p.ProductCategoryID
    JOIN SalesLT.ProductModelProductDescription pmpd ON p.ProductModelID = pmpd.ProductModelID
    JOIN SalesLT.ProductDescription pd ON pmpd.ProductDescriptionID = pd.ProductDescriptionID
    JOIN SalesLT.SalesOrderDetail sod ON p.ProductID = sod.ProductID
    JOIN SalesLT.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
    WHERE soh.OrderDate BETWEEN @StartDate AND @EndDate
    GROUP BY pc.Name
END
-- Manual Execution of the procedure
EXEC CalculateTotalSalesByProductCategoryAndDateRange @StartDate = '2008-01-01', @EndDate = '2008-12-31';