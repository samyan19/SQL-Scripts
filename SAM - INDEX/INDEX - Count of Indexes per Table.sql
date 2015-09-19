SELECT 
[schema_name] = s.name, table_name = o.name,COUNT(i.TYPE) IndexCount
FROM sys.indexes i
INNER JOIN sys.objects o ON i.[object_id] = o.[object_id]
INNER JOIN sys.schemas s ON o.[schema_id] = s.[schema_id]
WHERE o.TYPE IN ('U')
AND i.TYPE = 2
GROUP BY s.name, o.name
ORDER BY 3 desc,schema_name, table_name