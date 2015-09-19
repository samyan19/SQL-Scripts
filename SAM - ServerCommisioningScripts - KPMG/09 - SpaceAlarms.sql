USE [msdb]
GO
/*SET THE FOLLOWING VARIABLES*/
DECLARE @InstanceValue char(2) = 'P1'  /*EITHER P1 OR P2*/


/*OTHER DECLARTIONS AND SETTINGS*/
DECLARE @NewJobName varchar(128)
DECLARE @NewCommand1 varchar(1024)
DECLARE @NewOutput_file_name varchar(1024)
DECLARE @DriveStatsPS1Location varchar(1024) = (SELECT value FROM ZZSQLSERVERADMIN.DBO.TBLCONFIGS WHERE NAME = 'Powershell_Location') + 'DriveStats\'
SET @NewJobName = @InstanceValue + '_SpaceAlarms'
SET @NewCommand1=N'powershell -executionpolicy RemoteSigned -File "' + @DriveStatsPS1Location + '\DriveStats.ps1" -ComputerName ' + @@SERVERNAME + ' -InstanceName ' + @@SERVERNAME + ''
SET @NewOutput_file_name = @DriveStatsPS1Location + '\DriveStatsLog.txt'





/****** Object:  Job [P2_SpaceAlarms]    Script Date: 13/12/2013 14:36:52 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [DBAMaintenance]    Script Date: 13/12/2013 14:36:52 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'DBAMaintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'DBAMaintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=@NewJobName, 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'DBAMaintenance', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Find DriveStats using PS]    Script Date: 13/12/2013 14:36:52 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Find DriveStats using PS', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'CmdExec', 
		@command=@NewCommand1,
		@output_file_name=@NewOutput_file_name,
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Send Email]    Script Date: 13/12/2013 14:36:52 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Send Email', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF EXISTS (SELECT 1 FROM zzSQLServerAdmin.dbo.tblDriveStats WHERE [PercentFreeNow] < PercentFreeWarning)
BEGIN
	
	
	DECLARE @subject varchar(500)
	DECLARE @ProfileName VARCHAR(128) = (SELECT [Value] FROM [zzSQLServerAdmin].[dbo].[tblConfigs]  WHERE Name = ''profile_name'' AND  [ProcedureName] = ''spSendDBMail'')
	DECLARE @To VARCHAR(128) = (SELECT [Value]  FROM [zzSQLServerAdmin].[dbo].[tblConfigs]  WHERE Name = ''recipients'' AND  [ProcedureName] = ''spSendDBMail'')
	SET @subject = ''Low Disk Space Notification on '' + @@ServerName


DECLARE @body_format varchar(20) = ''HTML''
DECLARE @body NVARCHAR(MAX) =
   N''<head>'' +
    N''<style type="text/css">h2, body {font-family: Arial, verdana;} table{font-size:11px; border-collapse:collapse;} td{background-color:#F1F1F1; border:1px solid black; padding:3px;} th{background-color:#99CCFF;}</style>'' +
   N''<h2><font color="#0000ff" size="4">Low Disk Space Notification</font></h2>'' +   
   N''</head>'' +
   N''<p>'' + ''  '' + ''</p>''+
N''<body>'' +
N'' <hr> '' +
N''<h1><font color="#0000ff" size="2">The following disks have hit the threshold:</font></h1>'' + 
N'' '' +
    N''<table border="1">'' +
    N''<tr><th>DriveLetter</th><th>TotalSizeMB</th><th>FreeSpaceMB</th><th>PercentFreeNow</th><th>VolumeName</th><th>Threshold</th></tr>''
     +
        CAST ( ( SELECT td = DriveLetter,       '''',
                    td = replace(convert(varchar,convert(money,TotalSizeMB),1),''.00'',''''), '''',
					td = replace(convert(varchar,convert(money,FreeSpaceMB),1),''.00'',''''), '''',
					td = cast(PercentFreeNow as varchar(8)) + ''%'', '''',
					td = VolumeName, '''',
					td = CASE 
						WHEN PercentFreeNow > percentfreecrit THEN cast(percentfreewarning as VARCHAR(8)) + ''% - (Warning)''
						WHEN PercentFreeNow < percentfreecrit THEN cast(percentfreecrit as VARCHAR(8)) + ''% - (CRITICAL)''
						END, ''''
			      FROM zzSQLServerAdmin.dbo.tblDriveStats
			  WHERE [PercentFreeNow] < PercentFreeWarning
              FOR XML PATH(''tr''), TYPE 
    ) AS NVARCHAR(MAX) ) +
    N''</table>'' +
		   N'' <br></br>'' +
	   N''<p>'' + ''   '' + ''</p>''+
	   N''  <hr> '' +

	N''<h1><font color="#0000ff" size="2">In order for you to judge the overall health, I have included a full list of the disk for comparison:</font></h1>'' + 
N'' '' +
    N''<table border="1">'' +
    N''<tr><th>DriveLetter</th><th>TotalSizeMB</th><th>FreeSpaceMB</th><th>PercentFreeNow</th><th>VolumeName</th></tr>''
     +
        CAST ( ( SELECT td = DriveLetter,       '''',
                    td = replace(convert(varchar,convert(money,TotalSizeMB),1),''.00'',''''), '''',
					td = replace(convert(varchar,convert(money,FreeSpaceMB),1),''.00'',''''), '''',
					td = cast(PercentFreeNow as varchar(8)) + ''%'', '''',
					td = VolumeName, ''''
			      FROM zzSQLServerAdmin.dbo.tblDriveStats
              FOR XML PATH(''tr''), TYPE 
    ) AS NVARCHAR(MAX) ) +
    N''</table>'' +
    N''</body>'' ;


	EXEC zzSQLServerAdmin.dbo.spSendDBMail
	@profile_name = @ProfileName 
	,@recipients = @To 
	,@subject = @subject 
	,@body = @body 
	,@body_format = @body_format
END', 
		@database_name=N'zzSQLServerAdmin', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'P2_Daily_0100', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20111123, 
		@active_end_date=99991231, 
		@active_start_time=10000, 
		@active_end_time=235959, 
		@schedule_uid=N'41dfffc1-0904-4305-8ba8-ae6d1f66db19'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


