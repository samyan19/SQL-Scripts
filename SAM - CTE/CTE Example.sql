DECLARE @tableHTML  NVARCHAR(MAX) ;
Declare @DayofWeek	NVARCHAR(MAX)
SET @DayofWeek = DATENAME(DW,GETDATE())
if @DayofWeek = 'Monday'
	Begin
		DECLARE @FileDate nvarchar(12) SET @FileDate = convert(Varchar(4),datepart(YY,dateadd(d,-3,getdate())))
							+Substring(convert(varchar(11),convert(datetime,dateadd(d,-3,getdate())),102),6,2)
							+Substring(convert(varchar(11),convert(datetime,dateadd(d,-3,getdate())),102),9,2)
		DECLARE @FileDate1 nvarchar(12) SET @FileDate1 = convert(Varchar(4),datepart(YY,dateadd(d,-2,getdate())))
							+Substring(convert(varchar(11),convert(datetime,dateadd(d,-2,getdate())),102),6,2)
							+Substring(convert(varchar(11),convert(datetime,dateadd(d,-2,getdate())),102),9,2)
		DECLARE @FileName nvarchar(40) SET @FileName = 'GWP_BESTINVEST_Out_%_' + @FileDate + '.out';
	End
Else
	Begin
	
		SET @FileDate = convert(Varchar(4),datepart(YY,dateadd(d,-1,getdate())))
							+Substring(convert(varchar(11),convert(datetime,dateadd(d,-1,getdate())),102),6,2)
							+Substring(convert(varchar(11),convert(datetime,dateadd(d,-1,getdate())),102),9,2)
		SET @FileDate1 = convert(Varchar(4),datepart(YY,dateadd(d,0,getdate())))
							+Substring(convert(varchar(11),convert(datetime,dateadd(d,0,getdate())),102),6,2)
							+Substring(convert(varchar(11),convert(datetime,dateadd(d,0,getdate())),102),9,2)
		SET @FileName = 'GWP_BESTINVEST_Out_%_' + @FileDate + '.out';
	End
--print @FileName
DECLARE @List TABLE 
		(
			ProcessName NVARCHAR(100),
			Ord int,
			Status	NVARCHAR(100),
			StartTime	datetime,
			EndTime	datetime,
			Exceptions int
		);
		with a
			as
			(
				Select 'GWP_BESTINVEST_Out_Reference_'+@FileDate+'.out' as SEIFile--, 'UnProcessed' as Status
				union
				Select 'GWP_BESTINVEST_Out_Assets_'+@FileDate+'.out' as SEIFile--, 'UnProcessed' as Status
				union
				Select 'GWP_BESTINVEST_Out_PortfolioGroups_'+@FileDate+'.out' as SEIFile--, 'UnProcessed' as Status
				union
				Select 'GWP_BESTINVEST_Out_Clients_'+@FileDate+'.out' as SEIFile--, 'UnProcessed' as Status
				union
				Select 'GWP_BESTINVEST_Out_Accounts_'+@FileDate+'.out' as SEIFile--, 'UnProcessed' as Status
				union
				Select 'GWP_BESTINVEST_Out_ClientAccountLink_'+@FileDate+'.out' as SEIFile--, 'UnProcessed' as Status
				union
				Select 'GWP_BESTINVEST_Out_Transactions_'+@FileDate+'.out' as SEIFile--, 'UnProcessed' as Status
				union
				Select 'GWP_BESTINVEST_Out_EODPositions_'+@FileDate+'.out' as SEIFile--, 'UnProcessed' as Status
				union
				Select 'GWP_BESTINVEST_Out_PaidTo_'+@FileDate+'.out' as SEIFile--, 'UnProcessed' as Statu
			),b
			as
			(
			Select F.SEIFile, min(v.UpdateDate) as StartTime, max(v.UpdateDate) as EndTime
			from MESSAGING.SEIFileLog(NoLock) L
			JOIN MESSAGING.SEIFile(NoLock) F ON F.SeiFileId = L.SeiFileId
			JOIN MESSAGING.SEIStatus(NoLock) S ON S.SEIStatusID = L.SEIStatusID
			Join Messaging.SEIOvernight(NoLock) x ON f.SEIFileID = x.SEItoBIFileID
			Join MESSAGING.SEIDataLog(NoLock) v on  v.SEIOvernightID = x.SEIOvernightID
			Group by F.SEIFile, L.SEIStatusID
			having F.SEIFILE like @FileName and L.SEIStatusID IN (9)
			),x
			as
			(
			Select F.SEIFile, Count(v.SEIStatusID) as Exceptions
			from MESSAGING.SEIFileLog(NoLock) L
			JOIN MESSAGING.SEIFile(NoLock) F ON F.SeiFileId = L.SeiFileId
			JOIN MESSAGING.SEIStatus(NoLock) S ON S.SEIStatusID = L.SEIStatusID
			Join Messaging.SEIOvernight(NoLock) x ON f.SEIFileID = x.SEItoBIFileID
			Join MESSAGING.SEIDataLog(NoLock) v on  v.SEIOvernightID = x.SEIOvernightID
			Group by F.SEIFile, L.SEIStatusID,v.SEIStatusID
			having F.SEIFILE like @FileName and L.SEIStatusID IN (9) and v.SEIStatusID = 4
			),c
			as
			(
				Select 'File - Outbound file import-processed' as SEIFile
			)
			,d
			as
			(
				Select s.SEIStatus as SEIFile, min(l.UpdateDate) as StartTime, max(l.UpdateDate) as EndTime
				from MESSAGING.SEIFileLog(NoLock) L
				JOIN MESSAGING.SEIStatus(NoLock) S ON S.SEIStatusID = L.SEIStatusID
				where s.SEIStatus like 'File - Outbound file import-processed' and L.SEIStatusID IN (11) and 
					convert(Varchar(4),datepart(YY,L.UpdateDate))
						+Substring(convert(varchar(11),convert(datetime,L.UpdateDate),102),6,2)
						+Substring(convert(varchar(11),convert(datetime,L.UpdateDate),102),9,2) = @FileDate1
				group by s.SEIStatus
			),e
			as
			(
			select a.SEIFile as ProcessName, case when a.SEIFile not in (Select SEIFile from b) then 'UnProcessed' else 'Processed' End as Status, b.StartTime, b.EndTime, isnull(x.Exceptions,0) as Exceptions
			from a
			left outer join b on a.SEIFile = b.SEIFile
			left outer join x on a.SEIFile = x.SEIFile
			union
			select 'Daily- Fix Asset Data' as ProcessName, case when c.SEIFile not in (Select SEIFile from d) then 'UnProcessed' else 'Processed' End as Status, d.StartTime, d.EndTime, isnull(x.Exceptions,0) as Exceptions
			from c
			left outer join d on c.SEIFile = d.SEIFile
			left outer join x on c.SEIFile = x.SEIFile
			)
			Insert into @List 
			Select ProcessName,case when ProcessName like '%Reference%' then 1
							when ProcessName like '%Assets%' then 2
							when ProcessName like '%PortfolioGroups%' then 3
							when ProcessName like '%Clients%' then 4
							when ProcessName like '%Accounts%' then 5
							when ProcessName like '%ClientAccountLink%' then 6
							when ProcessName like '%Transactions%' then 7
							when ProcessName like '%EODPositions%' then 8
							when ProcessName like '%PaidTo%' then 9
							when ProcessName like '%Daily%' then 10 end as Ord, Status, StartTime, EndTime, Exceptions 
			from e 
			order by ord 

SET @tableHTML =
    N'<H1>Daily Services Status Report</H1>' +
    N'<table border="1" BORDERCOLOR=blue>' +
    N'<tr><th>Process Name</th><th>Status</th>' +
    N'<th>Start Time</th>' +
	N'<th>End Time</th>' +
	N'<th>No Of Exceptions</th>' +
    CAST ( (
			 SELECT td = ProcessName,       '',
                    td = [Status], '',
					td = StartTime, '',
					 td = EndTime, '', 
					td = Exceptions from @List
              FOR XML PATH('tr'), TYPE 
    ) AS NVARCHAR(MAX) ) +
    N'</table>' ;
--print @tableHTML
if @DayofWeek = 'Saturday'
	Begin
		EXEC msdb.dbo.sp_send_dbmail @recipients='Alex.Knott@bestinvest.co.uk;dg_Data@bestinvest.co.uk;dg_Web@bestinvest.co.uk;Daniel.Hayzelden@bestinvest.co.uk;Donald.Reid@bestinvest.co.uk;elizabeth.paradine@bestinvest.co.uk;Tajinder.dogra@gmail.com;Richard.Belli@yahoo.co.uk;Kojof@hotmail.com;psa_home@yahoo.co.uk;Narendrakumar.nk@gmail.com',
		--EXEC msdb.dbo.sp_send_dbmail @recipients='jayesh.patel@bestinvest.co.uk',
			@subject = 'Daily Processes Status',
			@body = @tableHTML,
			@body_format = 'HTML' ;
		
		--EXEC msdb.dbo.sp_send_dbmail @recipients='Tajinder.dogra@gmail.com;Richard.Belli@yahoo.co.uk;',
		--EXEC msdb.dbo.sp_send_dbmail @recipients='jayesh.patel@bestinvest.co.uk',
			--@subject = 'Daily Processes Status',
			--@body = @tableHTML,
			--@body_format = 'HTML' ;
	End
Else
	Begin
		EXEC msdb.dbo.sp_send_dbmail @recipients='Alex.Knott@bestinvest.co.uk;dg_Data@bestinvest.co.uk;dg_Web@bestinvest.co.uk;Daniel.Hayzelden@bestinvest.co.uk;Donald.Reid@bestinvest.co.uk;elizabeth.paradine@bestinvest.co.uk',
		--EXEC msdb.dbo.sp_send_dbmail @recipients='jayesh.patel@bestinvest.co.uk',
			@subject = 'Daily Processes Status',
			@body = @tableHTML,
			@body_format = 'HTML' ;
	End