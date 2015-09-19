set nocount on
DECLARE @test varchar(20), @key varchar(100)
if charindex('\',@@servername,0) <>0
begin
set @key = 'SOFTWARE\MICROSOFT\Microsoft SQL Server\'
+@@servicename+'\MSSQLServer\Supersocketnetlib\TCP'
end
else
begin
set @key = 'SOFTWARE\MICROSOFT\MSSQLServer\MSSQLServer\Supersocketnetlib\TCP'
end

EXEC master..xp_regread @rootkey='HKEY_LOCAL_MACHINE',
@key=@key,@value_name='Tcpport',@value=@test OUTPUT


SELECT 'Server Name: '+@@servername + ' Port Number:'+convert(varchar(10),@test)


