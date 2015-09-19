--KPMG Service Details

USE [master]
GO
EXEC [master].sys.sp_addextendedproperty @name=N'Owner', @value=N'Chris Ashbrook' 
GO
EXEC [master].sys.sp_addextendedproperty @name=N'Project Name', @value=N'UBS Multi J Production' 
GO
EXEC [master].sys.sp_addextendedproperty @name=N'Project Number', @value=N'EPRF75' 
GO
EXEC [master].sys.sp_addextendedproperty @name=N'Purpose', @value=N'UBS Multi J - Production' 
GO
EXEC [master].sys.sp_addextendedproperty @name=N'Sponsor', @value=N'Jason Strahan' 
GO
EXEC [master].sys.sp_addextendedproperty @name=N'TS Architect', @value=N'Mark Bradley / Greg Walker' 
GO
EXEC [master].sys.sp_addextendedproperty @name=N'TS Project Manager', @value=N'' 
GO


--KPMG Database

EXEC [pneuron_results].sys.sp_addextendedproperty @name=N'dbname', @value=N'pneuron_results' 
EXEC [pneuron_results].sys.sp_addextendedproperty @name=N'KPMGDepartment', @value=N'Data Insight Services' 
EXEC [pneuron_results].sys.sp_addextendedproperty @name=N'KPMGProject', @value=N'Project Coffee' 
EXEC [pneuron_results].sys.sp_addextendedproperty @name=N'KPMGProjectType', @value=N'POC' 
EXEC [pneuron_results].sys.sp_addextendedproperty @name=N'KPMGApplication', @value=N'' 
EXEC [pneuron_results].sys.sp_addextendedproperty @name=N'KPMGOwner', @value=N'Adam Delves, Ben Johnstone' 
EXEC [pneuron_results].sys.sp_addextendedproperty @name=N'KPMGProjectManager', @value=N'Bob Gettings' 
EXEC [pneuron_results].sys.sp_addextendedproperty @name=N'KPMGProjectPartner', @value=N'John Hall' 
EXEC [pneuron_results].sys.sp_addextendedproperty @name=N'KPMGPurpose', @value=N'Software Testing POC for Pneuron' 
EXEC [pneuron_results].sys.sp_addextendedproperty @name=N'KPMGCBCode', @value=N'' 
EXEC [pneuron_results].sys.sp_addextendedproperty @name=N'KPMGOwnerEmail', @value=N'' 
EXEC [pneuron_results].sys.sp_addextendedproperty @name=N'KPMGManagerEmail', @value=N'' 

