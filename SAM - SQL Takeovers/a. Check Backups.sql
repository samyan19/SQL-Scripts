/* 
   Backups!  First and foremost, before we touch anything, check backups.
   Check when each database has been backed up.  If databases aren't being
   backed up, check the maintenance plans or scripts.  If you don't have
   scripts, check http://ola.hallengren.com.
*/

/*
SELECT d.name, MAX(b.backup_finish_date) AS last_backup_finish_date,max(b.media_set_id),m.physical_device_name
FROM master.sys.databases d
LEFT OUTER JOIN msdb.dbo.backupset b ON d.name = b.database_name AND b.type = 'D'
join msdb.dbo.backupmediafamily m on b.media_set_id=m.media_set_id
WHERE d.database_id NOT IN (2, 3)  -- Bonus points if you know what that means
GROUP BY d.name, m.physical_device_name
ORDER BY 2 desc
*/

SELECT d.name, MAX(b.backup_finish_date) AS last_backup_finish_date
FROM master.sys.databases d
LEFT OUTER JOIN msdb.dbo.backupset b ON d.name = b.database_name AND b.type = 'D'
WHERE d.database_id NOT IN (2, 3)  -- Bonus points if you know what that means
GROUP BY d.name
ORDER BY 2 desc





/*
	Where are the backups going?  Ideally, we want them on a different server.
	If the backups are being taken to this same server, and the server's RAID
	card or motherboard goes bad, we're in trouble.  We sort by media_set_id
	descending because it's the primary key on the table, so it'll fly even
	when MSDB is on really slow drives.
	
	For more information about where your backups should go, check out:
	http://www.brentozar.com/sql/backup-best-practices/
*/
SELECT physical_device_name, * FROM msdb.dbo.backupmediafamily ORDER BY media_set_id DESC







/*
   Transaction log backups - do we have any databases in full recovery mode
   that haven't had t-log backups?  If so, we should think about putting it in
   simple recovery mode or doing t-log backups.
*/

SELECT d.name, d.recovery_model, d.recovery_model_desc
FROM master.sys.databases d
LEFT OUTER JOIN msdb.dbo.backupset b ON d.name = b.database_name AND b.type = 'L'
WHERE d.recovery_model IN (1, 2) AND b.type IS NULL AND d.database_id NOT IN (2, 3)







/* 
   Is the MSDB backup history cleaned up? If you have data older than a couple
   of months, this is a problem.  You need to set up backup cleanup jobs.  
   
   For more information on why this can be a problem?
   http://www.brentozar.com/archive/2009/09/checking-your-msdb-cleanup-jobs/
*/
SELECT TOP 1 backup_start_date, *
FROM msdb.dbo.backupset
ORDER BY backup_set_id ASC




/*purge jobhistory job*/


declare	@DaystoRetain int=30
 
DECLARE @Cutoff INT
SET @Cutoff = CONVERT(varchar, GETDATE() - @DaystoRetain, 112) --convert to YYYYMMDD then implicit CAST to INT on assignment
 
SET ROWCOUNT 100 --limit DELETEs
WHILE ( EXISTS(SELECT NULL FROM msdb.dbo.sysjobhistory WHERE run_date < @Cutoff) )
BEGIN
	PRINT 'delete sysjobhistory'
	DELETE FROM msdb.dbo.sysjobhistory WHERE run_date < @Cutoff
	WAITFOR DELAY '00:00:30'
END
 
--SET ROWCOUNT 0 --remove limit

