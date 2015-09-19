/*
SELECT	bac.database_name as SourceDatabase, res.destination_database_name as DestinationDatabase,
	    bac.[user_name] as SourceBackupUser,res.[user_name] as DestinationRestoreUser, 
        bac.backup_finish_date as SourceBackupDate, res.restore_date as DestinationRestoreDate, 
        bac.server_name as SourceServer, @@servername as DestinationServer
FROM	msdb..restorehistory res
JOIN msdb..backupset bac
ON res.backup_set_id = bac.backup_set_id
WHERE res.destination_database_name LIKE ('%bi%')
ORDER BY res.restore_date desc


SELECT d.name, MAX(b.backup_finish_date) AS last_backup_finish_date,b.backup_size/1024/1024/1024 as [Gigabytes Size]
FROM master.sys.databases d
LEFT OUTER JOIN msdb.dbo.backupset b ON d.name = b.database_name AND b.type = 'D'
WHERE d.database_id NOT IN (2, 3) and d.name LIKE 'LTB%' -- Bonus points if you know what that means
GROUP BY d.name,b.backup_size
ORDER BY 2 DESC
*/


select type,database_name,str(backup_size/1024/1024/1024,10,2) as BackupSizeGB,str(compressed_backup_size/1024/1024/1024,10,2) as CompressedBackupSizeGB,backup_start_date, backup_finish_date, DATEDIFF ( minute , backup_start_date , backup_finish_date ) as [Duration (minutes)] from dbo.backupset
--where type='D' /*and DATEPART(HH,backup_start_date)=23*/
order by backup_start_date desc