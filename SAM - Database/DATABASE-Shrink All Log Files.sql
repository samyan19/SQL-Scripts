select 'use '+QUOTENAME(db_name(database_id)) +'; dbcc shrinkfile('''+name+''');'
from sys.master_files
where type_desc='LOG' and database_id not in (1,2,3,4)
                                                                
EXEC sp_msforeachdb 'if DB_ID(''?'')<4 return; alter database [?] set recovery simple; use [?]; checkpoint; dbcc shrinkfile(2);'
                                
EXEC sp_msforeachdb 'dbcc shrinkfile(2);'
