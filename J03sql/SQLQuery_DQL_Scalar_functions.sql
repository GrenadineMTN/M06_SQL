-- Select data
SELECT TOP(5) CustomerID, FirstName FROM SalesLT.Customer;

--UPPER/LOWER
SELECT TOP(5) LastName AS bjr, FirstName
FROM SalesLT.Customer;

SELECT UPPER(LastName) , LOWER(FirstName) AS FIRST_NAME_LOWERCASE
FROM SalesLT.Customer;

--LENGTH
SELECT LEN(LastName) AS LAST_NAME_LENGTH, LastName
FROM SalesLT.Customer;

--CONCAT (Concatenation de chaine de caractère fonctionne aussi avec +)
-- 2 query equivalentes : 
SELECT CONCAT(Firstname, Lastname) as FULL_NAME, FirstName, LastName
FROM SalesLT.Customer;

SELECT Firstname + ' ' + Lastname as FULL_NAME
FROM SalesLT.Customer;

--CHARINDEX (Find index of starting position of a substring within a string)
Select TOP(5) Name FROM SalesLT.Product;

SELECT Name, CHARINDEX('Bike', Name) AS START_POSITION
FROM SalesLT.Product;

--SUBSTRING (Extract a substring from a larger string)
--SUBSTRING(string, start, length)
--Ici début = CHARINDEX('@', EmailAddress) + 1 --> Position du @ +1
-- fin = LEN(EmailAddress) - CHARINDEX('@', EmailAddress) --> Len de tout la chaine - Position du @
SELECT TOP(20) EmailAddress AS DOMAIN, CHARINDEX('@', EmailAddress) AS POSITION
FROM SalesLT.Customer;

SELECT TOP(20) SUBSTRING(EmailAddress,3,5), EmailAddress
FROM SalesLT.Customer

-- Retourne le domaine de l'email
SELECT TOP(5) SUBSTRING(EmailAddress, CHARINDEX('@', EmailAddress) + 1  , LEN(EmailAddress) - CHARINDEX('@', EmailAddress)) as DOMAIN
FROM SalesLT.Customer;

-- Retourne le nom du mail
SELECT TOP(5) SUBSTRING(EmailAddress, 0, CHARINDEX('@', EmailAddress)) as DOMAIN
FROM SalesLT.Customer;

-- LTRIM/RTRIM 
-- LTRIM --> Supprime en début de chaine les espaces
-- RTRIM --> Supprime en fin de chaine les espaces
SELECT TOP(20) addressline1 FROM SalesLT.Address; 
SELECT TOP(20) LTRIM(RTRIM(addressline1)) as CLEAN_ADDRESS
FROM SalesLT.Address;

SELECT 

SELECT LTRIM(RTRIM('       yohann       ')) AS test;
SELECT RTRIM('       yohann       ')AS test;
SELECT LTRIM('       yohann       ')AS test;

SELECT TRIM('       yohann       ') AS test;

-- Si deuxième argument possible de lui passer une liste de caractère à supprimer en début de chaine
-- La suppression s'arrete lorsque un des caractère n'est plus présent dans la liste de suppression
SELECT LTRIM('yohanncoucou' , 'haoyunc') AS test;
SELECT LTRIM('yohanncoucou' , 'yaho') AS test;

-- REPLACE (replace all occurrences of a substring within a string with a new value)
SELECT TOP(5) description FROM SalesLT.ProductDescription;
SELECT TOP(5) description, REPLACE(description, 'large', 'Extra Large')
FROM SalesLT.ProductDescription;

--ROUND (Note : 3ème argument 0 = au plus proche, 1 = tronquer)
-- Voir ligne 7 par exemple pour comprendre
SELECT TOP (20)
ListPrice as LIST_PRICE_ORIGINAL,
ROUND(ListPrice, 2) as LIST_PRICE_ROUNDED_USELESS,
ROUND(ListPrice, 1) as LIST_PRICE_ROUNDED_TEST,
ROUND(ListPrice, 1, 0) as LIST_PRICE_ROUNDED,
ROUND(ListPrice, 1, 1) as LIST_PRICE_TRUNCATED
FROM SalesLT.Product;

--SYSDATETIME Not really a scalar function but return current date and time. Can be usefull
SELECT SYSDATETIME() as CURRENT_DATE_AND_TIME
FROM BuildVersion;
-- Exemple utilisation via INSERT TO ou dans triggers
-- INSERT INTO UserLoginAttempts (Username, LoginTime)
-- VALUES ('JohnDoe', SYSDATETIME());

-- DATEADD Ajoute un interval de temps à une date. 
-- Possible de spécifier des nombres négatif pour retrancher du temps
-- Possible de spécifier beaucoup de type d'interval. Voir la doc W3School
-- Ex : year, quarter month, weekday, minutes, second etc...
SELECT TOP(5) OrderDate FROM SalesLT.SalesOrderHeader;

SELECT TOP(5) OrderDate, DATEADD(day, 18, OrderDate) AS NewOrderDate
FROM SalesLT.SalesOrderHeader;
SELECT TOP(5) OrderDate, DATEADD(year, 2, OrderDate) AS NewOrderDate
FROM SalesLT.SalesOrderHeader;
SELECT TOP(5) OrderDate, DATEADD(minute, 2, OrderDate) AS NewOrderDate
FROM SalesLT.SalesOrderHeader;
SELECT TOP(5) OrderDate, DATEADD(year, -2, OrderDate) AS NewOrderDate
FROM SalesLT.SalesOrderHeader;
SELECT TOP(5) OrderDate, DATEADD(minute, -2, OrderDate) AS NewOrderDate
FROM SalesLT.SalesOrderHeader;

-- DATEDIFF Calculate difference between two dates or datetimes
-- Valeur tronqué, voir exemple year
SELECT DATEDIFF(day, OrderDate, ShipDate) AS DaysToShip, OrderDate, ShipDate
FROM SalesLT.SalesOrderHeader;
SELECT DATEDIFF(year, OrderDate, ShipDate) AS DaysToShip
FROM SalesLT.SalesOrderHeader;
SELECT DATEDIFF(minute, OrderDate, ShipDate) AS DaysToShip
FROM SalesLT.SalesOrderHeader;

-- DATEPART pour extraire une valeur (numerique) de la date
-- DATENAME pour extraire une valeur (le nom de la date)
SELECT TOP(5) OrderDate,    
    DATEPART(year, OrderDate) AS OrderYear,
    DATEPART(month, OrderDate) AS OrderMonth,
    DATENAME(MONTH, OrderDate) AS OrderMonth,
    DATEPART(day, OrderDate) AS OrderDay,
    DATENAME(WEEKDAY, OrderDate) AS OrderDay
FROM SalesLT.SalesOrderHeader;

-- Convert Data Types with CAST function CAST(expression AS data_type)
-- CAST function to convert large volumes of data can result in performance issues
-- Look at last additonal ressources for more informations
SELECT TOP(5) CAST(SalesLT.SalesOrderHeader.OrderDate AS date) AS OrderDate
FROM SalesLT.SalesOrderHeader
WHERE CAST(SalesLT.SalesOrderHeader.OrderDate AS date) BETWEEN '2008-06-01' AND '2008-06-03'

-- Tips afficher nom de colonnes et DataType pour faire le cast
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'SalesOrderHeader';

-- Exemple du cours pas très parlant car on converti une datetime en date
SELECT CAST(SalesLT.SalesOrderHeader.OrderDate AS date) AS OrderDate
FROM SalesLT.SalesOrderHeader
WHERE CAST(SalesLT.SalesOrderHeader.OrderDate AS date) BETWEEN '2008-06-01' AND '2008-06-03'
-- Autre exemple proposé convertir SalesOrderNumber en Integer 
-- Besoin d'extraire uniquement les caractères après le S0 d'ou substring
-- Remarque sur le temps d'execution plus long, aller voir les ressources supplémentaire pour comprendre.
SELECT TOP(5) SalesOrderNumber, CAST(SUBSTRING(SalesOrderNumber, 3, LEN(SalesOrderNumber)) AS INT) AS ExtractedNumber, SUBSTRING(SalesOrderNumber, 3, LEN(SalesOrderNumber)) AS temp
FROM SalesLT.SalesOrderHeader;
