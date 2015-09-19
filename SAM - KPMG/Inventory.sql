SELECT TOP 1000 *
  FROM [Inventory].[dbo].[SQLServer]
  WHERE VAlidTo > GETDATE()



/*
CPU count by version and edition
*/


  USE Inventory
GO

;WITH subset AS (
	SELECT SQLInstanceName,
	PhysicalServerName,
	IsClustered,
	LogicalProcessors,
	 [SQLVersion],[SQLEdition]--,REPLACE(SUBSTRING(FQDN, CHARINDEX('.', FQDN), LEN(FQDN)), '.', '') AS Domain
	from [dbo].[SQLServer]
	WHERE CASt(lastupdate AS date)='2015-07-22'
)
SELECT sum(LogicalProcessors) AS CPUCount,SQLVersion,SQLEdition
FROM subset
GROUP BY sqlversion,SQLEdition
ORDER BY sqlversion DESC


