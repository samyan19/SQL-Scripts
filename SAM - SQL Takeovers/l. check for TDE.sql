/*
	SQL 2008 & above only - are any databases encrypted?  Transparent Data
	Encryption is all too transparent.  You won't notice that databases are
	encrypted if you just glance at SSMS.
	
	If this query returns any results, you need to start asking if the certificate
	has been backed up and where the password is.  If you don't have both the
	cert and the password to unlock it, then the database can't be restored.
*/
SELECT d.name, k.* 
  FROM sys.dm_database_encryption_keys k
  INNER JOIN sys.databases d ON k.database_id = d.database_id
  ORDER BY d.name