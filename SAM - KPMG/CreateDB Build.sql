USE [zzSQLServerAdminModel]
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetDefaultPath]    Script Date: 14/05/2014 13:49:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnGetDefaultPath]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
CREATE FUNCTION [dbo].[fnGetDefaultPath](@log int)
RETURNS nvarchar(260)
----------------------------------------------------------------------------------------------------
-- Object Name			: fnGetDefaultPath
-- Author				: Harris, Neil
-- Date                 : 20120303
-- Inputs               : 
--							@log bit - Returnm Log or data path, 0=Data; 1= Log 
-- Outputs				: None
-- RETURN CODES			: 
--		0 - success
-- Callers				: None
-- Dependencies			: master.dbo.xp_regread
--
-- Description          : 
-- Execution Example (optional)  : 
/*
  DECLARE @log INT
  SET  @log = 0 -- Return Default Data Path from registry
  
  SELECT DefaultDB.dbo.fnGetDefaultPath(@log) 
  SET  @log = 1 -- Return Default LogPath from registry
  SELECT DefaultDB.dbo.fnGetDefaultPath(@log) 
  
  SET  @log = 2 -- Return Default LogPath from registry
  SELECT DefaultDB.dbo.fnGetDefaultPath(@log) 
 
*/
----------------------------------------------------------------------------------------------------



-- 


AS
BEGIN
  DECLARE @instance_name nvarchar(200), @system_instance_name nvarchar(200), @registry_key nvarchar(512), @path nvarchar(260), @value_name nvarchar(20);

  SET @instance_name = COALESCE(convert(nvarchar(20), serverproperty(''InstanceName'')), ''MSSQLSERVER'');

  -- sql 2005/2008 with instance
  EXEC master.dbo.xp_regread N''HKEY_LOCAL_MACHINE'', N''Software\Microsoft\Microsoft SQL Server\Instance Names\SQL'', @instance_name, @system_instance_name output;
  SET @registry_key = N''Software\Microsoft\Microsoft SQL Server\'' + @system_instance_name + ''\MSSQLServer'';


	
	
  SET @value_name = N''DefaultData''
  IF @log = 1
   BEGIN
    SET @value_name = N''DefaultLog'';
   END
  IF @log = 2
   BEGIN
    SET @value_name = N''BackupDirectory'';
   END
   
   
  EXEC master.dbo.xp_regread N''HKEY_LOCAL_MACHINE'', @registry_key, @value_name, @path output;

  IF @log = 0 AND @path is null -- sql 2005/2008 default instance
   BEGIN
    SET @registry_key = N''Software\Microsoft\Microsoft SQL Server\'' + @system_instance_name + ''\Setup'';
    EXEC master.dbo.xp_regread N''HKEY_LOCAL_MACHINE'', @registry_key, N''SQLDataRoot'', @path output;
    SET @path = @path + ''\Data'';
   END

  IF @path IS NULL -- sql 2000 with instance
   BEGIN
    SET @registry_key = N''Software\Microsoft\Microsoft SQL Server\'' + @instance_name + ''\MSSQLServer'';
    EXEC master.dbo.xp_regread N''HKEY_LOCAL_MACHINE'', @registry_key, @value_name, @path output;
   END

  IF @path IS NULL -- sql 2000 default instance
   BEGIN
    SET @registry_key = N''Software\Microsoft\MSSQLServer\MSSQLServer'';
    EXEC master.dbo.xp_regread N''HKEY_LOCAL_MACHINE'', @registry_key, @value_name, @path output;
   END

  IF @log = 1 AND @path is null -- fetch the default data path instead.
   BEGIN
    SELECT @path = dbo.fnGetDefaultPath(0)
   END

  RETURN @path;
END


' 
END

GO
/****** Object:  Table [dbo].[tblMasterDBList]    Script Date: 14/05/2014 13:49:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblMasterDBList]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[tblMasterDBList](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [sysname] NOT NULL,
	[DBID] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[StateDesc] [nvarchar](60) NOT NULL,
	[TotalSizeKB] [int] NOT NULL,
	[KPMGDepartment] [nvarchar](200) NULL,
	[KPMGProject] [nvarchar](255) NULL,
	[KPMGProjectType] [nvarchar](255) NULL,
	[KPMGApplication] [nvarchar](255) NULL,
	[KPMGOwner] [nvarchar](255) NULL,
	[KPMGProjectManager] [nvarchar](255) NULL,
	[KPMGProjectPartner] [nvarchar](255) NULL,
	[KPMGPurpose] [nvarchar](200) NULL,
	[KPMGCBCode] [nvarchar](200) NULL,
	[KPMGOwnerEmail] [nvarchar](200) NULL,
	[KPMGManagerEmail] [nvarchar](200) NULL,
	[KPMGCreatedBy] [nvarchar](100) NULL,
	[KPMGStatus] [varchar](20) NULL,
	[KPMGStatusDate] [datetime] NULL,
	[KPMGStatusBy] [nvarchar](100) NULL,
	[RecordLastUpdated] [datetime] NOT NULL,
	[KPMGInitialTemplate] [varchar](255) NULL,
	[KPMGInitialTemplateVersion] [varchar](10) NULL,
	[KPMGFirstAddedBy] [nvarchar](100) NULL,
	[KPMGFirstAddedDate] [datetime] NULL,
	[KPMGBulkInsertAccount] [varchar](100) NULL,
	[KPMGBulkInsertPassword] [varchar](100) NULL,
	[KPMGInitialRestoreFile] [nvarchar](1000) NULL,
	[KPMGWarmStorageBackup] [nvarchar](1000) NULL,
	[KPMGColdStorageTapeNo] [varchar](10) NULL,
 CONSTRAINT [PK_tblMasterDBList] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_tblMasterDBList] UNIQUE NONCLUSTERED 
(
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO

/****** Object:  StoredProcedure [dbo].[spEmailDatabaseCreate]    Script Date: 14/05/2014 13:49:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEmailDatabaseCreate]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spEmailDatabaseCreate] AS' 
END
GO
ALTER PROCEDURE [dbo].[spEmailDatabaseCreate] 
	@dbName as VARCHAR(200)
AS
----------------------------------------------------------------------------------------------------
-- Object Name			: dbo.spEmailDatabaseCreate
-- Author				: Harris, Neil
-- Date                 : 2012-03-30
-- Inputs               : 
-- Outputs				: None
-- RETURN CODES			: 
--		0 - success
-- Callers				: Procedures Calling this Procedure
-- Dependencies			: Procedures Called By this Procedure
--
-- Description          : Send an email to the Database owners Informing them that the Databses have been Created

-- Execution Example (optional)  : 
/*
	DECLARE @rc tinyint
	EXEC @rc = dbo.spEmailDatabaseCreate 'DefaultDB'
	PRINT @rc
*/
----------------------------------------------------------------------------------------------------
DECLARE @subject varchar(500)
DECLARE @body varchar(MAX)
DECLARE @eBody varchar(MAX)
SELECT 
	@subject = @@SERVERNAME + ': Database Created'
	,@eBody =
'Hello

The Following Database has been created as on the server ' + @@Servername + ' per your Request:

<EmailOutput>

Best Regards

The Ghost in the Machine'


DECLARE @Server VARCHAR(200)
DECLARE @CreateDate VARCHAR(200)
DECLARE @Prj VARCHAR(200)
DECLARE @CBC VARCHAR(200)
DECLARE @Sz VARCHAR(200)
DECLARE @Dept VARCHAR(200)
DECLARE @Ownr VARCHAR(200)
DECLARE @Mgr VARCHAR(200)
DECLARE @Ptr VARCHAR(200)
DECLARE @MgrE VARCHAR(200)
DECLARE @OwnrE VARCHAR(200)
DECLARE @P VARCHAR(200)
DECLARE @To VARCHAR(2000)
SELECT
	@Server = @@SERVERNAME
	,@CreateDate = CONVERT( varchar(200),CreateDate,113) 
	,@Prj = KPMGProject
	,@CBC = KPMGCBCode
	,@sz = TotalSizeKB
	,@Dept = KPMGDepartment
	,@OwnrE = KPMGOwner
	,@mgr = KPMGProjectManager
	,@ptr = KPMGProjectPartner
	,@p = KPMGPurpose
	,@MgrE = KPMGManagerEmail
	,@OwnrE = KPMGOwnerEmail
FROM 
	.tblMasterDBList
WHERE 
	name = @dbname

DECLARE @tbl as Table (
	id int identity(1,1) PRIMARY KEY
	,Property VARCHAR(200)
	,Value VARCHAR(200)
	)
	
INSERT INTO 
	@tbl(Property, Value)
VALUES
	('Server: ', @Server) 
	,('Database Name: ', @dbName) 
	,('Create Date: ', @CreateDate)
	,('Total Size (kb):', @sz)
	,('Project: ', @Prj)
	,('CB Code: ', @CBC)
	,('Owner: ', @Ownr)
	,('Manager: ', @Mgr)
	,('Purpose: ', @P)

DECLARE @i INT
DECLARE @iMax INT

SELECT 
	@i = 1
	,@iMax = MAX(ID)
FROM 
	@tbl

DECLARE @EmailOutput nvarchar(max)
DECLARE @linebreak char(4)

SELECT 
	@EmailOutput = ''
	,@linebreak = CHAR(10) + CHAR(13)
			
WHILE @i <= @iMax
BEGIN 
	SELECT @EmailOutput = @EmailOutput + @linebreak + '- ' + Property + CHAR(9) + CHAR(9) + COALESCE(Value,'')
	FROM @tbl 
	WHERE ID = @i
	SET @i = @i + 1 
END

SELECT 
	@body = REPLACE(@ebody,'<EmailOutput>',COALESCE(@EmailOutput,'Error'))
	,@To = COALESCE(@MgrE,'') + '; ' + COALESCE(@OwnrE,'')


	exec msdb..sp_send_dbmail 
		@recipients = @to
		, @copy_recipients = 'neil.harris@kpmg.co.uk; Ronan.Sapun@kpmg.co.uk'
		, @subject = @subject
		, @body = @body
		, @profile_name = 'Ghost_RCSTSQL56'

SELECT	@To,@subject,@body
			


GO
/****** Object:  StoredProcedure [dbo].[spInsertMasterDBList]    Script Date: 14/05/2014 13:49:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spInsertMasterDBList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spInsertMasterDBList] AS' 
END
GO
ALTER PROCEDURE [dbo].[spInsertMasterDBList]
	@UserName NVARCHAR(80) = NULL
AS
/*
----------------------------------------------------------------------------------------------------
 Object Name			: dbo.spInsertMasterDBList
 Author					: Harris, Neil
 Date					: 2012-05-04
 Inputs					: 
 Outputs				: None
 RETURN CODES			: 
		0 - success
 Callers				: SQL Agent Job
 Dependencies			: 
		[dbo].spUpdateMasterDBExtendedProperties 
 Description			: 
	Collect details on all attached databases not currently included in the table tbglMasterDBList
 Execution Example (optional) 
	DECLARE @RC int
	DECLARE @UserName nvarchar(80)
	SELECT @UserName = SYSTEM_USER
	
EXECUTE @RC = [dbo].[spInsertMasterDBList] 
   @UserName


GO


----------------------------------------------------------------------------------------------------
*/
/*	
	SELECT * FROM sys.databases db  
	SELECT * FROM master..sysprocesses
	SELECT * FROM sys.master_files 

*/
DECLARE @uname as VARCHAR(80)
	SELECT @uname = isnull(@UserName,SYSTEM_USER)
	
	
	-- Survey the Attached databases and insert new ones
		INSERT INTO [dbo].[tblMasterDBList]
		(
				[Name]
			,	[DBID]
			,	[CreateDate]
			,	[StateDesc]
			,	[TotalSizeKB]
			--,	[DataSizeKB]
			--,	[LogSizeKB]
			,	[KPMGCreatedBy]
			,	[RecordLastUpdated]
		)
	SELECT
		db.name
		,db.database_id
		,db.create_date
		,db.state_desc
		, ft.[TotalSizeKB]
		--, fd.[DataSizeKB]
		--, fl.[LogSizeKB]		
		,@UNAME
		,GETDATE() as [RecordLastUpdated]
	FROM
		sys.databases db 
			INNER JOIN (SELECT database_id, sum(size) * 8 AS [TotalSizeKB] FROM master.sys.master_files GROUP BY database_id) ft ON db.database_id = ft.database_id
			--INNER JOIN (SELECT database_id, sum(size) * 8 AS [DataSizeKB] FROM master.sys.master_files WHERE [type] = 0 GROUP BY database_id) fd ON db.database_id = fd.database_id
			--INNER JOIN (SELECT database_id, sum(size) * 8 AS [LogSizeKB] FROM master.sys.master_files WHERE [type] = 1 GROUP BY database_id) fl ON db.database_id = fl.database_id
		LEFT OUTER JOIN dbo.tblMasterDBList m on db.name = m.Name
	WHERE m.Name is null


GO

/****** Object:  StoredProcedure [dbo].[spUpdateMasterDBListExtendedProperties]    Script Date: 14/05/2014 13:49:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spUpdateMasterDBListExtendedProperties]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spUpdateMasterDBListExtendedProperties] AS' 
END
GO


ALTER PROCEDURE [dbo].[spUpdateMasterDBListExtendedProperties]
AS
/*
DECLARE @RC int
EXECUTE @RC = [dbo].[spUpdateMasterDBListExtendedProperties] 
GO
*/

	exec sp_msforeachdb 'update .tblMasterDBList set [KPMGDepartment]  = convert(varchar(255),(select value from ?.sys.fn_listextendedproperty(''Department'', default, default, default, default, default, default))) where Name = ''?''' 
	exec sp_msforeachdb 'update .tblMasterDBList set [KPMGProject]  = convert(varchar(255),(select value from ?.sys.fn_listextendedproperty(''Project'', default, default, default, default, default, default))) where Name = ''?''' 
	exec sp_msforeachdb 'update .tblMasterDBList set [KPMGProjectType]  = convert(varchar(255),(select value from ?.sys.fn_listextendedproperty(''Project Type'', default, default, default, default, default, default))) where Name = ''?''' 
	exec sp_msforeachdb 'update .tblMasterDBList set [KPMGApplication]  = convert(varchar(255),(select value from ?.sys.fn_listextendedproperty(''Application'', default, default, default, default, default, default))) where Name = ''?''' 
	exec sp_msforeachdb 'update .tblMasterDBList set [KPMGOwner]  = convert(varchar(255),(select value from ?.sys.fn_listextendedproperty(''Owner'', default, default, default, default, default, default))) where Name = ''?''' 
	exec sp_msforeachdb 'update .tblMasterDBList set [KPMGProjectManager]  = convert(varchar(255),(select value from ?.sys.fn_listextendedproperty(''Project Manager'', default, default, default, default, default, default))) where Name = ''?''' 
	exec sp_msforeachdb 'update .tblMasterDBList set [KPMGProjectPartner]  = convert(varchar(255),(select value from ?.sys.fn_listextendedproperty(''Project Partner'', default, default, default, default, default, default))) where Name = ''?''' 
	exec sp_msforeachdb 'update .tblMasterDBList set [KPMGPurpose]  = convert(varchar(255),(select value from ?.sys.fn_listextendedproperty(''Purpose'', default, default, default, default, default, default))) where Name = ''?''' 
	exec sp_msforeachdb 'update .tblMasterDBList set [KPMGCBCode]  = convert(varchar(255),(select value from ?.sys.fn_listextendedproperty(''CB Code'', default, default, default, default, default, default))) where Name = ''?''' 
	exec sp_msforeachdb 'update .tblMasterDBList set [KPMGOwnerEmail]  = convert(varchar(255),(select value from ?.sys.fn_listextendedproperty(''Owner Email'', default, default, default, default, default, default))) where Name = ''?''' 
	exec sp_msforeachdb 'update .tblMasterDBList set [KPMGManagerEmail]  = convert(varchar(255),(select value from ?.sys.fn_listextendedproperty(''Manager Email'', default, default, default, default, default, default))) where Name = ''?''' 


	--exec sp_msforeachdb 'update .tblMasterDBList set KPMGDepartment		= convert(varchar(255),(select value from ?.sys.fn_listextendedproperty(''Department'', default, default, default, default, default, default))) where Name = ''?'''
	--exec sp_msforeachdb 'update .tblMasterDBList set KPMGProject			= convert(varchar(255),(select value from ?.sys.fn_listextendedproperty(''Project'', default, default, default, default, default, default))) where Name = ''?'''
	--exec sp_msforeachdb 'update .tblMasterDBList set KPMGProjectType		= convert(varchar(255),(select value from ?.sys.fn_listextendedproperty(''Project Type'', default, default, default, default, default, default))) where Name = ''?'''
	--exec sp_msforeachdb 'update .tblMasterDBList set KPMGApplication		= convert(varchar(255),(select value from ?.sys.fn_listextendedproperty(''Application'', default, default, default, default, default, default))) where Name = ''?'''
	--exec sp_msforeachdb 'update .tblMasterDBList set KPMGOwner			= convert(varchar(255),(select value from ?.sys.fn_listextendedproperty(''Database Owner'', default, default, default, default, default, default))) where Name = ''?'''
	--exec sp_msforeachdb 'update .tblMasterDBList set KPMGProjectManager  = convert(varchar(255),(select value from ?.sys.fn_listextendedproperty(''Database Manager'', default, default, default, default, default, default))) where Name = ''?'''
	--exec sp_msforeachdb 'update .tblMasterDBList set KPMGProjectPartner	= convert(varchar(255),(select value from ?.sys.fn_listextendedproperty(''Project Partner'', default, default, default, default, default, default))) where Name = ''?'''
	--exec sp_msforeachdb 'update .tblMasterDBList set KPMGPurpose			= convert(varchar(255),(select value from ?.sys.fn_listextendedproperty(''Purpose'', default, default, default, default, default, default))) where Name = ''?'''
	--exec sp_msforeachdb 'update .tblMasterDBList set KPMGCBCode			= convert(varchar(255),(select value from ?.sys.fn_listextendedproperty(''CB Code'', default, default, default, default, default, default))) where Name = ''?'''
	--exec sp_msforeachdb 'update .tblMasterDBList set KPMGOwnerEmail		= convert(varchar(255),(select value from ?.sys.fn_listextendedproperty(''Owner Email'', default, default, default, default, default, default))) where Name = ''?'''
	--exec sp_msforeachdb 'update .tblMasterDBList set KPMGManagerEmail    = convert(varchar(255),(select value from ?.sys.fn_listextendedproperty(''Manager Email'', default, default, default, default, default, default))) where Name = ''?'''
	





GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'Purpose' , N'SCHEMA',N'dbo', N'TABLE',N'tblMasterDBList', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'Purpose', @value=N'Master Database list.  A persistent list of databases attached to the Server' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblMasterDBList'
GO

/****** Object:  StoredProcedure [dbo].[spSetExtendedProperties]    Script Date: 14/05/2014 13:49:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spSetExtendedProperties]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spSetExtendedProperties] AS' 
END
GO
-- Step 2.2: Create Stored Procedure spSetExtendedProperties
ALTER PROCEDURE [dbo].[spSetExtendedProperties]
----------------------------------------------------------------------------------------------------
-- Object Name			: spSetExtendedProperties
-- Author				: Neil Harris
-- Date                 : 2012-04-11
-- Inputs               : 
--							@dbName sysname -  
--							@p2 int -  
-- Outputs				: None
-- RETURN CODES			: 
--		0 - success
-- Callers				: None
-- Dependencies			: [dbo].[spUpdateMasterDBListExtendedProperties] 

--
-- Description          : This Creates extended Properties for a given Database name. If the Properties already Exist 
--						They will instead be updated.

-- Execution Example (optional)  : 
/*
DECLARE @RC int
DECLARE @dbName sysname
DECLARE @KPMGDepartment nvarchar(256)
DECLARE @KPMGProjectType nvarchar(256)
DECLARE @KPMGProject nvarchar(256)
DECLARE @KPMGOwner nvarchar(256)
DECLARE @KPMGProjectManager nvarchar(256)
DECLARE @KPMGProjectPartner nvarchar(256)
DECLARE @KPMGPurpose nvarchar(256)

-- TODO: Set parameter values here.
SELECT @dbName = 'zzSQLServerAdmin'
	,@KPMGDepartment = 'Data Insight Services (DIS)'
	,@KPMGProjectType = 'SQL Admins Test db'
	,@KPMGProject = 'zzSQLServerAdmin'
	,@KPMGOwner = 'Neil Harris'
	,@KPMGProjectManager = 'Neil Harris'
	,@KPMGProjectPartner = 'Paul Tombleson'
	,@KPMGPurpose =

EXECUTE @RC = [dbo].[spSetExtendedProperties] 
   @dbName
  ,@KPMGDepartment
  ,@KPMGProjectType
  ,@KPMGProject
  ,@KPMGOwner
  ,@KPMGProjectManager
  ,@KPMGProjectPartner
  ,@KPMGPurpose

PRINT @rc

*/
----------------------------------------------------------------------------------------------------
	-- Add the parameters for the stored procedure here
	@dbName						SYSNAME
	,@KPMGDepartment			NVARCHAR(256)			-- TTG / DA / F-TECH (Name of your Dept)
	,@KPMGProject				NVARCHAR(256)			-- Project Name
	,@KPMGProjectType			NVARCHAR(256)			-- ProjectType TTG_ / KTrace / KFIT / EDM / DA / IPBR / Analysis
	,@KPMGApplication			NVARCHAR(200)			-- Application the db Supports
	,@KPMGOwner					NVARCHAR(256)			-- Contact Information Databse Owner (Who requested it)
	,@KPMGProjectManager		NVARCHAR(256)			-- Contact Information Database Manager (Who Approved it)
	,@KPMGProjectPartner		NVARCHAR(256)			-- Engagement Partner
	,@KPMGPurpose				NVARCHAR(256)			-- Narrative Purpose of the DB 
	,@KPMGCBCode				NVARCHAR(200)			-- Chargeable Code
	,@KPMGOwnerEmail			NVARCHAR(200) = NULL			-- Owner Email for Notification
	,@KPMGManagerEmail			NVARCHAR(200) = NULL	-- Manager Email for Notification	
AS
BEGIN
DECLARE @MySQL AS VARCHAR(8000) 

-- Build the Email if Not Supplied
SELECT 
	@KPMGManagerEmail = ISNULL(@KPMGManagerEmail, REPLACE(@KPMGProjectManager,' ','.') + '@kpmg.co.uk' )
	,@KPMGOwnerEmail = ISNULL(@KPMGOwnerEmail, REPLACE(@KPMGOwner,' ','.') + '@kpmg.co.uk' )

-- Check the Database exists
IF  EXISTS (SELECT name FROM sys.databases WHERE name = @dbName)
BEGIN
	SET @MySQL = 
		'if exists(select value from '+ QUOTENAME(@dbName) +'.sys.fn_listextendedproperty(''Department'', default, default, default, default, default, default))
		EXEC '+ QUOTENAME(@dbName) +'.sys.sp_updateextendedproperty @name=N''Department'', @value=N'''+@KPMGDepartment+'''
		ELSE 
		EXEC '+ QUOTENAME(@dbName) +'.sys.sp_addextendedproperty @name=N''Department'', @value=N'''+@KPMGDepartment+''' 
		if exists(select value from '+ QUOTENAME(@dbName) +'.sys.fn_listextendedproperty(''Project'', default, default, default, default, default, default))
		EXEC '+ QUOTENAME(@dbName) +'.sys.sp_updateextendedproperty @name=N''Project'', @value=N'''+@KPMGProject+'''
		ELSE 
		EXEC '+ QUOTENAME(@dbName) +'.sys.sp_addextendedproperty @name=N''Project'', @value=N'''+@KPMGProject+''' 	
		if exists(select value from '+ QUOTENAME(@dbName) +'.sys.fn_listextendedproperty(''Project Type'', default, default, default, default, default, default))
		EXEC '+ QUOTENAME(@dbName) +'.sys.sp_updateextendedproperty @name=N''Project Type'', @value=N'''+@KPMGProjectType+'''
		ELSE 
		EXEC '+ QUOTENAME(@dbName) +'.sys.sp_addextendedproperty @name=N''Project Type'', @value=N'''+@KPMGProjectType+'''
		if exists(select value from '+ QUOTENAME(@dbName) +'.sys.fn_listextendedproperty(''Application'', default, default, default, default, default, default))
		EXEC '+ QUOTENAME(@dbName) +'.sys.sp_updateextendedproperty @name=N''Application'', @value=N'''+@KPMGApplication+'''
		ELSE 
		EXEC '+ QUOTENAME(@dbName) +'.sys.sp_addextendedproperty @name=N''Application'', @value=N'''+@KPMGApplication+'''
		if exists(select value from '+ QUOTENAME(@dbName) +'.sys.fn_listextendedproperty(''Owner'', default, default, default, default, default, default))
		EXEC '+ QUOTENAME(@dbName) +'.sys.sp_updateextendedproperty @name=N''Owner'', @value=N'''+@KPMGOwner+'''
		ELSE 
		EXEC '+ QUOTENAME(@dbName) +'.sys.sp_addextendedproperty @name=N''Owner'', @value=N'''+@KPMGOwner+'''
		'
	--	PRINT @MySQL
		EXEC (@MySQL)
			
		SET @MySQL = ''
		SET @MySQL = 
		'
		if exists(select value from '+ QUOTENAME(@dbName) +'.sys.fn_listextendedproperty(''Project Manager'', default, default, default, default, default, default))
		EXEC '+ QUOTENAME(@dbName) +'.sys.sp_updateextendedproperty @name=N''Project Manager'', @value=N'''+@KPMGProjectManager+'''
		ELSE 
		EXEC '+ QUOTENAME(@dbName) +'.sys.sp_addextendedproperty @name=N''Project Manager'', @value=N'''+@KPMGProjectManager+'''
		if exists(select value from '+ QUOTENAME(@dbName) +'.sys.fn_listextendedproperty(''Project Partner'', default, default, default, default, default, default))
		EXEC '+ QUOTENAME(@dbName) +'.sys.sp_updateextendedproperty @name=N''Project Partner'', @value=N'''+@KPMGProjectPartner+'''
		ELSE 
		EXEC '+ QUOTENAME(@dbName) +'.sys.sp_addextendedproperty @name=N''Project Partner'', @value=N'''+@KPMGProjectPartner+'''
		if exists(select value from '+ QUOTENAME(@dbName) +'.sys.fn_listextendedproperty(''Purpose'', default, default, default, default, default, default))
		EXEC '+ QUOTENAME(@dbName) +'.sys.sp_updateextendedproperty @name=N''Purpose'', @value=N'''+@KPMGPurpose+'''
		ELSE 
		EXEC '+ QUOTENAME(@dbName) +'.sys.sp_addextendedproperty @name=N''Purpose'', @value=N'''+@KPMGPurpose+'''
		if exists(select value from '+ QUOTENAME(@dbName) +'.sys.fn_listextendedproperty(''CB Code'', default, default, default, default, default, default))
		EXEC '+ QUOTENAME(@dbName) +'.sys.sp_updateextendedproperty @name=N''CB Code'', @value=N'''+@KPMGCBCode+'''
		ELSE 
		EXEC '+ QUOTENAME(@dbName) +'.sys.sp_addextendedproperty @name=N''CB Code'', @value=N'''+@KPMGCBCode+'''
		if exists(select value from '+ QUOTENAME(@dbName) +'.sys.fn_listextendedproperty(''Owner Email'', default, default, default, default, default, default))
		EXEC '+ QUOTENAME(@dbName) +'.sys.sp_updateextendedproperty @name=N''Owner Email'', @value=N'''+@KPMGOwnerEmail+'''
		ELSE 
		EXEC '+ QUOTENAME(@dbName) +'.sys.sp_addextendedproperty @name=N''Owner Email'', @value=N'''+@KPMGOwnerEmail+'''
		if exists(select value from '+ QUOTENAME(@dbName) +'.sys.fn_listextendedproperty(''Manager Email'', default, default, default, default, default, default))
		EXEC '+ QUOTENAME(@dbName) +'.sys.sp_updateextendedproperty @name=N''Manager Email'', @value=N'''+@KPMGManagerEmail+'''
		ELSE 
		EXEC '+ QUOTENAME(@dbName) +'.sys.sp_addextendedproperty @name=N''Manager Email'', @value=N'''+@KPMGManagerEmail+'''
		'
		--PRINT @MySQL
		EXEC (@MySQL)

		EXECUTE [dbo].[spUpdateMasterDBListExtendedProperties]
	END

/* Test Scrap
SELECT
	(select value from sys.fn_listextendedproperty('Department', default, default, default, default, default, default)) as [Department]
	,(select value from sys.fn_listextendedproperty('Project', default, default, default, default, default, default)) as [Project]
	,(select value from sys.fn_listextendedproperty('Project Type', default, default, default, default, default, default)) as [Project Type]
	,(select value from sys.fn_listextendedproperty('Application', default, default, default, default, default, default)) as [Application]
	,(select value from sys.fn_listextendedproperty('Owner', default, default, default, default, default, default)) as [Owner]
	,(select value from sys.fn_listextendedproperty('Project Manager', default, default, default, default, default, default)) as [Project Manager]
	,(select value from sys.fn_listextendedproperty('Project Partner', default, default, default, default, default, default)) as [Project Partner]
	,(select value from sys.fn_listextendedproperty('Purpose', default, default, default, default, default, default)) as [Purpose]
	,(select value from sys.fn_listextendedproperty('CB Code', default, default, default, default, default, default)) as [CB Code]
	,(select value from sys.fn_listextendedproperty('Owner Email', default, default, default, default, default, default)) as [Owner Email]
	,(select value from sys.fn_listextendedproperty('Manager Email', default, default, default, default, default, default)) as [Manager Email]

DECLARE @RC int
DECLARE @dbName sysname
DECLARE @KPMGDepartment nvarchar(256)
DECLARE @KPMGProject nvarchar(256)
DECLARE @KPMGProjectType nvarchar(256)
DECLARE @KPMGApplication nvarchar(200)
DECLARE @KPMGOwner nvarchar(256)
DECLARE @KPMGProjectManager nvarchar(256)
DECLARE @KPMGProjectPartner nvarchar(256)
DECLARE @KPMGPurpose nvarchar(256)
DECLARE @KPMGCBCode nvarchar(200)
DECLARE @KPMGOwnerEmail nvarchar(200)
DECLARE @KPMGManagerEmail nvarchar(200)

-- TODO: Set parameter values here.
SELECT 
	@dbName = 'Shagga'
	,@KPMGDepartment = 'Data Insight Services (DIS)'
	,@KPMGProject = 'DIS zzSQLServerAdministration database'
	,@KPMGProjectType = 'SQL Admins Repository '
	,@KPMGApplication = 'zzSQLServerAdmin'
	,@KPMGOwner = 'Ronan Sapun'
	,@KPMGProjectManager = 'Neil Harris'
	,@KPMGProjectPartner = 'Paul Tombleson'
	,@KPMGPurpose = 'Create a Repository for Tracking Databases into and out of SQL Server'
	,@KPMGCBCode = ''
	,@KPMGOwnerEmail = NULL
	,@KPMGManagerEmail =NULL

EXECUTE @RC = [dbo].[spSetExtendedProperties] 
   @dbName
  ,@KPMGDepartment
  ,@KPMGProject
  ,@KPMGProjectType
  ,@KPMGApplication
  ,@KPMGOwner
  ,@KPMGProjectManager
  ,@KPMGProjectPartner
  ,@KPMGPurpose
  ,@KPMGCBCode
  ,@KPMGOwnerEmail
  ,@KPMGManagerEmail
GO

SELECT
	(select value from sys.fn_listextendedproperty('Department', default, default, default, default, default, default)) as [Department]
	,(select value from sys.fn_listextendedproperty('Project', default, default, default, default, default, default)) as [Project]
	,(select value from sys.fn_listextendedproperty('Project Type', default, default, default, default, default, default)) as [Project Type]
	,(select value from sys.fn_listextendedproperty('Application', default, default, default, default, default, default)) as [Application]
	,(select value from sys.fn_listextendedproperty('Owner', default, default, default, default, default, default)) as [Owner]
	,(select value from sys.fn_listextendedproperty('Project Manager', default, default, default, default, default, default)) as [Project Manager]
	,(select value from sys.fn_listextendedproperty('Project Partner', default, default, default, default, default, default)) as [Project Partner]
	,(select value from sys.fn_listextendedproperty('Purpose', default, default, default, default, default, default)) as [Purpose]
	,(select value from sys.fn_listextendedproperty('CB Code', default, default, default, default, default, default)) as [CB Code]
	,(select value from sys.fn_listextendedproperty('Owner Email', default, default, default, default, default, default)) as [Owner Email]
	,(select value from sys.fn_listextendedproperty('Manager Email', default, default, default, default, default, default)) as [Manager Email]
*/
END


GO
/****** Object:  StoredProcedure [dbo].[spCreateNewDB]    Script Date: 14/05/2014 13:49:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spCreateNewDB]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spCreateNewDB] AS' 
END
GO


-- Step 2.2: Create Stored Procedure spCreateNewDB
ALTER PROCEDURE [dbo].[spCreateNewDB]
----------------------------------------------------------------------------------------------------
-- Object Name			: spCreateNewDB
-- Author				: Neil Harris
-- Date                 : 2012-04-11
-- Inputs               : 
--							@dbName sysname -  
--							@p2 int -  
-- Outputs				: None
-- RETURN CODES			: 
--		0 - success
-- Callers				: None
-- Dependencies			: dbo.fnGetDefaultPath
--						: [dbo].[spSetExtendedProperties]

--
-- Description          : This procedure creates a database on this server in default folders 
--							and add extended properties.  There are no defaults for these and they myst be added.

-- Execution Example (optional)  : 
/*
DECLARE @RC int
DECLARE @dbName sysname
DECLARE @KPMGDepartment nvarchar(256)
DECLARE @KPMGProjectType nvarchar(256)
DECLARE @KPMGProject nvarchar(256)
DECLARE @KPMGOwner nvarchar(256)
DECLARE @KPMGProjectManager nvarchar(256)
DECLARE @KPMGProjectPartner nvarchar(256)
DECLARE @KPMGPurpose nvarchar(256)

-- TODO: Set parameter values here.
SELECT @dbName = ''
	,@KPMGDepartment = ''
	,@KPMGProjectType = ''
	,@KPMGProject = ''
	,@KPMGOwner = ''
	,@KPMGProjectManager = ''
	,@KPMGProjectPartner = ''
	,@KPMGPurpose = ''

EXECUTE @RC = [dbo].[spCreateNewDB] 
   @dbName
  ,@KPMGDepartment
  ,@KPMGProjectType
  ,@KPMGProject
  ,@KPMGOwner
  ,@KPMGProjectManager
  ,@KPMGProjectPartner
  ,@KPMGPurpose

PRINT @rc

*/
----------------------------------------------------------------------------------------------------
	-- Add the parameters for the stored procedure here
	@dbName					SYSNAME
	,@KPMGDepartment		NVARCHAR(256)			-- TTG / DA / F-TECH (Name of your Dept)
	,@KPMGProject			NVARCHAR(256)			-- Project Name
	,@KPMGProjectType		NVARCHAR(256)			-- ProjectType TTG_ / KTrace / KFIT / EDM / DA / IPBR / Analysis
	,@KPMGApplication		NVARCHAR(200)			-- Application the db Supports
	,@KPMGOwner				NVARCHAR(256)			-- Contact Information Databse Owner (Who requested it)
	,@KPMGProjectManager	NVARCHAR(256)			-- Contact Information Database Manager (Who Approved it)
	,@KPMGProjectPartner	NVARCHAR(256)			-- Engagement Partner
	,@KPMGPurpose			NVARCHAR(256)			-- Narrative Purpose of the DB 
	,@KPMGCBCode			NVARCHAR(200)			-- Chargeable Code
	,@KPMGOwnerEmail		NVARCHAR(200) = NULL	-- Owner Email for Notification
	,@KPMGManagerEmail		NVARCHAR(200) = NULL	-- Manager Email for Notification	
AS
BEGIN
-- Declare Local Variables
	DECLARE @cProcessName       VARCHAR(35) --Name of process
	DECLARE @cProcedureName     VARCHAR(35) --Name of current procedure
	DECLARE @iSQLErrm           INT         --Error code returned by last sql statement
	DECLARE @iStatus            INT         --Status of current execution
	DECLARE @msg				VARCHAR(200)
	
	DECLARE @UName NVARCHAR(200)
	
	
	-- Initialise local variables
    SELECT 
		@iStatus			= 0					-- 0 represents success
		,@cProcessName		= 'CreateDB'
		,@UName				= SYSTEM_USER
		,@cProcedureName	= OBJECT_NAME(@@PROCID)
		,@iSQLErrm			= 0 -- 0 represents no error
		,@iStatus			= 0 -- 0 represents success

	BEGIN TRY 
		-- SET NOCOUNT ON added to prevent extra result sets from
		-- interfering with SELECT statements.
		SET NOCOUNT ON;

		-- Insert statements for procedure here
		DECLARE @DataRoot NVARCHAR(256)				-- Data file: file path for database
		DECLARE @LogRoot NVARCHAR(256)				-- Log file file path for database

		DECLARE @DataFileName NVARCHAR(256)			-- Data file: file Name for database
		DECLARE @LogFileName NVARCHAR(256)			-- Log file: file Name for database
		DECLARE @DataLogicalName NVARCHAR(256)		-- Data file: Logical Name for datafile
		DECLARE @LogLogicalName NVARCHAR(256)		-- Data file: Logical Name for log file

		DECLARE @Compatability INT
		DECLARE @SQLCreate	VARCHAR(MAX)


		-- Build Variables of the DB Name
		SELECT 
			@DataRoot			= dbo.fnGetDefaultPath(0) + '\' + @dbName
			,@LogRoot			= dbo.fnGetDefaultPath(1) + '\' + @dbName
			,@DataLogicalName	= @dbName + '_DATA01'
			,@LogLogicalName	= @dbName + '_LOG01'
			,@DataFileName		= @DataRoot + '\' + @DataLogicalName + '.mdf'
			,@LogFileName		= @LogRoot + '\' + @LogLogicalName + '.ldf'

		-- Create email Addresses if they are not porvided
		SELECT 
			@KPMGManagerEmail = ISNULL(@KPMGManagerEmail, REPLACE(@KPMGProjectManager,' ','.') + '@kpmg.co.uk' )
			,@KPMGOwnerEmail = ISNULL(@KPMGOwnerEmail, REPLACE(@KPMGOwner,' ','.') + '@kpmg.co.uk' )

		-- Create the Database Specific directories on the server
		EXECUTE master.dbo.xp_create_subdir @DataRoot
		EXECUTE master.dbo.xp_create_subdir @LogRoot

		-- Create the Database with Standard Sizes and Growth Patterns
		SELECT 
			@SQLCreate = 
				'IF  NOT EXISTS (SELECT name FROM sys.databases WHERE name = N''' + @dbName + ''')
				CREATE DATABASE ' + QUOTENAME(@dbName) + ' ON  PRIMARY 
				( NAME = N'''+ @DataLogicalName + '''
				, FILENAME = N'''+ @DataFileName + '''
				, SIZE = 102400KB 
				, FILEGROWTH = 10% )
				LOG ON ( NAME = N''' + @LogLogicalName + '''
				, FILENAME = N''' + @LogFileName + ''' 
				, SIZE = 30720KB 
				, FILEGROWTH = 10%)
				
				EXEC '+ QUOTENAME(@dbName) +'.dbo.sp_changedbowner ''sa''
				ALTER DATABASE '+ QUOTENAME(@dbName) +' SET ANSI_NULL_DEFAULT OFF 
				ALTER DATABASE '+ QUOTENAME(@dbName) +' SET ANSI_NULLS OFF 
				ALTER DATABASE '+ QUOTENAME(@dbName) +' SET ANSI_PADDING OFF 
				ALTER DATABASE '+ QUOTENAME(@dbName) +' SET ANSI_WARNINGS OFF 
				ALTER DATABASE '+ QUOTENAME(@dbName) +' SET ARITHABORT OFF 
				ALTER DATABASE '+ QUOTENAME(@dbName) +' SET AUTO_CLOSE OFF 
				ALTER DATABASE '+ QUOTENAME(@dbName) +' SET AUTO_CREATE_STATISTICS ON 
				ALTER DATABASE '+ QUOTENAME(@dbName) +' SET AUTO_SHRINK OFF 
				ALTER DATABASE '+ QUOTENAME(@dbName) +' SET AUTO_UPDATE_STATISTICS ON 
				ALTER DATABASE '+ QUOTENAME(@dbName) +' SET CURSOR_CLOSE_ON_COMMIT OFF 
				ALTER DATABASE '+ QUOTENAME(@dbName) +' SET CURSOR_DEFAULT  GLOBAL 
				ALTER DATABASE '+ QUOTENAME(@dbName) +' SET CONCAT_NULL_YIELDS_NULL OFF 
				ALTER DATABASE '+ QUOTENAME(@dbName) +' SET NUMERIC_ROUNDABORT OFF 
				ALTER DATABASE '+ QUOTENAME(@dbName) +' SET QUOTED_IDENTIFIER OFF 
				ALTER DATABASE '+ QUOTENAME(@dbName) +' SET RECURSIVE_TRIGGERS OFF 
				ALTER DATABASE '+ QUOTENAME(@dbName) +' SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
				ALTER DATABASE '+ QUOTENAME(@dbName) +' SET DATE_CORRELATION_OPTIMIZATION OFF 
				ALTER DATABASE '+ QUOTENAME(@dbName) +' SET PARAMETERIZATION SIMPLE 
				ALTER DATABASE '+ QUOTENAME(@dbName) +' SET READ_WRITE 
				ALTER DATABASE '+ QUOTENAME(@dbName) +' SET RECOVERY FULL 
				ALTER DATABASE '+ QUOTENAME(@dbName) +' SET MULTI_USER 
				ALTER DATABASE '+ QUOTENAME(@dbName) +' SET PAGE_VERIFY CHECKSUM  
				'
			
			PRINT @SQLCreate
			EXEC(@SQLCreate)

				
			EXECUTE [dbo].[spSetExtendedProperties] 
				@dbName
				,@KPMGDepartment
				,@KPMGProject
				,@KPMGProjectType
				,@KPMGApplication
				,@KPMGOwner
				,@KPMGProjectManager
				,@KPMGProjectPartner
				,@KPMGPurpose
				,@KPMGCBCode
				,@KPMGOwnerEmail
				,@KPMGManagerEmail

		
			EXECUTE [dbo].[spInsertMasterDBList] @UserName = @UName
			EXECUTE [dbo].[spUpdateMasterDBListExtendedProperties]
			EXECUTE [dbo].[spEmailDatabaseCreate] @dbName
				

			-- Save this script to the Network Folder
			PRINT 'Now save the Report to \\na01\Special_Projects\SQL_Server_Admin\MACHINE\RCSTSQL56\MSSQL_10.50\00_RCSTSQL56\' + @dbName + '\CreateDatabase_' + @dbName + '.sql'
		
	END TRY
	BEGIN CATCH
			SET @iStatus = 1
			SET @msg = ERROR_MESSAGE()
			IF ERROR_NUMBER() < 50000
				SET @isqlErrm = ERROR_NUMBER()
--			EXECUTE spLogSQLStatus @cProcessName,@cProcedureName,@iStatus, @msg,@iSqlErrm  
	END CATCH
END




GO