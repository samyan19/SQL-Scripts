/*
Listing 6: Using sys.dm_db_index_physical_stats to monitor the number of forwarded records in a heap

Heap fragmentation
*/
SELECT  o.name ,
        ps.forwarded_record_count
FROM    sys.dm_db_index_physical_stats(DB_ID('AdventureWorks2014'), NULL, NULL,
                                       NULL, 'DETAILED') ps
        INNER JOIN sys.objects o ON o.object_id = ps.object_id
WHERE   forwarded_record_count > 0;
GO
