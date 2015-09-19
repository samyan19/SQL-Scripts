  --ALL
  DBCC SQLPERF('logspace')
  
  --Database specific
  DECLARE @sqlperf TABLE (dbname VARCHAR(100), logsize FLOAT, LOGSPACE FLOAT, STATUS BIT)

  INSERT INTO @sqlperf
  EXEC ('DBCC SQLPERF(''logspace'')')

  SELECT *
  FROM @sqlperf
  WHERE dbname='DA_BBC_PROCUREMENT_FINAL_2014'