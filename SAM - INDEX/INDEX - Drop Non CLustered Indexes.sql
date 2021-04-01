DECLARE @sql NVARCHAR(MAX) = N'';

SELECT @sql += N'DROP INDEX' 
    + QUOTENAME(SCHEMA_NAME(o.[schema_id]))
    + '.' + QUOTENAME(o.name) 
    + '.' + QUOTENAME(i.name) + ';'
    FROM sys.indexes AS i
    INNER JOIN sys.tables AS o
    ON i.[object_id] = o.[object_id]
WHERE i.is_primary_key = 0
AND i.index_id <> 0
AND o.is_ms_shipped = 0;

--PRINT @sql;
 EXEC sp_executesql @sql;
