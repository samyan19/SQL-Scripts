SELECT 'ALTER SCHEMA NewSchemaName TRANSFER [' + SysSchemas.Name + '].[' + DbObjects.Name + '];'
FROM sys.Objects DbObjects
INNER JOIN sys.Schemas SysSchemas ON DbObjects.schema_id = SysSchemas.schema_id
WHERE SysSchemas.Name = 'OldSchemaName'
AND (DbObjects.Type IN ('U', 'P', 'V'))
