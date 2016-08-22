USE [msdb]
GO
EXEC msdb.dbo.sp_update_job @job_name=N'day0_refresh_CBL_MDS_DEV', 
		@description=N'/****************************************
* Author: Samuel Yanzu
* Project: FSCS
* Desc: Job to refresh source databases
* Steps:
* 1. Restore database
* 2. Reapply permissions from script
****************************************/'
GO
