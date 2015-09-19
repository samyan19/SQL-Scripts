/****** Script for SelectTopNRows command from SSMS  ******/
SELECT collection_time,*
  FROM [DBA].[dbo].[WhoIsActive_20150225] w
  order by w.collection_time asc