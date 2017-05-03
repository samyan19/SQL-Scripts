/*
Examples
The following query lists the permissions explicitly granted or denied to server principals.
Important

The permissions of fixed server roles do not appear in sys.server_permissions. Therefore, server principals may have additional permissions not listed here.
*/

SELECT pr.principal_id, pr.name, pr.type_desc,   
    pe.state_desc, pe.permission_name   
FROM sys.server_principals AS pr   
JOIN sys.server_permissions AS pe   
    ON pe.grantee_principal_id = pr.principal_id;  
