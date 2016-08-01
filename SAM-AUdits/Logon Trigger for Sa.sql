/*
http://www.sqlshack.com/creating-successful-auditing-strategy-sql-server-databases/
*/
 
 
     USE DBA;
     CREATE TABLE LogonAudit
     (
      LogonTime datetime,
      HostName varchar(50),
      ProgramName varchar(500),
      LoginName varchar(50),
      OriginalLoginName varchar(50),
      ClientHost varchar(50)
     ) ON [DBA_Data]
    GO

Now for the trigger.

CREATE TRIGGER tr_LogonTrigger
ON ALL SERVER WITH EXECUTE AS 'sa'
FOR LOGON
AS
/* 
Used with 'sa logon audit', to determine who is logging in with sa, when and from where.
Auth:  Me
Date:  7/28/2016  
*/
BEGIN
    DECLARE
@LogonTriggerData xml,
       @EventTime datetime,
       @LoginName varchar(50),
       @ClientHost varchar(50),
       @LoginType varchar(50),
       @HostName varchar(50),
       @AppName varchar(500)

  SET @LogonTriggerData = eventdata()
  SET @EventTime = @LogonTriggerData.value('(/EVENT_INSTANCE/PostTime)[1]', 'datetime')
  SET @LoginName = @LogonTriggerData.value('(/EVENT_INSTANCE/LoginName)[1]', 'varchar(50)')
  SET @ClientHost = @LogonTriggerData.value('(/EVENT_INSTANCE/ClientHost)[1]', 'varchar(50)')
  SET @HostName = HOST_NAME()
  SET @AppName = APP_NAME()

  --- Add condition to log only succesful sa logins
  IF((ORIGINAL_LOGIN() = 'sa'))
  INSERT INTO DBA..LogonAudit (
       LogonTime,HostName,ProgramName,LoginName,OriginalLoginName,ClientHost )
  SELECT
       @EventTime,
       @HostName,
       @AppName,
       @LoginName,
       ORIGINAL_LOGIN(),
       @ClientHost
END

GO
