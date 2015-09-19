SELECT
    COUNT (*) * 8 / 1024 AS MBUsed, 
    SUM (CONVERT (BIGINT, free_space_in_bytes)) / (1024 * 1024) AS MBEmpty
FROM sys.dm_os_buffer_descriptors;
GO


/*
http://www.sqlskills.com/blogs/paul/performance-issues-from-wasted-buffer-pool-memory/
databases where we are caching free space

*/
SELECT
    (CASE WHEN ([database_id] = 32767)
        THEN N'Resource Database'
        ELSE DB_NAME ([database_id]) END) AS [DatabaseName],
    COUNT (*) * 8 / 1024 AS [MBUsed],
    SUM (CAST ([free_space_in_bytes] AS BIGINT)) / (1024 * 1024) AS [MBEmpty]
FROM sys.dm_os_buffer_descriptors
GROUP BY [database_id];
GO

/*
For all databases in buffer pool
*/
EXEC sp_MSforeachdb
    N'IF EXISTS (SELECT 1 FROM (SELECT DISTINCT DB_NAME ([database_id]) AS [name]
    FROM sys.dm_os_buffer_descriptors) AS names WHERE [name] = ''?'')
BEGIN
USE [?]
SELECT
    ''?'' AS [Database],
    OBJECT_NAME (p.[object_id]) AS [Object],
    p.[index_id],
    i.[name] AS [Index],
    i.[type_desc] AS [Type],
    --au.[type_desc] AS [AUType],
    --DPCount AS [DirtyPageCount],
    --CPCount AS [CleanPageCount],
    --DPCount * 8 / 1024 AS [DirtyPageMB],
    --CPCount * 8 / 1024 AS [CleanPageMB],
    (DPCount + CPCount) * 8 / 1024 AS [TotalMB],
    --DPFreeSpace / 1024 / 1024 AS [DirtyPageFreeSpace],
    --CPFreeSpace / 1024 / 1024 AS [CleanPageFreeSpace],
    ([DPFreeSpace] + [CPFreeSpace]) / 1024 / 1024 AS [FreeSpaceMB],
    CAST (ROUND (100.0 * (([DPFreeSpace] + [CPFreeSpace]) / 1024) / (([DPCount] + [CPCount]) * 8), 1) AS DECIMAL (4, 1)) AS [FreeSpacePC]
FROM
    (SELECT
        allocation_unit_id,
        SUM (CASE WHEN ([is_modified] = 1)
            THEN 1 ELSE 0 END) AS [DPCount],
        SUM (CASE WHEN ([is_modified] = 1)
            THEN 0 ELSE 1 END) AS [CPCount],
        SUM (CASE WHEN ([is_modified] = 1)
            THEN CAST ([free_space_in_bytes] AS BIGINT) ELSE 0 END) AS [DPFreeSpace],
        SUM (CASE WHEN ([is_modified] = 1)
            THEN 0 ELSE CAST ([free_space_in_bytes] AS BIGINT) END) AS [CPFreeSpace]
    FROM sys.dm_os_buffer_descriptors
    WHERE [database_id] = DB_ID (''?'')
    GROUP BY [allocation_unit_id]) AS buffers
INNER JOIN sys.allocation_units AS au
    ON au.[allocation_unit_id] = buffers.[allocation_unit_id]
INNER JOIN sys.partitions AS p
    ON au.[container_id] = p.[partition_id]
INNER JOIN sys.indexes AS i
    ON i.[index_id] = p.[index_id] AND p.[object_id] = i.[object_id]
WHERE p.[object_id] > 100 AND ([DPCount] + [CPCount]) > 12800 -- Taking up more than 100MB
ORDER BY [FreeSpacePC] DESC;
END';