/*
https://www.mssqltips.com/sqlservertip/3541/grant-user-access-to-all-sql-server-databases/
*/

Use master
GO

DECLARE @dbname VARCHAR(50)   
DECLARE @statement NVARCHAR(max)

DECLARE db_cursor CURSOR 
LOCAL FAST_FORWARD
FOR  
SELECT name
FROM master.dbo.sysdatabases
WHERE name NOT IN ('master','model','msdb','tempdb','distribution') 
 
OPEN db_cursor  
FETCH NEXT FROM db_cursor INTO @dbname  
WHILE @@FETCH_STATUS = 0  
BEGIN  

SELECT @statement = 'use '+@dbname +';'+ 'CREATE USER [CLOSEBROTHERSGP\ROLE-U-PCCE-PRD-3rdPartysupport] 
FOR LOGIN [CLOSEBROTHERSGP\ROLE-U-PCCE-PRD-3rdPartysupport];EXEC sp_addrolemember N''db_datareader'', 
[CLOSEBROTHERSGP\ROLE-U-PCCE-PRD-3rdPartysupport];'

exec sp_executesql @statement

FETCH NEXT FROM db_cursor INTO @dbname  
END  
CLOSE db_cursor  
DEALLOCATE db_cursor 
