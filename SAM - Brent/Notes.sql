/********** BRENT NOTES **************

Recommended software - SQL Query Stress - Adam Mechanic

sp_AskBrent @seconds =5, @ExpertMode =1 

--Run on virtual machine
sp_AskBrent @seconds =0, @ExpertMode =1 
--If high PAGEIO and queries tuneed then look at storage

method
-------
1) Tune queries
2) Tune index
3) Scale up
4) Add New

* PAGEIOLATCH - increase memory before new storage
* SOS_SCHEDULER_YIELD - maxdop, add CPU

trace flag 4199 - can help some queries in 2014

Columnstore index
------------------

* an index on every field
* useful for reporting queries where we do not know what columns would be outputted or sorted
* takes a while to connect 
* 2012 - column store index - cause read only
* 2014 - clustered column store - read write - not OLTP
* wide tables, high pageiolatch


**************************************/
