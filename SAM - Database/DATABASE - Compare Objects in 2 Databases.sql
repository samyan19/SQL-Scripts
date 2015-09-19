DECLARE @Sourcedb sysname 
    DECLARE @Destdb sysname 
    DECLARE @SQL varchar(max) 
     
    SELECT @Sourcedb = 'DS2' 
    SELECT @Destdb = 'SQLIO' 
     
    SELECT @SQL = ' SELECT ISNULL(SoSource.name,SoDestination.name) ''Object Name'' 
                         , CASE  
                           WHEN SoSource.object_id IS NULL      THEN SoDestination.type_desc +  '' missing in the source -- '  
                                                                                             + @Sourcedb + ''' COLLATE database_default 
                           WHEN SoDestination.object_id IS NULL THEN SoSource.type_desc      +  '' missing in the Destination -- ' + @Destdb  
                                                                                             + ''' COLLATE database_default 
                           ELSE SoDestination.type_desc + '' available in both Source and Destination'' COLLATE database_default 
                           END ''Status'' 
                     FROM (SELECT * FROM ' + @Sourcedb + '.SYS.objects  
                            WHERE Type_desc not in (''INTERNAL_TABLE'',''SYSTEM_TABLE'',''SERVICE_QUEUE'')) SoSource  
          FULL OUTER JOIN (SELECT * FROM ' + @Destdb + '.SYS.objects  
                            WHERE Type_desc not in (''INTERNAL_TABLE'',''SYSTEM_TABLE'',''SERVICE_QUEUE'')) SoDestination 
                       ON SoSource.name = SoDestination.name COLLATE database_default 
                      AND SoSource.type = SoDestination.type COLLATE database_default 
                      ORDER BY isnull(SoSource.type,SoDestination.type)' 
 
    EXEC (@Sql)