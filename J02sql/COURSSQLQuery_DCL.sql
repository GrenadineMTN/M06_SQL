-- First step créer un LOGIN au niveau de master (Login pour se connecter aux serveur)
-- Creation au niveau de master dans l'arborescence
-- Select master in the Database choice
-- Voir création dans dossier Security/Logins
CREATE LOGIN SalesUser WITH PASSWORD = 'QcAmKhsEKjVBpAU3';

DROP LOGIN SalesUser;
DROP USER SalesRep;
-- Second step créer le user pour la database (User de la database)
-- User = différente permission donné à un login
-- Voir création dans dossier AdventureWorks/Security/Users
CREATE USER SalesRep FOR LOGIN SalesUser;

-- Grant statement GRANT permission ON object TO user;
GRANT SELECT ON SalesLT.Customer TO SalesRep;
GRANT SELECT ON SalesLT.SalesOrderDetail TO SalesRep;

-- Revoke statement REVOKE permission_type ON object_name FROM user_name
REVOKE SELECT ON SalesLT.SalesOrderDetail FROM SalesRep;
REVOKE ALL ON SalesLT.SalesOrderDetail FROM SalesRep;


-- Deny statement DENY permission_type ON object_name TO user_name
DENY INSERT ON SalesLT.ProductModel TO SalesRep;
DENY SELECT ON SalesLT.ProductModel TO SalesRep;


-- Permission type values : SELECT UPDATE EXECUTE ALL INSERT
-- Distinction Login/User explication supplémentaire : 
-- Une personne va avoir un login (login1) et ensuite un userID associé à chaque lecture de database
-- Objectif full control sur les permissions accordé (notion de granularité)


-- Query to run to check permission of an user
SELECT 
    perm.permission_name, 
    perm.state_desc, 
    obj.name AS object_name, 
    sch.name AS schema_name
FROM 
    sys.database_permissions AS perm
    INNER JOIN sys.objects AS obj ON perm.major_id = obj.object_id
    INNER JOIN sys.schemas AS sch ON obj.schema_id = sch.schema_id
    INNER JOIN sys.database_principals AS pr ON perm.grantee_principal_id = pr.principal_id
WHERE 
    pr.name = 'SalesRep';