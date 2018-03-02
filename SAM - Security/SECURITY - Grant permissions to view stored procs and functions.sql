--By default users were able to see object definitions in SQL Server 2000, but in SQL Server 2005 this functionality was removed to allow another layer of security.  By using a new feature called VIEW DEFINITION it is possible to allow users that only have public access the ability to see object definitions.

--To turn on this feature across the board for all databases and all users you can issue the following statement:

USE master 
GO 
GRANT VIEW ANY DEFINITION TO PUBLIC
--To turn on this feature across the board for all databases for user "User1" you can issue the following statement:

USE master 
GO 
GRANT VIEW ANY DEFINITION TO User1
--To turn this feature on for a database and for all users that have public access you can issue the following:

USE AdventureWorks 
GO 
GRANT VIEW Definition TO PUBLIC
--If you want to grant access to only user "User1" of the database you can do the following:

USE AdventureWorks 
GO 
GRANT VIEW Definition TO User1
--To turn off this functionality you would issue the REVOKE command such as one of the following:

USE master  
GO  
REVOKE VIEW ANY DEFINITION TO User1  

-- or 

USE AdventureWorks  
GO  
REVOKE VIEW Definition TO User1  
--If you want to see which users have this access you can issue the following in the database.

USE AdventureWorks 
GO 
sp_helprotect
