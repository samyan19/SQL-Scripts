/* http://www.sanjaykumar.us/index.php/start-stop-sql-agent-service-using-tsql-commands/ */

--CHeck status
EXECUTE xp_servicecontrol 'querystate', 'MSSQLServerOlapService'

-- Start
EXEC xp_servicecontrol N'START',N'SQLServerAGENT'
GO
 
-- STOP 
EXEC xp_servicecontrol N'STOP',N'SQLServerAGENT'
GO
