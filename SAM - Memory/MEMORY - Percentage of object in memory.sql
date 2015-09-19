SELECT sys.tables.name TableName,
 sum(a.page_id)*8 AS MemorySpaceKB,
 SUM(sys.allocation_units.data_pages)*8 AS StorageSpaceKB,
 CASE WHEN SUM(sys.allocation_units.data_pages) <> 0 THEN SUM(a.page_id)/CAST(SUM(sys.allocation_units.data_pages) AS NUMERIC(18,2)) END AS 'Percentage Of Object In Memory'
FROM (SELECT database_id, allocation_unit_id, COUNT(page_id) page_id FROM sys.dm_os_buffer_descriptors GROUP BY database_id, allocation_unit_id) a
JOIN sys.allocation_units ON a.allocation_unit_id = sys.allocation_units.allocation_unit_id
JOIN sys.partitions ON (sys.allocation_units.type IN (1,3)
  AND sys.allocation_units.container_id = sys.partitions.hobt_id)
 OR (sys.allocation_units.type = 2 AND sys.allocation_units.container_id = sys.partitions.partition_id)
JOIN sys.tables ON sys.partitions.object_id = sys.tables.object_id
 AND sys.tables.is_ms_shipped = 0
WHERE a.database_id = DB_ID()
GROUP BY sys.tables.name