/* 
* Delete backup files
*
* http://www.patrickkeisler.com/2012/11/how-to-use-xpdeletefile-to-purge-old.html
*/

DECLARE @path nvarchar(100)='F:\SQLBackups\TEMP\'

DECLARE @DeleteDate DATETIME = DATEADD(dd,-3,GETDATE());

EXEC master.sys.xp_delete_file 0,@path,'BAK',@DeleteDate,1;
