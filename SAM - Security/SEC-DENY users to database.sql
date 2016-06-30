/*
http://sqlblogcasts.com/blogs/tonyrogerson/archive/2007/02/11/prevent-users-from-reconnecting-in-sql-server.aspx
*/

CREATE PROC control_user_access
      @op varchar(5),
      @db sysname
AS
BEGIN
      /******
            Author: Tony Rogerson, 2007
            http://sqlblogcasts.com/blogs/tonyrogerson
 
            Feel free to use at will but don't rip it off as your own!
 
       ******/
      IF @op NOT IN ( 'GRANT', 'DENY' )
      BEGIN
            RAISERROR( '@op takes values GRANT or DENY', 16, 1 )
 
      END
      ELSE
      BEGIN
            --    Prevent Logins from getting into SQL Server.
            DECLARE @sql varchar(max)
            SET @sql = '
            declare logins_cur cursor for
                  select sp.name
                  from [' + @db + '].sys.database_principals du
                        inner join master.sys.server_principals sp on sp.sid = du.sid
                  where du.principal_id > 1'
 
            EXEC( @sql )
 
            DECLARE @login_name sysname
 
            OPEN logins_cur
 
            FETCH NEXT FROM logins_cur INTO @login_name
 
            WHILE @@fetch_status = 0
            BEGIN
                  SET @sql = @op + ' CONNECT SQL TO [' + @login_name + ']'
                  PRINT @sql
                  EXEC( @sql )
 
                  FETCH NEXT FROM logins_cur INTO @login_name
 
            END
            DEALLOCATE logins_cur
 
            --    Kill the logins in the database
            DECLARE sessions_cur CURSOR FOR
                  SELECT spid
                  FROM master..sysprocesses     --    Have to use this because DMV's dont give me the dbid
                  WHERE dbid = DB_ID( @db )
 
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
 
      END
 
END
