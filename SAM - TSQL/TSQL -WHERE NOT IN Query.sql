SELECT contactid,MyAccountUserName
from CONTACT.Contact
where ContactID NOT IN 
(
	SELECT c.ContactID
	from CONTACT.Contact c
	join ACCOUNT.ContactAccount ca ON c.ContactID=ca.ContactID
	JOIN ACCOUNT.Account a ON ca.AccountID=a.AccountID
	where a.AccountName like '%ISA%'
)