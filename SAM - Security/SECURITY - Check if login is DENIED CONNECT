select spm.class_desc
,spm.permission_name
,spm.state_desc
,spr.name
,spr.type_desc
,spr.is_disabled
,ep.name
,ep.protocol_desc
,ep.state_desc
,ep.type_desc
from sys.server_permissions spm
join sys.server_principals spr on spm.grantee_principal_id=spr.principal_id
left outer join sys.endpoints ep on spm.major_id=ep.endpoint_id
WHERE ( spm.permission_name = 'CONNECT SQL' and spm.class_desc = 'SERVER')
OR (spm.permission_name = 'CONNECT' and spm.class_desc = 'ENDPOINT')



SELECT sp.[name],sp.type_desc
FROM sys.server_principals sp
INNER JOIN sys.server_permissions PERM ON sp.principal_id = PERM.grantee_principal_id
WHERE PERM.state_desc = 'DENY'
