;WITH cache AS (
SELECT 
    DB_NAME(database_id) AS [Database Name]
    ,CAST(COUNT(*) * 8/1024.0 AS DECIMAL (10,2))  AS [Cached Size (MB)]
FROM sys.dm_os_buffer_descriptors WITH (NOLOCK)
WHERE database_id not in (1,3,4) -- system databases
AND database_id <> 32767 -- ResourceDB
GROUP BY DB_NAME(database_id)
)
SELECT c.*,
		CAST(mf.size * 8/1024 AS DECIMAL (10,2)) AS [Size (MB)],
		mf.physical_name AS 'Physical Name'
FROM sys.master_files mf
JOIN cache c ON DB_NAME(mf.database_id) = c.[Database Name]
WHERE mf.type_desc='ROWS'
ORDER BY [Cached Size (MB)] desc