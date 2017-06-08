/* Generate statements to create server permissions for SQL logins, Windows Logins, and Groups

Changing the Setting From The Tools Menu
In the Options dialog box of Tools Menu, expand Query Results, 
expand SQL Server and then select Results to Text as shown in the image below. 
In the right side panel change the value of Maximum number of characters displayed 
in each column to 8192. Click OK to save the changes as shown in the image below. 
The changes will go into effect once you open a new query window.

*/ 
SET NOCOUNT ON 

SELECT  'USE' + SPACE(1) + QUOTENAME('MASTER') AS '--Database Context' 

-- Scripting Out the Logins To Be Created
SELECT 'IF (SUSER_ID('+QUOTENAME(SP.name,'''')+') IS NULL) BEGIN CREATE LOGIN ' +QUOTENAME(SP.name)+
			   CASE 
					WHEN SP.type_desc = 'SQL_LOGIN' THEN ' WITH PASSWORD = ' +CONVERT(NVARCHAR(MAX),SL.password_hash,1)+ ' HASHED, CHECK_EXPIRATION = ' 
						+ CASE WHEN SL.is_expiration_checked = 1 THEN 'ON' ELSE 'OFF' END +', CHECK_POLICY = ' +CASE WHEN SL.is_policy_checked = 1 THEN 'ON,' ELSE 'OFF,' END
					ELSE ' FROM WINDOWS WITH'
				END 
	   +' DEFAULT_DATABASE=[' +SP.default_database_name+ '], DEFAULT_LANGUAGE=[' +SP.default_language_name+ '] END;' COLLATE SQL_Latin1_General_CP1_CI_AS AS [-- Logins To Be Created --]
FROM sys.server_principals AS SP LEFT JOIN sys.sql_logins AS SL
		ON SP.principal_id = SL.principal_id
WHERE SP.type IN ('S','G','U')
		AND SP.name NOT LIKE '##%##'
		AND SP.name NOT LIKE 'NT AUTHORITY%'
		AND SP.name NOT LIKE 'NT SERVICE%'
		AND SP.name <> ('sa');

-- Role Members 
SELECT  'EXEC sp_addsrvrolemember @rolename =' + SPACE(1) 
        + QUOTENAME(usr1.name, '''') + ', @loginame =' + SPACE(1) 
        + QUOTENAME(usr2.name, '''') AS '--Role Memberships' 
FROM    sys.server_principals AS usr1 
        INNER JOIN sys.server_role_members AS rm ON usr1.principal_id = rm.role_principal_id 
        INNER JOIN sys.server_principals AS usr2 ON rm.member_principal_id = usr2.principal_id 
ORDER BY rm.role_principal_id ASC 

-- Permissions 
SELECT  server_permissions.state_desc COLLATE SQL_Latin1_General_CP1_CI_AS 
        + ' ' + server_permissions.permission_name COLLATE SQL_Latin1_General_CP1_CI_AS 
        + ' TO [' + server_principals.name COLLATE SQL_Latin1_General_CP1_CI_AS 
        + ']' AS '--Server Level Permissions' 
FROM    sys.server_permissions AS server_permissions WITH ( NOLOCK ) 
        INNER JOIN sys.server_principals AS server_principals WITH ( NOLOCK ) ON server_permissions.grantee_principal_id = server_principals.principal_id 
WHERE   server_principals.type IN ( 'S', 'U', 'G' ) 
ORDER BY server_principals.name, 
        server_permissions.state_desc, 
        server_permissions.permission_name 
