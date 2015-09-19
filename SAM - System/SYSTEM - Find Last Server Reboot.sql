/*
Windows Server 2003 and Windows XP:
-----------------------------------
 
     Run the following at a command prompt:
        net statistics server
 
     The second line that is returned will look something like this:
           Statistics since 11/12/2013 1:23:45 PM
 
     which for the majority of cases* will be the server uptime.

     * The value is actually the uptime of the Server service.  Unless that service
     has been restarted since server boot-time, which is not a common action,
     it will be the same as the server uptime.

Windows Server 2008, Windows 7 and Windows 8:
---------------------------------------------
 
     Start Task Manager by right-clicking the Taskbar, click the Performance tab
     and note the value for Uptime near the lower-right of the screen.
 
     - or -
 
     Run the following from a command prompt:
          systeminfo | find "Time:"
 
     The output will look something like this:
           System Boot Time: 11/12/2013, 1:23:45 AM
		   */