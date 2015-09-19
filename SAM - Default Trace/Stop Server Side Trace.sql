/*find traces running*/
SELECT * FROM ::fn_trace_getinfo(NULL)

/*stop server side trace*/
EXEC sp_trace_setstatus @traceid = 3 , @status = 0

/*clear from list*/
EXEC sp_trace_setstatus @traceid = 2 , @status = 2