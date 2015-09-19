SELECT name, has_filter, filter_definition
FROM sys.indexes
WHERE OBJECT_ID = OBJECT_ID('Sales.SalesOrderDetail');