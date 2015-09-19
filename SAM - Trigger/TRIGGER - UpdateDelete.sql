USE [dbDealing]
GO

/****** Object:  Trigger [ACCOUNT].[Account_UpdateDelete]    Script Date: 05/31/2013 14:36:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [ACCOUNT].[Account_UpdateDelete] ON [ACCOUNT].[Account] AFTER UPDATE, DELETE  
			AS 
			INSERT INTO AUDIT.ACCOUNTAccount 
			SELECT *, GETDATE() FROM DELETED
GO
