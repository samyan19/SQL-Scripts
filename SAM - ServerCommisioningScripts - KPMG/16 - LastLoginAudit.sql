/*REPLACE FILEPATH LOCATION WITH THE OUTPUT OF THE BELOW QUERY AND APPEND AUDIT\LastLoginAudit\ 
e.g.
I:\MSSQL11.ISQL01\MSSQL\Log\  +  AUDIT\LastLoginAudit\
I:\MSSQL11.ISQL01\MSSQL\Log\AUDIT\LastLoginAudit\
*/


(SELECT path FROM Sys.dm_os_server_diagnostics_log_configurations)


USE [master]
GO


CREATE SERVER AUDIT [LastLoginAudit]
TO FILE 
(	FILEPATH = <FileLocation>
	,MAXSIZE = 10 MB
	,MAX_ROLLOVER_FILES = 25
	,RESERVE_DISK_SPACE = OFF
)
WITH
(	QUEUE_DELAY = 1000
	,ON_FAILURE = CONTINUE
)

GO

ALTER SERVER AUDIT [LastLoginAudit] WITH (STATE = ON)
GO

USE [master]
GO

CREATE SERVER AUDIT SPECIFICATION [LastLoginAuditSpec]
FOR SERVER AUDIT [LastLoginAudit]
ADD (SUCCESSFUL_LOGIN_GROUP)
GO

ALTER SERVER AUDIT SPECIFICATION [LastLoginAuditSpec] WITH (STATE = ON)
GO


USE zzSQLServerAdmin
GO
INSERT INTO sec.tblLastLoginAudit_staging
SELECT  audit_file_path, audit_file_size
FROM sys.dm_server_audit_status
WHERE name = 'LastLoginAudit'