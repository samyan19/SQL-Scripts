sp_configure 'Database Mail XPs',1
RECONFIGURE
GO

DECLARE @profile_name sysname  ,
		@profile_description NVARCHAR(256),
        @account_name sysname,
		@account_description NVARCHAR(256),
        @SMTP_servername sysname,
        @email_address NVARCHAR(128),
        @replyto_address NVARCHAR(128),
	    @display_name NVARCHAR(128),
		@subject_name VARCHAR(128),
		@version VARCHAR(10);

-- Profile name. 
        SET @profile_name = 'Ghost_' + (SELECT CAST(SERVERPROPERTY('MachineName') AS VARCHAR(128)));
		SET @profile_description = N'Database Mail profile for ' + (SELECT CAST(SERVERPROPERTY('MachineName') AS NVARCHAR(128)));

-- Account information. 

		SET @account_name = N'Ghost_' + (SELECT CAST(SERVERPROPERTY('MachineName') AS NVARCHAR(128)));
		SET @account_description = N'Database Mail account for ' + (SELECT CAST(SERVERPROPERTY('MachineName') AS NVARCHAR(128)));
		SET @SMTP_servername = N'rcstsmtp03';
		SET @email_address = N'Ghost_' + (SELECT CAST(SERVERPROPERTY('MachineName') AS VARCHAR(128))) + '@forensicfdc.com';
        SET @display_name = N'Ghost_' + (SELECT CAST(SERVERPROPERTY('MachineName') AS VARCHAR(128)));
        SET @replyto_address = N'noreply@forensicfdc.com';

-- Verify the specified account and profile do not already exist.
IF EXISTS (SELECT * FROM msdb.dbo.sysmail_profile WHERE name = @profile_name)
BEGIN
  RAISERROR('The specified Database Mail profile already exists.', 10, 1);
  GOTO done;
END;

IF EXISTS (SELECT * FROM msdb.dbo.sysmail_account WHERE name = @account_name )
BEGIN
 RAISERROR('The specified Database Mail account already exists.', 10, 1) ;
 GOTO done;
END;

-- Start a transaction before adding the account and the profile
BEGIN TRANSACTION ;

DECLARE @rv INT;

-- Add the account
EXECUTE @rv=msdb.dbo.sysmail_add_account_sp
    @account_name = @account_name,
    @description = @account_description,
    @email_address = @email_address,
    @display_name = @display_name,
    @mailserver_name = @SMTP_servername,
    @replyto_address = @replyto_address;
    
	
IF @rv<>0
BEGIN
    RAISERROR('Failed to create the specified Database Mail account.', 10, 1) ;
    GOTO done;
END

-- Add the profile
EXECUTE @rv=msdb.dbo.sysmail_add_profile_sp
    @profile_name = @profile_name,
	@description = @profile_description ;

IF @rv<>0
BEGIN
    RAISERROR('Failed to create the specified Database Mail profile.', 10, 1);
	ROLLBACK TRANSACTION;
    GOTO done;
END;

-- Associate the account with the profile.
EXECUTE @rv=msdb.dbo.sysmail_add_profileaccount_sp
    @profile_name = @profile_name,
    @account_name = @account_name,
    @sequence_number = 1 ;

IF @rv<>0
BEGIN
    RAISERROR('Failed to associate the speficied profile with the specified account.', 10, 1) ;
	ROLLBACK TRANSACTION;
    GOTO done;
END;

COMMIT TRANSACTION;


SET @version = (SELECT case when @@MICROSOFTVERSION / 0x01000000 = '11' then '2012' 
			when @@MICROSOFTVERSION / 0x01000000 like '10%' then '2008'
			when @@MICROSOFTVERSION / 0x01000000 like '9%' then '2005'  end)

SET @subject_name = 'SQL Server '  + @version COLLATE LATIN1_GENERAL_CI_AS + ' mail setup'

exec msdb..sp_send_dbmail
@profile_name = @profile_name,
@recipients = N'ukfmsqlis@KPMG.co.uk',
@subject = @subject_name,
@body = 'This is a test mail and can be ignored'

done:

;
GO

USE [msdb]
GO

DECLARE @profile_name NVARCHAR(128)
SET @profile_name = 'Ghost_' + (SELECT CAST(SERVERPROPERTY('MachineName') AS VARCHAR(128)))

EXEC master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent', N'DatabaseMailProfile', N'REG_SZ', @profile_name
GO

