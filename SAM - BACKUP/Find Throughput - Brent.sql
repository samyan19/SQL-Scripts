SELECT  @@SERVERNAME AS ServerName ,
        YEAR(backup_finish_date) AS backup_year ,
        MONTH(backup_finish_date) AS backup_month ,
        CAST(AVG(( backup_size / ( DATEDIFF(ss, bset.backup_start_date,
                                            bset.backup_finish_date) )
                   / 1048576 )) AS INT) AS throughput_MB_sec_avg ,
        CAST(MIN(( backup_size / ( DATEDIFF(ss, bset.backup_start_date,
                                            bset.backup_finish_date) )
                   / 1048576 )) AS INT) AS throughput_MB_sec_min ,
        CAST(MAX(( backup_size / ( DATEDIFF(ss, bset.backup_start_date,
                                            bset.backup_finish_date) )
                   / 1048576 )) AS INT) AS throughput_MB_sec_max
FROM    msdb.dbo.backupset bset
WHERE   bset.type = 'D' /* full backups only */
        AND bset.backup_size > 5368709120 /* 5GB or larger */
        AND DATEDIFF(ss, bset.backup_start_date, bset.backup_finish_date) > 1 /* backups lasting over a second */
GROUP BY YEAR(backup_finish_date) ,
        MONTH(backup_finish_date)
ORDER BY @@SERVERNAME ,
        YEAR(backup_finish_date) DESC ,
        MONTH(backup_finish_date) DESC