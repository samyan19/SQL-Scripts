DECLARE @name VARCHAR(256) -- database name  
DECLARE @path VARCHAR(256) -- path for backup files  
DECLARE @fileName VARCHAR(256) -- filename for backup  
DECLARE @fileDate VARCHAR(20) -- used for file name
 
-- specify database backup directory
SET @path = '\\pdc2bkp001\Treasury_DR\'+@@SERVERNAME+'\'  

-- Create backup path
exec xp_create_subdir @path
 
-- specify filename format
SELECT @fileDate = CONVERT(VARCHAR(20),GETDATE(),112) 
 
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
