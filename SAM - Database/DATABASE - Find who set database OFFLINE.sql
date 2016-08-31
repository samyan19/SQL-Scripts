/*
  http://databasebestpractices.com/changed-sql-server-database-state-offline/
  
  1. Connect to SQL Server → open SQL Server logs and scan through the logs.
*/
EXEC sys.sp_readerrorlog @p1 = 0, @p2 = 1, @p3 = N'OFFLINE';

/*
  2.  Now go to Windows event viewer (under Administrative Tools) and open Application logs. 
      Here try to look for entries by Source = MSSQLSERVER around 9/6/2012 10:54:54 AM timeframe 
      (This step will be done by logging in to the server by making remote desktop connection)

  3.  If windows authenticated account changed the database state then you will find that account here against User. If the change was made by sql authenticated account then it will show N/A.
      Proceed to next step if it says N/A.
      
  4.  Now we know the spid, timeframe when this change was made. Also, we know the change was made by sql authenticated account. 
      Now, run the below script by changing spid value and starttime to correct value.
*/

DECLARE @FileName VARCHAR(MAX)

SELECT @FileName = SUBSTRING(path, 0, LEN(path)-CHARINDEX('\', REVERSE(path))+1) + '\Log.trc'
 FROM sys.traces
 WHERE is_default = 1;

SELECT DatabaseID, HostName, ApplicationName, LoginName, DatabaseName
 FROM sys.fn_trace_gettable( @FileName, DEFAULT )
 where starttime = '2012-09-06 10:54:55.117'
 and spid=61;
 
 
/*
  From output you can see that this change was made by use DM\USER123.

  Please note, this step will work only if default trace is enabled and the trace file is still available for the timeframe when database status was changed.

  Additionally, you can follow above steps to check who changed database state to ONLINE, READ-ONLY, etc.
*/
