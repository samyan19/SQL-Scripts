-- Volume info for all databases on the current instance (SQL Server 2008 R2 SP1 or greater)  (Query 17) (Volume Info)
SELECT DISTINCT vs.volume_mount_point, vs.file_system_type, 
vs.logical_volume_name, CONVERT(DECIMAL(18,2),vs.total_bytes/1073741824.0) AS total_size_gb,
CONVERT(DECIMAL(18,2),vs.available_bytes/1073741824.0) AS available_size_gb,  
CAST(CAST(vs.available_bytes AS FLOAT)/ CAST(vs.total_bytes AS FLOAT) AS DECIMAL(18,2)) * 100 AS [space_free_percentage] 
FROM sys.master_files AS f WITH (NOLOCK)
CROSS APPLY sys.dm_os_volume_stats(f.database_id, f.[file_id]) AS vs OPTION (RECOMPILE);
