 
 SELECT  '[' + Sch.name + '].[' + Tab.[name] + ']' AS TableName, 
        Ind.type_desc, 
        Ind.[name] AS IndexName, 
        SUBSTRING(( SELECT  ', ' + AC.name 
                    FROM    sys.[tables] AS T 
                            INNER JOIN sys.[indexes] I ON T.[object_id] = I.[object_id] 
                            INNER JOIN sys.[index_columns] IC ON I.[object_id] = IC.[object_id] 
                                                                 AND I.[index_id] = IC.[index_id] 
                            INNER JOIN sys.[all_columns] AC ON T.[object_id] = AC.[object_id] 
                                                               AND IC.[column_id] = AC.[column_id] 
                    WHERE   Ind.[object_id] = I.[object_id] 
                            AND Ind.index_id = I.index_id 
                            AND IC.is_included_column = 0 
                    ORDER BY IC.key_ordinal  
                  FOR 
                    XML PATH('') ), 2, 8000) AS KeyCols, 
        SUBSTRING(( SELECT  ', ' + AC.name 
                    FROM    sys.[tables] AS T 
                            INNER JOIN sys.[indexes] I ON T.[object_id] = I.[object_id] 
                            INNER JOIN sys.[index_columns] IC ON I.[object_id] = IC.[object_id] 
                                                                 AND I.[index_id] = IC.[index_id] 
                            INNER JOIN sys.[all_columns] AC ON T.[object_id] = AC.[object_id] 
                                                               AND IC.[column_id] = AC.[column_id] 
                    WHERE   Ind.[object_id] = I.[object_id] 
                            AND Ind.index_id = I.index_id 
                            AND IC.is_included_column = 1 
                    ORDER BY IC.key_ordinal  
                  FOR 
                    XML PATH('') ), 2, 8000) AS IncludeCols                 
FROM    sys.[indexes] AS Ind 
        INNER JOIN sys.[tables] AS Tab ON Tab.[object_id] = Ind.[object_id] 
        INNER JOIN sys.[schemas] AS Sch ON Sch.[schema_id] = Tab.[schema_id] 
WHERE  Ind.type_desc <> 'HEAP' 
--AND Tab.name  = 'YourTableNameHere' -- uncomment to get single table indexes detail 
ORDER BY TableName 