/*
Value of error log file you want to read: 0 = current, 1 = Archive #1, 2 = Archive #2, etc...
Log file type: 1 or NULL = error log, 2 = SQL Agent log
Search string 1: String one you want to search for
Search string 2: String two you want to search for to further refine the results
*/

exec sp_readerrorlog 0,1,'Recovery is complete'
