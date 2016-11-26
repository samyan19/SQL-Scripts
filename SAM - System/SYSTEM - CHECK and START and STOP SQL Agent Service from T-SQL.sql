/* https://www.mssqltips.com/sqlservertip/2036/monitor-start-and-stop-sql-server-services-using-xpservicecontrol/ */

--See below example to check the status of SQL Services
EXEC xp_servicecontrol N'querystate',N'MSSQLServer'
EXEC xp_servicecontrol N'querystate',N'SQLServerAGENT'
EXEC xp_servicecontrol N'querystate',N'msdtc'
EXEC xp_servicecontrol N'querystate',N'sqlbrowser'
EXEC xp_servicecontrol N'querystate',N'MSSQLServerOLAPService'
EXEC xp_servicecontrol N'querystate',N'ReportServer'
--See below example to start/stop service using SSMS
EXEC xp_servicecontrol N'stop',N'SQLServerAGENT'
EXEC xp_servicecontrol N'start',N'SQLServerAGENT'
--See below example to check non-SQL Service
EXEC xp_servicecontrol querystate, DHCPServer
