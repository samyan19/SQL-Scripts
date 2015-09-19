/*
Find out edition specific features that are enabled in current database - sys.dm_db_persisted_sku_features

If no rows returned then there are no server specific features
*/

select * from sys.dm_db_persisted_sku_features