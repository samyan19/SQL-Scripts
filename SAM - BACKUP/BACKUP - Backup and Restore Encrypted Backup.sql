/* 
https://docs.microsoft.com/en-us/sql/relational-databases/backup-restore/backup-encryption

*/



-- Encrypted Database Backup Restore using a Certificate.
---------------------------------------------------------


-- Executed on SOURCE

-- Create a database "master" key.
USE Master;  
GO  
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'els2234234ljljasdfLJLJ23'
GO 



CREATE CERTIFICATE CryptoBackup  
WITH SUBJECT = 'CryptoBackup';  
GO 



-- Does not have to be same password as "master" key. 
BACKUP CERTIFICATE CryptoBackup TO FILE = 'C:\Temp\CertBackup.cer'
  WITH PRIVATE KEY (FILE = 'C:\Temp\CertBackup.pvk',   
  ENCRYPTION BY PASSWORD = 'els2234234ljljasdfLJLJ23')
GO



BACKUP DATABASE [ToEncrypt]  
TO DISK = N'C:\Temp\ToEncrypt.bak'  
WITH  
  COMPRESSION,  
  ENCRYPTION   
   (  
   ALGORITHM = AES_256,  
   SERVER CERTIFICATE = CryptoBackup  
   ),  
  STATS = 10  
GO 


---------------------------
-- Executed on TARGET

-- Create a database "master" key.  
USE Master;  
GO  
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'els2234234ljljasdfLJLJ23'
GO



-- Copy Certificate to target then create
CREATE CERTIFICATE CryptoBackup   
    FROM FILE = 'C:\Temp\CertBackup.cer'   
    WITH PRIVATE KEY (FILE = 'C:\Temp\CertBackup.pvk',   
    DECRYPTION BY PASSWORD = 'els2234234ljljasdfLJLJ23'); 
GO



-- Copy bak to TARGET then Restore database from encrypted backup using Certificate
USE [master]
RESTORE DATABASE [ToEncrypt] 
 FROM DISK = N'C:\Temp\ToEncrypt.bak' WITH  FILE = 1, NOUNLOAD,  REPLACE,  STATS = 5
GO


-- Error if missing the certificate
Msg 33111, Level 16, State 3, Line 56
Cannot find server certificate with thumbprint '0xA70B9D1DC7B5ECFF4B84205340987FA692EA2889'.
Msg 3013, Level 16, State 1, Line 56
RESTORE DATABASE is terminating abnormally.

