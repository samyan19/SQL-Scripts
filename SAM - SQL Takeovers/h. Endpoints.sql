/*
	Server settings can be made outside of sp_configure too.  The easiest way
	to check out the service settings are to go into Start, Programs,
	Microsoft SQL Server, Configuration Tools, SQL Server Configuration Manager.
	Go there now, and drill into SQL Server Services, then right-click on each
	service and hit Properties.  The advanced properties for the SQL Server
	service itself can hide some startup parameters.

	
	Next, check Instant File Initialization.  Take a note of the service account
	SQL Server is using, and then run secpol.msc.  Go into Local Policy, User
	Rights Assignment, Perform Volume Maintenance Tasks.  Double-click on that
	and add the SQL Server service account.  This lets SQL Server grow data
	files instantly.  For more info:
	http://www.sqlskills.com/blogs/kimberly/post/Instant-Initialization-What-Why-and-How.aspx


	There's a few more server-level things I like to check, but I use the SSMS
	GUI.  Go into Server Objects, and check out what's under Endpoints, Linked
	Servers, Resource Governor, and Triggers.  If any of these objects exist, you
	want to research to find out what they're being used for.
*/
SELECT * FROM sys.endpoints WHERE type <> 2
SELECT * FROM sys.resource_governor_configuration
SELECT * FROM sys.server_triggers
SELECT * FROM sys.servers