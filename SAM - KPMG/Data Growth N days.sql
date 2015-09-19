  ;WITH a as(
  SELECT DBName
	,date
	,DataMB
	--,MAX(datamb)-MIN(DataMB) AS datagrowth
  FROM cp.tblDatabaseAndBackupSize
  WHERE date=CAST (GETDATE()-1 AS DATE)
--  GROUP BY DBName,DataMB
)
  ,b AS (

    SELECT DBName
	,date
	,DataMB
	--,MAX(datamb)-MIN(DataMB) AS datagrowth
  FROM cp.tblDatabaseAndBackupSize
  WHERE date=CAST (GETDATE()-120 AS DATE)
--  GROUP BY DBName,DataMB
)
  SELECT a.dbname
	,a.DataMB-ISNULL(b.DataMB,0) AS dbgrowthMB
	,a.DataMB AS CurrentSizeMB
  FROM a
  LEFT JOIN b ON a.DBName=b.DBName
  WHERE a.DataMB-ISNULL(b.DataMB,0)=0
  AND a.DBName NOT IN ('master','model','tempdb','zzSQLServerAdmin','zzSQLServer)')
  ORDER BY 3 DESC