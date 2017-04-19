/* Size includes logs */

select @@servername, 
a.name, 
a.compatibility_level,
b.database_id [database_id],
SUM(((size*8)/1024)) [Size_MB],
count(b.file_id) as file_count
FROM sys.databases a
join sys.master_files b on a.database_id=b.database_id
where b.type_desc='ROWS'
group by a.name,a.compatibility_level
,b.database_id
order by Size_MB desc



with CTE as
(
select @@servername as servername, 
a.name, 
a.compatibility_level,
b.database_id [database_id],
SUM(((size*8)/1024)) [Size_MB],
count(b.file_id) as file_count
FROM sys.databases a
join sys.master_files b on a.database_id=b.database_id
where b.type_desc='ROWS'
group by a.name,a.compatibility_level
,b.database_id
--order by Size_MB desc
)
select sum(Size_MB)/1024 as Size from CTE



