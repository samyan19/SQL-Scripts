Use zzSQLServerAdmin
GO
exec [dbo].[spCreateNewDB]
   @dbName = 'TTG_KPMGMeetingbooker_PRD01'
  ,@KPMGDepartment = 'Tax Web Farm'
  ,@KPMGProject = 'KPMG Meeting Booker'
  ,@KPMGProjectType = ''
  ,@KPMGApplication = ''
  ,@KPMGOwner = 'Victor Soares'
  ,@KPMGProjectManager = 'Victor Soares'
  ,@KPMGProjectPartner = ''
  ,@KPMGPurpose = ''
  ,@KPMGCBCode = ''
  ,@KPMGOwnerEmail = 'Victor.Soares@kpmg.co.uk'
  ,@KPMGManagerEmail = ''
