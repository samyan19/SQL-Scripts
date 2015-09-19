/*
	Right up there with data integrity, security's really important.
	Who else has sysadmin or securityadmin rights on this instance?
	I care about securityadmin users because they can add themselves to the SA
	role at any time to do their dirty work, then remove themselves back out.
	
	Don't think of them as other sysadmins.  
	Think of them as users who can get you fired.
*/

SELECT l.name, l.denylogin, l.isntname, l.isntgroup, l.isntuser
  FROM master.sys.syslogins l
  WHERE l.sysadmin = 1 OR l.securityadmin = 1
  ORDER BY l.isntgroup, l.isntname, l.isntuser







/*
	Now would be an excellent time to open up a Word doc and start documenting
	your findings, which helps you prove your worth as a DBA.  And for every
	SQL authentication user in that list, try logging in with a blank password.

	In your Blitz document, if SA includes Builtin\Administrators, list the 
	server's local administrators.
*/