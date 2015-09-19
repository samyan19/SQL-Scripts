USE Audit;
EXECUTE AS USER = 'ATDRUK\BStow';
select suser_name()
SELECT * FROM fn_my_permissions(NULL, 'Database') 
ORDER BY subentity_name, permission_name ; 
REVERT;
GO
-- At a database level  has administrative rights
USE Audit;
EXECUTE AS USER = 'ATDRUK\BStow';
select suser_name()
SELECT * FROM fn_my_permissions('dbo.ReportWeek', 'Object') 
ORDER BY subentity_name, permission_name ; 
REVERT;
GO
