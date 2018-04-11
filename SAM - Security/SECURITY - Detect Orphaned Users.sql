/*
https://docs.microsoft.com/en-us/sql/sql-server/failover-clusters/troubleshoot-orphaned-users-sql-server
*/
SELECT dp.type_desc, dp.SID, dp.name AS user_name,authentication_type_desc
FROM sys.database_principals AS dp  
LEFT JOIN sys.server_principals AS sp  
    ON dp.SID = sp.SID  
WHERE sp.SID IS NULL  
    AND authentication_type_desc in ('INSTANCE','WINDOWS')
	AND dp.name <>'dbo';  
