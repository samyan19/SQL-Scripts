-- Server Configuration (find any non-standard settings)
--        for SQL Server 2008.
DECLARE @config_defaults TABLE (
    name nvarchar(35),
    default_value sql_variant
)

INSERT INTO @config_defaults (name, default_value) VALUES
('access check cache bucket count',0),
('access check cache quota',0),
('Ad Hoc Distributed Queries',0),
('affinity I/O mask',0),
('affinity mask',0),
('affinity64 I/O mask',0),
('affinity64 mask',0),
('Agent XPs',1),
('allow updates',0),
('awe enabled',0),
('backup compression default',0),
('blocked process threshold (s)',0),
('c2 audit mode',0),
('clr enabled',0),
('common criteria compliance enabled',0),
('cost threshold for parallelism',5),
('cross db ownership chaining',0),
('cursor threshold',-1),
('Database Mail XPs',0),
('default full-text language',1033),
('default language',0),
('default trace enabled',1),
('disallow results from triggers',0),
('EKM provider enabled',0),
('filestream access level',0),
('fill factor (%)',0),
('ft crawl bandwidth (max)',100),
('ft crawl bandwidth (min)',0),
('ft notify bandwidth (max)',100),
('ft notify bandwidth (min)',0),
('index create memory (KB)',0),
('in-doubt xact resolution',0),
('lightweight pooling',0),
('locks',0),
('max degree of parallelism',0),
('max full-text crawl range',4),
('max server memory (MB)',2147483647),
('max text repl size (B)',65536),
('max worker threads',0),
('media retention',0),
('min memory per query (KB)',1024),
-- NOTE: SQL Server may change the min server
--   memory value 'in flight' in some environments
--    so it may commonly show up as being 'non default'
('min server memory (MB)',0),
('nested triggers',1),
('network packet size (B)',4096),
('Ole Automation Procedures',0),
('open objects',0),
('optimize for ad hoc workloads',0),
('PH timeout (s)',60),
('precompute rank',0),
('priority boost',0),
('query governor cost limit',0),
('query wait (s)',-1),
('recovery interval (min)',0),
('remote access',1),
('remote admin connections',0),
('remote login timeout (s)',20),
('remote proc trans',0),
('remote query timeout (s)',600),
('Replication XPs',0),
('scan for startup procs',0),
('server trigger recursion',1),
('set working set size',0),
('show advanced options',0),
('SMO and DMO XPs',1),
('SQL Mail XPs',0),
('transform noise words',0),
('two digit year cutoff',2049),
('user connections',0),
('user options',0),
('xp_cmdshell',0)

SELECT c.name, value, value_in_use, d.default_value
from sys.configurations c
INNER JOIN @config_defaults d ON c.name = d.name
where
    c.value != c.value_in_use
    OR c.value_in_use != d.default_value
GO
 

