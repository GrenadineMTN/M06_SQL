
-- UNION (OU)
-- Attention même nombre de colonnes dans les deux query que l'on souhaite coller
-- Et data types must be compatible.
-- [Status] =  Colonne crée lors de la requete qui sera rempli uniquement de 'Sold' ou 'Not Sold'
-- AS keyword selon votre choix perso

-- Query donné par le cours : Demander aux élèves pourquoi les 2 premiers JOINs sont pas nécéssaires ici
-- SELECT p.ProductID, p.Name, p.ListPrice, 'Sold' as [Status]
-- FROM SalesLT.Product p
-- JOIN SalesLT.ProductModelProductDescription pmpd ON p.ProductModelID = pmpd.ProductModelID
-- JOIN SalesLT.ProductDescription pd ON pmpd.ProductDescriptionID = pd.ProductDescriptionID
-- JOIN SalesLT.SalesOrderDetail sod ON p.ProductID = sod.ProductID

-- UNION

-- SELECT p.ProductID, p.Name, p.ListPrice, 'Not Sold' as [Status]
-- FROM SalesLT.Product p
-- JOIN SalesLT.ProductModelProductDescription pmpd ON p.ProductModelID = pmpd.ProductModelID
-- JOIN SalesLT.ProductDescription pd ON pmpd.ProductDescriptionID = pd.ProductDescriptionID
-- WHERE p.ProductID NOT IN (SELECT sod.ProductID FROM SalesLT.SalesOrderDetail sod)

SELECT TOP(20) * FROM SalesLT.SalesOrderDetail
SELECT TOP(20) * FROM  SalesLT.Product ORDER BY ProductID

SELECT p.ProductID, p.Name, p.ListPrice, 'Sold' AS [Status]
FROM SalesLT.Product AS p
JOIN SalesLT.SalesOrderDetail AS sod ON p.ProductID = sod.ProductID

UNION

SELECT p.ProductID,p.Name, p.ListPrice, 'Not Sold' AS [Status]
FROM SalesLT.Product AS p
JOIN SalesLT.ProductModelProductDescription pmpd ON p.ProductModelID = pmpd.ProductModelID
WHERE p.ProductID NOT IN (SELECT sod.ProductID FROM SalesLT.SalesOrderDetail AS sod)
ORDER BY p.ProductID


-- UNION 2ème example : "Tout les clients ayant commandé en 2008 OU ayant une address en Californie"
SELECT c.CustomerID, c.FirstName, c.LastName, c.EmailAddress, 'Order in 2008' as [Status]
FROM SalesLT.Customer c
JOIN SalesLT.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
WHERE YEAR(soh.OrderDate) = 2008

UNION

SELECT c.CustomerID, c.FirstName, c.LastName, c.EmailAddress, 'Billing Address in California' as [Status]
FROM SalesLT.Customer c
JOIN SalesLT.CustomerAddress ca ON c.CustomerID = ca.CustomerID
JOIN SalesLT.Address a ON ca.AddressID = a.AddressID
WHERE a.StateProvince = 'California'

-- UNION ALL (AVEC DOUBLONS) Garde les doublons qui sont dans les query de base
-- Doublons car JOIN sur Sales Order Details ou un même produit peut être vendu plusieurs fois
-- Doublons egalement car plusieurs ProductDescriptionID pour un même ProductModelID
SELECT * FROM SalesLT.SalesOrderDetail ORDER BY ProductID;
SELECT * FROM SalesLT.ProductModelProductDescription ORDER BY ProductModelID;

SELECT p.ProductID, p.Name, p.ListPrice, 'Sold' AS [Status]
FROM SalesLT.Product AS p 
JOIN SalesLT.SalesOrderDetail AS sod ON p.ProductID = sod.ProductID --> Join one to many so duplicates

UNION ALL

SELECT p.ProductID, p.Name, p.ListPrice, 'Not Sold' AS [Status]
FROM SalesLT.Product AS p 
JOIN SalesLT.ProductModelProductDescription AS pmpd ON p.ProductModelID = pmpd.ProductModelID 
JOIN SalesLT.ProductDescription AS pd ON pmpd.ProductDescriptionID = pd.ProductDescriptionID
WHERE p.ProductID NOT IN (SELECT sod.ProductID FROM SalesLT.SalesOrderDetail AS sod);

-- INTERSECT (ET) 
-- (returns only the rows that are common between the 2 queries)
-- Attention ne fonctionne pas avec tout les moteurs de base de données
-- Aller voir la doc ou utiliser des JOINS

-- Exemple 1 Tout les produits acheté en commun par 2 clients
SELECT p.Name
FROM SalesLT.SalesOrderDetail sod
JOIN SalesLT.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
JOIN SalesLT.Product p ON sod.ProductID = p.ProductID
WHERE soh.CustomerID = 29485

INTERSECT

SELECT p.Name
FROM SalesLT.SalesOrderDetail sod
JOIN SalesLT.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
JOIN SalesLT.Product p ON sod.ProductID = p.ProductID
WHERE soh.CustomerID = 29957

-- Exemple 2 Tout les clients qui ont deux adresses et qui sont au Canada
SELECT c.CustomerID, c.FirstName, c.LastName
FROM SalesLT.Customer c
JOIN SalesLT.CustomerAddress ca ON c.CustomerID = ca.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName
HAVING COUNT(DISTINCT ca.AddressID) > 1

INTERSECT

SELECT c.CustomerID, c.FirstName, c.LastName
FROM SalesLT.Customer c
JOIN SalesLT.CustomerAddress ca ON c.CustomerID = ca.CustomerID
JOIN SalesLT.Address a ON ca.AddressID = a.AddressID
WHERE a.CountryRegion = 'Canada';

-- Exemple 2 without INTERSECT
-- Interessant de comparer les executions time (cette requete est légèrement plus longue)
SELECT c.CustomerID, c.FirstName, c.LastName
FROM SalesLT.Customer c
JOIN SalesLT.CustomerAddress ca ON c.CustomerID = ca.CustomerID
JOIN SalesLT.Address a ON ca.AddressID = a.AddressID
WHERE a.CountryRegion = 'Canada'
GROUP BY c.CustomerID, c.FirstName, c.LastName
HAVING COUNT(DISTINCT ca.AddressID) > 1;

-- EXCEPT (SAUF)
-- Exemple 1 : Tout les clients qui n'ont pas commandé
SELECT CustomerID
FROM SalesLT.Customer 

EXCEPT 

SELECT CustomerID 
FROM SalesLT.SalesOrderHeader 

-- Exemple 2 Find all addresses that are associated with customers, but are not billing addresses
SELECT AddressID 
FROM SalesLT.CustomerAddress

EXCEPT

SELECT BillToAddressID 
FROM SalesLT.SalesOrderHeader 

-- Exemple 3 Find Products that has never been ordered
SELECT p.Name
FROM SalesLT.Product p

EXCEPT

SELECT p.Name
FROM SalesLT.Product p
JOIN SalesLT.SalesOrderDetail sod ON p.ProductID = sod.ProductID

-- Exemple 3 équivalent sans le EXCEPT
-- Voir laquelle on préfere niveau syntaxe. La pareil niveau temps.
SELECT p.Name
FROM SalesLT.Product p
WHERE p.ProductID NOT IN (
  SELECT sod.ProductID
  FROM SalesLT.SalesOrderDetail sod
)
