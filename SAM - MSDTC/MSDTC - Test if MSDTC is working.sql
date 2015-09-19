use DBA

begin distributed transaction;

;with cte as 
(
select top 200 *
from dtctest
)

delete from cte

--rollback transaction
commit transaction