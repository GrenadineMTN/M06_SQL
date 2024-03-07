-- VARIABLE

-- Syntax
-- DECLARE @variable_name data_type;
-- SET @variable_name = value;

-- Exemple 1
DECLARE @ProductName VARCHAR(100);
SET @ProductName = 'Road-150 Red, 48'
PRINT 'Variable: ' + @ProductName;

-- Exemple 2
DECLARE @ProductName VARCHAR(100);
SET @ProductName = 'Road-150 Red, 48';

SELECT ProductID, Name, Color, StandardCost
FROM SalesLT.Product
WHERE Name = @ProductName;

-- Exemple 3
DECLARE @CategoryName NVARCHAR(50);
SET @CategoryName = 'Mountain Bikes';
SELECT AVG(ListPrice) AS AveragePrice
FROM SalesLT.Product
WHERE ProductCategoryID IN (
    SELECT ProductCategoryID
    FROM SalesLT.ProductCategory
    WHERE Name = @CategoryName
);

-- Exemple 4
-- Declare variables
DECLARE @CustomerEmail NVARCHAR(100);
DECLARE @StartDate DATE;
DECLARE @EndDate DATE;

-- Set variable values
SET @CustomerEmail = 'catherine0@adventure-works.com';
SET @StartDate = '2008-01-01';
SET @EndDate = '2008-12-31';

-- Query to find the total sales amount for the specified customer in the given date range
SELECT C.CustomerID, C.FirstName, C.LastName, SUM(SOH.TotalDue) AS TotalSalesAmount
FROM SalesLT.Customer AS C
JOIN SalesLT.CustomerAddress AS CA ON C.CustomerID = CA.CustomerID
JOIN SalesLT.SalesOrderHeader AS SOH ON CA.CustomerID = SOH.CustomerID
WHERE C.EmailAddress = @CustomerEmail
    AND SOH.OrderDate BETWEEN @StartDate AND @EndDate
GROUP BY C.CustomerID, C.FirstName, C.LastName;


-- CURSORS (Operation row by row but slower)

-- Rappel (multiple rows in one time)
-- UPDATE Employees
-- SET Salary = Salary * 1.10
-- WHERE Department = 'Sales';

-- Exemple 1
-- Dans cette première query (voir que l'on utilise pas de curseur)
DECLARE @fName VARCHAR(255), @lName VARCHAR(255)
SELECT @fName = FirstName ,
        @lName = LastName
FROM SalesLT.Customer
WHERE FirstName = 'Brian'
PRINT @fName + ' ' + @lName 

-- SELECT query yields 6 rows, but only the final row is utilized. 
-- The outcome of this T-SQL code is "Brian Johnson," the last row in the dataset.
SELECT FirstName, LastName
FROM SalesLT.Customer
WHERE FirstName = 'Brian';


-- Exemple 1 Complet
DECLARE @fName VARCHAR(255), @lName VARCHAR(255);

DECLARE Cursor_Customer CURSOR FOR
SELECT FirstName, LastName
FROM SalesLT.Customer
WHERE FirstName = 'Brian'

-- Open the cursor
OPEN Cursor_Customer

-- Retrieve the first row of the data set and assign each column to a variable
FETCH NEXT FROM Cursor_Customer INTO @fName, @lName  

-- Loop through all the rows in the data set
WHILE @@FETCH_STATUS = 0  
BEGIN  
      PRINT 'The customer is named: ' + @fName + ' ' + @lName;
      PRINT 'FETCH STATUS: ' + CAST(@@FETCH_STATUS AS NVARCHAR(50));
      FETCH NEXT FROM Cursor_Customer INTO @fName, @lName  ; 
END 
PRINT 'FETCH STATUS: ' + CAST(@@FETCH_STATUS AS NVARCHAR(50));
CLOSE Cursor_Customer;      -- Obligatoire de CLOSE
DEALLOCATE Cursor_Customer; -- Pour effacer sa définition on deallocate

-- Exemple 2 
DECLARE @ProductID INT,
        @ListPrice DECIMAL(18, 2),
        @CategoryName NVARCHAR(50),
        @PriceIncreasePercentage DECIMAL(18, 2) = 10;

DECLARE product_cursor CURSOR FOR
SELECT p.ProductID, p.ListPrice, pc.Name
FROM SalesLT.Product AS p
JOIN SalesLT.ProductCategory AS pc ON p.ProductCategoryID = pc.ProductCategoryID
WHERE pc.Name = 'Mountain Bikes';

OPEN product_cursor;

FETCH NEXT FROM product_cursor INTO @ProductID, @ListPrice, @CategoryName;

WHILE @@FETCH_STATUS = 0
BEGIN
    UPDATE SalesLT.Product
    SET ListPrice = ListPrice * (1 + (@PriceIncreasePercentage / 100))
    WHERE ProductID = @ProductID;

    FETCH NEXT FROM product_cursor INTO @ProductID, @ListPrice, @CategoryName;
END

CLOSE product_cursor;
DEALLOCATE product_cursor;

-- Exemple 2 Without cursor (Comparer les temps d'execution)
DECLARE @PriceIncreasePercentage DECIMAL(18, 2) = 10;

UPDATE p
SET p.ListPrice = p.ListPrice * (1 + (@PriceIncreasePercentage / 100))
FROM SalesLT.Product AS p
JOIN SalesLT.ProductCategory AS pc ON p.ProductCategoryID = pc.ProductCategoryID
WHERE pc.Name = 'Mountain Bikes';


-- Exemple 3
DECLARE @OrderID INT,
        @OrderDate DATETIME,
        @Status NVARCHAR(50);

DECLARE order_cursor CURSOR FOR
SELECT SalesOrderID, OrderDate, Status
FROM SalesLT.SalesOrderHeader;

OPEN order_cursor;

FETCH NEXT FROM order_cursor INTO @OrderID, @OrderDate, @Status;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Perform necessary actions for processing the order, such as checking inventory levels, updating stock quantities, and generating invoices.

    -- Check product availability based on OrderQty in SalesOrderDetail for the current @OrderID
    WITH ProductAvailability AS (
        SELECT p.ProductID, p.Name, p.StandardCost, p.ListPrice,
               SUM(sod.OrderQty) AS TotalOrderQty
        FROM SalesLT.Product p
        JOIN SalesLT.SalesOrderDetail sod ON p.ProductID = sod.ProductID
        WHERE sod.SalesOrderID = @OrderID
        GROUP BY p.ProductID, p.Name, p.StandardCost, p.ListPrice
    ),
    UpdatedProductQuantities AS (
        SELECT ProductID, Name, StandardCost, ListPrice,
               CASE
                   -- Update product quantity based on a business rule, e.g., a 10% increase
                   WHEN TotalOrderQty > 100 THEN TotalOrderQty * 1.1
                   ELSE TotalOrderQty
               END AS UpdatedOrderQty
        FROM ProductAvailability
    )
    SELECT * FROM UpdatedProductQuantities;

    FETCH NEXT FROM order_cursor INTO @OrderID, @OrderDate, @Status;
END

CLOSE order_cursor;
DEALLOCATE order_cursor;
