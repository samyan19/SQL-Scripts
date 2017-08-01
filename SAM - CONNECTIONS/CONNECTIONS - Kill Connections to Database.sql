--    Kill the logins in the database

declare @sql nvarchar(4000);

DECLARE sessions_cur CURSOR FOR
  SELECT spid
  FROM master..sysprocesses     --    Have to use this because DMV's dont give me the dbid
  WHERE dbid = DB_ID('AGQuantumUAT')

OPEN sessions_cur

DECLARE @session_id int

FETCH NEXT FROM sessions_cur INTO @session_id

WHILE @@FETCH_STATUS = 0
BEGIN
  SET @sql = 'KILL ' + CAST( @session_id AS varchar(10) )
  PRINT @sql
  EXEC( @sql )

  FETCH NEXT FROM sessions_cur INTO @session_id
END
DEALLOCATE sessions_cur
