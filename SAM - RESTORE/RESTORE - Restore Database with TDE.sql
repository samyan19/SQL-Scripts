/*
Backup and restoring on instance with the same certificate works without error
*/


/*
Certificate expiration 
*/
--Backup existing or copy over existing certificate and create certificate on new instance
CREATE CERTIFICATE RCSTVSQL2K83_TDECertificate
FROM FILE = 'Y:\MSSQL\RCSTSQL58\11.00\00_RCSTSQL58\BACKUPS\RCSTVSQL2K83_TDECertificate.cer'
WITH PRIVATE KEY (FILE = 'Y:\MSSQL\RCSTSQL58\11.00\00_RCSTSQL58\BACKUPS\RCSTVSQL2K83_TDECertificate.PVK', 
DECRYPTION BY PASSWORD = 'gAWizVQU3mmrgUXaVHLh')


--Test to see if the file populates without error
restore filelistonly 
FROM  DISK = N'Y:\MSSQL\RCSTSQL58\11.00\00_RCSTSQL58\BACKUPS\FULL_RESTORE_TEMP\RTP_Nougat_CMTLite_Prod_20141106_190503.BAK' 


--Restore 
USE [master]
RESTORE DATABASE [RTP_Nougat_CMTLite_DEV01] 
FROM  DISK = N'Y:\MSSQL\RCSTSQL58\11.00\00_RCSTSQL58\BACKUPS\FULL_RESTORE_TEMP\RTP_Nougat_CMTLite_Prod_20141106_190503.BAK' 


