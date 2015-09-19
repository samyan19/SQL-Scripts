  SET NOCOUNT ON
    GO

    --Determine if you want to execute the script with FULLSCAN
    DECLARE @WithFullscan BIT
    SELECT  @WithFullscan = 1

    -------------------
    --Begin script
    -------------------

    DECLARE @StartTime DATETIME

    SELECT  @StartTime = GETDATE()

    IF OBJECT_ID('tempdb..#TablesToUpdateStats') IS NOT NULL 
        BEGIN
            DROP TABLE #TablesToUpdateStats
        END

    DECLARE @NumTables VARCHAR(20)

    SELECT  s.[Name] AS SchemaName
          , t.[name] AS TableName
          , SUM(p.rows) AS RowsInTable
    INTO    #TablesToUpdateStats
    FROM    sys.schemas s
            LEFT JOIN sys.tables t
                ON s.schema_id = t.schema_id
            LEFT JOIN sys.partitions p
                ON t.object_id = p.object_id
            LEFT JOIN sys.allocation_units a
                ON p.partition_id = a.container_id
    WHERE   p.index_id IN ( 0, 1 ) -- 0 heap table , 1 table with clustered index
            AND p.rows IS NOT NULL
            AND a.type = 1  -- row-data only , not LOB
    GROUP BY s.[Name]
          , t.[name]
    SELECT  @NumTables = @@ROWCOUNT

    DECLARE updatestats CURSOR
    FOR
        SELECT  ROW_NUMBER() OVER ( ORDER BY ttus.RowsInTable )
              , ttus.SchemaName
              , ttus.TableName
              , ttus.RowsInTable
        FROM    #TablesToUpdateStats AS ttus
        ORDER BY ttus.RowsInTable
    OPEN updatestats

    DECLARE @TableNumber VARCHAR(20)
    DECLARE @SchemaName NVARCHAR(128)
    DECLARE @tableName NVARCHAR(128)
    DECLARE @RowsInTable VARCHAR(20)
    DECLARE @Statement NVARCHAR(300)
    DECLARE @Status NVARCHAR(300)
    DECLARE @FullScanSQL VARCHAR(20)

    IF @WithFullscan = 1 
        BEGIN
            SELECT  @FullScanSQL = ' WITH FULLSCAN'
        END
    ELSE 
        BEGIN --If @WithFullscan<>1 then set @FullScanSQL to empty string
            SELECT  @FullScanSQL = ''
        END

    FETCH NEXT FROM updatestats INTO @TableNumber, @SchemaName, @tablename,
        @RowsInTable
    WHILE ( @@FETCH_STATUS = 0 ) 
        BEGIN

            SET @Statement = 'UPDATE STATISTICS [' + @SchemaName + '].['
                + @tablename + ']' + @FullScanSQL

            SET @Status = 'Table ' + @TableNumber + ' of ' + @NumTables
                + ': Running ''' + @Statement + ''' (' + @RowsInTable
                + ' rows)'
            RAISERROR (@Status, 0, 1) WITH NOWAIT  --RAISERROR used to immediately output status

            EXEC sp_executesql @Statement

            FETCH NEXT FROM updatestats INTO @TableNumber, @SchemaName,
                @tablename, @RowsInTable
        END

    CLOSE updatestats
    DEALLOCATE updatestats

    DROP TABLE #TablesToUpdateStats

    PRINT 'Total Elapsed Time: ' + CONVERT(VARCHAR(100), DATEDIFF(minute,
                                                              @StartTime,
                                                              GETDATE()))
        + ' minutes'

    GO