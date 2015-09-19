DECLARE @sptable TABLE (database_name varchar(100),feature_name VARCHAR(100),feature_id INT)

INSERT INTO @sptable
exec sp_msforeachdb '
use [?];
select ''?'',* from sys.dm_db_persisted_sku_features'


SELECT * FROM @sptable