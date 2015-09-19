
--not in 2005 upwards
DBCC REBUILD_LOG ('ReportServer', 'E:\MSSQLData\UserDB\ReportServer_log.ldf')

sp_helpfile


alter database reportserver set emergency

EXEC sp_attach_single_file_db @dbname = 'ReportServer', 
    @physname = N'D:\MSSQLData\UserDB\ReportServer.mdf';



USE [master]
GO
CREATE DATABASE [ReportServer] ON 
    (FILENAME = N'D:\MSSQLData\UserDB\ReportServer.mdf')
    FOR ATTACH_REBUILD_LOG
GO




sp_cycle_errorlog