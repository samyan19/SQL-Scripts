--check if report exisst
select * from  dbo.Subscriptions
where Report_OID='47B851D4-75FA-428D-97F1-D9D47E3C2581'


--check if user exists
select * from users



--Change owner of subscription

DECLARE @NewUserID uniqueidentifier

SELECT @NewUserID = UserID FROM dbo.Users

WHERE UserName = 'BESTLIVE\Yanzu_admin'

UPDATE dbo.Subscriptions SET OwnerID = @NewUserID
where Report_OID='47B851D4-75FA-428D-97F1-D9D47E3C2581'



/*
select * from Catalog

select * from Subscriptions
where Report_OID='47B851D4-75FA-428D-97F1-D9D47E3C2581'
*/



