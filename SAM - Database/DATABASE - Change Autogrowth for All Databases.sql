--IF EXISTS(SELECT name FROM sys.sysobjects WHERE name = N'ConfigAutoGrowth' AND xtype='U')  
--    DROP TABLE ConfigAutoGrowth  
--GO    
declare @ConfigAutoGrowth TABLE (  
iDBID       INT,  
sDBName     SYSNAME,  
vFileName   VARCHAR(max),  
vGrowthOption   VARCHAR(12)  
);  

PRINT 'Table ConfigAutoGrowth Created'  
--GO  
-- Inserting data into staging table  
INSERT INTO @ConfigAutoGrowth  
SELECT   
    SD.database_id,   
    SD.name,  
    SF.name,  
    --sf.fileid,   
    --SUSER_NAME(owner_sid),  
    --recovery_model_desc,  
    CASE SF.status & 0x100000  
    WHEN 1048576 THEN 'Percentage'  
    WHEN 0 THEN 'MB'  
    END AS 'GROWTH Option'  
FROM SYS.SYSALTFILES SF  
JOIN   
SYS.DATABASES SD  
ON   
SD.database_id = SF.dbid  
--GO  
  
-- Dynamically alters the file to set auto growth option to fixed mb   
DECLARE @name VARCHAR ( max ) -- Database Name  
DECLARE @dbid INT -- DBID  
DECLARE @vFileName VARCHAR ( max ) -- Logical file name  
DECLARE @vGrowthOption VARCHAR ( max ) -- Growth option  
DECLARE @Query VARCHAR(max) -- Variable to store dynamic sql  
  
  
DECLARE db_cursor CURSOR FOR  
SELECT   
idbid,sdbname,vfilename,vgrowthoption  
FROM @ConfigAutoGrowth  
WHERE sdbname NOT IN ( 'master' ,'msdb' )   
--AND vGrowthOption  = 'Percentage' or 'Mb' 
  
OPEN db_cursor  
FETCH NEXT FROM db_cursor INTO @dbid,@name,@vfilename,@vgrowthoption    
WHILE @@FETCH_STATUS = 0  
BEGIN  
    PRINT 'Changing AutoGrowth option for database:- '+ UPPER(@name)  
    SET @Query  = 'ALTER DATABASE '+ @name +' MODIFY FILE (NAME = '+@vFileName+',FILEGROWTH = 100MB)'  
    --EXEC(@Query)  
	PRINT(@Query)  
  
FETCH NEXT FROM db_cursor INTO @dbid,@name,@vfilename,@vgrowthoption    
END  
CLOSE db_cursor -- Closing the curson  
DEALLOCATE db_cursor  -- deallocating the cursor  
  
GO  
-- Querying system views to see if the changes are applied  
  DECLARE @SQL VARCHAR(8000), @sname VARCHAR(3)
SET @SQL=' USE ?
SELECT ''?'' [Dbname]
,[name] [Filename]
,CASE is_percent_growth
WHEN 1 THEN CONVERT(VARCHAR(5),growth)+''%''
ELSE CONVERT(VARCHAR(20),(growth/128))+'' MB''
END [Autogrow_Value]
,CASE max_size
WHEN -1 THEN CASE growth
WHEN 0 THEN CONVERT(VARCHAR(30),''Restricted'')
ELSE CONVERT(VARCHAR(30),''Unlimited'') END
ELSE CONVERT(VARCHAR(25),max_size/128)
END [Max_Size]
FROM ?.sys.database_files'

IF EXISTS(SELECT 1 FROM tempdb..sysobjects WHERE name='##Fdetails')
DROP TABLE ##Fdetails
CREATE TABLE  ##Fdetails (Dbname VARCHAR(50),Filename VARCHAR(50),Autogrow_Value VARCHAR(15),Max_Size VARCHAR(30))
INSERT INTO ##Fdetails
EXEC sp_msforeachdb @SQL
SELECT * FROM ##Fdetails  ORDER BY Dbname
  
--Dropping the staging table  
--DROP TABLE ConfigAutoGrowth   
GO
