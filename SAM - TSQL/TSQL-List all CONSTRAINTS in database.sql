/*
http://blog.sqlauthority.com/2007/09/16/sql-server-2005-list-all-the-constraint-of-database-find-primary-key-and-foreign-key-constraint-in-database/
*/

USE AdventureWorks;
GO
SELECT OBJECT_NAME(OBJECT_ID) AS NameofConstraint,
SCHEMA_NAME(schema_id) AS SchemaName,
OBJECT_NAME(parent_object_id) AS TableName,
type_desc AS ConstraintType
FROM sys.objects
WHERE type_desc LIKE '%CONSTRAINT'
GO
