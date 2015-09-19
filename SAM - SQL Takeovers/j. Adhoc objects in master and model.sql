
/*
	A few more checks at the server level.  Go into the Windows Event Logs,
	and review any errors in the System and Application events.  This is where
	hardware-level errors can show up too, like failed hard drives.
*/






/*
	I don't like any surprises in the system databases.  Let's check the list of
	objects in master and model.  I don't want to see any rows returned from
	these four queries - if there are objects in the system databases, I want to
	ask why, and get them removed if possible.
*/

SELECT * FROM master.sys.tables WHERE name NOT IN ('spt_fallback_db', 'spt_fallback_dev', 'spt_fallback_usg', 'spt_monitor', 'spt_values', 'MSreplication_options')
SELECT * FROM master.sys.procedures WHERE name NOT IN ('sp_MSrepl_startup', 'sp_MScleanupmergepublisher')
SELECT * FROM model.sys.tables
SELECT * FROM model.sys.procedures