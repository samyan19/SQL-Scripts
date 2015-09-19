begin tran
--select max(SellStartDate) from bigProduct


update bigproduct2
set Color='RED'

rollback tran



--View aquired locks
select * from sys.dm_tran_locks