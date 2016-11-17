DECLARE @name VARCHAR(256) -- database name  
DECLARE @path VARCHAR(256) -- path for backup files  
DECLARE @fileName VARCHAR(256) -- filename for backup  
DECLARE @fileDate VARCHAR(256) -- used for file name
DECLARE @Now DATETIME = CURRENT_TIMESTAMP
--Use smalldatetime if you do not want seconds
 
-- specify database backup directory
SET @path = '\\pdc1bkp001\CCT_Backups\'+@@SERVERNAME+'\'  
-- Create backup path
exec xp_create_subdir @path
 
-- specify filename format
--SELECT @fileDate = CONVERT(VARCHAR(20),GETDATE(),112) 
SELECT @fileDate=REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(32),@Now,120), '-',''), ' ','_'),':','')
 
DECLARE db_cursor CURSOR FOR  
--SELECT name 
--FROM master.dbo.sysdatabases 
--WHERE name NOT IN ('master','model','msdb','tempdb')  -- exclude these databases
SELECT name 
FROM master.dbo.sysdatabases 
WHERE name not in ('tempdb')
 
OPEN db_cursor   
FETCH NEXT FROM db_cursor INTO @name   
 
WHILE @@FETCH_STATUS = 0   
BEGIN   
       SET @fileName = @path + @name + '_' + @fileDate + '.BAK'  
       BACKUP DATABASE @name TO DISK = @fileName WITH COMPRESSION, STATS=10, COPY_ONLY, CHECKSUM 
 
       FETCH NEXT FROM db_cursor INTO @name   
END   
 
CLOSE db_cursor   
DEALLOCATE db_cursor
