USE [master]
GO
CREATE LOGIN [ATDRUK\SQL_SuperGroup_AR_RO] FROM WINDOWS WITH DEFAULT_DATABASE=[master]
GO
USE [DA_SuperGroup_AR_15]
GO
CREATE USER [ATDRUK\SQL_SuperGroup_AR_RO] FOR LOGIN [ATDRUK\SQL_SuperGroup_AR_RO]
GO
USE [DA_SuperGroup_AR_15]
GO
EXEC sp_addrolemember N'db_datareader', N'ATDRUK\SQL_SuperGroup_AR_RO'
GO
--EXEC sp_addrolemember N'db_datawriter', N'ATDRUK\SQL_SuperGroup_AR_RO'
--GO
