declare @REPLMONITOR table
  (
     Status                        INT NULL,
     Warning                       INT NULL,
     Subscriber                    SYSNAME NULL,
     Subscriber_db                 SYSNAME NULL,
     Publisher_db                  SYSNAME NULL,
     Publication                   SYSNAME NULL,
     Publication_type              INT NULL,
     Subtype                       INT NULL,
     Latency                       INT NULL,
     Latencythreshold              INT NULL,
     Agentnotrunning               INT NULL,
     Agentnotrunningthreshold      INT NULL,
     Timetoexpiration              INT NULL,
     Expirationthreshold           INT NULL,
     Last_distsync                 DATETIME,
     Distribution_agentname        SYSNAME NULL,
     Mergeagentname                SYSNAME NULL,
     Mergesubscriptionfriendlyname SYSNAME NULL,
     Mergeagentlocation            SYSNAME NULL,
     Mergeconnectiontype           INT NULL,
     Mergeperformance              INT NULL,
     Mergerunspeed                 FLOAT,
     Mergerunduration              INT NULL,
     Monitorranking                INT NULL,
     Distributionagentjobid        BINARY(16),
     Mergeagentjobid               BINARY(16),
     Distributionagentid           INT NULL,
     Distributionagentprofileid    INT NULL,
     Mergeagentid                  INT NULL,
     Mergeagentprofileid           INT NULL,
     Logreaderagentname            VARCHAR(100)
  )



INSERT INTO @REPLMONITOR
EXEC distribution.dbo.sp_replmonitorhelpsubscription @publication_type = 0, @Publisher = 'RCSTVSQL2K83-01\ISQL2K801'

SELECT CASE Status
         WHEN 1 THEN 'Started'
         WHEN 2 THEN 'Succeeded'
         WHEN 3 THEN 'In Profress'
         WHEN 4 THEN 'Idle'
         WHEN 5 THEN 'Retrying'
         WHEN 6 THEN 'Failed'
       END                                                AS Status,
       Publication,
       Publisher_db                                       Subscriber_db,
       Subscriber_db,
       CONVERT(VARCHAR(8), STUFF(STUFF(RIGHT('000000' + CONVERT(VARCHAR, Latency
                                             ), 6),
                                 5, 0, ':'), 3, 0,
                                               ':'), 108) AS Latency,
       CASE Monitorranking
         WHEN 60 THEN 'Error'
         WHEN 56 THEN 'Warning: performance critical'
         WHEN 52 THEN 'Warning: expiring soon or expired'
         WHEN 50 THEN 'Warning: subscription uninitialized'
         WHEN 40 THEN 'Retrying failed command'
         WHEN 30 THEN 'Not running (success)'
         WHEN 20 THEN 'Running (starting, running, or idle)'
       END                                                AS Healthcheck
FROM   @REPLMONITOR


