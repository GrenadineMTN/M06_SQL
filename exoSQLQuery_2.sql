SELECT TOP (20) CustomerID FROM dbo.Customers;

--Retrieve the length of the company name for all customers.
SELECT CompanyName ,LEN(CompanyName) AS lenghtcompanyname
FROM dbo.Customers;

--Retrieve the last name of all employees in uppercase.
SELECT LastName, UPPER(LastName) AS upperlastname
FROM dbo.Employees;

--Concatenate the first and last name of all employees.
SELECT FirstName, LastName, CONCAT(FirstName, ' ' , LastName) AS FullName
FROM dbo.Employees;

--Retrieve the first name and the first letter of the last name of all employees.
SELECT FirstName, LEFT(LastName, 1) as Initiale_Nom
FROM Employees;

--Retrieve the average length of company names for all customers.

SELECT AVG(LEN(CompanyName)) as AvgCompanyNameLength
FROM Customers;

--Retrieve the order date and the year for all orders.

SELECT OrderDate,  DATEPART(year, OrderDate) AS OrderYear
From Orders;

--solution
SELECT OrderDate, YEAR(OrderDate) as OrderYear
FROM Orders;

--Retrieve the first name and last name of all employees in lowercase and remove leading and trailing spaces.
SELECT CONCAT(LOWER(FirstName),LOWER(LastName)) AS fullname
FROM Employees;

--solution j'avais pas compris la question, ici on utilise ltrim et rtrim( left trim pour enlever les espaces autour des valeurs )
SELECT LTRIM(RTRIM(LOWER(FirstName))) as LowercaseFirstName, LTRIM(RTRIM(LOWER(LastName))) as LowercaseLastName
FROM Employees;


-- 8 Retrieve the average order value for all orders and round the result to 2 decimal places.
SELECT ROUND(AVG(OrderDetails.UnitPrice * OrderDetails.Quantity * (1 - OrderDetails.Discount)), 2) as AvgOrderValue
FROM OrderDetails;

--  9 Retrieve the year and the quarter of the order date for all orders and remove duplicates.
SELECT DISTINCT YEAR(OrderDate) as OrderYear, DATEPART(QUARTER, OrderDate) as OrderQuarter
FROM Orders;

-- 10 Retrieve the age of all employees in years.
SELECT EmployeeID, DATEDIFF(YEAR, BirthDate, GETDATE()) as Age
FROM Employees;

--solution Romain
SELECT EmployeeID, CAST(BirthDate AS DATE) AS BIRTHDATE, DATEDIFF(YEAR,BirthDate, SYSDATETIME()) AS Agemployee
FROM Employees;


--11 Retrieve the name and the title of all employees with the word "Manager" in their title.
SELECT FirstName, LastName, Title
FROM Employees
WHERE Title LIKE '%Manager%';

--12 Retrieve the country and the total number of customers from each country, 
--sorted by the number of customers in descending order.
SELECT Country, COUNT(*) as NumberOfCustomers
FROM Customers
GROUP BY Country
ORDER BY NumberOfCustomers DESC;

13 --Retrieve the product name and the total number of orders for each product,
-- sorted by the number of orders in descending order.

SELECT Products.ProductName, COUNT(*) as NumberOfOrders
FROM Orders
JOIN OrderDetails ON Orders.OrderID = OrderDetails.OrderID
JOIN Products ON OrderDetails.ProductID = Products.ProductID
GROUP BY Products.ProductName
ORDER BY NumberOfOrders DESC;

--solution Romain 
SELECT p.ProductName, COUNT(o.OrderID) AS NumberOfOrders
FROM Products as p 
JOIN OrderDetails AS o ON p.ProductID =o.ProductID
GROUP BY p.ProductName
ORDER BY NumberOfOrders DESC