USE [msdb]
GO

/****** Object:  Alert [Backup Failure - 18204]    Script Date: 07/01/2014 11:32:30 ******/
EXEC msdb.dbo.sp_add_alert @name=N'Backup Failure - 18204', 
		@message_id=18204, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=43200, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [Backup Failure - 18210]    Script Date: 07/01/2014 11:32:30 ******/
EXEC msdb.dbo.sp_add_alert @name=N'Backup Failure - 18210', 
		@message_id=18210, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=43200, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [Backup Failure - 3009]    Script Date: 07/01/2014 11:32:30 ******/
EXEC msdb.dbo.sp_add_alert @name=N'Backup Failure - 3009', 
		@message_id=3009, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=43200, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [Backup Failure - 3013]    Script Date: 07/01/2014 11:32:30 ******/
EXEC msdb.dbo.sp_add_alert @name=N'Backup Failure - 3013', 
		@message_id=3013, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=43200, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [Backup Failure - 3017]    Script Date: 07/01/2014 11:32:30 ******/
EXEC msdb.dbo.sp_add_alert @name=N'Backup Failure - 3017', 
		@message_id=3017, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=43200, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [Backup Failure - 3033]    Script Date: 07/01/2014 11:32:30 ******/
EXEC msdb.dbo.sp_add_alert @name=N'Backup Failure - 3033', 
		@message_id=3033, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=43200, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [Backup Failure - 3201]    Script Date: 07/01/2014 11:32:30 ******/
EXEC msdb.dbo.sp_add_alert @name=N'Backup Failure - 3201', 
		@message_id=3201, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=43200, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [Backup Success - 18264]    Script Date: 07/01/2014 11:32:31 ******/
EXEC msdb.dbo.sp_add_alert @name=N'Backup Success - 18264', 
		@message_id=18264, 
		@severity=0, 
		@enabled=0, 
		@delay_between_responses=43200, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [Error Number 823]    Script Date: 07/01/2014 11:32:31 ******/
EXEC msdb.dbo.sp_add_alert @name=N'Error Number 823', 
		@message_id=823, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [Error Number 824]    Script Date: 07/01/2014 11:32:31 ******/
EXEC msdb.dbo.sp_add_alert @name=N'Error Number 824', 
		@message_id=824, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [Error Number 825]    Script Date: 07/01/2014 11:32:31 ******/
EXEC msdb.dbo.sp_add_alert @name=N'Error Number 825', 
		@message_id=825, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [MemoryGrantsPending]    Script Date: 07/01/2014 11:32:31 ******/
EXEC msdb.dbo.sp_add_alert @name=N'MemoryGrantsPending', 
		@message_id=0, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=0, 
		@category_name=N'[Uncategorized]', 
		@performance_condition=N'SQLServer:Memory Manager|Memory Grants Pending||>|0', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [Restore Success - 18267]    Script Date: 07/01/2014 11:32:31 ******/
EXEC msdb.dbo.sp_add_alert @name=N'Restore Success - 18267', 
		@message_id=18267, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=43200, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [Restore Success - 18268]    Script Date: 07/01/2014 11:32:31 ******/
EXEC msdb.dbo.sp_add_alert @name=N'Restore Success - 18268', 
		@message_id=18268, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=43200, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [Restore Success - 18269]    Script Date: 07/01/2014 11:32:31 ******/
EXEC msdb.dbo.sp_add_alert @name=N'Restore Success - 18269', 
		@message_id=18269, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=43200, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [Restore Success - 3142]    Script Date: 07/01/2014 11:32:31 ******/
EXEC msdb.dbo.sp_add_alert @name=N'Restore Success - 3142', 
		@message_id=3142, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=43200, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [Restore Success - 3145]    Script Date: 07/01/2014 11:32:31 ******/
EXEC msdb.dbo.sp_add_alert @name=N'Restore Success - 3145', 
		@message_id=3145, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=43200, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [Restore Success - 3401]    Script Date: 07/01/2014 11:32:31 ******/
EXEC msdb.dbo.sp_add_alert @name=N'Restore Success - 3401', 
		@message_id=3401, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=43200, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [Restore Success - 3441]    Script Date: 07/01/2014 11:32:31 ******/
EXEC msdb.dbo.sp_add_alert @name=N'Restore Success - 3441', 
		@message_id=3441, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=43200, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [Restore Success - 3443]    Script Date: 07/01/2014 11:32:31 ******/
EXEC msdb.dbo.sp_add_alert @name=N'Restore Success - 3443', 
		@message_id=3443, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=43200, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [Severity 017]    Script Date: 07/01/2014 11:32:31 ******/
EXEC msdb.dbo.sp_add_alert @name=N'Severity 017', 
		@message_id=0, 
		@severity=17, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [Severity 018]    Script Date: 07/01/2014 11:32:31 ******/
EXEC msdb.dbo.sp_add_alert @name=N'Severity 018', 
		@message_id=0, 
		@severity=18, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [Severity 019]    Script Date: 07/01/2014 11:32:31 ******/
EXEC msdb.dbo.sp_add_alert @name=N'Severity 019', 
		@message_id=0, 
		@severity=19, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [Severity 020]    Script Date: 07/01/2014 11:32:31 ******/
EXEC msdb.dbo.sp_add_alert @name=N'Severity 020', 
		@message_id=0, 
		@severity=20, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [Severity 021]    Script Date: 07/01/2014 11:32:31 ******/
EXEC msdb.dbo.sp_add_alert @name=N'Severity 021', 
		@message_id=0, 
		@severity=21, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [Severity 022]    Script Date: 07/01/2014 11:32:31 ******/
EXEC msdb.dbo.sp_add_alert @name=N'Severity 022', 
		@message_id=0, 
		@severity=22, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [Severity 023]    Script Date: 07/01/2014 11:32:31 ******/
EXEC msdb.dbo.sp_add_alert @name=N'Severity 023', 
		@message_id=0, 
		@severity=23, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [Severity 024]    Script Date: 07/01/2014 11:32:31 ******/
EXEC msdb.dbo.sp_add_alert @name=N'Severity 024', 
		@message_id=0, 
		@severity=24, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [Severity 025]    Script Date: 07/01/2014 11:32:31 ******/
EXEC msdb.dbo.sp_add_alert @name=N'Severity 025', 
		@message_id=0, 
		@severity=25, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [TEMPDB_SizeLimit]    Script Date: 07/01/2014 11:32:31 ******/
EXEC msdb.dbo.sp_add_alert @name=N'TEMPDB_SizeLimit', 
		@message_id=0, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=120, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@performance_condition=N'SQLServer:Databases|Data File(s) Size (KB)|tempdb|>|120886080', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO


