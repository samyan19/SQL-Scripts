DECLARE @DBuser_sql VARCHAR(4000)
DECLARE @DBuser_table TABLE (DBName VARCHAR(200), UserName VARCHAR(250), LoginType VARCHAR(500), AssociatedRole VARCHAR(200))
SET @DBuser_sql='SELECT ''?'' AS DBName,a.name AS Name,a.type_desc AS LoginType,c.name AS AssociatedRole 
FROM [?].sys.database_principals a
LEFT OUTER JOIN [?].sys.database_role_members b ON a.principal_id=b.member_principal_id
LEFT OUTER JOIN [?].sys.database_principals c ON c.principal_id=b.role_principal_id
JOIN [?].sys.server_principals sp on a.name=sp.name
WHERE a.sid NOT IN (0x01,0x00) AND a.sid IS NOT NULL AND a.type NOT IN (''C'') AND a.is_fixed_role <> 1 AND a.name NOT LIKE ''##%'' AND ''?'' NOT IN (''master'',''msdb'',''model'',''tempdb'') ORDER BY Name'
INSERT @DBuser_table
EXEC sp_MSforeachdb @command1=@dbuser_sql
SELECT * FROM @DBuser_table --order by dbname

