
/* 
	SQL Server 2008 & above only - is auditing enabled?  If so, it might be
	writing to an audit path that will fill up, or the server might be set to
	stop if the file path isn't available.  Let's see if there's any audits.
	
	For a video explaining the SQL Server auditing options, check out:
	http://sqlserverpedia.com/blog/sql-server-2008/guest-podcast-auditing-your-database-server/
*/
SELECT * FROM sys.dm_server_audit_status