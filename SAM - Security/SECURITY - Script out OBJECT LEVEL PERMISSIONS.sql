declare @login_name nvarchar(100)='[TEST\ROLE-U-ALM-DEV-3rdPartySupport]'

/* DB level perms */
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


/* object level perms */
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


