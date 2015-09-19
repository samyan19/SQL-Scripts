/*
--Run dbcc check db to test
DBCC CHECKDB ([EDM_Circumflex_2014_TST01]) WITH NO_INFOMSGS, ALL_ERRORMSGS, DATA_PURITY
*/

--Script to output last good dbcc 
DBCC TRACEON(3604)
DBCC DBINFO('EDM_Circumflex_2014_TST01')
GO
DBCC TRACEOFF(3604)
GO