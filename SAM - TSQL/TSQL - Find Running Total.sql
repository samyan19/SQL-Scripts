USE tempdb
GO
CREATE TABLE #TestTable (ID INT, Value INT)
INSERT INTO #TestTable (ID, Value)
SELECT 1, 10
UNION ALL
SELECT 2, 20
UNION ALL
SELECT 3, 30
UNION ALL
SELECT 4, 40
UNION ALL
SELECT 5, 50
UNION ALL
SELECT 6, 60
UNION ALL
SELECT 7, 70
GO
-- selecting table
SELECT ID, Value
FROM #TestTable
GO

-- Running Total for SQL Server 2008 R2 and Earlier Version
SELECT ID, Value,
(SELECT SUM(Value)
FROM #TestTable T2
WHERE T2.ID <= T1.ID) AS RunningTotal
FROM #TestTable T1
GO

-- Running Total for SQL Server 2012 and Later Version
SELECT ID, Value,
SUM(Value) OVER(ORDER BY ID ROWS UNBOUNDED PRECEDING) AS RunningTotal
FROM #TestTable
GO