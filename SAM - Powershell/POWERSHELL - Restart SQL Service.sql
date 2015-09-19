# Date: 27/02/13
# Author: John Sansom
# Description: PS script to restart the SQL Server Agent Service for the provided instance
#
# Version: 1.0
#
# Example Execution: .\Restart_SQLServerAgent_v2.ps1 ServerName

param([String]$ServerName)

Get-Service -computer $ServerName SQLSERVERAGENT | Restart-Service