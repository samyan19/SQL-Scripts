/* 
grant permissions to run sp_whoisactive
https://devjef.wordpress.com/2015/08/14/minimal-permissions-needed-to-run-sp_whoisactive/
*/

USE master
GO
GRANT EXECUTE ON dbo.sp_WhoIsActive TO TestLogin
GO

USE master
GO
GRANT VIEW SERVER STATE TO TestLogin
GO

