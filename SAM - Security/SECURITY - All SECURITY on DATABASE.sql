/*****************************************************
Script to find server level logins and role assigned
******************************************************/
SELECT a.name as LoginName,a.type_desc AS LoginType, a.default_database_name AS DefaultDBName,
CASE WHEN b.sysadmin = 1 THEN 'sysadmin'
          WHEN b.securityadmin=1 THEN 'securityadmin'
          WHEN b.serveradmin=1 THEN 'serveradmin'
          WHEN b.setupadmin=1 THEN 'setupadmin'
          WHEN b.processadmin=1 THEN 'processadmin'
          WHEN b.diskadmin=1 THEN 'diskadmin'
          WHEN b.dbcreator=1 THEN 'dbcreator'
          WHEN b.bulkadmin=1 THEN 'bulkadmin'
          ELSE 'Public' END AS 'ServerRole'
FROM sys.server_principals a  JOIN master..syslogins b ON a.sid=b.sid WHERE a.type  <> 'R' AND a.name NOT LIKE '##%'

/******************************************************
Script to find database users and roles assigned
*******************************************************/
DECLARE @DBuser_sql VARCHAR(4000)
DECLARE @DBuser_table TABLE (DBName VARCHAR(200), UserName VARCHAR(250), LoginType VARCHAR(500), AssociatedRole VARCHAR(200))
SET @DBuser_sql='SELECT ''?'' AS DBName,a.name AS Name,a.type_desc AS LoginType,USER_NAME(b.role_principal_id) AS AssociatedRole FROM ?.sys.database_principals a
LEFT OUTER JOIN ?.sys.database_role_members b ON a.principal_id=b.member_principal_id
WHERE a.sid NOT IN (0x01,0x00) AND a.sid IS NOT NULL AND a.type NOT IN (''C'') AND a.is_fixed_role <> 1 AND a.name NOT LIKE ''##%'' AND ''?'' NOT IN (''master'',''msdb'',''model'',''tempdb'') ORDER BY Name'
INSERT @DBuser_table
EXEC sp_MSforeachdb @command1=@dbuser_sql
SELECT * FROM @DBuser_table ORDER BY DBName


/*****************************************************
Script to find Object level permission for user databases
********************************************************/

DECLARE @Obj_sql VARCHAR(2000)
DECLARE @Obj_table TABLE (DBName VARCHAR(200), UserName VARCHAR(250), SchemaName VARCHAR(500), ObjectName VARCHAR(500), Permission VARCHAR(200))
SET @Obj_sql='USE ? select ''?'' as DBName,U.name as username, schema_name(O.schema_id),O.name as object,  permission_name as permission from ?.sys.database_permissions
join ?.sys.sysusers U on grantee_principal_id = uid join ?.sys.objects O on major_id = object_id WHERE ''?'' NOT IN (''master'',''msdb'',''model'',''tempdb'') order by U.name '
INSERT @Obj_table
EXEC sp_msforeachdb @command1=@Obj_sql
SELECT * FROM @Obj_table

