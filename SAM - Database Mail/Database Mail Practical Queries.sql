--How to create a database mail account via t-sql ?
---------------------------------------------------
exec msdb.dbo.sysmail_add_account_sp
@account_name='account2',
@email_address='sudan.madhan@gmail.com',
@display_name='CASPRO Admin',
@replyto_address='sudan.madhan@gmail.com',
@description='This is the second account created for csfspd1caspro instance',
@mailserver_name='smtp.gmail.com',
@port=25,
@username='sudan.madhan@gmail.com',
@password='XXXXXXXX',
@enable_ssl=1

--How to view all the database mail accounts ?
------------------------------------------------
exec msdb.dbo.sysmail_help_account_sp

--How to create a new profile ?
------------------------------------------------
exec msdb.dbo.sysmail_add_profile_sp
@profile_name='profile2',
@description='this is my second profile'

--How to view all the profiles ?
------------------------------------------------
exec msdb.dbo.sysmail_help_profile_sp

--How to add account to the profile ?
--=============================================
exec msdb.dbo.sysmail_add_profileaccount_sp
@profile_name='profile2',
@account_name='account2',
@sequence_number=1
--The sequence number determines the order in which accounts are used in the profile.


--How to view the profiles and the accounts associated with it ?
--==================================================================
exec msdb.dbo.sysmail_help_profileaccount_sp

--How to grant access to a particular profile to all users ?
--==========================================================
exec msdb.dbo.sysmail_delete_principalprofile_sp
@principal_name='public',
@profile_name='profile2'
--public here is the database role within msdb db.

--How to view the principals that are given access to db mail profiles ?
--======================================================================
exec msdb.dbo.sysmail_help_principalprofile_sp

--How to start db mail ?
--=========================
exec msdb.dbo.sysmail_start_sp

--How to stop db mail ?
--============================
exec msdb.dbo.sysmail_stop_sp

--How to send an email ?
--============================
exec msdb.dbo.sp_send_dbmail
@profile_name='profile2',
@recipients='sudan.madhan@gmail.com',
@subject='System administrator',
@body='This message is for testing purposes only',
@body_format='html'

--How to find out if our db mail queue status is started or not ?
--===============================================================
exec msdb.dbo.sysmail_help_status_sp

--How to find out if there are any mail items in the queue waiting to be sent ?
--=============================================================================
exec msdb.dbo.sysmail_help_queue_sp
--the length column gives us the clue if there are any pending items

--How to view the configuration settings/properties of the db mail ?
--===================================================================
exec msdb.dbo.sysmail_help_configure_sp

--How to break the connectivity of a account and the associated profile ?
--=================================================
exec msdb.dbo.sysmail_delete_profileaccount_sp
@profile_name='profile2',
@account_name='account2'

--How to delete the account ?
--============================
exec msdb.dbo.sysmail_delete_account_sp
@account_name='account2'

--How to revoke the access to principals from a profile ?
--===================================================
exec msdb.dbo.sysmail_delete_principalprofile_sp
@principal_name='public',
@profile_name='profile2'

--How to delete the profile ?
--============================
exec msdb.dbo.sysmail_delete_profile_sp
@profile_name='profile2'

--What if any changes have to be made to either accounts or profiles ?
--============================

--Use the below stored procedures as per the situation :
exec msdb.dbo.sysmail_update_account_sp
exec msdb.dbo.sysmail_update_profile_sp
exec msdb.dbo.sysmail_update_profileaccount_sp
exec msdb.dbo.sysmail_update_principalprofile_sp

--What are the catalog views available related to db mail ?
--=========================================
--The following are the views available : (these are self explanatory)
select * from msdb.dbo.sysmail_allitems
select * from msdb.dbo.sysmail_sentitems
select * from msdb.dbo.sysmail_unsentitems
select * from msdb.dbo.sysmail_faileditems
select * from msdb.dbo.sysmail_mailattachments
select * from msdb.dbo.sysmail_event_log

--How to delete events from the Database Mail log (or) How to delete all events in the log or those events meeting a date or type criteria ?
--=============================================
exec msdb.dbo.sysmail_delete_log_sp
@logged_before='2010-01-26'

exec msdb.dbo.sysmail_delete_log_sp
@event_type='error' 

exec msdb.dbo.sysmail_delete_log_sp
--this deletes entire table

--Give some example queries related to sending an db mail via t-sql syntax ?
--==================================
--1)
exec msdb.dbo.sp_send_dbmail
@profile_name='profile1',
@recipients='sudan.madhan@gmail.com',
@subject='Shift availability information',
@query='select * from HumanResources.shift',
@attach_query_result_as_file=0,
@execute_query_database='AdventureWorks'

--2)

exec msdb.dbo.sp_send_dbmail
@profile_name='profile1',
@recipients='sudan.madhan@gmail.com',
@subject='Shift availability information',
@query='select * from HumanResources.shift',
@attach_query_result_as_file=1,
@execute_query_database='AdventureWorks',
@query_result_separator='|',
@query_result_width=100

--How to create a sql server agent job to archive database mail messages and event logs ?
--=====================================
--job name : dbmail_archives
--job description : This job is required to run first day of the month and archives the data from db mail event log,attachments and allitems into 3 separate tables.
--job category : Database Maintenance
--no of steps in this job : 4
--job1 : Clean the existing table
--in destiny db,
if exists(select name from sys.objects where name 

in('dbmail_event_log_archives','dbmail_attachements_archives','dbma

il_allitems_archives'))
begin
drop table dbmail_event_log_archives;
drop table dbmail_attachements_archives;
drop table dbmail_allitems_archives;
end

--job2 : archiving data into dbmail_event_log_archives
--in msdb database,
select *
into destiny.dbo.dbmail_event_log_archives
from msdb.dbo.sysmail_event_log

--job3 : archiving data into dbmail_attachements_archives
--in msdb database,
select *
into destiny.dbo.dbmail_attachements_archives
from msdb.dbo.sysmail_attachments

--job4 : archiving data into dbmail_allitems_archives
--in msdb database,
select *
into destiny.dbo.dbmail_allitems_archives
from msdb.dbo.sysmail_allitems

--job5 : cleaning the sysmail events,attachments and allitems
--in msdb database,
delete from dbo.sysmail_allitems;
delete from dbo.sysmail_attachments;
delete from dbo.sysmail_event_log;

--Schedule this job to run every month 1st day.

