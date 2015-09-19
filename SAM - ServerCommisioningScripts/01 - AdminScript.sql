BEGIN TRY
	EXEC msdb.dbo.sp_help_category @name = 'DBAMaintenance'
END TRY

BEGIN CATCH
EXEC msdb.dbo.sp_add_category 
		@class = 'JOB',
		@type = 'LOCAL',
		@name = 'DBAMaintenance'
END CATCH	