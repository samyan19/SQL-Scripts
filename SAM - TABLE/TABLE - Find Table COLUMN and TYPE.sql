SELECT t.name AS table_name,
SCHEMA_NAME(t.schema_id) AS schema_name,
c.name AS column_name,
d.name,
c.max_length
FROM sys.tables AS t
INNER JOIN sys.columns c ON t.OBJECT_ID = c.OBJECT_ID
JOIN sys.types d ON c.user_type_id=d.user_type_id
--WHERE c.name = 'StatusID'
--where c.user_type_id=58
ORDER BY schema_name, table_name;


select * from 
sys.types
where name='smalldatetime'