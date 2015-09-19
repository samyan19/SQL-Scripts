SELECT login_name,status,COUNT(*) 
FROM sys.dm_exec_sessions
group BY login_name,status
--where login_name='svc_WWWWebsite'
