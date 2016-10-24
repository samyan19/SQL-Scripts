SELECT TOP 1 *
FROM RESTOREHISTORY WITH (nolock)
WHERE (DESTINATION_DATABASE_NAME = 'raCentrica')
ORDER BY RESTORE_DATE DESC

/*
Last restore details including backup file the restore was done from 
*/


SELECT  distinct [rs].[destination_database_name] ,
        [rs].[restore_date] ,
        [bs].[backup_start_date] ,
        [bs].[backup_finish_date] ,
        [bs].[database_name] AS [source_database_name] ,
        [bmf].[physical_device_name] AS [backup_file_used_for_restore],
        rs.user_name
FROM    msdb..restorehistory rs
        INNER JOIN msdb..backupset bs ON [rs].[backup_set_id] = [bs].[backup_set_id]
        INNER JOIN msdb..backupmediafamily bmf ON [bs].[media_set_id] = [bmf].[media_set_id]
WHERE rs.destination_database_name in ('P2_Current','P2_CRMIRefData','P2_CRMIMirror')
ORDER BY [rs].[restore_date] DESC

