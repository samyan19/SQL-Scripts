/* Total */

SELECT CONVERT(DECIMAL(10,2),(SUM(size * 8.00) / 1024.00 / 1024.00)) As UsedSpaceGB
FROM master.sys.master_files

/* Breakdown by filetype */

SELECT 
type_desc,
CONVERT(DECIMAL(10,2),(SUM(size * 8.00) / 1024.00 / 1024.00)) As UsedSpaceGB
FROM master.sys.master_files
group by type_desc
order by UsedSpaceGB desc


