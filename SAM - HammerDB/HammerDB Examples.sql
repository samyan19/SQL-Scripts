/*
******* HAMMERDB OPTIONS ***********

--use from client (represent usage over network)

--Form minimum level of Mem and IO to maximize CPU utilization
* 200-250 Warehouses Per CPU
* Keying/Thinking FALSE
* Virtual Users - No. of warehouses/No. of Cores

--Warehouses - Ordering system based on number of warehouses (actual warehouses)

--Log output to Temp
--Saved to C:\Temp - must be created.

--rampup period (1 minute)

* NOPM - Transaction per minute
* TPM - orders per minute

-- TPC-C - Standard Benchmarking OLTP
-- TPC-H - Reporting workload

-- Vendors results puiblished. SQL TPC-E

*/


/*
*********** 
overall - total number of complete trans
opm=orders per min
rollbacks 
--pct_newcustomers=0 to restrict the new user output
threads 1=users,
think time=0,
***************
*/