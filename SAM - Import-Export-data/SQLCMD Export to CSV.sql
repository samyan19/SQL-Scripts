
--RUnning .sql file and exporting to CSV
SQLCMD -S RCSTVSQL2k83-01\ISQL2k801 -E -d IES_LINKEDATA_UBS_PRD01 -i E:\RITM0019938\PreliminaryPendActiveInactiveJan012014ToOct312015.sql -s "," -o "E:\RITM0019938\Yourfilename.csv"

--running Query and exporting to CSV
SQLCMD -S RCSTVSQL2k83-01\ISQL2k801 -E -d IES_LINKEDATA_UBS_PRD01 -Q "Select * from sys.databases" -s "," -o "E:\RITM0019938\Yourfilename.csv"
