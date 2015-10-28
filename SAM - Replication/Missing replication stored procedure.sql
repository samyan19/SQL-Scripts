/* 
e.g:
CALL [sp_MSdel_dboCMT_BATCH_TABLE]
CALL [sp_MSins_dboCMT_BATCH_TABLE]
SCALL [sp_MSupd_dboCMT_BATCH_TABLE]

check to see if the stored proc is in the replication objects of the subscriber 
*/

use RTP_NOUGAT_CMT_UAT01
GO
select * from dbo.MSreplication_objects

/* 
in publisher script out stored procedures and run on subscriber
In SSMS change the maximum number of characters displayed in each column to 8192
* Tools -> Options -> Query Results -> Results to Text
*/

USE UAT
GO
EXEC sp_scriptpublicationcustomprocs @publication='REP_SQL58_CMT_CASES_UAT'
