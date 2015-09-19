USE AUDIT
GO
select  u.name
        ,case when (r.principal_id is null) then 'public' else r.name end
        ,l.default_database_name
        ,u.default_schema_name
        ,u.principal_id
from sys.database_principals u
    left join (sys.database_role_members m join sys.database_principals r on m.role_principal_id = r.principal_id) 
        on m.member_principal_id = u.principal_id
    left join sys.server_principals l on u.sid = l.sid
    where u.type <> 'R'