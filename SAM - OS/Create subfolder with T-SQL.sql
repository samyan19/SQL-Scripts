/*

https://www.mssqltips.com/sqlservertip/1460/sql-server-script-to-create-windows-directories/
*/

DECLARE @name VARCHAR(50) -- database name  
DECLARE @path VARCHAR(256) -- path for backup files  
DECLARE @fileName VARCHAR(256) -- filename for backup  
DECLARE @fileDate VARCHAR(20) -- used for file name
 
-- specify database backup directory
SET @path = '\\pdc2bkp001\Treasury_DR\'+@@SERVERNAME  

exec xp_create_subdir @path
