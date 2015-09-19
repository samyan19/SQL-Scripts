--Scripts to update null statistics

SELECT 'update statistics' + ' ' + RTRIM(object_name(I.id)) + ' ' + RTRIM(name),
DATALENGTH (statblob) size,
STATS_DATE (I.id, I.indid) last_updated 
FROM
sysindexes as I
WHERE
OBJECTPROPERTY(I.id, N'IsUserTable') = 1 AND
INDEXPROPERTY (I.id , name , 'IsAutoStatistics' ) = 1 AND
DATALENGTH (statblob) is null

--Scripts to drop null statistics

SELECT 'drop statistics' + ' ' + RTRIM(object_name(I.id)) + '.' + RTRIM(name),
DATALENGTH (statblob) size,
STATS_DATE (I.id, I.indid) last_updated
FROM
sysindexes as I
WHERE
OBJECTPROPERTY(I.id, N'IsUserTable') = 1 AND
INDEXPROPERTY (I.id , name , 'IsAutoStatistics' ) = 1 AND
DATALENGTH (statblob) is null
