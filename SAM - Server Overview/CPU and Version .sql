declare @ver nvarchar(128)
set @ver=cast(SERVERPROPERTY('ProductVersion') as nvarchar)

select cpu_count, 
case 
when @ver like '11%' then 'SQL Server 2012'
when @ver like '10.5%' then 'SQL Server 2008 R2'
when @ver like '10%' then 'SQL Server 2008'
when @ver like '9%' then 'SQL Server 2005'
when @ver like '8%' then 'SQL Server 2000' end as 'Version',
SERVERPROPERTY('edition') as Edition,
SERVERPROPERTY('productlevel') as SPLevel
 from sys.dm_os_sys_info
