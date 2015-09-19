USE [master]
GO
ALTER DATABASE EDDS1035346 SET  SINGLE_USER WITH ROLLBACK IMMEDIATE
GO
USE [master]
GO
EXEC master.dbo.sp_detach_db @dbname = N'EDDS1035346'
	--/*uncomment to add statistics update*/ , @skipchecks = 'false'
GO
