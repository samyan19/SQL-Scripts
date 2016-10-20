
select b1.database_name, DATEDIFF ( minute , b1.backup_start_date , b1.backup_finish_date ) as [Duration (minutes)],b1.backup_start_date,b1.backup_finish_date
FROM msdb.dbo.backupset  b1
join 
(
SELECT  database_name, MAX(backup_finish_date) AS last_backup_finish_date,max(backup_set_id) as last_backup_set_id
FROM msdb.dbo.backupset b
join msdb.sys.databases d on d.name= b.database_name
WHERE database_name <> 'tempdb' and type = 'D'
GROUP BY database_name) b2 on b1.backup_set_id=b2.last_backup_set_id
order by 1
