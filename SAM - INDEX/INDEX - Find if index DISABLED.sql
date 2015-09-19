SELECT name, has_filter, filter_definition, is_disabled
FROM sys.indexes
where name like '%ixHolding_Active%'