create procedure s_TryRebuildOnlineOtherwiseOffline
(
	@schema sysname = 'dbo',
	@tablename sysname,
	@indexname sysname
)
as
begin
	set @schema = QUOTENAME(@schema);
	set @tablename = QUOTENAME(@tablename);
	set @indexname = QUOTENAME(@indexname);
 
	declare @sqlRebuild nvarchar(max)
	set @sqlRebuild = N'ALTER INDEX ' + @indexname + ' ON ' + @schema + '.' + @tablename + ' REBUILD';
	declare @sqlRebuildOnline nvarchar(max)
	set @sqlRebuildOnline = @sqlRebuild + ' WITH (ONLINE=ON)';
 
	begin try
		EXEC sp_executesql @sqlRebuildOnline;
		print @sqlRebuildOnline;
	end try
	begin catch
		EXEC sp_executesql @sqlRebuild;
		print @sqlRebuild;
	end catch
end
go