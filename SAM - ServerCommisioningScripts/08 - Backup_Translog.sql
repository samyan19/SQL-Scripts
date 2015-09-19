USE [msdb]
GO
/*SET THE FOLLOWING VARIABLES*/
DECLARE @InstanceValue char(2) = 'P1'  /*EITHER P1 OR P2*/




/*OTHER DECLARTIONS AND SETTINGS*/
DECLARE @NewJobName varchar(128)
DECLARE @NewCommand1 varchar(1024)
DECLARE @NewCommand2 varchar(1024)
DECLARE @NewOutput_file_name varchar(1024)
DECLARE @BackupDirectory varchar(1024) = (SELECT value FROM ZZSQLSERVERADMIN.DBO.TBLCONFIGS WHERE NAME = 'Tlog_BackupLocation') 
DECLARE @DeleteBackupsPS1Location varchar(1024) = (SELECT value FROM ZZSQLSERVERADMIN.DBO.TBLCONFIGS WHERE NAME = 'Powershell_Location')
SET @NewJobName = @InstanceValue + '_Backup_Translog'
SET @NewCommand1=N'powershell -executionpolicy RemoteSigned -File "' + @DeleteBackupsPS1Location  + 'DeleteBackups.ps1" -numDays 2 -BackupDir "' + @BackupDirectory + '\*" -FileExtensionToDelete trn'
SET @NewOutput_file_name = @DeleteBackupsPS1Location + 'DeleteLogBackups.txt'
SET	@NewCommand2=N'USE zzSQLServerAdmin
GO
EXEC spBackupLogs @BackupPath = ''' + @BackupDirectory + ''''

/****** Object:  Job [P2_Backup_Translog]    Script Date: 09/09/2013 11:08:12 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [DBAMaintenance]    Script Date: 09/09/2013 11:08:12 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'DBAMaintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'DBAMaintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name= @NewJobName, 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Backup logs Hourly Age and Delete', 
		@category_name=N'DBAMaintenance', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'SQLInsightServices', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [P2_1.0 Backup Logs]    Script Date: 09/09/2013 11:08:12 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup Logs', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command= @NewCommand2,  
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [P2_2.0 Log_Age and Delete Old Logs]    Script Date: 09/09/2013 11:08:12 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Log_Age and Delete Old Logs', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'CmdExec', 
		@command= @NewCommand1, 
		@output_file_name= @NewOutput_file_name, 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'QuarterHour', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=15, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20130619, 
		@active_end_date=99991231, 
		@active_start_time=40000, 
		@active_end_time=220000
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


