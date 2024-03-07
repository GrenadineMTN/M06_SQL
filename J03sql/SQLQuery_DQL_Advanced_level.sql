-- Windows functions (Assez complexe) ici on ne va voir que les most commons comme ROW_NUMBER, RANK etc....
-- Syntax = <window_function> (<expression>) OVER ([PARTITION BY <partition_expression>] [ORDER BY <sort_expression> <window_frame_clause>])
-- PARTITION BY = GROUPBY mais sur toute les lignes / ORDER BY = Sort selon une des colonnes

-- ROW_NUMBER(): assigns a unique sequential number to each row within a result set.
SELECT * FROM SalesLT.SalesOrderHeader;

SELECT ROW_NUMBER() OVER(ORDER BY SalesOrderID) AS RowNum, *
FROM SalesLT.SalesOrderHeader;

-- Equivalent sans la création de nouvelle colonne
SELECT *
FROM SalesLT.SalesOrderHeader ORDER BY SalesOrderID;

-- RANK() : Plus fréquemment utilisé --> On assigne un classement
-- En cas d'égalité de montant Due, on autorise les doublons de classement 1,2,2,4
-- Ici pas le cas mais à savoir 
SELECT RANK() OVER(ORDER BY TotalDue DESC) AS Rank, *
FROM SalesLT.SalesOrderHeader;

-- DENSE_RANK () : La même chose mais cette fois-ci en cas d'égalité (1,2,2,3)
SELECT DENSE_RANK() OVER(ORDER BY TotalDue DESC) AS DenseRank, *
FROM SalesLT.SalesOrderHeader;

-- NTIL() : Divise le résultat en groupe de même taille (ici 4 groupe)
SELECT NTILE(4) OVER(ORDER BY TotalDue DESC) AS Quartile, *
FROM SalesLT.SalesOrderHeader;

-- LEAD() : Affiche le résultat de la prochaine ligne (Ligne 1 Next Total Due = Ligne 2 TotalDue)
-- Souvent utiliser pour comparer du temps (comme valeur précédent mois par exemple à comparer avec le mois en cours)
-- Cas concret : Table Mois CA CA M-1 pour ensuite soustraire les deux colonnes et voir l'évolution. 
SELECT SalesOrderID, TotalDue, LEAD(TotalDue, 1) OVER(ORDER BY SalesOrderID) AS NextTotalDue
FROM SalesLT.SalesOrderHeader;

-- LAG() : C'est l'inverse Affiche le résultat de la precédente ligne (Ligne 1 Next Total Due = Ligne 2 TotalDue)
SELECT SalesOrderID, TotalDue, LAG(TotalDue, 1) OVER(ORDER BY SalesOrderID) AS NextTotalDue
FROM SalesLT.SalesOrderHeader;

-- Exemple de query LAG sur database hypothétique car pas applicable à Adevnture Works
-- Add column quantity of the previous order for each product
SELECT 
    o.order_id, 
    p.product_name, 
    o.quantity AS current_quantity,
    LAG(o.quantity) OVER (PARTITION BY o.product_id ORDER BY o.order_date) AS previous_quantity
    
FROM 
    Orders o
JOIN 
    Products p ON o.product_id = p.product_id;

-- Compare les ventes du mois en cours avec le mois précédent
SELECT 
    annee, 
    mois, 
    total_ventes AS ventes_actuelles,
    LAG(total_ventes) OVER (ORDER BY annee, mois) AS ventes_mois_precedent
FROM 
    Ventes;

-- FIRST_VALUE(): Première query avec PARTITION BY (si problème de compréhension all) faire le premier exemple avec la somme
-- Ici pour bien comprendre RUN ces deux query. 
-- Ce qu'il faut voir c'est que ProductCategoryID 1,2,3,4 sont associées à une ParentProductCategoryID NULL 
-- On groupby ParentProductCategoryID et on recupère la première valeur de nom (ici Bikes dans l'ordre alphabethique)
-- Pareil pour ProductID 5,6,7 de ParentID = 1, on groupby et on récupére la prémière valeur de name dans l'ordre alphabétique (ici Mountain Bikes)
SELECT DISTINCT ProductCategoryID, Name AS Original_name,
       FIRST_VALUE(Name) OVER(PARTITION BY ParentProductCategoryID ORDER BY Name) AS FirstCategory
FROM SalesLT.ProductCategory;

-- Pour comprendre le fonctionnement de FIRST_VALUE()
SELECT DISTINCT ProductCategoryID, ParentProductCategoryID, Name
FROM SalesLT.ProductCategory ORDER BY ParentProductCategoryID, Name;

-- LAST_VALUE(): C'est l'inverse on récupère la dernière occurence
-- Cette query ne fonctionne pas 
SELECT DISTINCT ProductCategoryID,
       LAST_VALUE(Name) OVER(PARTITION BY ParentProductCategoryID ORDER BY Name) AS LastCategory
FROM SalesLT.ProductCategory;
-- Réparation via cette query mais concepts trop avancé honnetement pas si important
SELECT DISTINCT ProductCategoryID,
       LAST_VALUE(Name) OVER(
           PARTITION BY ParentProductCategoryID 
           ORDER BY Name 
           RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
       ) AS LastCategory
FROM SalesLT.ProductCategory;

-- SUM(), AVG(), COUNT(), MIN(), MAX()
-- Ici voir que Total quantity du product 707 est bien égal à la somme de OrderQty
SELECT ProductID, OrderQty, SUM(OrderQty) OVER(PARTITION BY ProductID) AS TotalQty
FROM SalesLT.SalesOrderDetail;



-- Query intéressante pour le business Permet de voir la répartition en % des ventes pour un product ID
SELECT ProductID, OrderQty, SUM(OrderQty) OVER(PARTITION BY ProductID) AS TotalQty, 100. * OrderQty/SUM(OrderQty) OVER (PARTITION BY ProductID)
FROM SalesLT.SalesOrderDetail;

-- PERCENT_RANK() Value between 0 and 1 representing the percentile rank of the row
SELECT SalesOrderID, TotalDue, PERCENT_RANK() OVER(ORDER BY TotalDue) AS Percentile
FROM SalesLT.SalesOrderHeader;

-- CUME_DIST() Value between 0 and 1 representing the proportion of rows that have a value less than or equal to the current row's value
-- Pourcentage cumulé
SELECT SalesOrderID, TotalDue, CUME_DIST() OVER(ORDER BY TotalDue) AS CumulativeDistribution
FROM SalesLT.SalesOrderHeader

-- Exemple 1 Windows functions
-- TotalSalesAmount = Montant total dépensé par un client
-- PercentOfTotalSalesAmount = Pourcentage du TotalSalesAmount par rapport à la SOMME de TotalSalesAmount
SELECT
    c.CustomerID,
    SUM(sod.LineTotal) AS TotalSalesAmount,
    CAST(SUM(sod.LineTotal) * 100 / SUM(SUM(sod.LineTotal)) OVER() AS DECIMAL(5,2)) AS PercentOfTotalSalesAmount,
    CAST(SUM(sod.LineTotal) * 100 / SUM(SUM(sod.LineTotal)) OVER(ORDER BY SUM(sod.LineTotal) DESC) AS DECIMAL(5,2)) AS RunningTotalPercentOfTotalSalesAmount
FROM
    SalesLT.Customer AS c
    JOIN SalesLT.SalesOrderHeader AS soh ON c.CustomerID = soh.CustomerID
    JOIN SalesLT.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY
    c.CustomerID
ORDER BY
    TotalSalesAmount DESC;
-- Ici voir que l'on a un groupby (qui se rapporte aux lignes c.CustomerID and SUM(sod.LineTotal))
-- Et qu'ensuite on a des windows functions qui vont faire un calcul à partir de ces deux colonnes

-- Exemple 2 
-- Total Sales Amount = Vente totale rapportée par le produit
-- PercentOfCatagory = Que represente la part du porduit dans la category
-- On donne un numéro aux lignes sans l'ordre.
With ranking AS(
SELECT
    pc.Name AS ProductCategoryName,
    p.Name AS ProductName,
    SUM(sod.LineTotal) AS TotalSalesAmount,
    CAST(SUM(sod.LineTotal) * 100 / SUM(SUM(sod.LineTotal)) OVER(PARTITION BY pc.Name) AS DECIMAL(5,2)) AS PercentOfCategorySalesAmount,
    ROW_NUMBER() OVER(PARTITION BY pc.Name ORDER BY SUM(sod.LineTotal) DESC) AS Rank
FROM
    SalesLT.Product AS p
    JOIN SalesLT.ProductCategory AS pc ON p.ProductCategoryID = pc.ProductCategoryID
    JOIN SalesLT.ProductModelProductDescription AS pmpd ON p.ProductModelID = pmpd.ProductModelID
    JOIN SalesLT.ProductDescription AS pd ON pmpd.ProductDescriptionID = pd.ProductDescriptionID
    JOIN SalesLT.SalesOrderDetail AS sod ON p.ProductID = sod.ProductID
GROUP BY
    pc.Name,
    p.Name
)
SELECT *
FROM ranking
WHERE Rank <= 3

-- Ici à la limite pas très intérressant, on préférerais voir pour chaque product
-- le pourcentage par rapport au vente total --> A faire

-- Exemple 3
-- Ici compare le total sale de l'année avec le Total sales toute année confondu
-- Ici pas intéressant car le même résultat.
SELECT
    pc.Name,
    YEAR(soh.OrderDate) AS OrderYear,
    SUM(sod.LineTotal) AS TotalSales,
    SUM(SUM(sod.LineTotal)) OVER (PARTITION BY pc.Name ORDER BY YEAR(soh.OrderDate)) AS RunningTotalSales
FROM
    SalesLT.SalesOrderHeader soh
    JOIN SalesLT.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
    JOIN SalesLT.Product p ON sod.ProductID = p.ProductID
    JOIN SalesLT.ProductModel pm ON p.ProductModelID = pm.ProductModelID
    JOIN SalesLT.ProductModelProductDescription pmpd ON pm.ProductModelID = pmpd.ProductModelID
    JOIN SalesLT.ProductDescription pd ON pmpd.ProductDescriptionID = pd.ProductDescriptionID
    JOIN SalesLT.ProductCategory pc ON p.ProductCategoryID = pc.ProductCategoryID
GROUP BY
    pc.Name,
    YEAR(soh.OrderDate)
ORDER BY
    pc.Name,
    YEAR(soh.OrderDate)

-- Exemple 4 
SELECT
    pc.Name,
    pm.Name AS ProductModelName,
    SUM(sod.LineTotal) AS TotalSales,
    SUM(sod.LineTotal) / SUM(SUM(sod.LineTotal)) OVER (PARTITION BY pc.Name) AS SalesPercentage
FROM
    SalesLT.SalesOrderHeader soh
    JOIN SalesLT.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
    JOIN SalesLT.Product p ON sod.ProductID = p.ProductID
    JOIN SalesLT.ProductModel pm ON p.ProductModelID = pm.ProductModelID
    JOIN SalesLT.ProductModelProductDescription pmpd ON pm.ProductModelID = pmpd.ProductModelID
    JOIN SalesLT.ProductDescription pd ON pmpd.ProductDescriptionID = pd.ProductDescriptionID
    JOIN SalesLT.ProductCategory pc ON p.ProductCategoryID = pc.ProductCategoryID
GROUP BY
    pc.Name,
    pm.Name
ORDER BY
    pc.Name,
    pm.Name


-- CASE WHEN
-- Syntax : 
-- SELECT column1, column2, ...
-- FROM table_name
-- WHERE condition
-- ORDER BY column_name
-- CASE
--     WHEN condition1 THEN result1
--     WHEN condition2 THEN result2
--     ...
--     WHEN conditionN THEN resultN
--     ELSE result
-- END;

-- Exemple 1 :
-- Ici comprendre que SUM nécéssaire du à la présence du groupBY 
-- Mais potentiellement on remplace par AVG et cela donne le même résultat

SELECT c.CustomerID, c.FirstName, c.LastName,
       SUM(CASE
           WHEN soh.TotalDue > 10000 THEN 1
           WHEN soh.TotalDue > 5000 THEN 2
           ELSE 3
       END) AS OrderCategory
FROM SalesLT.Customer c
JOIN SalesLT.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName

SELECT c.CustomerID, c.FirstName, c.LastName,
       MAX(CASE
           WHEN soh.TotalDue > 10000 THEN 1
           WHEN soh.TotalDue > 5000 THEN 2
           ELSE 3
       END) AS OrderCategory
FROM SalesLT.Customer c
JOIN SalesLT.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName

-- Cette query est complétement équivalente et moins compliqué (donc plûtot montrer celle-ci)
SELECT c.CustomerID, c.FirstName, c.LastName,
       CASE
           WHEN soh.TotalDue > 10000 THEN 1
           WHEN soh.TotalDue > 5000 THEN 2
           ELSE 3
       END AS OrderCategory
FROM SalesLT.Customer c
JOIN SalesLT.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID

-- Exemple 2 :
-- Selon la valeur dans AverageOrderValue on associe un category
SELECT
    ProductCategory.Name AS CategoryName,
    AVG(SalesOrderDetail.UnitPrice * SalesOrderDetail.OrderQty) AS AverageOrderValue,
    CASE
        WHEN AVG(SalesOrderDetail.UnitPrice * SalesOrderDetail.OrderQty) > 100 THEN 'High Value'
        WHEN AVG(SalesOrderDetail.UnitPrice * SalesOrderDetail.OrderQty) > 50 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS CategoryValue
FROM SalesLT.SalesOrderDetail
    JOIN SalesLT.Product
        ON SalesOrderDetail.ProductID = Product.ProductID
    JOIN SalesLT.ProductCategory
        ON ProductCategory.ProductCategoryID = Product.ProductCategoryID
GROUP BY
    ProductCategory.Name;

-- Exemple 3 : Une ligne en sortie
SELECT
    YEAR(OrderDate) AS OrderYear,
    DATEPART(QUARTER, OrderDate) AS OrderQuarter,
SUM(LineTotal) AS TotalSales,
CASE
WHEN SUM(LineTotal) > 100000 THEN 'High Sales'
WHEN SUM(LineTotal) > 50000 THEN 'Medium Sales'
ELSE 'Low Sales'
END AS SalesValue
FROM
SalesLT.SalesOrderHeader
JOIN SalesLT.SalesOrderDetail
ON SalesOrderHeader.SalesOrderID = SalesOrderDetail.SalesOrderID
GROUP BY
YEAR(OrderDate),
DATEPART(QUARTER, OrderDate);

-- Exemple 4 (Very complex not necessary)
WITH ProductSales AS (
    SELECT p.ProductID, p.Name, p.ListPrice, pc.Name AS Category,
           SUM(sod.OrderQty * sod.UnitPrice) AS SalesRevenue
    FROM SalesLT.Product p
    JOIN SalesLT.ProductCategory pc ON p.ProductCategoryID = pc.ProductCategoryID
    JOIN SalesLT.ProductModelProductDescription pmpd ON p.ProductModelID = pmpd.ProductModelID
    JOIN SalesLT.ProductDescription pd ON pmpd.ProductDescriptionID = pd.ProductDescriptionID
    JOIN SalesLT.SalesOrderDetail sod ON p.ProductID = sod.ProductID
    JOIN SalesLT.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
    GROUP BY p.ProductID, p.Name, p.ListPrice, pc.Name, pc.ProductCategoryID
),
ProductRanking AS (
    SELECT ps.ProductID, ps.Name, ps.ListPrice, ps.Category, ps.SalesRevenue,
           RANK() OVER (PARTITION BY ps.Category ORDER BY ps.SalesRevenue DESC) AS SalesRank,
           RANK() OVER (ORDER BY ps.SalesRevenue DESC) AS RevenueRank
    FROM ProductSales ps
)
SELECT pr.ProductID, pr.Name, pr.ListPrice, pr.Category, pr.SalesRevenue,
       pr.SalesRank, pr.RevenueRank
FROM ProductRanking pr
