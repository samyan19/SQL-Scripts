select o.name Object_Name,
	   SCHEMA_NAME(o.schema_id) Schema_name,
	   i.name Index_name,
	   i.Type_Desc,
	   s.no_recompute as [NotRecomputingStats],
	stats_date(i.object_id,index_id) as LastStatisticsUpdate
From sys.objects  o
	 JOIN sys.indexes   i
	 JOIN sys.stats AS s ON s.stats_id = i.index_id AND s.object_id = i.object_id
	 on o.object_id = i.object_id
WHERE 	s.no_recompute = 1