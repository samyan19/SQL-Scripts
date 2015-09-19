DECLARE @query varchar(1000),
@dbname varchar(1000),
@count int

SET NOCOUNT ON

DECLARE csr CURSOR FAST_FORWARD READ_ONLY
FOR
SELECT name
FROM master.dbo.sysdatabases

CREATE TABLE ##loginfo
(
dbname varchar(100),
num_of_rows int)

OPEN csr

FETCH NEXT FROM csr INTO @dbname

WHILE (@@fetch_status <> -1)
BEGIN

CREATE TABLE #log_info
(
fileid tinyint,
file_size bigint,
start_offset bigint,
FSeqNo int,
[status] tinyint,
parity tinyint,
create_lsn numeric(25,0)
)

SET @query = 'DBCC loginfo (' + '''' + @dbname + ''') '

INSERT INTO #log_info
EXEC (@query)

SET @count = @@rowcount

DROP TABLE #log_info

INSERT ##loginfo
VALUES(@dbname, @count)

FETCH NEXT FROM csr INTO @dbname

END

CLOSE csr
DEALLOCATE csr

SELECT dbname,
num_of_rows
FROM ##loginfo
WHERE num_of_rows >= 50 --My rule of thumb is 50 VLFs. Your mileage may vary.
ORDER BY dbname

DROP TABLE ##loginfo;