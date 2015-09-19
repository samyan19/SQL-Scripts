/*

https://social.msdn.microsoft.com/Forums/sqlserver/en-US/86ced655-c00d-4ec4-946a-c6e6b34a2293/cannot-add-identity-column-since-an-identity-column-already-exists?forum=transactsql

I found a rather crude way of getting around this...

if i cast the column that has the identity on it to the same datatype it doesnt carry forward the identity

 

for eg if columnB was an INT...then CAST(columnB as INT) as columnB, columnC .......works fine.

 

i'd still like to find out if there is a legit way of doing this though.

 

cheers.
*/