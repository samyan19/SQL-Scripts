USE msdb ;
GO

EXEC dbo.sp_update_alert
  @name = N'Test Alert',
  @enabled = 0 ;
GO