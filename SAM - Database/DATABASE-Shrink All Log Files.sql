select 'use '+db_name(database_id) +'; dbcc shrinkfile('+name+');'
from sys.master_files
where type_desc='LOG' and database_id not in (1,2,3,4)
