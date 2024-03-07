-- Atomicity (Course Example will produce bug to be analysed with students)
-- The first error indicates that a NULL value was attempted to be inserted into the 'PostalCode' column, which does not allow NULL values.
-- The second error indicates that the insert conflicted with a FOREIGN KEY constraint named "FK_CustomerAddress_Address_AddressID". 
-- This means that the insert attempted to insert a value into the 'AddressID' column that did not exist in the 'SalesLT.Address'
-- Begin the transaction. Should be closed by ROLLBACK or COMMIT Statement
BEGIN TRANSACTION;

-- Declare the scalar variables
DECLARE @NewCustomerID INT;
DECLARE @NewAddressID INT;

-- Insert a new customer
INSERT INTO SalesLT.Customer (FirstName, LastName, CompanyName, EmailAddress, Phone, PasswordHash, PasswordSalt)
VALUES ('Jane', 'Doe', 'ACME Corp', 'jane.doe@acme.com', '555-123-4568', 'PLACEHOLDER_OR_HASHED_PASSWORD', '1KjXYs4=');

-- Get the newly inserted customer ID
SELECT @NewCustomerID = SCOPE_IDENTITY();

-- Insert a new address
INSERT INTO SalesLT.Address (AddressLine1, City, StateProvince, CountryRegion)
VALUES ('123 Main St', 'Seattle', 'WA', 'USA');

-- Get the newly inserted address ID
SELECT @NewAddressID = SCOPE_IDENTITY();

-- Associate the new address with the new customer
INSERT INTO SalesLT.CustomerAddress (CustomerID, AddressID, AddressType)
VALUES (@NewCustomerID, @NewAddressID, 'Billing');

-- Check for any errors, roll back the transaction if necessary
IF @@ERROR != 0
BEGIN
    ROLLBACK TRANSACTION;
    PRINT 'Transaction failed and has been rolled back.';
END
ELSE
BEGIN
    COMMIT TRANSACTION;
    PRINT 'Transaction committed successfully.';
END

-- CORRECTION ATOMICITY Proposé
BEGIN TRANSACTION;

-- Declare the scalar variables
DECLARE @NewCustomerID INT;
DECLARE @NewAddressID INT;

-- Insert a new customer
INSERT INTO SalesLT.Customer (FirstName, LastName, CompanyName, EmailAddress, Phone, PasswordHash, PasswordSalt)
VALUES ('Jane', 'Doe', 'ACME Corp', 'jane.doe@acme.com', '555-123-4568', 'PLACEHOLDER_OR_HASHED_PASSWORD', '1KjXYs4=');

-- Get the newly inserted customer ID into variable New customer ID
SELECT @NewCustomerID = SCOPE_IDENTITY();
PRINT 'The new Customer ID is: ' + CAST(@NewCustomerID AS NVARCHAR(10));

-- Insert a new address
INSERT INTO SalesLT.Address (AddressLine1, City, StateProvince, CountryRegion, PostalCode)
VALUES ('123 Main St', 'Seattle', 'WA', 'USA','456');

-- Get the newly inserted address ID into variable
SELECT @NewAddressID = SCOPE_IDENTITY();
PRINT 'The new Address ID is: ' + CAST(@NewAddressID AS NVARCHAR(10));

-- Associate the new address with the new customer
INSERT INTO SalesLT.CustomerAddress (CustomerID, AddressID, AddressType)
VALUES (@NewCustomerID, @NewAddressID, 'Billing');

-- Check for any errors, roll back the transaction if necessary
PRINT 'Error Number ' + CAST(@@ERROR AS NVARCHAR(10));
IF @@ERROR != 0
BEGIN
    ROLLBACK TRANSACTION;  -- ROLLBACK OR COMMIT are ending the BEGIN TRANSACTION
    PRINT 'Transaction failed and has been rolled back.';
END
ELSE 
BEGIN
    COMMIT TRANSACTION;
    PRINT 'Transaction committed successfully.';
END

-- CONSISTENCY
SELECT TOP(20) * FROM SalesLT.Product; -- To check price before 

-- To reaffect a logic price
UPDATE SalesLT.Product
SET ListPrice = 9000
WHERE ProductID = 680;

-- Begin the transaction
BEGIN TRANSACTION;

-- Update product prices for a specific category
UPDATE SalesLT.Product
SET ListPrice = ListPrice * 1.1 
WHERE ProductID = 680;

-- Check if all prices are within a valid range
IF NOT EXISTS (
    SELECT *
    FROM SalesLT.Product
    WHERE ListPrice < 0 OR ListPrice > 10000)
BEGIN
    COMMIT TRANSACTION;
    PRINT 'Transaction committed successfully.';
END
ELSE
BEGIN
    ROLLBACK TRANSACTION;
    PRINT 'Transaction failed and has been rolled back.';
END


-- ISOLATION (ici juste discuter de la structure, on a pas les tables pour interpréter les résultats)
-- Set transaction isolation level to SERIALIZABLE
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

-- Begin the transaction
BEGIN TRANSACTION;

DECLARE @amountToTransfer DECIMAL(19, 4) = 500;
DECLARE @fromAccountID INT = 1;
DECLARE @toAccountID INT = 2;

-- Check the balance of the 'from' account
SELECT balance
FROM BankAccounts
WHERE AccountID = @fromAccountID;

-- Check if there's enough balance to make the transfer
IF (SELECT balance FROM BankAccounts WHERE AccountID = @fromAccountID) >= @amountToTransfer
BEGIN
    -- Deduct the amount from the 'from' account
    UPDATE BankAccounts
    SET balance = balance - @amountToTransfer
    WHERE AccountID = @fromAccountID;

    -- Add the amount to the 'to' account
    UPDATE BankAccounts
    SET balance = balance + @amountToTransfer
    WHERE AccountID = @toAccountID;

    -- Commit the transaction
    COMMIT;
END
ELSE
BEGIN
    -- Rollback the transaction if there's not enough balance
    ROLLBACK TRANSACTION;
END


-- DURABILITY
-- Durability is ensured by the SQL Server itself. Once a transaction is committed, it is permanently saved to the database. 

SET IMPLICIT_TRANSACTIONS ON; -- Need to commit every transaction when set to ON

-- Insert a new record (this will start a new transaction implicitly)
INSERT INTO SalesLT.Customer (FirstName, LastName, CompanyName, EmailAddress, Phone, PasswordHash, PasswordSalt)
VALUES ('Jane', 'Doe', 'ACME Corp', 'jane.doe@acme.com', '555-123-4568', 'PLACEHOLDER_OR_HASHED_PASSWORD', '1KjXYs4=');

-- Commit the transaction
COMMIT;

-- Disable implicit transactions and revert to autocommit mode
SET IMPLICIT_TRANSACTIONS OFF; --> Transaction are commited automaticaly
