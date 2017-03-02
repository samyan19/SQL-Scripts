/**
** This script is to script out the TSQL required to apply the complete permissions of a given user.
** Simply assign the login name you would like to script permissions for to the @login_name variable and execute
**/
DECLARE @login_name nvarchar(100)='closebrothersgp\zSvcALMUAT'

DECLARE @command TABLE (ID INT IDENTITY (1,1),TSQL nvarchar(4000))

/* Generate statements to create server permissions for SQL logins, Windows Logins, and Groups */ 
SET NOCOUNT ON 

-- Scripting Out the Logins To Be Created
INSERT INTO @command
SELECT  '--Logins to be created'
INSERT INTO @command
SELECT 'USE master; IF (SUSER_ID('+QUOTENAME(SP.name,'''')+') IS NULL) BEGIN CREATE LOGIN ' +QUOTENAME(SP.name)+
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
		AND SP.name <> ('sa')
		AND SP.name=@login_name;

-- Permissions 
INSERT INTO @command
SELECT  ''
INSERT INTO @command
SELECT  '--Server level permissions'
INSERT INTO @command
SELECT  'USE master; '+server_permissions.state_desc COLLATE SQL_Latin1_General_CP1_CI_AS 
        + ' ' + server_permissions.permission_name COLLATE SQL_Latin1_General_CP1_CI_AS 
        + ' TO [' + server_principals.name COLLATE SQL_Latin1_General_CP1_CI_AS 
        + '];' AS '--Server Level Permissions' 
FROM    sys.server_permissions AS server_permissions WITH ( NOLOCK ) 
        INNER JOIN sys.server_principals AS server_principals WITH ( NOLOCK ) ON server_permissions.grantee_principal_id = server_principals.principal_id 
WHERE   server_principals.type IN ( 'S', 'U', 'G' ) 
		AND server_principals.name=@login_name
ORDER BY server_principals.name, 
        server_permissions.state_desc, 
        server_permissions.permission_name 


-- Role Members 
INSERT INTO @command
SELECT  ''
INSERT INTO @command
SELECT  '--Server role permissions'
INSERT INTO @command
SELECT  'USE master; EXEC sp_addsrvrolemember @rolename =' + SPACE(1) 
        + QUOTENAME(usr1.name, '''') + ', @loginame =' + SPACE(1) 
        + QUOTENAME(usr2.name, '''')  + ';'AS '--Role Memberships' 
FROM    sys.server_principals AS usr1 
        INNER JOIN sys.server_role_members AS rm ON usr1.principal_id = rm.role_principal_id 
        INNER JOIN sys.server_principals AS usr2 ON rm.member_principal_id = usr2.principal_id 
WHERE usr2.name=@login_name
ORDER BY rm.role_principal_id ASC 




/************* DB level perms ************************/
DECLARE @DB_permissions TABLE (login_name sysname,TSQL nvarchar(4000))

INSERT INTO @command
SELECT  ''
INSERT INTO @command
SELECT  '--Database level permissions'
INSERT INTO @DB_permissions
EXEC sp_MSforeachdb '
use [?]
SELECT 
UPPER(USER_NAME(usr.principal_id)) as ''login_name'',
''USE ?; ''+ CASE WHEN perm.state <> ''W'' THEN perm.state_desc ELSE ''GRANT'' END
       + SPACE(1) + perm.permission_name + SPACE(1)
       + SPACE(1) + ''TO'' + SPACE(1) + QUOTENAME(USER_NAME(usr.principal_id)) COLLATE database_default
       + CASE WHEN perm.state <> ''W'' THEN '';'' ELSE SPACE(1) + ''WITH GRANT OPTION'' END AS ''TSQL''
FROM   sys.database_permissions AS perm
       INNER JOIN
       sys.database_principals AS usr
       ON perm.grantee_principal_id = usr.principal_id
WHERE  perm.major_id = 0
ORDER BY perm.permission_name ASC, perm.state_desc ASC'


INSERT INTO @command
SELECT TSQL 
from @DB_permissions
where login_name=UPPER(@login_name)

/******************** SCript DB ROle permissions **********************/

DECLARE @DB_role_permissions TABLE (login_name sysname,TSQL nvarchar(4000))

INSERT INTO @command
SELECT  ''
INSERT INTO @command
SELECT  '--Database role permissions'
INSERT INTO @DB_role_permissions
EXEC sp_MSforeachdb '
use [?]
SELECT 
UPPER(USER_NAME(rm.member_principal_id)) as ''login_name'',
''USE ?; EXEC sp_addrolemember @rolename =''
+ SPACE(1) + QUOTENAME(USER_NAME(rm.role_principal_id), '''''''') + '', @membername ='' + SPACE(1) + QUOTENAME(USER_NAME(rm.member_principal_id), '''''''') +'';'' AS [-- SQL STATEMENTS --]
FROM sys.database_role_members AS rm
WHERE USER_NAME(rm.member_principal_id) IN ( 
--get user names on the database
SELECT [name]
FROM sys.database_principals
WHERE [principal_id] > 4 -- 0 to 4 are system users/schemas
and [type] IN (''G'', ''S'', ''U'') -- S = SQL user, U = Windows user, G = Windows group
 )'

INSERT INTO @command
SELECT TSQL 
from @DB_role_permissions
where login_name=UPPER(@login_name)

/******************* object level perms *********************/
DECLARE @DB_object_permissions TABLE (login_name sysname,TSQL nvarchar(4000))

INSERT INTO @command
SELECT  ''
INSERT INTO @command
SELECT  '--Object level permissions'
INSERT INTO @DB_object_permissions
EXEC sp_MSforeachdb '
use [?]
SELECT 
USER_NAME(usr.principal_id) as ''login_name'',
''USE ?; ''+ CASE WHEN perm.state <> ''W'' THEN perm.state_desc ELSE ''GRANT'' END
	+ SPACE(1) + perm.permission_name + SPACE(1) + ''ON '' + QUOTENAME(USER_NAME(obj.schema_id)) + ''.'' + QUOTENAME(obj.name) 
	+ CASE WHEN cl.column_id IS NULL THEN SPACE(0) ELSE ''('' + QUOTENAME(cl.name) + '')'' END
	+ SPACE(1) + ''TO'' + SPACE(1) + QUOTENAME(USER_NAME(usr.principal_id)) COLLATE database_default
	+ CASE WHEN perm.state <> ''W'' THEN '';'' ELSE SPACE(1) + ''WITH GRANT OPTION'' END AS TSQL
FROM	sys.database_permissions AS perm
	INNER JOIN
	sys.objects AS obj
	ON perm.major_id = obj.[object_id]
	INNER JOIN
	sys.database_principals AS usr
	ON perm.grantee_principal_id = usr.principal_id
	LEFT JOIN
	sys.columns AS cl
	ON cl.column_id = perm.minor_id AND cl.[object_id] = perm.major_id
ORDER BY perm.permission_name ASC, perm.state_desc ASC;'

INSERT INTO @command
SELECT TSQL 
from @DB_object_permissions
where login_name=@login_name

--return complete script
select TSQL
from @command
order by ID asc
