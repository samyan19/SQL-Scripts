-- *************************************************************************************************************************
-- Header Block
-- FM008.1_Template_SQL_Script.sql
-- Use the Specify Values for Template Parameters command (Ctrl-Shift-M) to fill in the parameter values below.
-- See SP022.1_How_to_Comment_an_SQL_Script.doc for more instruction.

-- Copyright KPMG   KPMG Forensic 2011 
-- Project:         SQL Server Administration: SQL Server Admin
-- Application      
-- Purpose:         Create a default db for all user logins
-- Inputs			
--					
-- Outputs:         A Database on a SQL Server in the Appropriate Directories
-- Author:			Neil Harris
-- Run By:          Neil Harris
-- Run on date:     2011-04-18
-- Version:			1.8
-- File Name:		FM041.1_SQLSERVER_CreateNewAnalysisDB.sql
--
-- Change Log
--	Date		Name			Version	Change
--	18/04/2011	NMH				1.0		Altered from the original FM041.1_SQLSERVER_CreateNewAnalysisDB.sql
--
-- *************************************************************************************************************************

-- Step 3: Create the Database
	CREATE DATABASE [zzDefaultDB] 

	

	IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
	begin
	EXEC [zzDefaultDB].[dbo].[sp_fulltext_database] @action = 'disable'
	end

	ALTER DATABASE [zzDefaultDB] SET ANSI_NULL_DEFAULT OFF 

	ALTER DATABASE [zzDefaultDB] SET ANSI_NULLS OFF 

	ALTER DATABASE [zzDefaultDB] SET ANSI_PADDING OFF 

	ALTER DATABASE [zzDefaultDB] SET ANSI_WARNINGS OFF 

	ALTER DATABASE [zzDefaultDB] SET ARITHABORT OFF 

	ALTER DATABASE [zzDefaultDB] SET AUTO_CLOSE OFF 

	ALTER DATABASE [zzDefaultDB] SET AUTO_CREATE_STATISTICS ON 

	ALTER DATABASE [zzDefaultDB] SET AUTO_SHRINK OFF 

	ALTER DATABASE [zzDefaultDB] SET AUTO_UPDATE_STATISTICS ON 

	ALTER DATABASE [zzDefaultDB] SET CURSOR_CLOSE_ON_COMMIT OFF 

	ALTER DATABASE [zzDefaultDB] SET CURSOR_DEFAULT  GLOBAL 

	ALTER DATABASE [zzDefaultDB] SET CONCAT_NULL_YIELDS_NULL OFF 

	ALTER DATABASE [zzDefaultDB] SET NUMERIC_ROUNDABORT OFF 

	ALTER DATABASE [zzDefaultDB] SET QUOTED_IDENTIFIER OFF 

	ALTER DATABASE [zzDefaultDB] SET RECURSIVE_TRIGGERS OFF 

	ALTER DATABASE [zzDefaultDB] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 

	ALTER DATABASE [zzDefaultDB] SET DATE_CORRELATION_OPTIMIZATION OFF 

	ALTER DATABASE [zzDefaultDB] SET PARAMETERIZATION SIMPLE 

	ALTER DATABASE [zzDefaultDB] SET  READ_WRITE 

	ALTER DATABASE [zzDefaultDB] SET RECOVERY SIMPLE 

	ALTER DATABASE [zzDefaultDB] SET  MULTI_USER 

	ALTER DATABASE [zzDefaultDB] SET PAGE_VERIFY CHECKSUM  

	GO


	USE [zzDefaultDB]

	IF NOT EXISTS (SELECT name FROM sys.filegroups WHERE is_default=1 AND name = N'PRIMARY') ALTER DATABASE [zzDefaultDB] MODIFY FILEGROUP [PRIMARY] DEFAULT


-- Step 4: Change the Newly created db Owner to the default
	USE [zzDefaultDB]

	exec sp_changedbowner 'sa'


	-- Step 5:  Add Standard Extended Properties to describe the Database and its purpose
	USE [zzDefaultDB]

	EXEC sys.sp_addextendedproperty 
		@name=N'Project'
		, @value=N'SQL Server Admin' 

	EXEC sys.sp_addextendedproperty 
		@name=N'Application'
		, @value=N'' 

	EXEC sys.sp_addextendedproperty 
		@name=N'Purpose'
		, @value='Create a default db for all user logins'

	EXEC sys.sp_addextendedproperty 
		@name=N'Owner'
		, @value='Neil Harris'

	EXEC sys.sp_addextendedproperty 
		@name=N'Project Manager'
		, @value=N'Neil Harris' 

	EXEC sys.sp_addextendedproperty 
		@name=N'Project Partner'
		, @value=N'Neil Harris' 




-- Step 9: Save this script to \\na01\Special_Projects\SQL_Server_Admin\Databases\zzDefaultDB
	PRINT 'Now save this script to \\na01\Special_Projects\SQL_Server_Admin\MACHINE\FTVSQL07\MSSQL_11.00\00_FTVSQL07\zzDefaultDB\FM041.1_SQLSERVER_CreateNewAnalysisDB.sql'



