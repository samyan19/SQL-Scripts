USE [EDDS1045614]
go

SELECT DISTINCT
	schema_name(o.schema_id) as schem,
    object_name(ips.object_id) AS objectname,
    ips.index_id AS indexid,
    i.name,
    i.type_desc,
    ips.partition_number AS partitionnum,
    ips.alloc_unit_type_desc,
    avg_fragmentation_in_percent AS frag,
	ps.row_count,
	ips.page_count,
	i.fill_factor
FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL , NULL, 'LIMITED') ips
inner JOIN sys.indexes i ON ips.index_id=i.index_id
inner JOIN sys.objects o ON i.object_id=o.object_id
inner JOIN sys.dm_db_partition_stats ps ON ps.object_id=o.object_id
WHERE i.object_id=ips.object_id
--and i.name='PK_ErrorLog'
--AND avg_fragmentation_in_percent>30
--AND page_count>8
--AND i.name In (
--'PK_f1566033_f1566034',
--'IX_Value',
--'IX_GUID',
--'PK_f1565734_f1565735',
--'PK_f4031154_f4031155',
--'IX_1003669',
--'PK_f1046072_f1046073',
--'IX_ViewField_AVFID_ViewID',
--'IX_BatchUnit',
--'IX_PK_AssistedReviewCodingHistory_ProjectID_docID',
--'IX_PK_AssistedReviewCodingHistory_DocIDUserID',
--'IX_ViewField_ViewID',
--'PK_DocumentBatch',
--'PK_AccessControlListPermission'
--	)
order by frag DESC