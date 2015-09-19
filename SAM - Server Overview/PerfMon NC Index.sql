USE [zzPerfMon]
GO

/****** Object:  Index [NIX_CounterID]    Script Date: 20/07/2015 13:08:30 ******/
CREATE NONCLUSTERED INDEX [NIX_CounterID] ON [dbo].[CounterData]
(
	[CounterID] ASC
)
INCLUDE ( 	[CounterDateTime],
	[CounterValue]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO


