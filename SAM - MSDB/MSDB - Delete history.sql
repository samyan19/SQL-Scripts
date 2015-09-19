USE msdb
GO
DECLARE @CutOffDate DATETIME
SET @CutOffDate = CONVERT(VARCHAR(10), DATEADD(dd, -30,GETDATE()), 101)
EXEC sp_delete_backuphistory @CutOffDate
GO