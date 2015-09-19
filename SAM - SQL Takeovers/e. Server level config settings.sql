/*
	Let's review some server-level security & configuration settings.
*/
EXEC dbo.sp_configure 'show advanced options', 1
GO
RECONFIGURE
GO
EXEC dbo.sp_configure











/*
	Look for anything that's been changed from the default value.
	What?  You don't know the defaults by heart?  Well, me neither.
	In SSMS, go into the Object Explorer, then right-click on the server name.
	Click Reports, Standard Reports, Server Dashboard, and then expand the
	section Non Default Configuration Options.  It'll show everything that
	deviates from the defaults.


	Below, I set advanced options off, but that's just for demo purposes.
	You can leave that on if you like.

EXEC dbo.sp_configure 'show advanced options', 0
GO
RECONFIGURE
GO
*/