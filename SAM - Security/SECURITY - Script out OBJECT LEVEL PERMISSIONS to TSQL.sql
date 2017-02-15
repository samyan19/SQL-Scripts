declare @login_name nvarchar(100)='[closebrothersgp\zSvcALMUAT]'

/************* DB level perms ************************/
SELECT	CASE WHEN perm.state <> 'W' THEN perm.state_desc ELSE 'GRANT' END
	+ SPACE(1) + perm.permission_name + SPACE(1)
	+ SPACE(1) + 'TO' + SPACE(1) + QUOTENAME(USER_NAME(usr.principal_id)) COLLATE database_default
	+ CASE WHEN perm.state <> 'W' THEN ';' ELSE SPACE(1) + 'WITH GRANT OPTION' END AS '--Database Level Permissions'
FROM	sys.database_permissions AS perm
	INNER JOIN
	sys.database_principals AS usr
	ON perm.grantee_principal_id = usr.principal_id
WHERE	perm.major_id = 0
and QUOTENAME(USER_NAME(usr.principal_id))=@login_name
ORDER BY perm.permission_name ASC, perm.state_desc ASC

/******************** SCript DB ROle permissions **********************/
SELECT '-- [-- DB ROLES --] --' AS [-- SQL STATEMENTS --],
5 AS [-- RESULT ORDER HOLDER --]
UNION
SELECT 'EXEC sp_addrolemember @rolename ='
+ SPACE(1) + QUOTENAME(USER_NAME(rm.role_principal_id), '''') + ', @membername =' + SPACE(1) + QUOTENAME(USER_NAME(rm.member_principal_id), '''') AS [-- SQL STATEMENTS --],
5.1 AS [-- RESULT ORDER HOLDER --]
FROM sys.database_role_members AS rm
WHERE USER_NAME(rm.member_principal_id) IN ( 
--get user names on the database
SELECT [name]
FROM sys.database_principals
WHERE [principal_id] > 4 -- 0 to 4 are system users/schemas
and [type] IN ('G', 'S', 'U') -- S = SQL user, U = Windows user, G = Windows group
and QUOTENAME(USER_NAME(rm.member_principal_id))=@login_name
 )
--ORDER BY rm.role_principal_id ASC

/******************* object level perms *********************/
SELECT	CASE WHEN perm.state <> 'W' THEN perm.state_desc ELSE 'GRANT' END
	+ SPACE(1) + perm.permission_name + SPACE(1) + 'ON ' + QUOTENAME(USER_NAME(obj.schema_id)) + '.' + QUOTENAME(obj.name) 
	+ CASE WHEN cl.column_id IS NULL THEN SPACE(0) ELSE '(' + QUOTENAME(cl.name) + ')' END
	+ SPACE(1) + 'TO' + SPACE(1) + QUOTENAME(USER_NAME(usr.principal_id)) COLLATE database_default
	+ CASE WHEN perm.state <> 'W' THEN ';' ELSE SPACE(1) + 'WITH GRANT OPTION' END AS '--Object Level Permissions'
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
WHERE QUOTENAME(USER_NAME(usr.principal_id))=@login_name
ORDER BY perm.permission_name ASC, perm.state_desc ASC;


