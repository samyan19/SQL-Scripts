-- ======================
-- Stop Trace template
-- ======================
IF EXISTS (
	SELECT * FROM sys.fn_trace_getinfo(2)
)
BEGIN
	-- Stops the specified trace
	EXEC sp_trace_setstatus 2, 0

	-- Closes the specified trace and deletes its definition from the server
	EXEC sp_trace_setstatus 2, 2

	-- Delete trace file 
	EXEC xp_cmdshell 'del C:\Temp\MyTrace.trc'
END
ELSE
	PRINT 'Traceid (2) does not exist'
GO

