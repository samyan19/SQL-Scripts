/*Generate scripts to alter database paths for mdfs*/

select	'alter database '+DB_NAME(dbid)+' modify file (name='+ name+',filename=''I:\Databases\'+RIGHT(filename, CHARINDEX('\', REVERSE(filename)) - 1)+''')'
from	sys.sysaltfiles
where	(filename like '%.mdf' or filename like '%.ndf')
and		DB_NAME(dbid) not in ('master','model','msdb','tempdb')

/*Generate scripts to alter database paths for ldfs*/

select	'alter database '+DB_NAME(dbid)+' modify file (name='+ name+',filename=''S:\Logs\'+RIGHT(filename, CHARINDEX('\', REVERSE(filename)) - 1)+''')'
from	sys.sysaltfiles
where	filename like '%.ldf'
and		DB_NAME(dbid) not in ('master','model','msdb','tempdb')
