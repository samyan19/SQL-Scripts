/*
TCP 1433
=========
TCP port 1433 is the default port for SQL Server. 
This port is also the official Internet Assigned Number Authority (IANA) socket number for SQL Server. 
Client systems use TCP 1433 to connect to the database engine; 
SQL Server Management Studio (SSMS) uses the port to manage SQL Server instances across the network. 
You can reconfigure SQL Server to listen on a different port, but 1433 is by far the most common implementation.

TCP 1434
=========
TCP port 1434 is the default port for the Dedicated Admin Connection. 
You can start the Dedicated Admin Connection through sqlcmd or by typing 
ADMIN: followed by the server name in the SSMS Connect to Database Engine dialog box.

UDP 1434
=========
UDP port 1434 is used for SQL Server named instances. 
The SQL Server Browser service listens on this port for incoming connections to a named instance. 
The service then responds to the client with the TCP port number for the requested named instance.

TCP 2383
=========
TCP port 2383 is the default port for SQL Server Analysis Services.

TCP 2382
=========
TCP port 2382 is used for connection requests to a named instance of Analysis Services. 
Much like the SQL Server Browser service does for the relational database engine on UDP 1434, 
the SQL Server Browser listens on TCP 2382 for requests for Analysis Services named instances. 
Analysis Services then redirects the request to the appropriate port for the named instance.

TCP 135
=========
TCP port 135 has several uses. The Transact-SQL debugger uses the port. TCP 135 is also used to start, stop, and control SQL Server Integration Services, although it is required only if you connect to a remote instance of the service from SSMS.

TCP 80 and 443
==============
TCP ports 80 and 443 are most typically used for report server access. However, they also support URL requests to SQL Server and Analysis Services. TCP 80 is the standard port for HTTP connections that use a URL. TCP 443 is used for HTTPS connections that use secure sockets layer (SSL).

Unofficial TCP Ports
=====================
Microsoft uses TCP port 4022 for SQL Server Service Broker examples in SQL Server Books Online. Likewise, BOL Database Mirroring examples use TCP port 7022.

SMTP 25
========
Database Mail

TCP 5022
=========
Database Mirroring	TCP	No official default port, but examples tend to use 5022.

TCP 139 and 445
===============
Filestream

TCP 80
=======
SQL Server (default instance) over HTTP

TCP 443
========
SQL Server (default instance) over HTTPS

TCP 135
========
SQL Server Integration Services	
TSQL Debugger	

*/