WITH BackupThroughput AS (
SELECT
bs.backup_finish_date AS DateCompleted
,[MB/sec] = (bs.backup_size / 1048576.0) /
CASE
WHEN DATEDIFF(SECOND, bs.backup_start_date, bs.backup_finish_date) > 0
THEN DATEDIFF(SECOND, bs.backup_start_date, bs.backup_finish_date)
ELSE 1
END
FROM msdb.dbo.backupset AS bs
INNER JOIN msdb.dbo.backupmediafamily AS bmf
ON bs.media_set_id = bmf.media_set_id
WHERE bs.type != 'L'
AND DATEDIFF(SECOND, bs.backup_start_date, bs.backup_finish_date) > 600
)
SELECT
BackupDate = MIN(DateCompleted)
,AverageThroughput = AVG([MB/sec])
FROM BackupThroughput
GROUP BY
DATEPART(YEAR,DateCompleted)
,DATEPART(MONTH,DateCompleted)
,DATEPART(DAY,DateCompleted)
ORDER BY
DATEPART(YEAR,DateCompleted)
,DATEPART(MONTH,DateCompleted)
,DATEPART(DAY,DateCompleted)