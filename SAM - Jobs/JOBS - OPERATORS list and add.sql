
select * from sysoperators


EXECUTE msdb.dbo.sp_update_operator
  @name = N'JobWatcher',
  @email_address = N'person1@company.org;person2@company.org';