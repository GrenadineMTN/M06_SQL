-- INNER JOIN (EQUIV JOIN )
SELECT 
    O.SalesOrderID,
    O.OrderDate,
    C.CustomerID,
    C.FirstName,
    C.LastName
FROM 
    SalesLT.Customer AS C
INNER JOIN 
    SalesLT.SalesOrderHeader AS O ON C.CustomerID = O.CustomerID;


-- LEFT JOIN 
SELECT 
    O.SalesOrderID,
    O.OrderDate,
    C.CustomerID,
    C.FirstName,
    C.LastName
FROM 
    SalesLT.Customer AS C
LEFT JOIN 
    SalesLT.SalesOrderHeader AS O ON C.CustomerID = O.CustomerID;


-- RIGHT JOIN 
 
SELECT 
    O.SalesOrderID,
    O.OrderDate,
    C.CustomerID,
    C.FirstName,
    C.LastName
FROM 
    SalesLT.Customer AS C
RIGHT JOIN 
    SalesLT.SalesOrderHeader AS O ON C.CustomerID = O.CustomerID;

-- RIGHT JOIN = INNER JOIN car pas de null values dans colonne CustomerID

-- OUTER JOIN 
SELECT 
    COALESCE(O.SalesOrderID, 0) AS OrderID,
    COALESCE(O.OrderDate, 0) AS OrderDate,
    C.CustomerID,
    C.FirstName,
    C.LastName
FROM 
    SalesLT.Customer AS C
FULL OUTER JOIN 
    SalesLT.SalesOrderHeader AS O ON C.CustomerID = O.CustomerID;

