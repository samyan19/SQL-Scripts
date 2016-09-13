--Page life expectancy limit
declare @max int 
SET @max=(
SELECT CAST(value_in_use AS INT)
FROM sys.configurations
WHERE name LIKE '%max server memory%')

DECLARE @threshold int
SET @threshold=((@max/1024.0)/4) * 300

print @max
print @threshold
