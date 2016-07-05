    if exists (select * from tempdb.sys.tables where name like '#Errorlog%') 
        drop table #Errorlog;

    create table #ErrorLog 
    ( 
        LogDate datetime, 
        ProcessInfo nvarchar(16), 
        [Text] nvarchar(2048) 
    ) 
    go

    declare @p1 nvarchar(64); 
    declare @p2 nvarchar(64); 
    declare @logNum int; 
    declare @NumErrorLogs int;

    -- add search conditions here 
    select @p1 = null; 
    select @p2 = null; 
    
    --get the value of max errorlogs from registry 
    exec master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer', N'NumErrorLogs', @NumErrorLogs OUTPUT

    -- init counter 
    set @logNum = 0;

    while (@logNum <= @NumErrorLogs) 
     begin 
        declare @exists int 
        --exec xp_fileexist 'c:\windows\notepad.exe', @exists out 
        --if (@exists = 1) 
        --    begin 
            insert into #Errorlog 
                exec xp_readerrorlog @logNum, 1, @p1, @p2 
            --end 
        select @logNum = (@logNum + 1); 
     end

    select min(logdate) as mindate
	 from #ErrorLog
	where text like 'BACKUP DATABASE%'
	group by cast(logdate as date)
	order by mindate desc


	drop table #ErrorLog
