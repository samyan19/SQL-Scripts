--

DECLARE @sql AS VARCHAR(MAX)='';

SELECT @sql = @sql + 
'ALTER INDEX ' + i.name + ' ON  ' + schema_name(o.schema_id)+ '.'+ o.name + ' DISABLE;' +CHAR(13)+CHAR(10)
FROM 
    sys.indexes i
JOIN 
    sys.objects o
    ON i.object_id = o.object_id
WHERE i.type_desc = 'NONCLUSTERED'
  AND o.type_desc = 'USER_TABLE'
  and SCHEMA_NAME(o.schema_id)='MESSAGING'
  and o.name='SEIOvernight';

EXEC(@sql);
