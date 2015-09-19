/*
1. Set single user and restore database 
*/

use master
GO
ALTER DATABASE BestInvestDB SET  SINGLE_USER WITH ROLLBACK IMMEDIATE
GO
RESTORE DATABASE BestInvestDB FROM  DISK = N'\\pl3sqlc01ext.bestlive.bestinvest.co.uk\Backup\BestInvestDB.bak' WITH  FILE = 1,  NOUNLOAD,  REPLACE,  STATS = 10

--RESTORE VERIFYONLY FROM  DISK = N'\\pl3sqlc01ext.bestlive.bestinvest.co.uk\Backup\UmbracoSelect.bak'
GO

/*
2. set to simple 
*/
ALTER DATABASE BestInvestDB SET RECOVERY SIMPLE WITH NO_WAIT

/*
3. shrink log
*/
sp_helpfile

use BestInvestDB
GO
DBCC SHRINKFILE (BestInvestDB_log);

/*
4. sync logins
*/

--sp_change_users_login 'report'

exec sp_change_users_login 'report'
exec sp_change_users_login 'auto_fix', 'FileMakerUser'
exec sp_change_users_login 'auto_fix', 'svc_ReleaseProcess'
exec sp_change_users_login 'auto_fix', 'InvestingUser'
exec sp_change_users_login 'auto_fix', 'WebsiteUser'
--exec sp_change_users_login 'auto_fix', 'umbraco-best-invest'


