	SELECT * FROM sys.dm_db_index_physical_stats(db_id(), object_id('MESSAGING.SEIOvernight'),5 , null, 'LIMITED');
	
	SELECT * FROM sys.sysindexes where name like  '%ixSEIOvernight_SEIInterfaceID_SEItoBIFileID_SEIOvernightID%'
	
	
	SELECT 2280381*8 --KB