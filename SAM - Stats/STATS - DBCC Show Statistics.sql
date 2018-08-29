/*
target

Name of the index, statistics, or column for which to display statistics information. 
target is enclosed in brackets, single quotes, double quotes, or no quotes. 
If target is a name of an existing index or statistics on a table or indexed view, the statistics information about 
this target is returned. If target is the name of an existing column, and an automatically created statistics on 
this column exists, information about that auto-created statistic is returned. If an automatically created statistic 
does not exist for a column target, error message 2767 is returned.

In SQL Data Warehouse and Parallel Data Warehouse, target cannot be a column name.
*/


dbcc show_statistics ('MESSAGING.SEIOvernight','ixSEIOvernight_SEIInterfaceID')

--The smaller the density is the more selective that column is.
