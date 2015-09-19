--Review output of dbo.sysprocesses

SELECT spid

,dbid

,uid

,status

,sql_handle

,waittype

,waittime

,lastwaittype

,cmd

,hostname

,program_name

,nt_domain

,nt_username

,loginame

FROM master.dbo.sysprocesses

WHERE waittype IN (0x040, 0x0040)

AND lastwaittype = 'RESOURCE_SEMAPHORE'