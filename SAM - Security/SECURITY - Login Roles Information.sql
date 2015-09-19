select
[Login Type]=
case sp.type
when 'u' then 'WIN'
when 's' then 'SQL'
when 'g' then 'GRP'
end,
convert(char(45),sp.name) as srvLogin,
convert(char(45),sp2.name) as srvRole,
convert(char(25),dbp.name) as dbUser,
convert(char(25),dbp2.name) as dbRole
from
sys.server_principals as sp join
sys.database_principals as dbp on sp.sid=dbp.sid join
sys.database_role_members as dbrm on dbp.principal_Id=dbrm.member_principal_Id join
sys.database_principals as dbp2 on dbrm.role_principal_id=dbp2.principal_id left join
sys.server_role_members as srm on sp.principal_id=srm.member_principal_id left join
sys.server_principals as sp2 on srm.role_principal_id=sp2.principal_id
WHERE sp.name IN ('EDMS_AdminUtil',
'EDMS_Securelogin',
'EDMS_Servicedesk',
'EDMS_ServiceLine',
'EDMS_OutsourceManager',
'EDMS_BenjyFinder',
'EDMS_BCM',
'EDMS_exportmanagement',
'EDMS_InvoiceManager')