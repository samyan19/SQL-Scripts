use tempdb;
GO
SELECT
sp.stats_id, name, last_updated, rows, rows_sampled, steps, unfiltered_rows, modification_counter
FROM sys.stats AS stat
CROSS APPLY sys.dm_db_stats_properties(stat.object_id, stat.stats_id) AS sp
WHERE stat.object_id = object_id('#temp');
GO
