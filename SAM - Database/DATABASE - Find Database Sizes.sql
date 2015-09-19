/* Size includes logs */

select @@servername, 
a.name, 
a.compatibility_level,
b.database_id [database_id],
SUM(((size*8)/1024)) [Size_MB] 
FROM sys.databases a,sys.master_files b
where a.database_id=b.database_id
group by a.name,a.compatibility_level
,b.database_id