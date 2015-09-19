--Turn off annoying rowcount
SET NOCOUNT ON
 
--Some variables
declare @v_restore varchar(1000)
declare @v_backup varchar(1000)
declare @v_sql varchar(max)
declare @datadir varchar(1000)
declare @logdir varchar(1000)
 
--Set backup file location, database name
set @v_backup = 'C:\demo\test.bak'
set @v_restore='Test_demo'
set @datadir = 'C:\Restore\Data'
set @logdir = 'C:\Restore\Log'
 
--Storage table
 
declare @restorelist table
(LogicalName nvarchar(128)
,PhysicalName nvarchar(260)
,Type char(1)
,FileGroupName nvarchar(128)
,Size numeric(20,0)
,MaxSize numeric(20,0)
,Fileid tinyint
,CreateLSN numeric(25,0)
,DropLSN numeric(25, 0)
,UniqueID uniqueidentifier
,ReadOnlyLSN numeric(25,0)
,ReadWriteLSN numeric(25,0)
,BackupSizeInBytes bigint
,SourceBlocSize int
,FileGroupId int
,LogGroupGUID uniqueidentifier
,DifferentialBaseLSN numeric(25,0)
,DifferentialBaseGUID uniqueidentifier
,IsReadOnly bit
,IsPresent bit
,TDEThumbprint varchar(100)) --Be careful, this last field (TDEThumbprint) isn’t in 2k5
 
--Capture the file list
insert into @restorelist
exec('RESTORE FILELISTONLY FROM DISK='''+@v_backup+'''')
 
--Build your restore command
select @v_sql = 'RESTORE DATABASE '+@v_restore+' '+char(10)+'FROM DISK=''' +@v_backup+ ''''+ CHAR(10)+'WITH '
select @v_sql = coalesce(@v_sql,'')+'MOVE '''+logicalname +
''' TO '''+CASE when type='L' then @logdir else @datadir end +'\'+ right(physicalname,charindex('\',reverse(physicalname))-1)+''',' + char(10)
from @restorelist
 
--display the restore command, trim trailing comma and char(10)
print substring(@v_sql,1,LEN(@v_sql)-2)