/*=====================

Five Files Kept
20 MB each - max of 100MB
.trc

https://blogs.msdn.microsoft.com/askjay/2012/06/28/default-trace-and-system-health/
======================*/


SELECT REVERSE(SUBSTRING(REVERSE(path), CHARINDEX('\', REVERSE(path)), 256)) AS [DefaultTracePath]
FROM    sys.traces
WHERE   is_default = 1
