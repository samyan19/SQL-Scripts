
/*
	Check for triggers in any database.  I can't change these right away, but I
	want to know if they're present, because it'll help me troubleshoot faster.
	If I didn't know the database had triggers, I probably wouldn't think to look.
*/
EXEC dbo.sp_MSforeachdb 'SELECT ''[?]'' AS database_name, o.name AS table_name, t.* FROM [?].sys.triggers t INNER JOIN [?].sys.objects o ON t.parent_id = o.object_id'



