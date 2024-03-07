--Aggregation without grouping
-- Some aggregation function can be used with our without groupby clause but only one result.
-- SUM / AVG / MAX
SELECT TOP(5) ListPrice FROM SalesLT.Product;
SELECT SUM(ListPrice) as TotalListPrice,
 AVG(ListPrice) as AverageListPrice,
  MIN(ListPrice) as MinListPrice
FROM SalesLT.Product;



-- GROUPBY statement (L'un des plus important)
-- Note obligatoire que la colonne du GroupBy soit présent dans le SELECT
-- Groupby = Notion de Metrics/Dimensions (on groupby Dimensions toujours)
-- Note Join = Unnormalized data 
-- Join vu dans Advanced query donc pour aujourd'hui on passe. on verra cela demain
-- Ici voir que le groupBY nous donne bien une ligne par category de produit.

--GROUPBY review
SELECT * FROM SalesLT.Product; 
-- Calculer la moyenne de prix pour chaque couleur.
SELECT Color, AVG(ListPrice)
FROM SalesLT.Product
GROUP BY Color;

-- Join  Review
SELECT TOP(5) * FROM SalesLT.SalesOrderDetail;
SELECT TOP(5) * FROM SalesLT.Product;

SELECT TOP (5) first_table.SalesOrderID, second_table.Name
FROM SalesLT.SalesOrderDetail AS first_table
JOIN SalesLT.Product AS second_table
ON first_table.ProductID = second_table.ProductID;

-- WithOUT GROUPBY 
SELECT ProductCategory.Name, SalesOrderDetail.LineTotal
FROM SalesLT.SalesOrderDetail
JOIN SalesLT.Product
ON SalesLT.SalesOrderDetail.ProductID = SalesLT.Product.ProductID
JOIN SalesLT.ProductCategory
ON SalesLT.Product.ProductCategoryID = SalesLT.ProductCategory.ProductCategoryID
ORDER BY SalesOrderDetail.LineTotal;


-- With GROUPBY
SELECT ProductCategory.Name, SUM(SalesOrderDetail.LineTotal) as TotalSales
FROM SalesLT.SalesOrderDetail
JOIN SalesLT.Product
ON SalesLT.SalesOrderDetail.ProductID = SalesLT.Product.ProductID
JOIN SalesLT.ProductCategory
ON SalesLT.Product.ProductCategoryID = SalesLT.ProductCategory.ProductCategoryID
GROUP BY ProductCategory.Name;

-- COUNT other example 
SELECT TOP(5) * FROM SalesLT.Product;

SELECT Color, COUNT(Name)
FROM SalesLT.Product
GROUP BY Color;

SELECT Color, COUNT(ListPrice)
FROM SalesLT.Product
GROUP BY Color;

SELECT Color, COUNT(ProductID)
FROM SalesLT.Product
GROUP BY Color;

-- COUNT (ici nous donne le nombre total de client) le nombre de ligne 
SELECT COUNT(*) AS TOTAL_CUSTOMERS
FROM SalesLT.Customer;

-- Ici * donne le même résultat que CustomerID car contrainte de NOT NULL
SELECT COUNT(CustomerID) AS TOTAL_CUSTOMERS
FROM SalesLT.Customer;

-- Sur colonne avec NULL autorisé 
SELECT COUNT(Suffix) AS TOTAL_SUFFIX
FROM SalesLT.Customer;
SELECT Suffix FROM SalesLT.Customer;

-- Rappel sur DISTINCT --> 5 valeurs uniques.
SELECT COUNT(DISTINCT(Suffix)) AS TOTAL_SUFFIX
FROM SalesLT.Customer;

-- Ici voir que NULL marqué en distinct value mais pas comptabilisé dans le count()
SELECT DISTINCT(Suffix) AS DIFF_SUFFIX
FROM SalesLT.Customer;

-- SUM Function
SELECT SUM(ListPrice) AS TOTAL_LIST_PRICE
FROM SalesLT.Product;

-- AVG Function 
SELECT AVG(ListPrice) AS AVG_LIST_PRICE
FROM SalesLT.Product;

-- MIN / MAX functions
SELECT MIN(ListPrice) AS MIN_LIST_PRICE, MAX(ListPrice) AS MAX_LIST_PRICE
FROM SalesLT.Product;

-- STRING_AGG
-- STRING_AGG is a function in SQL that allows you to concatenate the values in a column into a single string,
-- with a specified delimiter separating each value.
-- Note that STRING_AGG is only available in SQL Server 2017 and later versions.
SELECT TOP(5) FirstName, LastName FROM SalesLT.Customer
WHERE Suffix IS NOT NULL;

SELECT STRING_AGG(FirstName + ' ' + LastName, ', ') AS FullNames
FROM SalesLT.Customer
WHERE Suffix IS NOT NULL;
-- ICI on met un where pour filtrer et éviter l'erreur que l'on a vu (exceed 8000 bytes)
-- Le résultat c'est une liste de chaine de caractères. A récupérer en Python potentiellement.


-- HAVING pour filtrer une colonne aggrégé
-- RAPPEL HAVING VS WHERE (WHERE filtre avec le groupby, Having used specifically with aggregate functions
-- and is applied after GROUP BY to filter group results)
SELECT CustomerID, SUM(TotalDue) AS TOTAL_SALES
FROM SalesLT.SalesOrderHeader
GROUP BY CustomerID
HAVING SUM(TotalDue) > 100000;

-- Possible d'écrire en écriture scientifique
SELECT CustomerID, SUM(TotalDue) AS TOTAL_SALES
FROM SalesLT.SalesOrderHeader
GROUP BY CustomerID
HAVING SUM(TotalDue) > 1E5;

-- ROLL UP --> Add a row for each client corresponding to the sum of total sales for each category
-- Voir Ligne 17 (Customer ID = 29485) pour comprendre
SELECT CustomerID, ProductCategory.Name AS PRODUCT_CATEGORY, SUM(TotalDue) AS TOTAL_SALES
FROM SalesLT.SalesOrderHeader
INNER JOIN SalesLT.SalesOrderDetail ON SalesLT.SalesOrderHeader.SalesOrderID = SalesLT.SalesOrderDetail.SalesOrderID
INNER JOIN SalesLT.Product ON SalesLT.SalesOrderDetail.ProductID = SalesLT.Product.ProductID
INNER JOIN SalesLT.ProductCategory ON SalesLT.Product.ProductCategoryID = SalesLT.ProductCategory.ProductCategoryID
GROUP BY CustomerID, ProductCategory.Name WITH ROLLUP;

-- WITHOUT ROLLUP to see there is no NULL row correspondign to the total SUM
SELECT CustomerID, ProductCategory.Name AS PRODUCT_CATEGORY, SUM(TotalDue) AS TOTAL_SALES
FROM SalesLT.SalesOrderHeader
INNER JOIN SalesLT.SalesOrderDetail ON SalesLT.SalesOrderHeader.SalesOrderID = SalesLT.SalesOrderDetail.SalesOrderID
INNER JOIN SalesLT.Product ON SalesLT.SalesOrderDetail.ProductID = SalesLT.Product.ProductID
INNER JOIN SalesLT.ProductCategory ON SalesLT.Product.ProductCategoryID = SalesLT.ProductCategory.ProductCategoryID
GROUP BY CustomerID, ProductCategory.Name ORDER BY CustomerID;

--NULL VALUES / COALESCE
-- Difference between the two 
-- ISNULL can handle only two parameters: the expression to check and the replacement value.
-- COALESCE can handle multiple expressions and returns the first non-NULL value.
SELECT TOP(5) Weight FROM SalesLT.Product;

SELECT
    AVG(Weight) as AVG_WEIGHT_withNull, --> AVG sans considérer les colonnes ou c'est NULL (on reduit le n) donc logique que moyenne plus élevé
    AVG(ISNULL(Weight, 0)) as AVG_WEIGHT, --> Ici ISNULL on remplace WEIGHT par 0 quand c'est NULL
    AVG(COALESCE(Weight,0 )) as AVG_WEIGHT --> COALESCE ici prend la première colonne NON NULL donc soit WEIGHT <> NULL on prends WEIGHT, soit WEIGHT == NULL, on prends 0
FROM SalesLT.Product;

-- Count NULL values
SELECT
    COUNT(Title) as Non_Null_Title,
    COUNT(*) as Total_Rows
FROM SalesLT.Customer;


-- Query to look at null values
SELECT ProductID, Name, Weight
FROM SalesLT.Product
WHERE Weight IS NULL;

-- Query bonus ROLLUP and COALESCE
--SELECT CustomerID, ProductCategory.Name AS PRODUCT_CATEGORY, SUM(TotalDue) AS TOTAL_SALES
SELECT CustomerID, COALESCE(ProductCategory.Name, 'Grand TOTAL') AS PRODUCT_CATEGORY, SUM(TotalDue) AS TOTAL_SALES
FROM SalesLT.SalesOrderHeader
INNER JOIN SalesLT.SalesOrderDetail ON SalesLT.SalesOrderHeader.SalesOrderID = SalesLT.SalesOrderDetail.SalesOrderID
INNER JOIN SalesLT.Product ON SalesLT.SalesOrderDetail.ProductID = SalesLT.Product.ProductID
INNER JOIN SalesLT.ProductCategory ON SalesLT.Product.ProductCategoryID = SalesLT.ProductCategory.ProductCategoryID
GROUP BY CustomerID, ProductCategory.Name WITH ROLLUP;