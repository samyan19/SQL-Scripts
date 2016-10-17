/*
* Original is commented out. I have amended the code to specify the physical_device_name

SELECT  d.name, MAX(b.backup_finish_date) AS last_backup_finish_date
FROM    master.sys.databases d WITH (NOLOCK)
LEFT OUTER JOIN msdb.dbo.backupset b WITH (NOLOCK) ON d.name = b.database_name AND b.type = 'D'
WHERE d.name <> 'tempdb'
GROUP BY d.name
ORDER BY 2
*/

SELECT distinct a.name, a.last_backup_finish_date,bmf.physical_device_name
from msdb.dbo.backupmediafamily bmf 
join 
(
SELECT  d.name, MAX(b.backup_finish_date) AS last_backup_finish_date, MAX(b.media_set_id) as last_media_set_id
FROM    master.sys.databases d WITH (NOLOCK)
LEFT OUTER JOIN msdb.dbo.backupset b WITH (NOLOCK) ON d.name = b.database_name AND b.type = 'D'
WHERE d.name <> 'tempdb'
/*Uncomment below for last networker backup*/
--and b.user_name='NT AUTHORITY\SYSTEM'
GROUP BY d.name
) a on bmf.media_set_id=a.last_media_set_id
order by 1
