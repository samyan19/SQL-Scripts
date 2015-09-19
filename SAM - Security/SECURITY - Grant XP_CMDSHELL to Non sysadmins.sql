EXEC sp_xp_cmdshell_proxy_account 'UL3SQLV01\SQLUATProxy','Proxy123'

use master
GO
GRANT EXECUTE ON xp_cmdshell TO WebsiteUser