
/*
	Index fragmentation is the leading cause of DBA heartburn. It's a lot like
	file fragmentation, but it happens inside of the database.  The below script
	shows fragmented objects that might be a concern.
	
	This is an IO-intensive operation, so start by running it in a small database.
	To run it for all databases, go to the line with this:
	
	INNER JOIN sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL , NULL, N'Limited') ps
	
	and replace it with:
	
	INNER JOIN sys.dm_db_index_physical_stats (NULL, NULL, NULL , NULL, N'Limited') ps	
	
	But be careful - that can run VERY long on large database systems, like hours.
	For more about index fragmentation, check out this page with a video:
	http://sqlserverpedia.com/wiki/Index_Maintenance
*/
SELECT
      db.name AS databaseName
    , SCHEMA_NAME(obj.schema_id) AS schemaName
    , OBJECT_NAME(ps.OBJECT_ID) AS tableName
    , ps.OBJECT_ID AS objectID
    , ps.index_id AS indexID
    , ps.partition_number AS partitionNumber
    , ps.avg_fragmentation_in_percent AS fragmentation
    , ps.page_count
FROM sys.databases db
  INNER JOIN sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL , NULL, N'Limited') ps
      ON db.database_id = ps.database_id
  INNER JOIN sys.objects obj ON ps.object_id = obj.object_id
WHERE ps.index_id > 0 
   AND ps.page_count > 100 
   AND ps.avg_fragmentation_in_percent > 30
ORDER BY databaseName, schemaName, tableName
OPTION (MaxDop 1);