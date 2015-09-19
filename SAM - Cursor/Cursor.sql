declare @name nvarchar (100)

DECLARE edmsCursor cursor local FAST_FORWARD for

select name
from sys.sysusers
where name like 'EDMS%'

open edmsCursor

fetch next from edmsCursor
into @name

while @@FETCH_STATUS=0
begin

IF EXISTS (SELECT name FROM sys.syslogins WHERE name = @name)
begin
exec sp_change_users_login'update_one',@name,@name
end

fetch next from edmsCursor
into @name

end
close edmsCursor
deallocate edmsCursor