SELECT SCHEMA_NAME(o.schema_id) AS [schema]
,OBJECT_NAME(i.object_id) AS [table]
,p.rows
,'EXEC sp_rename ''[' + SCHEMA_NAME(o.schema_id) + '].[' + OBJECT_NAME(i.object_id) + ']'', ''[' + SCHEMA_NAME(o.schema_id) + '].[_ToBeDropped_' + OBJECT_NAME(i.object_id) + ']''' AS ScriptToRename
,'DROP TABLE ''[' + SCHEMA_NAME(o.schema_id) + '].[' + OBJECT_NAME(i.object_id) + ']''' AS ScriptToDrop
FROM sys.indexes i
INNER JOIN sys.objects o ON i.object_id = o.object_id
INNER JOIN sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
LEFT OUTER JOIN sys.dm_db_index_usage_stats ius ON i.object_id = ius.object_id AND i.index_id = ius.index_id
WHERE i.type_desc = 'HEAP'
AND COALESCE(ius.user_seeks, ius.user_scans, ius.user_lookups, ius.user_updates, ius.last_user_seek, ius.last_user_scan, ius.last_user_lookup) IS NULL
ORDER BY rows desc