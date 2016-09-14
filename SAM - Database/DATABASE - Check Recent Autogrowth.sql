
DECLARE @path NVARCHAR(260);

SELECT 
   @path = REVERSE(SUBSTRING(REVERSE([path]), 
   CHARINDEX('\', REVERSE([path])), 260)) + N'log.trc'
FROM    sys.traces
WHERE   is_default = 1;

SELECT 
   DatabaseName,
   [FileName],
   SPID,
   Duration,
   StartTime,
   EndTime,
   FileType = CASE EventClass 
       WHEN 92 THEN 'Data'
       WHEN 93 THEN 'Log'
   END
FROM sys.fn_trace_gettable(@path, DEFAULT)
WHERE
   EventClass IN (92,93)
ORDER BY
   StartTime DESC;
