

Select SUSER_SNAME([Transaction SID]) As Changer, [Transaction Name],*
From fn_dblog(null, null)