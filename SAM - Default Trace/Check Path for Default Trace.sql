/*=====================

Five Files Kept
.trc

======================*/


SELECT REVERSE(SUBSTRING(REVERSE(path), CHARINDEX('\', REVERSE(path)), 256)) AS [DefaultTracePath]
FROM    sys.traces
WHERE   is_default = 1
