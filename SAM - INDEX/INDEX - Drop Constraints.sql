/*
https://docs.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-objects-transact-sql?view=sql-server-ver15
C = CHECK constraint

D = DEFAULT (constraint or stand-alone)

F = FOREIGN KEY constraint

PK = PRIMARY KEY constraint

R = Rule (old-style, stand-alone)

TA = Assembly (CLR-integration) trigger

TR = SQL trigger

UQ = UNIQUE constraint

EC = Edge constraint
*/

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
WHERE c.[type] IN ('UQ')
ORDER BY c.[type];

--PRINT @sql;
EXEC sys.sp_executesql @sql;
