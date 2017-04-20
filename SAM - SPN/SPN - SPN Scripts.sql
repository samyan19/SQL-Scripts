/*
If issue with SPN it should appear in the Errorlog.
*/

--List SPN
setspn -L computername
setspn -L bestlive\svc_sqlservice

--Add SPN to standalone
setspn -A MSSQLSvc/PDC1SQL058.INTERNAL.CLOSEBROTHERS.COM bestlive\svc_sqlservice
setspn -A MSSQLSvc/PDC1SQL058.INTERNAL.CLOSEBROTHERS.COM:1433 bestlive\svc_sqlservice

--Add SPN to Instance
setspn -A MSSQLSvc/PL3SQLC01EXT.BESTLIVE.BESTINVEST.CO.UK:EXT01 bestlive\svc_sqlservice
setspn -A MSSQLSvc/PL3SQLC01INT.BESTLIVE.BESTINVEST.CO.UK:50382 bestlive\svc_sqlservice

--Delete SPN
setspn -D MSSQLSvc/PL3SQLC01INT.BESTLIVE.BESTINVEST.CO.UK:50382 bestlive\svc_sqlservice
