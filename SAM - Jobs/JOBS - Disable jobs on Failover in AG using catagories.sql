USE [msdb]
GO

/****** Object:  Job [DBA:SSRS_CHANGE_JOBS_STATUS]    Script Date: 20/11/2024 17:01:40 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 20/11/2024 17:01:41 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA:SSRS_CHANGE_JOBS_STATUS', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Enable COMPASS jobs on primary node only', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'prfSQL_ERRORLOG_ALERTS', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [monitor jobs status]    Script Date: 20/11/2024 17:01:42 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'monitor jobs status', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @is_primary			smallint
DECLARE @sql				varchar(max)
DECLARE @job_name			VARCHAR(100)


------------------------------------------------------------------------------------------

SELECT @is_primary = (SELECT sys.fn_hadr_is_primary_replica (''ReportServer''))

------------------------------------------------------------------------------------------

-- Cursor for all SSRS jobs
DECLARE csr_Jobs_Names CURSOR
FOR 
SELECT [sJOB].name
FROM msdb.dbo.sysjobs AS [sJOB] 
LEFT JOIN [msdb].[dbo].[syscategories] AS [sCAT]
ON [sJOB].[category_id] = [sCAT].[category_id]
WHERE [sCAT].name = ''Report Server''
AND [sJOB].enabled <> @is_primary
ORDER BY name


OPEN csr_Jobs_Names
FETCH NEXT FROM csr_Jobs_Names INTO @job_name 

WHILE (@@FETCH_STATUS <> -1)    -- Do for each job
BEGIN 
	SELECT @sql =  ''EXEC msdb.dbo.sp_update_job @job_name='' + '''''''' + @job_name + '''''''' + '',@enabled = '' + cast(@is_primary as varchar)
	EXEC (@sql)
	--PRINT @sql

	FETCH NEXT FROM csr_Jobs_Names INTO @job_name 
END

CLOSE csr_Jobs_Names
DEALLOCATE csr_Jobs_Names
SET NOCOUNT OFF

------------------------------------------------------------------------------------------', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'monitor jobs status', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20210514, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959--, 
		--@schedule_uid=N'df9212bd-7105-4c83-88c4-e552d55b9288'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


