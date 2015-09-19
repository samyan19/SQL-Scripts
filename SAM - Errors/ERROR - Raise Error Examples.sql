/* Raise error to messages tab */
RAISERROR (N'Create temp tables.',0,1) WITH NOWAIT;

/* 
* Raise error to messages tab with parameters
* 12 = security level
* 1 = state
*/
declare @mode varchar(10)='levels'
BEGIN
	RAISERROR ('@mode must be one of: "setup", "start", "stop", "report" you passed: "%s"',12,1, @mode)
	RETURN
END


/* Raise error to SQL log with parameters */
RAISERROR ('zzSQLServerAdmin.dbo.up_ElevatedRights executed with @mode="%s", by login="%s".',0,1, @mode,@original_login) with log