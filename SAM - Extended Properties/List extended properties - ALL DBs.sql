DECLARE @EP table (DatabaseName varchar(255), PropertyName varchar(max), 
            PropertyValue varchar(max))
			INSERT INTO @EP
EXEC sp_msforeachdb 'SELECT ''?'' AS DatabaseName, 
            CAST(name AS varchar), CAST(Value AS varchar) 
        FROM [?].sys.extended_properties WHERE class=0'
SELECT * FROM @EP