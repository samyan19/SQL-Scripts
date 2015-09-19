SELECT i.name, ddips.index_depth, ddips.index_level
    , (ddips.page_count*8)/1024 as [Size (mb)], ddips.record_count
FROM sys.indexes AS i
Join sys.dm_db_index_physical_stats(DB_ID(), 
    OBJECT_ID(N'dbo.WH_DimContract'), Null, Null, N'Detailed') AS ddips
    ON i.OBJECT_ID = ddips.OBJECT_ID
    And i.index_id = ddips.index_id
WHERE i.name In ('pk_WH_Contract')
    AND ddips.index_level = 0;