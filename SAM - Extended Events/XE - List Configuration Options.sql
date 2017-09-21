/*https://www.sqlskills.com/blogs/jonathan/an-xevent-a-day-6-of-31-targets-week-asynchronous_file_target/*/

SELECT 
    oc.name AS column_name,
    oc.column_id,
    oc.type_name,
    oc.capabilities_desc,
    oc.description,
	o.name
FROM sys.dm_xe_packages AS p
JOIN sys.dm_xe_objects AS o 
    ON p.guid = o.package_guid
JOIN sys.dm_xe_object_columns AS oc 
    ON o.name = oc.OBJECT_NAME 
    AND o.package_guid = oc.object_package_guid
WHERE (p.capabilities IS NULL OR p.capabilities & 1 = 0)
  AND (o.capabilities IS NULL OR o.capabilities & 1 = 0)
  AND o.object_type = 'target'
  --AND o.name = 'asynchronous_file_target'
