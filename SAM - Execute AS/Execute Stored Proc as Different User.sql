use zzSQLServerAdmin	
GO

alter proc restoredb
with execute as owner
as
SELECT SUSER_NAME() -- returns 'DynamicSQLUser'

EXECUTE AS CALLER
SELECT SUSER_NAME() -- returns actual caller of stored procedure

REVERT


SELECT SUSER_NAME() -- returns 'DynamicSQLUser'

RESTORE DATABASE [TestData2] FROM  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Backup\TestData2.bak' WITH  FILE = 1,  NOUNLOAD,  REPLACE,  STATS = 5
