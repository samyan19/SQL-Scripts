/*Disabling TDE Encryption



Use this to find out the d/b id

select * from sys.databases


The following process will get TDE removed from your database, after you have determined the performance hit is too much, or the novelty of having an encrypted database has worn off.

Removing TDE is basically the reverse of enabling it, however you will need to wait between steps.*/

--- REMOVE ENCRYPTION
USE master;
ALTER DATABASE DBNAME
SET ENCRYPTION OFF;
GO

/* This will make the database start the decryption process. Use the query below to check the status of the decryption process. */

--- CHECK ENCRYPTION STATUS
USE master
SELECT database_id, encryption_state, percent_complete
FROM sys.dm_database_encryption_keys;
GO

----wait until it goes to 100%

--- REMOVE THE ENCRYPTION KEY
Use DBNAME
DROP DATABASE ENCRYPTION KEY
GO


--- CHECK ENCRYPTION STATUS
USE master
SELECT database_id, encryption_state, percent_complete
FROM sys.dm_database_encryption_keys;
GO

/*Should disappear*/
