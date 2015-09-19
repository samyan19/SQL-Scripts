/*
Identify logins where password enforcement has been set
*/

SELECT name,
CASE CAST(is_policy_checked AS TINYINT) + CAST(is_expiration_checked AS TINYINT)
WHEN 0 THEN 'Not Enforced'
WHEN 1 THEN 'Password - No Expiration'
WHEN 2 THEN 'Password With Expiration' END AS PasswordEnforcement,
LOGINPROPERTY(name,'BadPasswordCount') AS BadPasswordCount,
LOGINPROPERTY(name,'BadPasswordTime') AS BadPasswordTime,
LOGINPROPERTY(name,'DaysUntilExpiration') AS DaysUntilExpiration,
default_database_name,
CASE WHEN LOGINPROPERTY(name,'IsExpired') = 0 THEN 'NO' ELSE 'YES' END AS IsExpired,
CASE WHEN LOGINPROPERTY(name,'IsLocked') = 0 THEN 'NO' ELSE 'YES' END AS IsLocked,
CASE WHEN LOGINPROPERTY(name,'IsMustChange') = 0 THEN 'NO' ELSE 'YES' END AS IsMustChange,
LOGINPROPERTY(name,'LockoutTime') AS LockoutTime,
LOGINPROPERTY(name,'PasswordLastSetTime') AS PasswordLastSetTime
FROM sys.sql_logins
ORDER BY PasswordEnforcement DESC




