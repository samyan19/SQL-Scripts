SELECT 
	c.name,
	c.path,
	u3.username as subscriptionowner,
	s.description,
	s.laststatus,
	s.lastruntime
from Catalog c
join users u1 on c.createdbyid=u1.userid
JOIN users u2 on c.modifiedbyid=u2.userid
join subscriptions s ON c.itemid=s.report_oid
join users u3 on s.ownerid=u3.userid
ORDER by c.name