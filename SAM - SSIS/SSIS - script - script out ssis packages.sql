/*Export All Packages to FileSystem*/
select 'DTUTIL /SQL '+f.foldername+'/'+name+' /COPY FILE;G:\MSSQL10_50.MSSQLSERVER\MSSQL\Backup\SSIS\'+name+'.DTSX /QUIET'
from msdb.dbo.sysssispackages p
join dbo.sysssispackagefolders f on p.folderid=f.folderid
where f.foldername='BGB_Synergy'


/*Import All Packages from File*/
select 'DTUTIL /file G:\MSSQL10_50.MSSQLSERVER\MSSQL\Backup\SSIS\'+name+'.DTSX /copy sql;'+f.foldername+'/'+name+' /quiet'
from msdb.dbo.sysssispackages p
join dbo.sysssispackagefolders f on p.folderid=f.folderid
where f.foldername='BGB_Synergy'