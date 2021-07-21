/* 

https://www.sqlserverinternals.com/blog/2018/4/19/kalen-delaney-geek-city-spcacheobjects

*/



--  Create a view to show most of the same information
--       as SQL Server 2000's syscacheobjects
USE master
GO
DROP VIEW IF EXISTS sp_cacheobjects;
GO
-- You may want to add other filters in the WHERE clause to remove
--   other system operations on your own SQL Server
CREATE VIEW sp_cacheobjects (bucketid, cacheobjtype, objtype, 
                        usecounts, pagesused, objid, dbid, 
                        dbidexec, uid, refcounts, setopts, langid, 
                        dateformat, status, lasttime, maxexectime, 
                        avgexectime, lastreads, lastwrites, sqlbytes, 
                        sql, plan_handle) 
AS
            SELECT  pvt.bucketid, 
              CONVERT(nvarchar(18), pvt.cacheobjtype) as cacheobjtype, 
              pvt.objtype, pvt.usecounts, 
              pvt.size_in_bytes / 8192 as size_in_bytes,
              CONVERT(int, pvt.objectid)as object_id, 
              CONVERT(smallint, pvt.dbid) as dbid,
              CONVERT(smallint, pvt.dbid_execute) as execute_dbid, 
              CONVERT(smallint, pvt.user_id) as user_id,
              pvt.refcounts, 
              CONVERT(int, pvt.set_options) as setopts, 
              CONVERT(smallint, pvt.language_id) as langid,
              CONVERT(smallint, pvt.date_format) as date_format, 
              CONVERT(int, pvt.status) as status,
              CONVERT(bigint, 0), CONVERT(bigint, 0), 
              CONVERT(bigint, 0), CONVERT(bigint, 0), 
              CONVERT(bigint, 0), 
              CONVERT(int, LEN(CONVERT(nvarchar(max), fgs.text)) * 2), 
              CONVERT(nvarchar(3900), fgs.text), plan_handle
        FROM (SELECT ecp.*, epa.attribute, epa.value
                 FROM sys.dm_exec_cached_plans ecp
                 OUTER APPLY
                 sys.dm_exec_plan_attributes(ecp.plan_handle) epa) as ecpa
            PIVOT (MAX(ecpa.value) 
                 for ecpa.attribute IN
                     ("set_options", "objectid", "dbid", 
                      "dbid_execute", "user_id", "language_id", 
                      "date_format", "status")) as pvt
            OUTER APPLY sys.dm_exec_sql_text(pvt.plan_handle) fgs
    WHERE cacheobjtype like 'Compiled%'
    AND pvt.dbid between 5 and 32766
    AND text NOT LIKE '%msparam%'
    AND text not like '%xtp%'
    AND text not like '%filetable%'
    AND text not like '%fulltext%';
