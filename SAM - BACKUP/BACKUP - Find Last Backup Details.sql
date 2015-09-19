use msdb
GO

select top 20 database_name,str(backup_size/1024/1024/1024,10,2) as BackupSizeGB,str(compressed_backup_size/1024/1024/1024,10,2) as CompressedBackupSizeGB,backup_start_date, backup_finish_date, DATEDIFF ( minute , backup_start_date , backup_finish_date ) as [Duration (minutes)] ,type
from dbo.backupset
--where database_name='dbDealing' --and type='L' /*and DATEPART(HH,backup_start_date)=23*/
where database_name in(
	'EDDS1028244',
	'EDDS1031253',
	'EDDS1035346',
	'EDDS1045614'
	)
	AND type='I'
order by backup_start_date DESC
