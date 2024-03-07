-- Creation de la table (To create auto incremental : "ProductReviewID INT IDENTITY(1,1) PRIMARY KEY,")
CREATE TABLE SalesLT.ProductReview (
    ProductReviewID INT PRIMARY KEY,
    ProductID INT NOT NULL,
    ReviewerName NVARCHAR(50) NOT NULL,
    ReviewDate DATE NOT NULL,
    Rating INT CHECK (Rating >= 1 AND Rating <= 5),
    CONSTRAINT FK_ProductID FOREIGN KEY (ProductID) REFERENCES SalesLT.Product(ProductID)
);

-- Drop it 
DROP TABLE IF EXISTS SalesLT.ProductReview;

-- Verification du contenu de la table 
SELECT TOP(10) * FROM SalesLT.ProductReview;

-- Insertion de nouvelles lignes
INSERT INTO SalesLT.ProductReview
(ProductReviewID, ProductID, ReviewerName, ReviewDate, Rating)
VALUES
(1, 680, 'John Doe', '2022-02-01', 4);

INSERT INTO SalesLT.ProductReview
(ProductReviewID,ProductID, ReviewerName, ReviewDate, Rating)
VALUES
(2, 763,'Jane Smith', '2022-02-02', 4.5);

INSERT INTO SalesLT.ProductReview
(ProductReviewID,ProductID, ReviewerName, ReviewDate, Rating)
VALUES
(3, 763,'Nicolle', '2022-02-03', 3);

-- PRIMARY KEY Constraint
INSERT INTO SalesLT.ProductReview
(ProductReviewID, ProductID, ReviewerName, ReviewDate, Rating)
VALUES
(1, 680, 'Jane Smith', '2022-02-01', 4);

-- FOREIGN KEY Constraint 
SELECT TOP(5) * FROM SalesLT.Product
WHERE ProductID = 7600;

INSERT INTO SalesLT.ProductReview
(ProductReviewID, ProductID, ReviewerName, ReviewDate, Rating)
VALUES
(6, 7600, 'John Doe', '2022-02-01', 4);

-- CHECK Constraint 
INSERT INTO SalesLT.ProductReview
(ProductReviewID, ProductID, ReviewerName, ReviewDate, Rating)
VALUES
(5, 706, 'Bob Smith', '2022-02-03', 4);

-- Retrieve information about the constraints applied to a specific column.
EXEC sp_helpconstraint 'SalesLT.SalesOrderHeader', 'OrderDate';


-- ALTER statement``
-- Syntax : 
-- ALTER TABLE table_name
-- ADD column_name datatype [NULL | NOT NULL],
-- DROP COLUMN column_name,
-- ALTER COLUMN column_name datatype [NULL | NOT NULL],
-- ADD CONSTRAINT constraint_name constraint_type (column_name),
-- DROP CONSTRAINT constraint_name

 
ALTER TABLE SalesLT.Customer
ADD BirthDate DATE NULL CONSTRAINT CK_Customer_Age CHECK (DATEDIFF(year, BirthDate, GETDATE()) >= 18);

-- New column 
ALTER TABLE SalesLT.Customer
ADD Age INT NULL;

-- Modify a column 
ALTER TABLE SalesLT.Customer
ALTER COLUMN Age SMALLINT;

-- New constraint (Primary Key PK)
DROP TABLE IF EXISTS SalesLT.ProductTemp;

CREATE TABLE SalesLT.ProductTemp (ProductReviewID INT NOT NULL);

ALTER TABLE SalesLT.ProductTemp
ADD CONSTRAINT PK_temp PRIMARY KEY (ProductReviewID);

-- New check constraint (Check values)
ALTER TABLE SalesLT.Customer
ADD CONSTRAINT CK_Customer_Phone
CHECK (Phone LIKE '%[0-9()-]%' AND LEN(Phone) >= 10 AND LEN(Phone) <= 20);

ALTER TABLE SalesLT.Customer
ADD CONSTRAINT CK_Customer_Email
CHECK (EmailAddress LIKE '%@%.%');

ALTER TABLE SalesLT.ProductDescription
ADD CONSTRAINT CK_ProductDescription_Length
CHECK (LEN(Description) BETWEEN 3 AND 300);

-- DROP column
ALTER TABLE SalesLT.Customer
DROP COLUMN Age;

-- DROP constraint
ALTER TABLE SalesLT.Customer
DROP CONSTRAINT CK_Customer_Email;

-- DEFAULT values
-- Creation of the column
ALTER TABLE SalesLT.Product
ADD Status INT NULL;

ALTER TABLE SalesLT.Product
DROP COLUMN Status;

ALTER TABLE SalesLT.Product
DROP CONSTRAINT DF_Product_Status;

-- Instruction doesn't work, need to be done in two statement
ALTER TABLE SalesLT.Product
ALTER COLUMN Status VARCHAR(10) NOT NULL DEFAULT 'Active';

-- First statement 
ALTER TABLE SalesLT.Product
ALTER COLUMN Status VARCHAR(10);

-- Second statement
ALTER TABLE SalesLT.Product
ADD CONSTRAINT DF_Product_Status DEFAULT 'Active' FOR Status;

-- TRUNCATE 
SELECT TOP(10) * FROM SalesLT.ProductReview;

TRUNCATE TABLE SalesLT.ProductReview;

-- DROP 
DROP TABLE SalesLT.ProductReview;

SELECT TOP(20) * FROM SalesLT.Product