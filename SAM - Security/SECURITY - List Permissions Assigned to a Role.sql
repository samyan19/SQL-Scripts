/*
Script to find permissions related to a role

https://basitaalishan.com/tag/query-to-find-permission-assigned-to-public-role/

Link above is tailored to public but amended to return all 
rows for a single database or all databases in a server

*/


/*

	1. SINGLE DATABASE

*/

--USE [<Database_Name>] -- Specify database name
--GO

;WITH [RoleDBPermissions]
AS (
    SELECT p.[state_desc] AS [PermissionType]
        ,p.[permission_name] AS [PermissionName]
        ,USER_NAME(p.[grantee_principal_id]) AS [DatabaseRole]
        ,CASE p.[class]
            WHEN 0
                THEN 'Database::' + DB_NAME()
            WHEN 1
                THEN OBJECT_NAME(major_id)
            WHEN 3
                THEN 'Schema::' + SCHEMA_NAME(p.[major_id])
            END AS [ObjectName]
    FROM [sys].[database_permissions] p
    WHERE p.[class] IN (0, 1, 3)
        AND p.[minor_id] = 0
    )
SELECT 
[DatabaseRole]
,[PermissionType]
    ,[PermissionName]
    ,SCHEMA_NAME(o.[schema_id]) AS [ObjectSchema]
    ,[ObjectName]
    ,o.[type_desc] AS [ObjectType]
FROM [RoleDBPermissions] p
INNER JOIN [sys].[objects] o
    ON o.[name] = p.[ObjectName]
        AND OBJECTPROPERTY(o.object_id, 'IsMSShipped') = 0
--WHERE [DatabaseRole] = ''Public''
ORDER BY [DatabaseRole]
    ,[ObjectName]
    ,[ObjectType]



/*

	2. ALL DATABASES ON SERVER

*/


DECLARE  @temp table (DatabaseName nvarchar(100),DatabaseRole nvarchar(100),PermissionType nvarchar(100),PermissionName nvarchar(100),ObjectSchema nvarchar(100),
						ObjectName nvarchar(100),ObjectType nvarchar(100))

INSERT INTO @temp
exec sp_MSforeachdb 'USE ?
;WITH [RoleDBPermissions]
AS (
    SELECT p.[state_desc] AS [PermissionType]
        ,p.[permission_name] AS [PermissionName]
        ,USER_NAME(p.[grantee_principal_id]) AS [DatabaseRole]
        ,CASE p.[class]
            WHEN 0
                THEN ''Database::'' + DB_NAME()
            WHEN 1
                THEN OBJECT_NAME(major_id)
            WHEN 3
                THEN ''Schema::'' + SCHEMA_NAME(p.[major_id])
            END AS [ObjectName]
    FROM [sys].[database_permissions] p
    WHERE p.[class] IN (0, 1, 3)
        AND p.[minor_id] = 0
    )
SELECT 
''?'' as DatabaseName
,[DatabaseRole]
,[PermissionType]
    ,[PermissionName]
    ,SCHEMA_NAME(o.[schema_id]) AS [ObjectSchema]
    ,[ObjectName]
    ,o.[type_desc] AS [ObjectType]
FROM [RoleDBPermissions] p
INNER JOIN [sys].[objects] o
    ON o.[name] = p.[ObjectName]
        AND OBJECTPROPERTY(o.object_id, ''IsMSShipped'') = 0
--WHERE [DatabaseRole] = ''Public''
ORDER BY [DatabaseRole]
    ,[ObjectName]
    ,[ObjectType]'


select * from @temp
