USE [your_database];
GO

DECLARE
    @trace_id INT,
    @filename NVARCHAR(4000);

SELECT @trace_id = id
    FROM sys.traces
    WHERE is_default = 1;

SELECT @filename = CONVERT(NVARCHAR(4000), value)
    FROM sys.fn_trace_getinfo(@trace_id)
    WHERE property = 2;

SELECT HostName, LoginName, StartTime
    FROM sys.fn_trace_gettable(@filename, DEFAULT)
    WHERE EventClass   = 109
    AND DatabaseName   = N'your_database'
    AND TargetUserName = N'bob'
