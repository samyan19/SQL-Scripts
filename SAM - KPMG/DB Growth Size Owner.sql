DECLARE @EP TABLE (DatabaseName NVARCHAR(100)
					,createdate DATETIME
					,LOG INT
					,DATA INT
					,lastaccessdate DATETIME
					,OWNER NVARCHAR(100)
					,KPMGOwner NVARCHAR(100)
					,APPLICATION NVARCHAR(100)
					,kpmgproject NVARCHAR(100)
					,kpmgprojectmanager NVARCHAR(100)
					,kpmgprojectpartner NVARCHAR(100)
					)   
			INSERT INTO @EP
			EXEC [dbo].[spUseForDecommissionProcess]

--SELECT * FROM @EP

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
,c AS (

SELECT * FROM @EP)
  SELECT 
	a.dbname
	,a.DataMB-ISNULL(b.DataMB,0) AS dbgrowthMB
	,a.DataMB AS CurrentSizeMB
	,KPMGOwner
	,d.physical_name
  FROM a
  LEFT JOIN b ON a.DBName=b.DBName
  LEFT JOIN c ON a.DBName=c.DatabaseName
  LEFT JOIN sys.master_files d ON a.DBName=DB_NAME(d.database_id)
  WHERE a.DataMB-ISNULL(b.DataMB,0)=0
  AND a.DBName NOT IN ('master','model','tempdb','zzSQLServerAdmin','zzSQLServer)')
  AND physical_name LIKE 'L:%'
  --GROUP BY KPMGOwner
  ORDER BY 3 DESC


 -- SELECT * FROM sys.master_files

  /*
SELECT S.name as [Schema Name], O.name AS [Object Name], ep.name, ep.value AS [Extended property]
FROM [DA_RosettaVoiceNice_CLS].sys.extended_properties EP
LEFT JOIN  [DA_RosettaVoiceNice_CLS].sys.all_objects O ON ep.major_id = O.object_id 
LEFT JOIN  [DA_RosettaVoiceNice_CLS].sys.schemas S on O.schema_id = S.schema_id
left JOIN  [DA_RosettaVoiceNice_CLS].sys.columns AS c ON ep.major_id = c.object_id AND ep.minor_id = c.column_id
*/