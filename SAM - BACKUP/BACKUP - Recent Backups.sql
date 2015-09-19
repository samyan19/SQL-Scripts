use msdb
GO

select top 20 database_name,str(backup_size/1024/1024/1024,10,2) as BackupSizeGB,str(compressed_backup_size/1024/1024/1024,10,2) as CompressedBackupSizeGB,backup_start_date, backup_finish_date, DATEDIFF ( minute , backup_start_date , backup_finish_date ) as [Duration (minutes)] ,type
from dbo.backupset
--where database_name='dbDealing' --and type='L' /*and DATEPART(HH,backup_start_date)=23*/
order by backup_start_date desc