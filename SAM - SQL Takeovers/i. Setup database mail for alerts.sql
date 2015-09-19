/*
	Then go into Management, Resource Governor - that's another landmine.


	Now as long as we're in the SSMS GUI, let's set up Database Mail.  It's
	possible to script that out, but I like the GUI for that since I often use
	wildly different parameters for different clients or departments.

	Once Database Mail is set up, the below script will test it.

*/
EXEC msdb.dbo.sp_send_dbmail
    @recipients = 'email@domain.com',
    @body = @@SERVERNAME,
    @subject = 'Testing SQL Server Database Mail - see body for server name';
GO





/*
	After enabling Database Mail, the below script sets up a default set of
	notifications for problems.  In this section, replace these strings:
	- 'dba.alerts' - your name goes here
	- 'YourEmailAddress@Hotmail.com' - your email
	- '8005551212@cingularme.com' - your phone/pager's email address
*/


USE [msdb]
GO
EXEC msdb.dbo.sp_add_operator @name=N'dba.alerts', 
		@enabled=1, 
		@weekday_pager_start_time=0, 
		@weekday_pager_end_time=235959, 
		@saturday_pager_start_time=0, 
		@saturday_pager_end_time=235959, 
		@sunday_pager_start_time=0, 
		@sunday_pager_end_time=235959, 
		@pager_days=0, 
		@email_address=N'dg_db.alerts@bestinvest.co.uk', 
		@category_name=N'[Uncategorized]'
GO
EXEC msdb.dbo.sp_add_alert @name=N'Severity 016', 
		@message_id=0, 
		@severity=16, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 016', @operator_name=N'dba.alerts', @notification_method = 7
GO
EXEC msdb.dbo.sp_add_alert @name=N'Severity 017', 
		@message_id=0, 
		@severity=17, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 017', @operator_name=N'dba.alerts', @notification_method = 7
GO
EXEC msdb.dbo.sp_add_alert @name=N'Severity 018', 
		@message_id=0, 
		@severity=18, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 018', @operator_name=N'dba.alerts', @notification_method = 7
GO
EXEC msdb.dbo.sp_add_alert @name=N'Severity 019', 
		@message_id=0, 
		@severity=19, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 019', @operator_name=N'dba.alerts', @notification_method = 7
GO
EXEC msdb.dbo.sp_add_alert @name=N'Severity 020', 
		@message_id=0, 
		@severity=20, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 020', @operator_name=N'dba.alerts', @notification_method = 7
GO
EXEC msdb.dbo.sp_add_alert @name=N'Severity 021', 
		@message_id=0, 
		@severity=21, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 021', @operator_name=N'dba.alerts', @notification_method = 7
GO
EXEC msdb.dbo.sp_add_alert @name=N'Severity 022', 
		@message_id=0, 
		@severity=22, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 022', @operator_name=N'dba.alerts', @notification_method = 7
GO
EXEC msdb.dbo.sp_add_alert @name=N'Severity 023', 
		@message_id=0, 
		@severity=23, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 023', @operator_name=N'dba.alerts', @notification_method = 7
GO
EXEC msdb.dbo.sp_add_alert @name=N'Severity 024', 
		@message_id=0, 
		@severity=24, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 024', @operator_name=N'dba.alerts', @notification_method = 7
GO
EXEC msdb.dbo.sp_add_alert @name=N'Severity 025', 
		@message_id=0, 
		@severity=25, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 025', @operator_name=N'dba.alerts', @notification_method = 7
GO

/* Specific Alert for Error 825 
http://www.sqlskills.com/BLOGS/PAUL/post/A-little-known-sign-of-impending-doom-error-825.aspx
*/
EXEC msdb.dbo.sp_add_alert @name=N'Error 825', 
		@message_id=825, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Error 825', @operator_name=N'dba.alerts', @notification_method = 7
GO

EXEC msdb.dbo.sp_add_alert @name=N'Error 823', 
		@message_id=823, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Error 823', @operator_name=N'dba.alerts', @notification_method = 7
GO


EXEC msdb.dbo.sp_add_alert @name=N'Error 824', 
		@message_id=824, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Error 824', @operator_name=N'dba.alerts', @notification_method = 7
GO


EXEC msdb.dbo.sp_add_alert @name=N'Error 832', 
		@message_id=832, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Error 832', @operator_name=N'dba.alerts', @notification_method = 7
GO
