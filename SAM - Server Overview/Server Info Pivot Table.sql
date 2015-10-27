DECLARE @clusNodes VARCHAR(MAX)
SELECT @clusNodes = COALESCE(@clusNodes+',' ,'') + NodeName
FROM sys.dm_os_cluster_nodes;

--exec xp_msver


--select RIGHT(@@version, LEN(@@version)- 3 -charindex (' ON ', @@VERSION))

;with cte as(
select 
@@SERVERNAME as sql_instance_name,
serverproperty('isclustered') as 'is_clustered',
case when serverproperty('isclustered')=1
	then @clusNodes
	else null end as 'cluster_nodes',
virtual_machine_type_desc,
SERVERPROPERTY('productversion') as product_version,
SERVERPROPERTY('edition') as edition,
SERVERPROPERTY('productlevel') as product_level,
cpu_count,
physical_memory_in_bytes/1024/1024 as memory,
RIGHT(SUBSTRING(@@VERSION, 
CHARINDEX('Windows NT', @@VERSION), 14), 3) as windows_version
FROM sys.dm_os_sys_info
)
select 
db_name(database_id) as db_name,
type_desc,
(size*8)/1024 as size_mb,
cte.*
from sys.master_files, cte







