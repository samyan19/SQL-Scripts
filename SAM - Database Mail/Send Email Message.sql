EXEC msdb.dbo.sp_send_dbmail
    @profile_name = 'Adventure Works Administrator',
    @recipients = 'danw@Adventure-Works.com',
    @body = 'The stored procedure finished successfully.',
    @subject = 'Automated Success Message' ;