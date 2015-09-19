use master
go
if exists (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_NAME = 'sp_What_To_Compress') 
	drop procedure sp_What_To_Compress;
go
/*============================================================
--http://www.SQLBalls.com
--@SQLBalls: bball@pragmaticworks.com
--What_To_Compress_V2
--

This Sample Code is provided for the purpose of illustration only and is not intended
to be used in a production environment.  THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.

Feel free to use the scripts below, but you must give credit where it is due
leave the header at the top as a referece.  Not for use in commercial purposes without express consent of the owner.

2/14/2014 BTB-This version will run against any database that you execute the stored procedure in.  It will provide the count of In_ROW_DATA, ROW_OVERFLOW_DATA, and LOB_DATA, the Scan and Update Patterns for the tables or indexes, Recommend a compression level setting, and provide a description for that setting.

4/22/2014 BTB-This version has the @pageCount parameter.  This is so you can determine what the threshold is for tables you want to compress.  Thanks to Roger Wolter for the Feedback!

5/22/2014 BTB-Added % Compressible and % Uncompressible columns for in order to further highlight how allocation units and their make up of your tables should limit the type of compression that you use.

PARAMETER DESCRIPTION:

@pageCount - Determines the threshold for the number of pages that you want to compress in an object.  If set to 0 will evaluate all tables in a database.

SCRIPT DESCRIPTION:
This script is intentded to take a usage based look at a database and review the objects inside the database and evaluate if they should be compressed or not.  It will evaluate your Allocation Units, Scans, and Updates for objects by partition and will offer a recommendation for compression, which level, and why.


==============================================================*/
create proc sp_What_To_Compress
	@execute char(1)='N',
	@mintablesize int=0
as

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

declare @recommendations TABLE (
	[ID]int identity(1,1),
	[SchemaName] [sysname] NOT NULL,
	[ObjectName] [nvarchar](128) NULL,
	[IndexName] [sysname] NULL,
	[IndexID] [int] NOT NULL,
	[Partition_Number] [int] NOT NULL,
	[In_Row_Data] [bigint] NOT NULL,
	[Row_Overflow_Data] [bigint] NOT NULL,
	[Lob_Data] [bigint] NOT NULL,
	[Compressible Data] [varchar](1000) NULL,
	[UnCompressible Data] [varchar](1000) NULL,
	[ReadPercent] [decimal](13, 2) NULL,
	[ReadDescription] [varchar](21) NOT NULL,
	[UpdatePercent] [decimal](13, 2) NULL,
	[UpdateDescription] [varchar](23) NOT NULL,
	[size_KB] [bigint] NULL,
	[Size_MB] [bigint] NULL,
	[RecCompSetting] [varchar](5) NULL,
	[Recommendations] [varchar](2208) NULL,
	[Statement] [nvarchar](445) NULL
)


declare @pageCount int


set @pageCount=8

insert @recommendations
select 
	SchemaName
	,ObjectName
	,IndexName
	,IndexID
	,Partition_Number
	,In_Row_Data
	,Row_Overflow_Data
	,Lob_Data
	,case In_Row_Data
	when 0 then '0.00%'
	else cast(cast((In_Row_Data*100.0/(Row_Overflow_Data+Lob_Data+In_Row_Data))as decimal(13,2)) as varchar(1000))
	end as 'Compressible Data'
,case
		when (Lob_Data + Row_Overflow_Data)=0 then '0.00%'
		else cast(cast(((Lob_Data+Row_Overflow_Data)*100.0/(Row_Overflow_Data+Lob_Data+In_Row_Data))as decimal(13,2)) as varchar(1000))
	end as 'UnCompressible Data'
	,ScanPercent as ReadPercent
	,case 
		when ((cast(scanPercent as int))>=60) then 'High Level of Reads'
		when (ScanPercent)>40 and (scanPercent)<60 then'Medium Level of Reads'
		else 'Low Level of Reads'
	end as ReadDescription
	,UpdatePercent
	,case 
		when ((cast(UpdatePercent as int))>=60) then 'High Level of Updates'
		when (UpdatePercent)>40 and (UpdatePercent)<60 then'Medium Level of Updates'
		else 'Low Level of Writes'
	end as UpdateDescription
	,size_KB
	,Size_MB
	,case
		When (In_Row_Data>=Row_Overflow_Data) and (In_Row_Data>=Lob_Data) then
			case
				when (In_Row_Data+Row_Overflow_Data+Lob_Data)<@pageCount then 'None'
				when (In_Row_Data+Row_Overflow_Data+Lob_Data)>=@pageCount Then
					case
						when (Row_Overflow_Data+Lob_Data)=0 and In_Row_Data>0 then 
						case
										when (ScanPercent)>=65 and (UpdatePercent)<=30 then 'PAGE'
										when (ScanPercent)>=65 and (UpdatePercent)<=50 and (UpdatePercent)>=31 then 'PAGE'
									    when (ScanPercent)>=65 and (UpdatePercent)<=100 and (UpdatePercent)>=51 then 'None'
										When (ScanPercent)>=45 and (ScanPercent)<=64 and (UpdatePercent)<=30 Then 'ROW'
										When isnull(ScanPercent,0)=0 and isnull(UpdatePercent,0)=0 Then 'PAGE'
										else 'None'
										end 
						when (Row_Overflow_Data+Lob_Data)>1 then
							case 
								when (In_Row_Data*100.0/(Row_Overflow_Data+Lob_Data))>=65 then 
									case
										when (ScanPercent)>=65 and (UpdatePercent)<=30 then 'PAGE'
										when (ScanPercent)>=65 and (UpdatePercent)<=50 and (UpdatePercent)>=31 then 'PAGE'
									    when (ScanPercent)>=65 and (UpdatePercent)<=100 and (UpdatePercent)>=51 then 'None'
										When (ScanPercent)>=45 and (ScanPercent)<=64 and (UpdatePercent)<=30 Then 'ROW'
										else 'None'
										end 
									when (In_Row_Data*100.0/(Row_Overflow_Data+Lob_Data))<=64 and (In_Row_Data*100.0/(Row_Overflow_Data+Lob_Data))>=45 then 
										case
											when (ScanPercent)>=65 and (UpdatePercent)<=30 then 'PAGE'
											when (ScanPercent)>=65 and (UpdatePercent)<=50 and (UpdatePercent)>=31 then 'PAGE'
											when (ScanPercent)>=65 and (UpdatePercent)<=100 and (UpdatePercent)>=51 then 'None'
											When (ScanPercent)>=45 and (ScanPercent)<=64 and (UpdatePercent)<=30 Then 'ROW'
											else 'None'
											end 
										Else 
											case
												when (Row_Overflow_Data)<>0 and (Lob_Data)<>0 Then 'None'
												when (Row_Overflow_Data)=0 and (Lob_Data)<>0 Then 'None'
												when (Row_Overflow_Data)<>0 and (Lob_Data)=0 Then 'None'
												end
											end
										end 
									end
	When (In_Row_Data<=Row_Overflow_Data) and (In_Row_Data>=Lob_Data) then 
				case
					when (In_Row_Data+Row_Overflow_Data+Lob_Data)<@pageCount then 'None'
					when (In_Row_Data+Row_Overflow_Data+Lob_Data)>=@pageCount Then
						case
							when (Row_Overflow_Data)<>0 and (Lob_Data)<>0 Then 'None'
							when (Row_Overflow_Data)=0 and (Lob_Data)<>0 Then 'None'
							when (Row_Overflow_Data)<>0 and (Lob_Data)=0 Then 'None'
							end
						end
When (In_Row_Data>=Row_Overflow_Data) and (In_Row_Data<Lob_Data) then 
		case
				when (In_Row_Data+Row_Overflow_Data+Lob_Data)<@pageCount then 'None'
				when (In_Row_Data+Row_Overflow_Data+Lob_Data)>=@pageCount Then
					case
						when (Row_Overflow_Data)<>0 and (Lob_Data)<>0 Then 'None'
						when (Row_Overflow_Data)=0 and (Lob_Data)<>0 Then  'None'
						when (Row_Overflow_Data)<>0 and (Lob_Data)=0 Then  'None'
		end
	end
		else 'error'
	end as RecCompSetting
,case
		When (In_Row_Data>=Row_Overflow_Data) and (In_Row_Data>=Lob_Data) then
			case
				when (In_Row_Data+Row_Overflow_Data+Lob_Data)<@pageCount then 'Do Not Compress.  You may see minimal performance gain by compressing Heaps, Clustered Indexes, or Non-Clustered Indexes with less than ' + cast(@pageCount as varchar(50)) + ' Pages.'
				when (In_Row_Data+Row_Overflow_Data+Lob_Data)>=@pageCount Then
					case
						when (Row_Overflow_Data+Lob_Data)=0 and In_Row_Data>0 then 
						case
										when (ScanPercent)>=65 and (UpdatePercent)<=30 then 
											'The Percentage of Scan and Seek operations is ' + cast(isnull(ScanPercent,0) as varchar(6)) +'% and the average amount of Update operations is '+ cast(isnull(UpdatePercent,0) as varchar(6)) +'%.  Data that can be compressed makes up '+cast(cast((In_Row_Data*100.0/(Row_Overflow_Data+Lob_Data+In_Row_Data))as decimal(13,2)) as varchar(1000)) +'% of this table.  This table is an excellent candidate for Page Compression.  Test with sp_estimate_data_compression_savings.  Remember that it takes 5% of the tables size and moves it to tempDB.  Validate that you have enough room on your server to perform this operation before attempting.'
										when (ScanPercent)>=65 and (UpdatePercent)<=50 and (UpdatePercent)>=31 then 
											'The Percentage of Scan and Seek operations is ' + cast(isnull(ScanPercent,0) as varchar(6))  +'% and the average amount of Update operations is '+ cast(UpdatePercent as varchar(6)) +'%.  Data that can be compressed makes up '+cast(cast((In_Row_Data*100.0/(Row_Overflow_Data+Lob_Data+In_Row_Data))as decimal(13,2)) as varchar(1000)) +'% of this table.  This table is an medium candidate for Page Compression.  Test with sp_estimate_data_compression_savings.  Remember that it takes 5% of the tables size and moves it to tempDB.  Validate that you have enough room on your server to perform this operation before attempting.'
									    when (ScanPercent)>=65 and (UpdatePercent)<=100 and (UpdatePercent)>=51 then 
											'The Percentage of Scan and Seek operations is ' + cast(isnull(ScanPercent,0) as varchar(6))  +'% and the average amount of Update operations is '+ cast(UpdatePercent as varchar(6)) +'%.  Data that can be compressed makes up '+cast(cast((In_Row_Data*100.0/(Row_Overflow_Data+Lob_Data+In_Row_Data))as decimal(13,2)) as varchar(1000)) +'% of this table.  This table is an not a candidate for Compression.  The amount of Updates may adversley affect the query performance against the table.  If you still wish to proceece, test with sp_estimate_data_compression_savings.  Remember that it takes 5% of the tables size and moves it to tempDB.  Validate that you have enough room on your server to perform this operation before attempting.'
										When (ScanPercent)>=45 and (ScanPercent)<=64 and (UpdatePercent)<=30 Then
										'The Percentage of Scan and Seek operations is ' + cast(isnull(ScanPercent,0) as varchar(6))  +'% and the average amount of Update operations is '+ cast(isnull(UpdatePercent,0) as varchar(6)) +'%.   Data that can be compressed makes up '+cast(cast((In_Row_Data*100.0/(Row_Overflow_Data+Lob_Data+In_Row_Data))as decimal(13,2)) as varchar(1000)) +'% of this table.  This table is an excellent candidate for Row Compression.  If you apply Page Compression it will have a higher CPU cost because of the medium Seek and Scan Ratio.  Test with sp_estimate_data_compression_savings.  Remember that it takes 5% of the tables size and moves it to tempDB.  Validate that you have enough room on your server to perform this operation before attempting.'
										When isnull(ScanPercent,0)=0 and isnull(UpdatePercent,0)=0 Then
										'The Percentage of Scan and Seek operations is ' + cast(isnull(ScanPercent,0) as varchar(6))  +'% and the average amount of Update operations is '+ cast(isnull(UpdatePercent,0) as varchar(6)) +'%.  Data that can be compressed makes up '+cast(cast((In_Row_Data*100.0/(Row_Overflow_Data+Lob_Data+In_Row_Data))as decimal(13,2)) as varchar(1000)) +'% of this table.  There is no workload for the current table.  Please wait for the usage statistics to become representative of a typical work load.  If this is a typical work load, this is an excellent candidate for Page Compression.  Test with sp_estimate_data_compression_savings.  Remember that it takes 5% of the tables size and moves it to tempDB.  Validate that you have enough room on your server to perform this operation before attempting.'
										else
										'The Percentage of Scan and Seek operations is ' + cast(isnull(ScanPercent,0) as varchar(6))  +'% and the average amount of Update operations is '+ cast(UpdatePercent as varchar(6)) +'%.  Data that can be compressed makes up '+cast(cast((In_Row_Data*100.0/(Row_Overflow_Data+Lob_Data+In_Row_Data))as decimal(13,2)) as varchar(1000)) +'% of this table.  However Based on the workload of this server this table should not be compressed.  If you apply Row or Page Compression it will have a higher CPU cost because of the low Seek and Scan Ratio.  Test with sp_estimate_data_compression_savings.  Remember that it takes 5% of the tables size and moves it to tempDB.  Validate that you have enough room on your server to perform this operation before attempting.'
										end 
						when (Row_Overflow_Data+Lob_Data)>1 then
							case 
								when (In_Row_Data*100.0/(Row_Overflow_Data+Lob_Data))>=65 then 
									case
										when (ScanPercent)>=65 and (UpdatePercent)<=30 then 
											'The Percentage of Scan and Seek operations is ' + cast(ScanPercent as varchar(6)) +'% and the average amount of Update operations is '+ cast(isnull(UpdatePercent,0) as varchar(6)) +'%.  Data that can be compressed makes up '+cast(cast((In_Row_Data*100.0/(Row_Overflow_Data+Lob_Data+In_Row_Data))as decimal(13,2)) as varchar(1000)) +'% of this table.  This table is an excellent candidate for Page Compression.  Test with sp_estimate_data_compression_savings.  Remember that it takes 5% of the tables size and moves it to tempDB.  Validate that you have enough room on your server to perform this operation before attempting.'
										when (ScanPercent)>=65 and (UpdatePercent)<=50 and (UpdatePercent)>=31 then 
											'The Percentage of Scan and Seek operations is ' + cast(ScanPercent as varchar(6))  +'% and the average amount of Update operations is '+ cast(UpdatePercent as varchar(6)) +'%.  Data that can be compressed makes up '+cast(cast((In_Row_Data*100.0/(Row_Overflow_Data+Lob_Data+In_Row_Data))as decimal(13,2)) as varchar(1000)) +'% of this table.  This table is an medium candidate for Page Compression.  Test with sp_estimate_data_compression_savings.  Remember that it takes 5% of the tables size and moves it to tempDB.  Validate that you have enough room on your server to perform this operation before attempting.'
									    when (ScanPercent)>=65 and (UpdatePercent)<=100 and (UpdatePercent)>=51 then 
											'The Percentage of Scan and Seek operations is ' + cast(ScanPercent as varchar(6))  +'% and the average amount of Update operations is '+ cast(UpdatePercent as varchar(6)) +'%.  Data that can be compressed makes up '+cast(cast((In_Row_Data*100.0/(Row_Overflow_Data+Lob_Data+In_Row_Data))as decimal(13,2)) as varchar(1000)) +'% of this table.  This table is an not a candidate for Compression.  The amount of Updates may adversley affect the query performance against the table.  If you still wish to proceece, test with sp_estimate_data_compression_savings.  Remember that it takes 5% of the tables size and moves it to tempDB.  Validate that you have enough room on your server to perform this operation before attempting.'
										When (ScanPercent)>=45 and (ScanPercent)<=64 and (UpdatePercent)<=30 Then
										'The Percentage of Scan and Seek operations is ' + cast(ScanPercent as varchar(6))  +'% and the average amount of Update operations is '+ cast(isnull(UpdatePercent,0) as varchar(6)) +'%.   Data that can be compressed makes up '+cast(cast((In_Row_Data*100.0/(Row_Overflow_Data+Lob_Data+In_Row_Data))as decimal(13,2)) as varchar(1000)) +'% of this table.  This table is an excellent candidate for Row Compression.  If you apply Page Compression it will have a higher CPU cost because of the medium Seek and Scan Ratio.  Test with sp_estimate_data_compression_savings.  Remember that it takes 5% of the tables size and moves it to tempDB.  Validate that you have enough room on your server to perform this operation before attempting.'
										else
										'The Percentage of Scan and Seek operations is ' + cast(isnull(ScanPercent,0) as varchar(6))  +'% and the average amount of Update operations is '+ cast(isnull(UpdatePercent,0) as varchar(6)) +'%.  Data that can be compressed makes up '+cast(cast((In_Row_Data*100.0/(Row_Overflow_Data+Lob_Data+In_Row_Data))as decimal(13,2)) as varchar(1000)) +'% of this table.  However Based on the workload of this server this table should not be compressed.  If you apply Row or Page Compression it will have a higher CPU cost because of the low Seek and Scan Ratio.  Test with sp_estimate_data_compression_savings.  Remember that it takes 5% of the tables size and moves it to tempDB.  Validate that you have enough room on your server to perform this operation before attempting.'
										end 
									when (In_Row_Data*100.0/(Row_Overflow_Data+Lob_Data))<=64 and (In_Row_Data*100.0/(Row_Overflow_Data+Lob_Data))>=45 then 
										case
											when (ScanPercent)>=65 and (UpdatePercent)<=30 then 
											'The Percentage of Scan and Seek operations is ' + cast(ScanPercent as varchar(6)) +'% and the average amount of Update operations is '+ cast(isnull(UpdatePercent,0) as varchar(6)) +'%.  Data that can be compressed makes up '+cast(cast((In_Row_Data*100.0/(Row_Overflow_Data+Lob_Data+In_Row_Data))as decimal(13,2)) as varchar(1000)) +'% of this table.  This table is a candidate for Page Compression.  Keep in mind that the data that cannot be compressed in this table is sizable and it may cause addition CPU overhead.  Test with sp_estimate_data_compression_savings.  Remember that it takes 5% of the tables size and moves it to tempDB.  Validate that you have enough room on your server to perform this operation before attempting.'
											when (ScanPercent)>=65 and (UpdatePercent)<=50 and (UpdatePercent)>=31 then 
											'The Percentage of Scan and Seek operations is ' + cast(ScanPercent as varchar(6))  +'% and the average amount of Update operations is '+ cast(UpdatePercent as varchar(6)) +'%.  Data that can be compressed makes up '+cast(cast((In_Row_Data*100.0/(Row_Overflow_Data+Lob_Data+In_Row_Data))as decimal(13,2)) as varchar(1000)) +'% of this table.  This table is an  candidate for Page Compression.  Keep in mind that the data that cannot be compressed in this table is sizable and it may cause addition CPU overhead. Test with sp_estimate_data_compression_savings.  Remember that it takes 5% of the tables size and moves it to tempDB.  Validate that you have enough room on your server to perform this operation before attempting.'
											when (ScanPercent)>=65 and (UpdatePercent)<=100 and (UpdatePercent)>=51 then 
											'The Percentage of Scan and Seek operations is ' + cast(ScanPercent as varchar(6))  +'% and the average amount of Update operations is '+ cast(UpdatePercent as varchar(6)) +'%.  Data that can be compressed makes up '+cast(cast((In_Row_Data*100.0/(Row_Overflow_Data+Lob_Data+In_Row_Data))as decimal(13,2)) as varchar(1000)) +'% of this table.  This table is an not a candidate for Compression.  Keep in mind that the data that cannot be compressed in this table is sizable and it may cause addition CPU overhead. The amount of Updates may adversley affect the query performance against the table.  If you still wish to proceece, test with sp_estimate_data_compression_savings.  Remember that it takes 5% of the tables size and moves it to tempDB.  Validate that you have enough room on your server to perform this operation before attempting.'
											When (ScanPercent)>=45 and (ScanPercent)<=64 and (UpdatePercent)<=30 Then
										'The Percentage of Scan and Seek operations is ' + cast(ScanPercent as varchar(6))  +'% and the average amount of Update operations is '+ cast(isnull(UpdatePercent,0) as varchar(6)) +'%.   Data that can be compressed makes up '+cast(cast((In_Row_Data*100.0/(Row_Overflow_Data+Lob_Data+In_Row_Data))as decimal(13,2)) as varchar(1000)) +'% of this table.  This table is an  candidate for Row Compression. Keep in mind that the data that cannot be compressed in this table is sizable and it may cause addition CPU overhead. If you apply Page Compression it will have a higher CPU cost because of the medium Seek and Scan Ratio.  Test with sp_estimate_data_compression_savings.  Remember that it takes 5% of the tables size and moves it to tempDB.  Validate that you have enough room on your server to perform this operation before attempting.'
											else
										'The Percentage of Scan and Seek operations is ' + cast(isnull(ScanPercent,0) as varchar(6))  +'% and the average amount of Update operations is '+ cast(isnull(UpdatePercent,0) as varchar(6)) +'%.  Data that can be compressed makes up '+cast(cast((In_Row_Data*100.0/(Row_Overflow_Data+Lob_Data+In_Row_Data))as decimal(13,2)) as varchar(1000)) +'% of this table.  However Based on the workload of this server this table should not be compressed.  If you apply Row or Page Compression it will have a higher CPU cost because of the low Seek and Scan Ratio.  Test with sp_estimate_data_compression_savings.  Remember that it takes 5% of the tables size and moves it to tempDB.  Validate that you have enough room on your server to perform this operation before attempting.'
											end 
										Else 
											case
												when (Row_Overflow_Data)<>0 and (Lob_Data)<>0 Then 
										('The amount of Uncompressible data in this table does not make it a match for compression.  Data that can be compressed makes up '+cast(cast((In_Row_Data*100.0/(Row_Overflow_Data+Lob_Data+In_Row_Data))as decimal(13,2)) as varchar(1000)) +'% of this table.  While data that cannot be compressed makes up '+ cast(cast(((Row_Overflow_Data+Lob_Data)*100.0/100.0)as decimal(13,2)) as varchar(1000)) + '% of this table.')
												when (Row_Overflow_Data)=0 and (Lob_Data)<>0 Then 
										('The amount of Uncompressible data in this table does not make it a match for compression.  Data that can be compressed makes up '+cast(cast((In_Row_Data*100.0/(Row_Overflow_Data+Lob_Data+In_Row_Data))as decimal(13,2)) as varchar(1000)) +'% of this table.  While data that cannot be compressed makes up '+ cast(cast((Lob_Data*100.0/(Row_Overflow_Data+Lob_Data+In_Row_Data)) as decimal(13,2)) as varchar(1000)) + '% of this table.')
												when (Row_Overflow_Data)<>0 and (Lob_Data)=0 Then 
											('The amount of Uncompressible data in this table does not make it a match for compression.  Data that can be compressed makes up '+cast(cast((In_Row_Data*100.0/(Row_Overflow_Data+Lob_Data+In_Row_Data))as decimal(13,2)) as varchar(1000)) +'% of this table.  While data that cannot be compressed makes up '+ cast(cast((Row_Overflow_Data*100.0/(Row_Overflow_Data+Lob_Data+In_Row_Data)) as decimal(13,2)) as varchar(1000)) + '% of this table.')
												end
											end
										end 
									end
	When (In_Row_Data<=Row_Overflow_Data) and (In_Row_Data>=Lob_Data) then 
				case
					when (In_Row_Data+Row_Overflow_Data+Lob_Data)<@pageCount then 'Do Not Compress.  You may see minimal performance gain by compressing Heaps, Clustered Indexes, or Non-Clustered Indexes with less than ' + cast(@pageCount as varchar(50)) + ' Pages.'
					when (In_Row_Data+Row_Overflow_Data+Lob_Data)>=@pageCount Then
						case
							when (Row_Overflow_Data)<>0 and (Lob_Data)<>0 Then 
										('The amount of Uncompressible data in this table does not make it a match for compression.  Data that can be compressed makes up '+cast(cast((In_Row_Data*100.0/(Row_Overflow_Data+Lob_Data+In_Row_Data))as decimal(13,2)) as varchar(1000)) +'% of this table.  While data that cannot be compressed makes up '+ cast(cast(((Row_Overflow_Data+Lob_Data)*100.0/100.0)as decimal(13,2)) as varchar(1000)) + '% of this table.')
							when (Row_Overflow_Data)=0 and (Lob_Data)<>0 Then 
										('The amount of Uncompressible data in this table does not make it a match for compression.  Data that can be compressed makes up '+cast(cast((In_Row_Data*100.0/(Row_Overflow_Data+Lob_Data+In_Row_Data))as decimal(13,2)) as varchar(1000)) +'% of this table.  While data that cannot be compressed makes up '+ cast(cast((Lob_Data*100.0/(Row_Overflow_Data+Lob_Data+In_Row_Data)) as decimal(13,2)) as varchar(1000)) + '% of this table.')
							when (Row_Overflow_Data)<>0 and (Lob_Data)=0 Then 
											('The amount of Uncompressible data in this table does not make it a match for compression.  Data that can be compressed makes up '+cast(cast((In_Row_Data*100.0/(Row_Overflow_Data+Lob_Data+In_Row_Data))as decimal(13,2)) as varchar(1000)) +'% of this table.  While data that cannot be compressed makes up '+ cast(cast((Row_Overflow_Data*100.0/(Row_Overflow_Data+Lob_Data+In_Row_Data)) as decimal(13,2)) as varchar(1000)) + '% of this table.')
							end
						end
When (In_Row_Data>=Row_Overflow_Data) and (In_Row_Data<Lob_Data) then 
		case
				when (In_Row_Data+Row_Overflow_Data+Lob_Data)<@pageCount then 'Do Not Compress.  You may see minimal performance gain by compressing Heaps, Clustered Indexes, or Non-Clustered Indexes with less than ' + cast(@pageCount as varchar(50)) + ' Pages.'
				when (In_Row_Data+Row_Overflow_Data+Lob_Data)>=@pageCount Then
					case
						when (Row_Overflow_Data)<>0 and (Lob_Data)<>0 Then 
										('The amount of Uncompressible data in this table does not make it a match for compression.  Data that can be compressed makes up '+cast(cast((In_Row_Data*100.0/(Row_Overflow_Data+Lob_Data+In_Row_Data))as decimal(13,2)) as varchar(1000)) +'% of this table.  While data that cannot be compressed makes up '+ cast(cast(((Row_Overflow_Data+Lob_Data)*100.0/100.0)as decimal(13,2)) as varchar(1000)) + '% of this table.')
						when (Row_Overflow_Data)=0 and (Lob_Data)<>0 Then 
										('The amount of Uncompressible data in this table does not make it a match for compression.  Data that can be compressed makes up '+cast(cast((In_Row_Data*100.0/(Row_Overflow_Data+Lob_Data+In_Row_Data))as decimal(13,2)) as varchar(1000)) +'% of this table.  While data that cannot be compressed makes up '+ cast(cast((Lob_Data*100.0/(Row_Overflow_Data+Lob_Data+In_Row_Data)) as decimal(13,2)) as varchar(1000)) + '% of this table.')
						when (Row_Overflow_Data)<>0 and (Lob_Data)=0 Then 
											('The amount of Uncompressible data in this table does not make it a match for compression.  Data that can be compressed makes up '+cast(cast((In_Row_Data*100.0/(Row_Overflow_Data+Lob_Data+In_Row_Data))as decimal(13,2)) as varchar(1000)) +'% of this table.  While data that cannot be compressed makes up '+ cast(cast((Row_Overflow_Data*100.0/(Row_Overflow_Data+Lob_Data+In_Row_Data)) as decimal(13,2)) as varchar(1000)) + '% of this table.')
		end
	end
		else 'error'
	end as Recommendations,
	NULL
--into recommendations
from (
	SELECT
	ss.name as SchemaName
	,OBJECT_NAME(sp.object_id) ObjectName
	,si.name AS IndexName
	,si.index_id as IndexID
	,sp.partition_number as Partition_Number
	,sps.in_row_data_page_count as In_Row_Data
	,sps.row_overflow_used_page_count AS Row_Overflow_Data
	,sps.lob_reserved_page_count AS Lob_Data
	,case
		when (ios.range_scan_count)=0 then 0
		else cast((ios.range_scan_count *100.0/
	(ios.range_scan_count +
	ios.leaf_delete_count + 
	ios.leaf_insert_count + 
	ios.leaf_page_merge_count + 
	ios.leaf_update_count + 
	ios.singleton_lookup_count)) as decimal(13,2)) 
	end as ScanPercent
	,case
		when (ios.leaf_update_count)=0 then 0
		else cast((ios.leaf_update_count *100/
	(ios.range_scan_count + 
	ios.leaf_insert_count + 
	ios.leaf_delete_count + 
	ios.leaf_update_count + 
	ios.leaf_page_merge_count +
	ios.singleton_lookup_count)) as decimal(13,2))
	end as UpdatePercent
	,(sps.in_row_data_page_count+sps.row_overflow_used_page_count+sps.lob_reserved_page_count)*8 as size_KB
	,((sps.in_row_data_page_count+sps.row_overflow_used_page_count+sps.lob_reserved_page_count)*8)/1024 as size_MB
FROM
	sys.dm_db_partition_stats sps with (nolock)
	JOIN sys.partitions sp with (nolock)
	ON sps.partition_id=sp.partition_id
	JOIN sys.objects so with (nolock)
	ON so.object_id=sp.object_id 
	JOIN sys.indexes si with (nolock)
	ON sp.index_id=si.index_id AND sp.object_id = si.object_id
	JOIN sys.schemas ss with (nolock)
	ON so.schema_id = ss.schema_id 
	left outer join sys.dm_db_index_operational_stats(db_id(),NULL,NULL,NULL) ios
	on si.object_id=ios.object_id and si.index_id=ios.index_id
	
WHERE
	OBJECTPROPERTY(sp.object_id,'IsUserTable')	=1 and sp.data_compression=0
	) as s
where size_MB>@mintablesize
order by size_kb desc OPTION(RECOMPILE);

/*===Delete rows which are less than 1GB and the RecCompSetting is None===*/
--delete from @recommendations
--where size_MB>@mintablesize 
--or RecCompSetting='None';


update @recommendations
set statement=(select case 
		when IndexID=0 then 'ALTER TABLE ['+SchemaName+'].['+ObjectName+'] REBUILD WITH (DATA_COMPRESSION='+[RecCompSetting]+');'
		else 'ALTER INDEX ['+IndexName+'] ON ['+SchemaName+'].['+ObjectName+'] REBUILD WITH (DATA_COMPRESSION='+[RecCompSetting]+');'
		end)
from @recommendations
where RecCompSetting<>'None'

if @execute='N'
	select * from @recommendations
else if @execute='Y'
begin

/*================================================
-- Uncomment this section to apply compression scripts
=================================================*/

declare @count int=1
declare @max int
declare @cmd nvarchar(max)
declare @start datetime
declare @end datetime


select @max=MAX(ID)
from @recommendations

while @count<=@max
begin
	set @start=GETDATE()
	select @cmd=statement from @recommendations where ID=@count;
	
	if @cmd is not null
		exec (@cmd)
		
	set @end=GETDATE()
	
	raiserror(@cmd,0,1)with nowait;
	
	set @cmd=cast(DATEDIFF(minute,@start,@end) as varchar(100)) + ' Minute(s)...'
	raiserror(@cmd,0,1)with nowait;
	
	set @count=@count+1;
end
end
/*=================================================*/

go

use master
go
EXEC sys.sp_MS_marksystemobject sp_What_To_Compress;