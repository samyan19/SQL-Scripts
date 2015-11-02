SELECT  
DB_NAME(p.dbid) as DBName,  
loginame as LoginName, 
status,
p.hostname,
p.program_name,
t.text,
p.last_batch,
p.spid
--COUNT(p.dbid) as NumberOfConnections
FROM 
    sys.sysprocesses p
cross APPLY sys.dm_exec_sql_text(sql_handle) t
WHERE  p.dbid > 0 
AND DB_NAME(p.dbid)='RTP_NOUGAT_CMT_UAT01'
--GROUP BY  p.dbid, loginame, status,hostname,program_name,t.text,p.last_batch
order by DBName;
