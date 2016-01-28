/*list all server roles*/
EXEC sp_helpsrvrole

/*Quick list of members of server role*/
EXEC sp_helpsrvrolemember 'sysadmin';

/*To query*/
USE master
GO
 
SELECT  p.name AS [loginname] ,
        p.type ,
        p.type_desc ,
        p.is_disabled,
        CONVERT(VARCHAR(10),p.create_date ,101) AS [created],
        CONVERT(VARCHAR(10),p.modify_date , 101) AS [update]
FROM    sys.server_principals p
        JOIN sys.syslogins s ON p.sid = s.sid
WHERE   p.type_desc IN ('SQL_LOGIN', 'WINDOWS_LOGIN', 'WINDOWS_GROUP')
        -- Logins that are not process logins
        AND p.name NOT LIKE '##%' and p.name like '%Admin%'
        -- Logins that are sysadmins
        AND s.sysadmin = 1;
        
        
        
  
