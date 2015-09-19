===================
--script to change database collation - James Agnini
--
--Replace <DATABASE> with the database name
--Replace <COLLATION> with the collation, eg SQL_Latin1_General_CP1_CI_AS
--
--After running this script, run the script to rebuild all indexes

ALTER DATABASE <DATABASE> COLLATE <COLLATION> 

exec sp_configure 'allow updates',1
go
reconfigure with override
go
update syscolumns
set collationid = (select top 1 collationid from systypes where systypes.xtype=syscolumns.xtype)
where collationid <> (select top 1 collationid from systypes where systypes.xtype=syscolumns.xtype)
go
exec sp_configure 'allow updates',0
go
reconfigure with override
go
/*===================

As we have directly edited system tables, we need to run a script to rebuild all the indexes. Otherwise you will get strange results like comparing strings in different table not working.
The indexes have to actually be dropped and recreated in separate statements.
You can't use DBCC DBREINDEX or create index with the DROP_EXISTING option as they won't do anything(thanks to SQL Server "optimization").
This script loops through the tables and then loops through the indexes and unique constraints in separate sections. It gets the index information and drops and re-creates it.
(The script could probably be tidied up with the duplicate code put into a stored procedure).

====================*/
--Script to rebuild all table indexes, Version 0.1, May 2004 - James Agnini
--
--Database backups should be made before running any set of scripts that update databases.
--All users should be out of the database before running this script

print 'Rebuilding indexes for all tables:' 
go

DECLARE @Table_Name varchar(128)
declare @Index_Name varchar(128)
declare @IndexId int
declare @IndexKey int

DECLARE Table_Cursor CURSOR FOR
select TABLE_NAME from INFORMATION_SCHEMA.tables where table_type != 'VIEW'

OPEN Table_Cursor 
FETCH NEXT FROM Table_Cursor
INTO @Table_Name

--loop through tables
WHILE @@FETCH_STATUS = 0

BEGIN
print ''
print @Table_Name

DECLARE Index_Cursor CURSOR FOR
select indid, name from sysindexes
where id = OBJECT_ID(@Table_Name) and indid > 0 and indid < 255 and (status & 64)=0 and 
not exists(Select top 1 NULL from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
where TABLE_NAME = @Table_Name AND (CONSTRAINT_TYPE = 'PRIMARY KEY' or CONSTRAINT_TYPE = 'UNIQUE') and 
CONSTRAINT_NAME = name) 
order by indid

OPEN Index_Cursor 
FETCH NEXT FROM Index_Cursor
INTO @IndexId, @Index_Name

--loop through indexes
WHILE @@FETCH_STATUS = 0
begin

declare @SQL_String varchar(256)
set @SQL_String = 'drop index '
set @SQL_String = @SQL_String + @Table_Name + '.' + @Index_Name

set @SQL_String = @SQL_String + ';create '

if( (select INDEXPROPERTY ( OBJECT_ID(@Table_Name) , @Index_Name , 'IsUnique')) =1)
set @SQL_String = @SQL_String + 'unique '

if( (select INDEXPROPERTY ( OBJECT_ID(@Table_Name) , @Index_Name , 'IsClustered')) =1)
set @SQL_String = @SQL_String + 'clustered '

set @SQL_String = @SQL_String + 'index '
set @SQL_String = @SQL_String + @Index_Name
set @SQL_String = @SQL_String + ' on '
set @SQL_String = @SQL_String + @Table_Name

set @SQL_String = @SQL_String + '('

--form column list 
SET @IndexKey = 1

-- Loop through index columns, INDEX_COL can be from 1 to 16.
WHILE @IndexKey <= 16 and INDEX_COL(@Table_Name, @IndexId, @IndexKey)
IS NOT NULL
BEGIN

IF @IndexKey != 1
set @SQL_String = @SQL_String + ','

set @SQL_String = @SQL_String + index_col(@Table_Name, @IndexId, @IndexKey) 

SET @IndexKey = @IndexKey + 1
END

set @SQL_String = @SQL_String + ')'

print @SQL_String
EXEC (@SQL_String)

FETCH NEXT FROM Index_Cursor
INTO @IndexId, @Index_Name 
end 

CLOSE Index_Cursor
DEALLOCATE Index_Cursor 



--loop through unique constraints
DECLARE Contraint_Cursor CURSOR FOR
select indid, name from sysindexes
where id = OBJECT_ID(@Table_Name) and indid > 0 and indid < 255 and (status & 64)=0 and 
exists( Select top 1 NULL from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
where TABLE_NAME = @Table_Name AND CONSTRAINT_TYPE = 'UNIQUE' and CONSTRAINT_NAME = name) 
order by indid

OPEN Contraint_Cursor 
FETCH NEXT FROM Contraint_Cursor
INTO @IndexId, @Index_Name

--loop through indexes
WHILE @@FETCH_STATUS = 0
begin

set @SQL_String = 'alter table '
set @SQL_String = @SQL_String + @Table_Name
set @SQL_String = @SQL_String + ' drop constraint '
set @SQL_String = @SQL_String + @Index_Name

set @SQL_String = @SQL_String + '; alter table '
set @SQL_String = @SQL_String + @Table_Name
set @SQL_String = @SQL_String + ' WITH NOCHECK add constraint '
set @SQL_String = @SQL_String + @Index_Name 
set @SQL_String = @SQL_String + ' unique '

if( (select INDEXPROPERTY ( OBJECT_ID(@Table_Name) , @Index_Name , 'IsClustered')) =1)
set @SQL_String = @SQL_String + 'clustered ' 

set @SQL_String = @SQL_String + '('

--form column list 
SET @IndexKey = 1

-- Loop through index columns, INDEX_COL can be from 1 to 16.
WHILE @IndexKey <= 16 and INDEX_COL(@Table_Name, @IndexId, @IndexKey)
IS NOT NULL
BEGIN

IF @IndexKey != 1
set @SQL_String = @SQL_String + ','

set @SQL_String = @SQL_String + index_col(@Table_Name, @IndexId, @IndexKey) 

SET @IndexKey = @IndexKey + 1
END

set @SQL_String = @SQL_String + ')'

print @SQL_String
EXEC (@SQL_String)

FETCH NEXT FROM Contraint_Cursor
INTO @IndexId, @Index_Name 
end 

CLOSE Contraint_Cursor
DEALLOCATE Contraint_Cursor

FETCH NEXT FROM Table_Cursor
INTO @Table_Name
end

CLOSE Table_Cursor
DEALLOCATE Table_Cursor

print ''
print 'Finished, Please check output for errors.'
====================
