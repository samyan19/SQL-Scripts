declare @s varchar(50);
set @s = 'N:\MSSQL10_50.INT01\MSSQL\Data\tempdb.mdf'

/* last one: */
select
    RIGHT(@s, CHARINDEX('\', REVERSE(@s)) - 1)