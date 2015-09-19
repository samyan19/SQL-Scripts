USE master
GO

CREATE PROCEDURE DBO.spMasterLastServiceRestart
AS 
WAITFOR DELAY '00:02:00'

EXEC zzSQLServerAdmin.dbo.spLastServiceRestartTime
GO

EXEC sp_configure 'scan for startup procs', '1';
RECONFIGURE
GO

EXEC sp_procoption N'spMasterLastServiceRestart', 'startup', 'on'
GO
