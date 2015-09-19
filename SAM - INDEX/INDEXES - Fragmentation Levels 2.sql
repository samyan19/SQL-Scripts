SELECT DISTINCT i.name, ddips.index_depth, ddips.index_level
    , ddips.page_count,(ddips.page_count*8)/1024 as [Size MB], ddips.record_count, ddips.avg_fragmentation_in_percent,i.fill_factor,sp.data_compression
FROM sys.indexes AS i with (NOLOCK)
join sys.partitions as sp with (NOLOCK) ON i.object_id=sp.object_id
Join sys.dm_db_index_physical_stats(DB_ID(), 
    OBJECT_ID(N'dbo.Mart_Fact_Consumption'), Null, Null, N'Detailed') AS ddips
    ON i.OBJECT_ID = ddips.OBJECT_ID
    And i.index_id = ddips.index_id
/*WHERE i.name In ('IX_Sales_SalesOrderDetail_SpecialOfferID'
    , 'FIX_Sales_SalesOrderDetail_SpecialOfferID_Filtered'
    , 'PK_SalesOrderDetail_SalesOrderID_SalesOrderDetailID')*/
    AND ddips.index_level = 0
option (maxdop 1);