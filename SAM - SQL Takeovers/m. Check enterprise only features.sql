
/*
	Are any of the databases using features that are Enterprise Edition only?
	If a database is using something like partitioning, compression, or
	Transparent Data Encryption, then I won't be able to restore it onto a
	Standard Edition server.
*/
EXEC dbo.sp_MSforeachdb 'SELECT ''[?]'' AS DatabaseName, * FROM [?].sys.dm_db_persisted_sku_features'


