SELECT * FROM fn_my_permissions(N'Contracts', N'DATABASE')



EXECUTE AS USER = 'ATDRUK\mcarpenter';
SELECT * FROM fn_my_permissions(NULL, 'DATABASE') 
    ORDER BY subentity_name, permission_name ;  
REVERT;
GO