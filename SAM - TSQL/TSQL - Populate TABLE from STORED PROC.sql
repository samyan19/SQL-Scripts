CREATE PROC getBusinessLineHistory
AS
BEGIN
    SELECT * FROM sys.databases
END
GO

sp_configure 'Show Advanced Options', 1
GO
RECONFIGURE
GO
sp_configure 'Ad Hoc Distributed Queries', 1
GO
RECONFIGURE
GO

SELECT * INTO #MyTempTable FROM OPENROWSET('SQLNCLI', 'Server=(local)\SQL2008;Trusted_Connection=yes;',
     'EXEC getBusinessLineHistory')

SELECT * FROM #MyTempTable