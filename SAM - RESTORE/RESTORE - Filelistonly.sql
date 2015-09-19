RESTORE FILELISTONLY from disk=N'\\pl3sqlc01ext.bestlive.bestinvest.co.uk\Backup\Bestinvestdb.bak'

/*
Insert results into table
*/
declare @fileListTable table
(
ID int identity(1,1),
LogicalName nvarchar(128)
,PhysicalName nvarchar(260)
,Type char(1)
,FileGroupName nvarchar(128)
,Size numeric(20,0)
,MaxSize numeric(20,0),
FileId tinyint,
CreateLSN numeric(25,0),
DropLSN numeric(25, 0),
UniqueID uniqueidentifier,
ReadOnlyLSN numeric(25,0),
ReadWriteLSN numeric(25,0),
BackupSizeInBytes bigint,
SourceBlockSize int,
FileGroupId int,
LogGroupGUID uniqueidentifier,
DifferentialBaseLSN numeric(25,0),
DifferentialBaseGUID uniqueidentifier,
IsReadOnly bit,
IsPresent bit,
TDEThumbprint varbinary(32)
)


insert @fileListTable
EXEC ('restore filelistonly from disk = ''' + @backupfile + '''')