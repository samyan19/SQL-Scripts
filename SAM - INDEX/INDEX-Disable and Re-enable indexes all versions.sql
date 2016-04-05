/* http://stackoverflow.com/questions/11301383/automatically-drop-and-recreate-current-indexes*/

--Disable

DECLARE @sql AS VARCHAR(MAX);
SET @sql = '';
SELECT 
    @sql = @sql + 'ALTER INDEX [' + i.name + '] ON [' + o.name + '] DISABLE; '
FROM sys.indexes AS i
JOIN sys.objects AS o ON i.object_id = o.object_id
WHERE i.type_desc = 'NONCLUSTERED'
AND o.type_desc = 'USER_TABLE'

EXEC (@sql)

--Rebuild

DECLARE @sql AS VARCHAR(MAX);
SET @sql = '';
SELECT 
    @sql = @sql + 'ALTER INDEX [' + i.name + '] ON [' + o.name + '] REBUILD WITH (FILLFACTOR = 80); '
FROM sys.indexes AS i
JOIN sys.objects AS o ON i.object_id = o.object_id
WHERE i.type_desc = 'NONCLUSTERED'
AND o.type_desc = 'USER_TABLE'

EXEC (@sql);
