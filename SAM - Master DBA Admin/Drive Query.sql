/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP 1000 [Drive]
      ,[MB_Free]/1024.0
      ,[Date]
  FROM [dba_admin].[dbo].[diskspace]
  where [Date] >='07/04/2011' AND Drive IN ('x','i','g')
  GROUP BY Drive,[Date],MB_Free