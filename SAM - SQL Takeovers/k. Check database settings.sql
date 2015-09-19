/*
	Alright, we're done with the server level!  Let's check databases.  We could
	right-click on each database and click Properties, but it can be easier to
	scan across the results of sys.databases.  I look for any variations - are
	there some databases that have different settings than others?
*/
SELECT * FROM sys.databases
