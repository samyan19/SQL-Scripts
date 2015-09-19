DECLARE @start_date datetime='2012-01-01'
declare @end_date datetime='2013-01-01'

;WITH sample AS (
    SELECT @start_date AS dt
    UNION ALL
    SELECT DATEADD(dd, 1, dt)
      FROM sample s
     WHERE DATEADD(dd, 1, dt) <= @end_date)
SELECT s.dt
  FROM sample s