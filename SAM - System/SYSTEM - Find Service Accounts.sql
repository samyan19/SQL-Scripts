DECLARE       @DBEngineLogin       VARCHAR(100)
DECLARE       @AgentLogin          VARCHAR(100)
 
EXECUTE       master.dbo.xp_instance_regread
              @rootkey      = N'HKEY_LOCAL_MACHINE',
              @key          = N'SYSTEM\CurrentControlSet\Services\MSSQLServer',
              @value_name   = N'ObjectName',
              @value        = @DBEngineLogin OUTPUT
 
EXECUTE       master.dbo.xp_instance_regread
              @rootkey      = N'HKEY_LOCAL_MACHINE',
              @key          = N'SYSTEM\CurrentControlSet\Services\SQLServerAgent',
              @value_name   = N'ObjectName',
              @value        = @AgentLogin OUTPUT
 
SELECT        [DBEngineLogin] = @DBEngineLogin, [AgentLogin] = @AgentLogin
GO

/*
Result Set:

DBEngineLogin        AgentLogin
.\Administrator      NT AUTHORITY\NETWORKSERVICE
 
(1 row(s) affected)

We can use same registry for default and named instances as xp_instance_regread returns instance specific registry.

With SQL Server 2008 R2 SP1 and above a new server related DMV sys.dm_server_services is available which returns information of all instance services. This view also returns additional information about each of services such as startup type, status, current process id, physical executable name. We can also query service account name using this DMV:
*/

SELECT servicename, service_account
FROM   sys.dm_server_services
GO