--2005 and above

SELECT schema_name(schema_id) AS SchemaName,  object_name(o.object_id) AS ObjectName, 
    i.name AS IndexName, index_id, o.type, 
    STATS_DATE(o.object_id, index_id) AS statistics_update_date 
FROM sys.indexes i join sys.objects o 
       on i.object_id = o.object_id 
WHERE o.object_id > 100 AND index_id > 0 
  AND is_ms_shipped = 0;


--2008R2 SP2 and above

SELECT object_name(sp.object_id) as object_name,name as stats_name, sp.stats_id,  
    last_updated, rows, rows_sampled, steps, unfiltered_rows, modification_counter 
FROM sys.stats AS s 
CROSS APPLY sys.dm_db_stats_properties(s.object_id, s.stats_id) AS sp 
WHERE sp.object_id > 100;




