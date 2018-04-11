/*
https://docs.microsoft.com/en-us/sql/sql-server/failover-clusters/troubleshoot-orphaned-users-sql-server
SINGLE DATABASE
*/
SELECT dp.type_desc, dp.SID, dp.name AS user_name,authentication_type_desc
FROM sys.database_principals AS dp  
LEFT JOIN sys.server_principals AS sp  
    ON dp.SID = sp.SID  
WHERE sp.SID IS NULL  
    AND authentication_type_desc in ('INSTANCE','WINDOWS')
	AND dp.name <>'dbo';  


/*

ALL DATABASES
*/

CREATE TABLE ##ORPHANUSER 
( 
DBNAME VARCHAR(100), 
USERNAME VARCHAR(100), 
CREATEDATE VARCHAR(100), 
USERTYPE VARCHAR(100) 
) 
 
EXEC SP_MSFOREACHDB' USE [?] 
INSERT INTO ##ORPHANUSER 
SELECT DB_NAME() DBNAME, NAME,CREATEDATE, 
(CASE  
WHEN ISNTGROUP = 0 AND ISNTUSER = 0 THEN ''SQL LOGIN'' 
WHEN ISNTGROUP = 1 THEN ''NT GROUP'' 
WHEN ISNTGROUP = 0 AND ISNTUSER = 1 THEN ''NT LOGIN'' 
END) [LOGIN TYPE] FROM sys.sysusers 
WHERE SID IS NOT NULL AND SID <> 0X0 AND ISLOGIN =1 AND 
SID NOT IN (SELECT SID FROM sys.syslogins) AND NAME <>''dbo''' 
 
SELECT * FROM ##ORPHANUSER 
 
DROP TABLE ##ORPHANUSER 
