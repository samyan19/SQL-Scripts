SELECT S.name as [Schema Name], O.name AS [Object Name], ep.name, ep.value AS [Extended property]
FROM [DA_RosettaVoiceNice_CLS].sys.extended_properties EP
LEFT JOIN  [DA_RosettaVoiceNice_CLS].sys.all_objects O ON ep.major_id = O.object_id 
LEFT JOIN  [DA_RosettaVoiceNice_CLS].sys.schemas S on O.schema_id = S.schema_id
left JOIN  [DA_RosettaVoiceNice_CLS].sys.columns AS c ON ep.major_id = c.object_id AND ep.minor_id = c.column_id