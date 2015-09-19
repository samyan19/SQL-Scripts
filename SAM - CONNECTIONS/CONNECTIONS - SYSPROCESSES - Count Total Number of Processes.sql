SELECT  
DB_NAME(dbid) as DBName,  
loginame as LoginName, 
status,
hostname,
COUNT(dbid) as NumberOfConnections

FROM 
    sys.sysprocesses 
WHERE  dbid > 0 
--AND DB_NAME(dbid)='UmbracoWWW'
GROUP BY  dbid, loginame, status,hostname 
order by DBName;



--SELECT * from sys.sysprocesses


--==================
--Including SQL text
--===================
SELECT  
DB_NAME(p.dbid) as DBName,  
loginame as LoginName, 
status,
p.hostname,
p.program_name,
t.text,
p.last_batch,
COUNT(p.dbid) as NumberOfConnections
FROM 
    sys.sysprocesses p
cross APPLY sys.dm_exec_sql_text(sql_handle) t
WHERE  p.dbid > 0 
AND DB_NAME(p.dbid)='RSUPDESK'
GROUP BY  p.dbid, loginame, status,hostname,program_name,t.text,p.last_batch
order by DBName;