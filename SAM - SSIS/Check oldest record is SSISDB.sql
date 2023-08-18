/*Find the last date in SSISDB*/

use SSISDB
go

select min(end_time) from internal.operations
