/****** Script for SelectTopNRows command from SSMS  ******/
SELECT count (distinct SourceCustomerID)
  FROM [DEV_CIDA_TDM_STD_OFFS].[dbo].[STD_CUSTOMER]

SELECT count (distinct FirstName)
  FROM [DEV_CIDA_TDM_STD_OFFS].[dbo].[STD_CUSTOMER]
