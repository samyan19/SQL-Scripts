/*
OLD

EXEC sys.sp_MS_marksystemobject sp_OptimizeIndexes
*/

use master
go
create proc sp_samtest2
as
select name from sys.tables


use master
go
EXEC sys.sp_MS_marksystemobject sp_samtest