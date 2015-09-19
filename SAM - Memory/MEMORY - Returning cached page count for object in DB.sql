SELECT COUNT(*)AS cached_pages_count 
    ,name ,index_id,
	cast (count(*)*8./1024. as numeric(10,1)) as cached_mb,
	cast (100.* sum(free_space_in_bytes)/1024./1024. / 
		(count(*)*8./1024. ) as numeric(3,1)) as [free_space_%],
	sum(row_count) as total_rows,
	cast(sum(row_count)/(1.*count(*)) as numeric(10,1)) as avg_rows
FROM sys.dm_os_buffer_descriptors AS bd 
    INNER JOIN 
    (
        SELECT object_name(object_id) AS name 
            ,index_id ,allocation_unit_id
        FROM sys.allocation_units AS au
            INNER JOIN sys.partitions AS p 
                ON au.container_id = p.hobt_id 
                    AND (au.type = 1 OR au.type = 3)
        UNION ALL
        SELECT object_name(object_id) AS name   
            ,index_id, allocation_unit_id
        FROM sys.allocation_units AS au
            INNER JOIN sys.partitions AS p 
                ON au.container_id = p.partition_id 
                    AND au.type = 2
    ) AS obj 
        ON bd.allocation_unit_id = obj.allocation_unit_id
WHERE database_id = DB_ID()
GROUP BY name, index_id 
ORDER BY cached_pages_count DESC;