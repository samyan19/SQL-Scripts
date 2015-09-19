DECLARE @Search nvarchar(500)
SET @Search=N'your text here'
SELECT DISTINCT
    o.name AS Object_Name,o.type_desc --, m.definition
    FROM sys.sql_modules        m 
        INNER JOIN sys.objects  o ON m.object_id=o.object_id
    WHERE m.definition Like '%'+@Search+'%'
    ORDER BY 2,1
