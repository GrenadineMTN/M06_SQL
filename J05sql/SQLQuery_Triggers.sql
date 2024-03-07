-- TRIGGERS
-- Syntax : 
-- CREATE TRIGGER trigger_name
-- ON table_name
-- AFTER | INSTEAD OF event_type
-- AS
-- BEGIN
--     -- trigger logic goes here
-- END;

-- Exemple 1
-- Une fois crée (aller voir que le trigger est bien disponible sous Tables / SalesLT.Product / Triggers )
CREATE TRIGGER LogNewProduct
ON SalesLT.Product
AFTER INSERT
AS
BEGIN
    INSERT INTO ErrorLog (UserName, ErrorNumber, ErrorMessage)
    SELECT SUSER_SNAME(), 0, 'New product added: ' + i.Name
    FROM inserted i
END;

-- Test du trigger par insertion d'une row
INSERT INTO SalesLT.Product
(Name, ProductNumber, StandardCost, ListPrice, SellStartDate, rowguid, ModifiedDate)
VALUES
('New Test Product2', 'TEST-002', 100, 200, GETDATE(), NEWID(), GETDATE());

-- Verification de la validité du Trigger
SELECT * FROM ErrorLog
ORDER BY ErrorLogID DESC;


-- Example 2 (Pour modifier la date lors d'une mise à jour)
CREATE TRIGGER UpdateProductModifiedDate
ON SalesLT.Product
AFTER UPDATE
AS
BEGIN
    IF UPDATE(ListPrice)
    BEGIN
        UPDATE p
        SET p.ModifiedDate = GETDATE()
        FROM SalesLT.Product p
        INNER JOIN inserted i ON p.ProductID = i.ProductID
    END
END;

SELECT ProductID, Name, ListPrice, ModifiedDate
FROM SalesLT.Product
WHERE ProductID = 680;

UPDATE SalesLT.Product
SET ListPrice = ListPrice * 1.1 -- Increase the ListPrice by 10%
WHERE ProductID = 680;

SELECT ProductID, Name, ListPrice, ModifiedDate
FROM SalesLT.Product
WHERE ProductID = 680;

-- Exemple 3
CREATE TRIGGER CheckOrderFrequency
ON SalesLT.SalesOrderHeader
AFTER INSERT
AS
BEGIN
    DECLARE @CustomerID INT,
            @OrderCount INT,
            @MaxOrders INT = 10,
            @TimeFrame INT = 30;

    SELECT @CustomerID = CustomerID FROM inserted;

    SELECT @OrderCount = COUNT(*)
    FROM SalesLT.SalesOrderHeader
    WHERE CustomerID = @CustomerID
    AND DATEDIFF(DAY, OrderDate, GETDATE()) <= @TimeFrame;

    IF @OrderCount > @MaxOrders
    BEGIN
        ROLLBACK TRANSACTION; -- triggers operates within the same transaction

        INSERT INTO ErrorLog (ErrorMessage)
        VALUES ('Customer ' + CAST(@CustomerID AS VARCHAR(10)) + ' exceeded the maximum allowed number of orders within the specified time frame.');
    END
END;



-- Update views with TRIGGERS INSTEAD OF
-- Exemple 1
-- Première étape on crée la vue
CREATE VIEW ProductWithCategory AS
SELECT 
    p.ProductID,
    p.Name AS ProductName,
    p.ListPrice,
    pc.ProductCategoryID,
    pc.Name AS CategoryName
FROM 
    SalesLT.Product p
JOIN 
    SalesLT.ProductCategory pc
ON 
    p.ProductCategoryID = pc.ProductCategoryID;
-- 2ème étape, on crée le trigger
CREATE TRIGGER UpdateProductWithCategory
ON ProductWithCategory
INSTEAD OF UPDATE -- when an UPDATE operation is attempted on this view,
                  -- instead of performing the UPDATE on the view directly
                  -- (which is not possible because views do not store data), 
                  -- the trigger will execute.
AS
BEGIN
    UPDATE SalesLT.Product
    SET Name = i.ProductName,       -- i for inserted
        ListPrice = i.ListPrice,
        ProductCategoryID = i.ProductCategoryID
    FROM SalesLT.Product p
    JOIN inserted i ON p.ProductID = i.ProductID;

    UPDATE SalesLT.ProductCategory
    SET Name = i.CategoryName
    FROM SalesLT.ProductCategory pc
    JOIN inserted i ON pc.ProductCategoryID = i.ProductCategoryID;
END;

UPDATE ProductWithCategory
SET ProductName = 'Updated Product Name',
    ListPrice = 150.00,
    CategoryName = 'Updated Category'
WHERE ProductID = 680;

SELECT * FROM ProductWithCategory WHERE ProductID = 680;
SELECT * FROM SalesLT.Product WHERE ProductID = 680;
SELECT * FROM SalesLT.ProductCategory WHERE ProductCategoryID = (SELECT ProductCategoryID FROM SalesLT.Product WHERE ProductID = 680);

-- Exemple 2 (Voir les messages car le update ne fonctionne pas car Prix négatif)
CREATE TRIGGER ValidateProductPrice
ON SalesLT.Product
INSTEAD OF UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE ListPrice < 0)
    BEGIN
        RAISERROR('Product price cannot be negative', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    UPDATE p
    SET p.Name = i.Name,
        p.ProductNumber = i.ProductNumber,
        p.Color = i.Color,
        p.StandardCost = i.StandardCost,
        p.ListPrice = i.ListPrice,
        p.Size = i.Size,
        p.Weight = i.Weight,
        p.ProductCategoryID = i.ProductCategoryID,
        p.ProductModelID = i.ProductModelID,
        p.SellStartDate = i.SellStartDate,
        p.SellEndDate = i.SellEndDate,
        p.DiscontinuedDate = i.DiscontinuedDate,
        p.ThumbNailPhoto = i.ThumbNailPhoto,
        p.ThumbnailPhotoFileName = i.ThumbnailPhotoFileName,
        p.rowguid = i.rowguid,
        p.ModifiedDate = GETDATE()
    FROM SalesLT.Product p
    INNER JOIN inserted i ON p.ProductID = i.ProductID;
END;
-- BUG because ListPrice <0
UPDATE SalesLT.Product
SET ListPrice = -5
WHERE ProductID = 680 ;
-- Corrected List Price > 0
UPDATE SalesLT.Product
SET ListPrice = 5
WHERE ProductID = 680;