/*
https://msdn.microsoft.com/en-us/library/hh204542.aspx

2008 R2 SP1 +

Limited the SQL, Agent and Full-Text

*/


SELECT servicename, service_account
FROM   sys.dm_server_services
GO
