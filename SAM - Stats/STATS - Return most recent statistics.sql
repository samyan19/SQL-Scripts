
SELECT name AS stats_name, 
    STATS_DATE(object_id, stats_id) AS statistics_update_date
FROM sys.stats 
WHERE object_id IN( OBJECT_ID('STG_ENERGY_VOLUME_CURRENT_D82_CONS'));
GO