DECLARE @sql nvarchar(max)='';

DECLARE @DBuser_sql VARCHAR(4000)
DECLARE @DBuser_table TABLE (DBName VARCHAR(200), UserName VARCHAR(250), LoginType VARCHAR(500), AssociatedRole VARCHAR(200))
SET @DBuser_sql='SELECT ''?'' AS DBName,a.name AS Name,a.type_desc AS LoginType,c.name AS AssociatedRole 
FROM [?].sys.database_principals a
LEFT OUTER JOIN [?].sys.database_role_members b ON a.principal_id=b.member_principal_id
LEFT OUTER JOIN [?].sys.database_principals c ON c.principal_id=b.role_principal_id
WHERE a.sid NOT IN (0x01,0x00) AND a.sid IS NOT NULL AND a.type NOT IN (''C'') AND a.is_fixed_role <> 1 AND a.name NOT LIKE ''##%'' ORDER BY Name'
INSERT @DBuser_table
EXEC sp_MSforeachdb @command1=@DBuser_sql
SELECT @sql=@sql+'USE '+ QUOTENAME(DBName) + '; ALTER ROLE '+QUOTENAME(AssociatedRole)+' DROP MEMBER '+QUOTENAME(UserName)+';'
FROM @DBuser_table --order by dbname
where UserName='CLOSEBROTHERSGP\zSvcALMPRE' AND LoginType='WINDOWS_USER'
AND ((DBName='master' and AssociatedRole='db_owner')
OR (DBName='ALM_PRE_OneSumXFSArch_fsdb' and AssociatedRole<>'db_owner')
OR (DBName='ALM_PRE_OneSumXFS_fsdb' and AssociatedRole <> 'db_owner'))
--where DBName='master'

--print len(@sql)
--select @sql

exec(@sql)
