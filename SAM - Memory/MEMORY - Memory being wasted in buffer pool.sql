SELECT
    COUNT (*) * 8 / 1024 AS MBUsed, 
    SUM (CONVERT (BIGINT, free_space_in_bytes)) / (1024 * 1024) AS MBEmpty
FROM sys.dm_os_buffer_descriptors;
GO