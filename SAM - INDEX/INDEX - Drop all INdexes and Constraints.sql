/* 
o.type filters:
S = System table
IT = Internal table
*/

/* Drop constraints */ 
DECLARE @sql NVARCHAR(MAX);
SET @sql = N'';

SELECT @sql = @sql + N'
  ALTER TABLE ' + QUOTENAME(s.name) + N'.'
  + QUOTENAME(t.name) + N' DROP CONSTRAINT '
  + QUOTENAME(c.name) + ';'
FROM sys.objects AS c
INNER JOIN sys.tables AS t
ON c.parent_object_id = t.[object_id]
INNER JOIN sys.schemas AS s 
ON t.[schema_id] = s.[schema_id]
WHERE c.[type] IN ('D','C','F','PK','UQ')
AND c.type not in ('S','IT')
ORDER BY c.[type];
--PRINT @sql;
EXEC sys.sp_executesql @sql;

/* Drop indexes */
declare @qry nvarchar(max);
SET @qry = N'';
select @qry =@qry+N'
drop index '+QUOTENAME(s.name)+'.'+QUOTENAME(o.name)+'.'+QUOTENAME(i.name)+';'
  from sys.indexes i join sys.objects o on  i.object_id=o.object_id
    join sys.schemas s on o.schema_id=s.schema_id
  where o.type not in ('S','IT')  and is_primary_key<>1 and index_id>0;
--print @qry;
exec sp_executesql @qry
