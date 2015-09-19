/*
The following example changes the enabled status of the NightlyJobs schedule to 0 and sets the owner to terrid.
*/

USE msdb ;
GO

EXEC dbo.sp_update_schedule
    @name = 'NightlyJobs',
    @enabled = 0,
    @owner_login_name = 'terrid' ;
GO