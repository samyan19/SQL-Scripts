/*
    DESCRIPTION: Lists all SSIS packages deployed to the MSDB database.
    WRITTEN BY: Valentino Vranken
    VERSION: 1.1
    COPIED FROM: http://blog.hoegaerden.be

    Note: this query was written for SQL Server 2008. For SQL2005:
        o sysssispackagefolders => sysdtspackagefolders90
        o sysssispackages => sysdtspackages90
        o For packages stored in msdb only!
*/
with ChildFolders
as
(
    select PARENT.parentfolderid, PARENT.folderid, PARENT.foldername,
        cast('' as sysname) as RootFolder,
        cast(PARENT.foldername as varchar(max)) as FullPath,
        0 as Lvl
    from msdb.dbo.sysssispackagefolders PARENT
    where PARENT.parentfolderid is null
    UNION ALL
    select CHILD.parentfolderid, CHILD.folderid, CHILD.foldername,
        case ChildFolders.Lvl
            when 0 then CHILD.foldername
            else ChildFolders.RootFolder
        end as RootFolder,
        cast(ChildFolders.FullPath + '/' + CHILD.foldername as varchar(max))
            as FullPath,
        ChildFolders.Lvl + 1 as Lvl
    from msdb.dbo.sysssispackagefolders CHILD
        inner join ChildFolders on ChildFolders.folderid = CHILD.parentfolderid
)
select F.RootFolder, F.FullPath, P.name as PackageName,
    P.description as PackageDescription, P.packageformat, P.packagetype,
    P.vermajor, P.verminor, P.verbuild, P.vercomments,
    cast(cast(P.packagedata as varbinary(max)) as xml) as PackageData
from ChildFolders F
    inner join msdb.dbo.sysssispackages P on P.folderid = F.folderid
order by F.FullPath asc, P.name asc;


/* EXCLUDING DATA COLLECTOR ETC...

select F.RootFolder, F.FullPath, P.name as PackageName,
    P.description as PackageDescription, P.packageformat, P.packagetype,
    P.vermajor, P.verminor, P.verbuild, P.vercomments,
    cast(cast(P.packagedata as varbinary(max)) as xml) as PackageData
from ChildFolders F
    inner join msdb.dbo.sysssispackages P on P.folderid = F.folderid
where F.RootFolder <> 'Data Collector'
order by F.FullPath asc, P.name asc;
*/