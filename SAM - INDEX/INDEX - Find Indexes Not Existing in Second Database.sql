/*
Change
	[KCRCSQL411I02\I02].[FATCATESTODS] for source
	[BPMO-ODS] for dest
*/
	



;WITH CTE
AS (
	SELECT '[' + Sch.NAME + '].[' + Tab.[name] + ']' AS TableName
		,Ind.type_desc
		,Ind.[name] AS IndexName
		,Tab.name as tname
		,SUBSTRING((
				SELECT ', ' + AC.NAME
				FROM [KCRCSQL411I02\I02].[FATCATESTODS].sys.[tables] AS T
				INNER JOIN [KCRCSQL411I02\I02].[FATCATESTODS].sys.[indexes] I ON T.[object_id] = I.[object_id]
				INNER JOIN [KCRCSQL411I02\I02].[FATCATESTODS].sys.[index_columns] IC ON I.[object_id] = IC.[object_id]
					AND I.[index_id] = IC.[index_id]
				INNER JOIN [KCRCSQL411I02\I02].[FATCATESTODS].sys.[all_columns] AC ON T.[object_id] = AC.[object_id]
					AND IC.[column_id] = AC.[column_id]
				WHERE Ind.[object_id] = I.[object_id]
					AND Ind.index_id = I.index_id
					AND IC.is_included_column = 0
				ORDER BY IC.key_ordinal
				FOR XML PATH('')
				), 2, 8000) AS KeyCols
		,SUBSTRING((
				SELECT ', ' + AC.NAME
				FROM [KCRCSQL411I02\I02].[FATCATESTODS].sys.[tables] AS T
				INNER JOIN [KCRCSQL411I02\I02].[FATCATESTODS].sys.[indexes] I ON T.[object_id] = I.[object_id]
				INNER JOIN [KCRCSQL411I02\I02].[FATCATESTODS].sys.[index_columns] IC ON I.[object_id] = IC.[object_id]
					AND I.[index_id] = IC.[index_id]
				INNER JOIN [KCRCSQL411I02\I02].[FATCATESTODS].sys.[all_columns] AC ON T.[object_id] = AC.[object_id]
					AND IC.[column_id] = AC.[column_id]
				WHERE Ind.[object_id] = I.[object_id]
					AND Ind.index_id = I.index_id
					AND IC.is_included_column = 1
				ORDER BY IC.key_ordinal
				FOR XML PATH('')
				), 2, 8000) AS IncludeCols
	FROM [KCRCSQL411I02\I02].[FATCATESTODS].sys.[indexes] AS Ind
	INNER JOIN [KCRCSQL411I02\I02].[FATCATESTODS].sys.[tables] AS Tab ON Tab.[object_id] = Ind.[object_id]
	INNER JOIN [KCRCSQL411I02\I02].[FATCATESTODS].sys.[schemas] AS Sch ON Sch.[schema_id] = Tab.[schema_id]
	WHERE Ind.type_desc <> 'HEAP'
	)
SELECT *
FROM CTE c
/* Added to query only tables that exist on destination */
join [BPMO-ODS].sys.tables t on c.tname=t.name
WHERE NOT EXISTS (
		SELECT 1
		FROM [BPMO-ODS].sys.indexes i
		WHERE i.NAME = c.IndexName
		)
ORDER BY TableName