/***

https://glennsqlperformance.com/2020/12/13/some-quick-comparative-crystaldiskmark-results-in-2020/
https://www.brentozar.com/archive/2019/11/how-to-use-crystaldiskmark-7-to-test-your-sql-servers-storage/

Seq – long, sequential operations. For SQL Server, this is somewhat akin to doing backups or doing table scans of perfectly defragmented data, like a data warehouse.

512K – random large operations one at a time.  This doesn’t really match up to how SQL Server works.

4K – random tiny operations one at a time.  This is somewhat akin to a lightly loaded OLTP server.

4K QD32 – random tiny operations, but many done at a time.  This is somewhat akin to an active OLTP server.


***/
