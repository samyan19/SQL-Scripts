use dbDealing

exec sp_MSForEachDB 'IF "[?]" NOT IN ("master","model","msdb","tempdb") 
						exec [?].dbo.sp_OptimizeIndexes;'


DECLARE @count int = (select MAX(database_id) from sys.databases);
DECLARE @str nvarchar(4000);

WHILE @count > 4
begin 
	select @str =name
	from sys.databases
	where database_id=@count;

	if @str is not null
	begin
		set @str='exec '+@str+'.dbo.sp_OptimizeIndexes;';
		print @str;
		exec(@str);
	end 

	set @str = NULL;
	set @count=@count-1;
end