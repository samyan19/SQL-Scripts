--Trace Flags 
--trace client side connection closures
use msdb;
GO

DBCC TRACEON (7827, -1)


--log to errorlog when network disconnect occurs
dbcc traceon(4029,-1)

dbcc traceon(3689,-1)
