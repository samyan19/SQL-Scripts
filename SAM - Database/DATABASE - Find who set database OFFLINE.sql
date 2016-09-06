/*
  http://databasebestpractices.com/changed-sql-server-database-state-offline/


1. Connect to SQL Server → open SQL Server logs and scan through the logs.
  
Parameter Name	Usage
@ArchiveID	Extension of the file which we would like to read.
0 = ERRORLOG/SQLAgent.out
1 = ERRORLOG.1/SQLAgent.1  and so on

@LogType	
1 for SQL Server ERRORLOG (ERRORLOG.*)
2 for SQL Agent Logs (SQLAgent.*)

@FilterText1	First Text filter on data
@FilterText2	Another Text filter on data. Output would be after applying both filters, if specified
@FirstEntry	Start Date Filter on Date time in the log
@LastEntry	End Date Filter on Date time in the log
@SortOrder	‘asc’ or ‘desc’ for sorting the data based on time in log.
 
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
