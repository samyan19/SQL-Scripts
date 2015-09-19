
--(SELECT path FROM Sys.dm_os_server_diagnostics_log_configurations)
/* RUN ABOVE QUERY TO FIND THE <FileLocation> AND REPLACE IN THE ***TWO*** PLACES IN NEEDS TO GO*/


INSERT INTO dbo.tblConfigs (Value, Name)
VALUES('<FileLocation>\Audit\ServerRoles\','ServerRoleAuditLocation')

USE [master]
GO

CREATE SERVER AUDIT [ServerRolesAudit]
TO FILE 
(	FILEPATH = N'<FileLocation>\Audit\ServerRoles'
	,MAXSIZE = 10 MB
	,MAX_ROLLOVER_FILES = 5
	,RESERVE_DISK_SPACE = OFF
)
WITH
(	QUEUE_DELAY = 1000
	,ON_FAILURE = CONTINUE
)

GO

ALTER SERVER AUDIT ServerRolesAudit WITH (STATE = ON)
GO

USE [master]
GO

CREATE SERVER AUDIT SPECIFICATION [ServerRoleAuditSpec]
FOR SERVER AUDIT [ServerRolesAudit]
ADD (SERVER_ROLE_MEMBER_CHANGE_GROUP)
GO

ALTER SERVER AUDIT SPECIFICATION ServerRoleAuditSpec WITH (STATE = ON)
GO