--TASK 1

CREATE TABLE CustomerFeedback (
    FeedbackID INT PRIMARY KEY,
    CustomerID INT NOT NULL,
    FeedbackText NVARCHAR(200) NOT NULL,
    FeedbackDate DATETIME NOT NULL,
);

SELECT TOP(10) * FROM CustomerFeedback;

-- TASK 2
ALTER TABLE Products
ADD CategoryID INT;

-- TASK 3 alter column modifie en brut alors que
-- add constraint est modifiable constraint c est
-- pour la primary key ou une clé etrangere

ALTER TABLE Customers
ALTER COLUMN CompanyName NVARCHAR(40) NOT NULL;

-- TASK 4 

ALTER TABLE Orders
ALTER  COLUMN ShipCity NVARCHAR (40) NOT NULL;

-- TASK 5  il faut creer la primarykey 
--- ds chaque table créée

CREATE TABLE OrderItems (
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL (10,2) NOT NULL,
    PRIMARY KEY (OrderID,ProductID)
) ;

--TASK 6
ALTER TABLE OrderItems
ADD CONSTRAINT ck_Quantity_Order
CHECK ( Quantity > O)

--TASK 7
ALTER TABLE 