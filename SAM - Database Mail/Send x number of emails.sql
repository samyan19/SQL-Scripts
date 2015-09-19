declare --@profile_name nvarchar(100)=
    @profile_name nvarchar(100)= 'Ghost_RCSTVMAN07',
    @recipients nvarchar(100)= 'KPMGOutlookTest@hotmail.com',
    @body nvarchar(100)= 'Test Email 00',
    @subject nvarchar(100)= 'Test 00' ;

declare @sql nvarchar(4000)='EXEC msdb.dbo.sp_send_dbmail '
declare @sql2 nvarchar(4000)=''

declare @count int=1

while @count<=3500
begin

set @sql2=@sql+'@profile_name='''+@profile_name+''','+'@recipients='''+@recipients+''','+'@body='''+@body+cast(@count as varchar(5))+''','+'@subject='''+@subject+cast(@count as varchar(5))+'''';
SET @sql2=@sql2+',@exclude_query_output=1'

exec(@sql2);

set @count=@count+1;
end







