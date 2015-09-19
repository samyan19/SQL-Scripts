DECLARE @EP table (DatabaseName varchar(255), PropertyName varchar(max), 
            PropertyValue varchar(max))
			INSERT INTO @EP
EXEC sp_msforeachdb 'SELECT ''?'' AS DatabaseName, 
            CAST(name AS varchar), CAST(Value AS varchar) 
        FROM [?].sys.extended_properties WHERE class=0'
--SELECT * FROM @EP;

;WITH cte as(
select size,physical_name,  DB_NAME(mf.database_id) AS DbName
from sys.master_files mf
       inner join

(SELECT d.name, d.database_id
  FROM [zzSQLServerAdmin].[dbo].[tblIndexUsageByDatabase] ius
       RIGHT OUTER JOIN sys.databases d
              on ius.[dB] = d.name
  WHERE d.name NOT IN      (
                                  SELECT [DB] FROM [zzSQLServerAdmin].[dbo].[tblDatabaseUsageException]
                                  WHERE [StartDate] < GETDATE()
                                  AND [EndDate] > GETDATE()
                                         )
  GROUP BY [d].name, d.database_id
  HAVING ISNULL(SUM(userSeeks), 0) + ISNULL(SUM(userScans), 0) + ISNULL(SUM(userLookups), 0) + ISNULL(SUM(userUpdates), 0) = 0 )a
  ON mf.database_id = a.database_id
  GROUP BY mf.size,mf.physical_name,DB_NAME(mf.database_id)
  HAVING physical_name LIKE 'L:\%'
  )
SELECT size,physical_name,DbName,PropertyName,PropertyValue
  FROM cte c 
  JOIN @EP e ON c.DbName=e.DatabaseName
  WHERE PropertyName LIKE '%owner%' 
  AND PropertyName NOT LIKE '%Email%'
  ORDER BY size DESC
  --ORDER BY SUM(Size) desc
