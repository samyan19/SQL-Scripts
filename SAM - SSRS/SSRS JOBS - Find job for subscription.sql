SELECT ScheduleID, Path, Name, s.Description
FROM ReportServer.dbo.Catalog c
JOIN ReportServer.dbo.Subscriptions s ON c.ItemID = s.Report_OID
JOIN ReportServer.dbo.ReportSchedule rs on rs.SubscriptionID = s.SubscriptionID