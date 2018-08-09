
select 'use '+QUOTENAME(db_name(database_id)) +'; dbcc shrinkfile('''+name+''',100);'
from sys.master_files
where type_desc='ROWS' and database_id not in (1,2,3,4)
and DB_NAME(database_id) like '%_2'
