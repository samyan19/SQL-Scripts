/*=====================================
Installing Using Command Prompt
=====================================

Go to the SQL Server installation media root from the command prompt and specify the ConfigurationFile.ini as a parameter as shown below.


Setup.exe /ConfigurationFile=ConfigurationFile.INI


You can override any of the values in the configuration file or add more values which are not specified in the configuration file by providing additional command line parameters to setup.exe as shown below.



Setup.exe /SQLSVCPASSWORD="password" /ASSVCPASSWORD="password" /AGTSVCPASSWORD="password"
  /ISSVCPASSWORD="password" /RSSVCPASSWORD="password" /SAPWD="password"
/ConfigurationFile=ConfigurationFile.INI



You can also control the level of the installer interface while installing SQL Server from the command prompt. The installer interface level can be silent, basic or full interaction. You have to use the below switches for the installer interface level.

/Q- specifies that setup runs in a quiet mode without any user interface. This is used for unattended installations.
/QS - specifies that setup runs and shows progress through the UI, but does not accept any input or show any error messages.
Please note

There is no configuration file template available on the installation media. To get the configuration file you have to run the SQL Server Installation wizard until you get to the Ready to Install page.
Make sure you make a copy of the ConfigurationFile.inifile before modifying it
Installer does not write passwords into the ConfigurationFile.inifile. You have to either specify the password through a parameter or you can specify during the installation screen prompt for the password.
If you have chosen the authentication mode as Mixed Mode, you have to specify the SA password using the /SAPWDswitch.
For any method of installation, you have to accept the software license terms agreement. For SQL Server 2008 R2 for a fully unattended installation you can specify it by using the /IACCEPTSQLSERVERLICENSETERMSswitch.
Also, for SQL Server 2008 R2 you can use the /UIMODE switch instead of /Q or /QS switch.