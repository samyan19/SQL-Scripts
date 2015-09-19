; WITH a AS (SELECT
bs.database_name AS DBName
,bs.backup_start_date AS DateStarted
,bs.backup_finish_date AS DateCompleted
,Duration =
DATEDIFF(SECOND, bs.backup_start_date, bs.backup_finish_date)
,bs.backup_size / 1048576.0 AS DataSizeMB
,[MB/sec] = (bs.backup_size / 1048576.0) /
CASE
WHEN DATEDIFF(SECOND, bs.backup_start_date, bs.backup_finish_date) > 0
THEN DATEDIFF(SECOND, bs.backup_start_date, bs.backup_finish_date)
ELSE 1
END
,bmf.physical_device_name AS BackupFile
FROM msdb.dbo.backupset AS bs
INNER JOIN msdb.dbo.backupmediafamily AS bmf
ON bs.media_set_id = bmf.media_set_id
WHERE bs.type != 'L'
AND DATEDIFF(SECOND, bs.backup_start_date, bs.backup_finish_date) > 600
)
SELECT * 
FROM a 
WHERE DBName='KTrace_Unilever_US_2014_20141124032630'
ORDER BY DateStarted DESC;
--ORDER BY [MB/sec] DESC;