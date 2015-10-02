
--system stored procedure to run in distribution database
execute sp_replmonitorsubscriptionpendingcmds
--replication publisher server
@publisher ='RCSTVSQL2K83-01\ISQL2K801',
--replication publisher database
@publisher_db = 'RTP_Nougat_CMT_PRD01',
--replication publication name
@publication ='REP_SQL2K8_CMTMI_PRD01',
--replication subscriber server
@subscriber ='RCSTSQL58',
--replication subscriber database
@subscriber_db ='NOUGAT_MI_PRD01',
--choose type of subscription you have
@subscription_type ='0' --0 for push and 1 for pull
GO
