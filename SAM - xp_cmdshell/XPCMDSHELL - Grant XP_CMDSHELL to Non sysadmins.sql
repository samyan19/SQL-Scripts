EXEC sp_xp_cmdshell_proxy_account 'DL3SQLV01\svc_SQLServerProxyDev','Proxy123'

USE [master]
GO
CREATE USER [InvestingUser] FOR LOGIN [InvestingUser]
GO

use master
GO
GRANT EXECUTE ON xp_cmdshell TO InvestingUser