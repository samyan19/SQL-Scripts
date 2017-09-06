;WITH XMLNAMESPACES  -- XML namespace def must be the first in with clause.
(DEFAULT 'http://schemas.microsoft.com/sqlserver/reporting/2006/03/reportdatasource'
,'http://schemas.microsoft.com/SQLServer/reporting/reportdesigner'
 AS rd)
,SDS AS
(SELECT SDS .name AS SharedDsName
,isnull(RCounts .Dependents, 0) as Dependents ,SDS. [Path]
,CONVERT( xml, CONVERT(varbinary (max), content)) AS DEF 
,DS .extension as Extension
,case DS.credentialretrieval
       when 1 then 'User Supplied'
      when 2 then 'Stored'
      when 3 then 'Windows Integrated'
      when 4 then 'Not Required'
      end as CredentialType,
    CONVERT( smalldatetime,SDS .CreationDate, 100) as CreationDate,
   u .Username as CreatedBy, um . Username as ModifiedBy ,
    CONVERT(smalldatetime ,SDS. ModifiedDate,100 ) as ModifiedDate
     FROM dbo. [Catalog] AS SDS
 JOIN ReportServer. dbo.Users U ON SDS. CreatedByID = U .UserID
 JOIN ReportServer .dbo. Users UM ON SDS. ModifiedByID = UM .UserID
 JOIN Reportserver. dbo.Datasource DS on SDS. ItemID=DS .itemID
LEFT OUTER JOIN (SELECT DS .Link as DSLink, count(*) as Dependents
  FROM  Catalog AS C INNER JOIN Users AS CU ON C. CreatedByID = CU .UserID
  INNER JOIN Users AS MU ON C. ModifiedByID = MU .UserID
  LEFT OUTER JOIN SecData AS SD ON C.PolicyID = SD. PolicyID AND SD.AuthType = 1
  INNER JOIN DataSource AS DS ON C. ItemID = DS .ItemID
  group by DS.Link ) RCounts on Rcounts.DSLink =SDS. ItemID
WHERE SDS. Type = 5)    
  
SELECT  CON. [Path]
,CON. SharedDsName
,CON. Dependents
,CON. ConnString
,CON. extension
,CON. credentialtype
,CON. CreationDate
,CON. CreatedBy
,CON. ModifiedDate
,CON. ModifiedBy
FROM
(SELECT SDS .[Path]
,SDS. SharedDsName
,SDS. Dependents
,DSN. value('ConnectString[1]' , 'varchar(MAX)' ) AS ConnString
,SDS. extension
,SDS. credentialtype
,SDS. CreationDate
,SDS. CreatedBy
,SDS. ModifiedDate
,SDS. ModifiedBy
FROM SDS
CROSS APPLY  
SDS .DEF. nodes('/DataSourceDefinition' ) AS R(DSN )
 ) AS CON
-- Optional filter:
--WHERE upper (CON. Path) LIKE '%YOURPATH%'
