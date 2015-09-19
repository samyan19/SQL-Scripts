USE [msdb]
GO

DECLARE @Profile VARCHAR(256)
DECLARE @name sysname
DECLARE @email varchar(64)
SET @name = 'SQLInsightServices'
SET @email = 'SQLInsightServices@kpmg.co.uk'

IF (SELECT @@SERVICENAME) = 'MSSQLSERVER'
BEGIN
	SELECT @Profile = 'SQLSERVER:Memory Manager|Memory Grants Pending||>|0'	
END
ELSE
BEGIN
	SELECT @Profile = 'MSSQL$' + @@SERVICENAME + ':Memory Manager|Memory Grants Pending||>|0'
END


BEGIN TRY
EXEC msdb.dbo.sp_help_operator @name
END TRY

BEGIN CATCH
	EXEC msdb.dbo.sp_add_operator @name=@name,
			@enabled=1, 
			@weekday_pager_start_time=90000, 
			@weekday_pager_end_time=180000, 
			@saturday_pager_start_time=90000, 
			@saturday_pager_end_time=180000, 
			@sunday_pager_start_time=90000, 
			@sunday_pager_end_time=180000, 
			@pager_days=0, 
			@email_address=@email, 
			@category_name=N'[Uncategorized]'
END CATCH		


BEGIN TRY
EXEC msdb.dbo.sp_help_alert 'MemoryGrantsPending'
END TRY

BEGIN CATCH
EXEC msdb.dbo.sp_add_alert @name=N'MemoryGrantsPending', 
		@message_id=0, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=0, 
		@category_name=N'[Uncategorized]', 
		@performance_condition=@Profile, 
		@job_id=N'00000000-0000-0000-0000-000000000000'
END CATCH			



BEGIN TRY
EXEC msdb.dbo.sp_add_notification 'MemoryGrantsPending', @name, 1
END TRY

BEGIN CATCH
SELECT 1
END CATCH



BEGIN TRY
EXEC msdb.dbo.sp_help_alert 'Error Number 823'
END TRY


BEGIN CATCH
EXEC msdb.dbo.sp_add_alert @name=N'Error Number 823', 
		@message_id=823, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
END CATCH

BEGIN TRY
EXEC msdb.dbo.sp_add_notification 'Error Number 823', @name, 1
END TRY

BEGIN CATCH
SELECT 1
END CATCH



BEGIN TRY
EXEC msdb.dbo.sp_help_alert 'Error Number 824'
END TRY


BEGIN CATCH
EXEC msdb.dbo.sp_add_alert @name=N'Error Number 824', 
		@message_id=824, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
END CATCH

BEGIN TRY
EXEC msdb.dbo.sp_add_notification 'Error Number 824', @name, 1
END TRY

BEGIN CATCH
SELECT 1
END CATCH



BEGIN TRY
EXEC msdb.dbo.sp_help_alert 'Error Number 825'
END TRY


BEGIN CATCH
EXEC msdb.dbo.sp_add_alert @name=N'Error Number 825', 
		@message_id=825,
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
END CATCH

BEGIN TRY
EXEC msdb.dbo.sp_add_notification 'Error Number 825', @name, 1
END TRY

BEGIN CATCH
SELECT 1
END CATCH



/* Severity 17 error */

BEGIN TRY
EXEC msdb.dbo.sp_help_alert 'Severity 017'
END TRY


BEGIN CATCH
EXEC msdb.dbo.sp_add_alert @name=N'Severity 017', 
		@message_id=0,
		@severity=17, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
END CATCH


BEGIN TRY
EXEC msdb.dbo.sp_add_notification 'Severity 017', @name, 1
END TRY

BEGIN CATCH
SELECT 1
END CATCH


/* Severity 18 error */

BEGIN TRY
EXEC msdb.dbo.sp_help_alert 'Severity 018'
END TRY


BEGIN CATCH
EXEC msdb.dbo.sp_add_alert @name=N'Severity 018', 
		@message_id=0,
		@severity=18, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
END CATCH


BEGIN TRY
EXEC msdb.dbo.sp_add_notification 'Severity 018', @name, 1
END TRY

BEGIN CATCH
SELECT 1
END CATCH



/* Severity 19 error */

BEGIN TRY
EXEC msdb.dbo.sp_help_alert 'Severity 019'
END TRY


BEGIN CATCH
EXEC msdb.dbo.sp_add_alert @name=N'Severity 019', 
		@message_id=0,
		@severity=19, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
END CATCH


BEGIN TRY
EXEC msdb.dbo.sp_add_notification 'Severity 019', @name, 1
END TRY

BEGIN CATCH
SELECT 1
END CATCH


/* Severity 20 error */

BEGIN TRY
EXEC msdb.dbo.sp_help_alert 'Severity 020'
END TRY


BEGIN CATCH
EXEC msdb.dbo.sp_add_alert @name=N'Severity 020', 
		@message_id=0,
		@severity=20, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
END CATCH


BEGIN TRY
EXEC msdb.dbo.sp_add_notification 'Severity 020', @name, 1
END TRY

BEGIN CATCH
SELECT 1
END CATCH


/* Severity 21 error */

BEGIN TRY
EXEC msdb.dbo.sp_help_alert 'Severity 021'
END TRY


BEGIN CATCH
EXEC msdb.dbo.sp_add_alert @name=N'Severity 021', 
		@message_id=0,
		@severity=21, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
END CATCH


BEGIN TRY
EXEC msdb.dbo.sp_add_notification 'Severity 021', @name, 1
END TRY

BEGIN CATCH
SELECT 1
END CATCH


/* Severity 22 error */

BEGIN TRY
EXEC msdb.dbo.sp_help_alert 'Severity 022'
END TRY


BEGIN CATCH
EXEC msdb.dbo.sp_add_alert @name=N'Severity 022', 
		@message_id=0,
		@severity=22, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
END CATCH


BEGIN TRY
EXEC msdb.dbo.sp_add_notification 'Severity 022', @name, 1
END TRY

BEGIN CATCH
SELECT 1
END CATCH


/* Severity 23 error */

BEGIN TRY
EXEC msdb.dbo.sp_help_alert 'Severity 023'
END TRY


BEGIN CATCH
EXEC msdb.dbo.sp_add_alert @name=N'Severity 023', 
		@message_id=0,
		@severity=23, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
END CATCH


BEGIN TRY
EXEC msdb.dbo.sp_add_notification 'Severity 023', @name, 1
END TRY

BEGIN CATCH
SELECT 1
END CATCH



/* Severity 24 error */

BEGIN TRY
EXEC msdb.dbo.sp_help_alert 'Severity 024'
END TRY


BEGIN CATCH
EXEC msdb.dbo.sp_add_alert @name=N'Severity 024', 
		@message_id=0,
		@severity=24, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
END CATCH


BEGIN TRY
EXEC msdb.dbo.sp_add_notification 'Severity 024', @name, 1
END TRY

BEGIN CATCH
SELECT 1
END CATCH


/* Severity 25 error */

BEGIN TRY
EXEC msdb.dbo.sp_help_alert 'Severity 025'
END TRY


BEGIN CATCH
EXEC msdb.dbo.sp_add_alert @name=N'Severity 025', 
		@message_id=0,
		@severity=25, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
END CATCH


BEGIN TRY
EXEC msdb.dbo.sp_add_notification 'Severity 025', @name, 1
END TRY

BEGIN CATCH
SELECT 1
END CATCH


