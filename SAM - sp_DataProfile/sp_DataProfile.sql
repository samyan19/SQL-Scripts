USE [master]
GO

IF OBJECT_ID('dbo.sp_DataProfile') IS NOT NULL 
  DROP PROCEDURE dbo.sp_DataProfile;
GO

CREATE PROCEDURE dbo.sp_DataProfile
   @TableName NVARCHAR(500) ,
   @Mode TINYINT = 0 , /* 0 = Table Overview, 1 = Column Detail, 2 = Column Statistics, 3 = Candidate Key Check, 4 = Column Value Distribution */
   @ColumnList NVARCHAR(4000) = NULL ,
   @DatabaseName NVARCHAR(128) = NULL ,
   @ShowForeignKeys BIT = 0 ,
   @ShowIndexes BIT = 0 ,
   @SampleValue INT = NULL ,
   @SampleType NVARCHAR(50) = 'PERCENT' ,
   @Verbose BIT = 0
/*
sp_DataProfile v0.3 - Apr 20, 2015

(C) 2015, Jorriss LLC 
See http://jorriss.com/eula for the End User Licensing Agreement.

Documentation is located at: http://www.jorriss.com/spdataprofile

How to use:
Mode:
0 = Table Overview 
1 = Column Detail - Number Unique Values, Number Nulls, Min Len, Max Len
2 = Column Statistics - Min, Max, Mean, Median, Standard Deviation
3 = Candidate Key Check - You need a @ColumnList with this
4 = Column Value Distribution - You need to provide a single column name in @ColumnList. If more than one is provided only the first one is used.

You can use @ShowIndexes = 1 and @ShowForeignKeys = 1 in any mode to see all of the indexes and foreign keys.

Example usage:
Table Overview
sp_dataprofile 'Users', 0;

Table Overview with Indexes and FKs
sp_dataprofile 'Users', 0, @ShowIndexes=1, @ShowForeignKeys=1;

Column Detail
sp_dataprofile 'Users', 1

Column Statistics - Only using 10% of the table values
sp_dataprofile 'Users', 2, @SampleValue = 10

Candidate Key Check
sp_dataprofile 'Users', 3, 'DisplayName, Location, WebsiteUrl, CreationDate'

Column Value Distribution
sp_dataprofile 'Posts', 4, 'PostTypeId'

*/
AS
BEGIN
  SET NOCOUNT ON;
  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

  DECLARE @SQLString NVARCHAR(4000);
  DECLARE @SQLStringFK NVARCHAR(4000);
  DECLARE @SQLStringIndexes NVARCHAR(4000);
  DECLARE @Schema NVARCHAR(100);
  DECLARE @DatabaseID INT;
  DECLARE @SchemaPosition INT;
  DECLARE @Msg NVARCHAR(4000);
  DECLARE @ErrorSeverity INT;
  DECLARE @ErrorState INT;
  DECLARE @RowCount BIGINT;
  DECLARE @IsSample BIT = 0;
  DECLARE @TableSample NVARCHAR(100) = '';
  DECLARE @FromTableName NVARCHAR(100) = '';
  DECLARE @ColumnListString NVARCHAR(4000);
  DECLARE @ColumnNameFirst NVARCHAR(4000);
  DECLARE @SQLServerVersion NVARCHAR(100) = '';
  DECLARE @SQLCompatLevelMaster INT;
  DECLARE @SQLCompatLevelDB INT;
  DECLARE @SQLCompatLevelDBOut INT;
  DECLARE @SQLCompatLevel INT;
  DECLARE @ViewSQLDataString NVARCHAR(4000);

  BEGIN TRY

    /* Get that SQL Server Version son! 2005 or older up in here! */
    SELECT @SQLServerVersion = CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(128));

    IF (SELECT LEFT(@SQLServerVersion, CHARINDEX('.', @SQLServerVersion, 0) -1 )) <= 8
    BEGIN
      SET @msg = N'I''m sorry Dave. I can''t run on your version of SQL Server. I require a SQL Server 2005 and higher. The version of this instance is: ' + @SQLServerVersion + '. I promise I won''t open the airlock.';
      RAISERROR(@msg, 16, 1);
    END

    IF @DatabaseName IS NULL
      SET @DatabaseName = DB_NAME();

    /* Get Compat Level. We're going to use this later to determine if we can do the wierd stuff. */
    SELECT @SQLCompatLevelMaster = compatibility_level FROM sys.databases WHERE name = 'master';

    SET @SQLString = N'
      SELECT @SQLCompatLevelDBOut = compatibility_level 
      FROM sys.databases WHERE name = ''' + @DatabaseName + ''';'
    
    IF @SQLString IS NULL 
      RAISERROR('@SQLString is null', 16, 1);
    
    EXEC sp_executesql @SQLString, N'@SQLCompatLevelDBOut INT OUTPUT', @SQLCompatLevelDBOut = @SQLCompatLevelDB OUTPUT;
    
    IF @SQLCompatLevelMaster < @SQLCompatLevelDB 
      SET @SQLCompatLevel = @SQLCompatLevelMaster;
    ELSE
      SET @SQLCompatLevel = @SQLCompatLevelDB;
    
    IF @SQLCompatLevel < 110
    BEGIN 
      SET @Msg = 'Your compatibility level of ' + CAST(@SQLCompatLevel AS NVARCHAR(10)) + ' is a bit too low. I can''t perform median calculations for compatibility levels lower than 110. If this is unacceptable to you feel free to write the median calculation yourself. I accept pull requests. ;)';
      RAISERROR(@msg, 0, 1);
    END

    SET @Schema = PARSENAME(@TableName, 2);
    SET @TableName = PARSENAME(@TableName, 1);
  
    IF @Schema IS NULL 
      SET @Schema = 'dbo';

    IF @Mode NOT IN (0, 1, 2, 3, 4) 
    BEGIN
      SET @msg = 'Mode values should only be 0, 1, 2, 3 or 4. 0 = Table Overview, 1 = Table Detail, 2 = Column Statistics, 3 = Candidate Key Check, 4 = Column Value Distribution';
      RAISERROR(@msg, 1, 1);
      RETURN;
    END 

    IF (@Mode IN (3, 4)) AND (@ColumnList IS NULL OR @ColumnList = '') 
    BEGIN      
      SET @msg = 'It looks like you didn''t provide a ColumnList. A ColumnList is required for the Candidate Key Check and the Column Value Distribution modes.';
      RAISERROR(@msg, 1, 1);
      RETURN;
    END 
  
    IF @SampleType NOT IN ('ROWS', 'PERCENT') 
    BEGIN
      SET @msg = 'Did you mistype the SampleType value? SampleType should be either ''ROWS'' or ''PERCENT''';
      RAISERROR(@msg, 1, 1);
      RETURN;
    END 

    IF @SampleValue < 0 OR @SampleValue > 100 
    BEGIN
      SET @msg = 'Whoops. The SampleValue should be between 0 and 100.';
      RAISERROR(@msg, 1, 1);
      RETURN;
    END

    IF @SampleValue IS NOT NULL
    BEGIN
      SET @IsSample = 1;
      SET @TableSample = ' TABLESAMPLE (' + CAST(@SampleValue AS NVARCHAR(3)) + ' ' + @SampleType + ') REPEATABLE(100) ';
    END

    SET @FromTableName = QUOTENAME(@Schema) + '.' + QUOTENAME(@TableName) + @TableSample;

    If DB_NAME() <> @DatabaseName
      SET @FromTableName = QUOTENAME(@DatabaseName) + '.' + @FromTableName;

    SELECT  @DatabaseID = database_id
    FROM    sys.databases
    WHERE   [name] = @DatabaseName
    AND     user_access_desc = 'MULTI_USER'
    AND     state_desc = 'ONLINE';
          
    /* Format ColumnList  */
    DECLARE @ColumnListClean NVARCHAR(4000);
    DECLARE @ColumnListComma NVARCHAR(4000);
    DECLARE @CommaPos  INT;
    DECLARE @CommaPart NVARCHAR(4000);
    
    SET @ColumnListComma = @ColumnList;
    SET @ColumnListClean = '';
    
    IF RIGHT(RTRIM(@ColumnListComma), 1) <> N','
      SET @ColumnListComma = @ColumnListComma + N',';
    
    SET @CommaPos =  PATINDEX(N'%,%', @ColumnListComma);
    WHILE @CommaPos <> 0 
    BEGIN
      SET @CommaPart = LEFT(@ColumnListComma, @CommaPos - 1);
      SET @ColumnListClean = @ColumnListClean + LTRIM(RTRIM(@CommaPart)) + ',';
      SET @ColumnListComma = STUFF(@ColumnListComma, 1, @CommaPos, '');
      SET @CommaPos = PATINDEX(N'%,%', @ColumnListComma);
    END
    
    SET @ColumnList = @ColumnListClean;
    
    IF RIGHT(@ColumnList, 1) = ','
      SET @ColumnList = LEFT(@ColumnList, LEN(@ColumnList) - 1);
    SET @ColumnListString = '''' + REPLACE(@ColumnList, ',', ''',''') + '''';

    IF @VERBOSE = 1
    BEGIN
      SET @msg = N'ColumnListstring: ' + @ColumnList
      RAISERROR (@msg, 0, 1) WITH NOWAIT;
    END

    IF OBJECT_ID ('tempdb..#table_column_profile') IS NOT NULL
      DROP TABLE #table_column_profile;
    
    CREATE TABLE #table_column_profile (
      [object_id]          INT           NOT NULL ,
      [column_id]          INT           NOT NULL , 
      [name]               NVARCHAR(128) NOT NULL , 
      [system_type]        NVARCHAR(100) NOT NULL ,
      [user_type]          NVARCHAR(100) NOT NULL ,
      [collation]          NVARCHAR(100) NULL ,
      [length]             INTEGER       NULL ,
      [precision]          INTEGER       NULL ,
      [scale]              INTEGER       NULL ,
      [is_nullable]        BIT           NOT NULL ,
      [num_rows]           BIGINT        NULL ,
      [num_unique_values]  BIGINT        NULL ,
      [unique_ratio] AS CAST((CAST([num_unique_values] AS DECIMAL(25,5)) / ISNULL(NULLIF([num_rows], 0), 1)) AS DECIMAL(25,5)) ,
      [num_nulls]          BIGINT        NULL ,
      [nulls_ratio] AS CAST((CAST([num_nulls] AS DECIMAL(25,5)) / ISNULL(NULLIF([num_rows], 0), 1)) AS DECIMAL(25,5)) ,
      [min_length]         INT           NULL ,
      [max_length]         INT           NULL ,
      [min_value]          NVARCHAR(100) NULL ,
      [max_value]          NVARCHAR(100) NULL ,
      [mean]               NVARCHAR(100) NULL ,
      [median]             NVARCHAR(100) NULL ,
      [std_dev]            NVARCHAR(100) NULL
    );

    CREATE TABLE #table_relationship (
     [relationship_type]         NVARCHAR(25)  NULL ,
     [fk_name]                   NVARCHAR(128) NOT NULL ,
     [parent_table]              NVARCHAR(128) NOT NULL ,
     [parent_column_name]        NVARCHAR(128) NOT NULL ,
     [parent_column_id]          INT           NULL ,
     [referrenced_table]         NVARCHAR(128) NOT NULL ,
     [referrenced_column_name]   NVARCHAR(128) NOT NULL ,
     [referenced_column_id]      INT           NULL
    );
  
    CREATE TABLE #table_indexes (
      [name]                 NVARCHAR(128)  NOT NULL ,
      [index_id]             INT            NULL ,
      [type_desc]            NVARCHAR(60)   NULL ,
      [is_primary_key]       BIT            NULL ,
      [is_unique]            BIT            NULL ,
      [is_unique_constraint] BIT            NULL ,
      [is_disabled]          BIT            NULL ,
      [fill_factor]          TINYINT        NULL ,
      [index_columns]        NVARCHAR(max)  NULL ,
      [included_columns]     NVARCHAR(max)  NULL ,
      [filter_definition]    NVARCHAR(max)
    );

    /* Inserting data into #table_column_profile */
    SET @SQLString = N'
      SELECT t.object_id ,
             c.column_id ,
             c.name ,
             sys.name,
             typ.name ,
             c.collation_name ,
             CAST(
               CASE  
                 WHEN c.max_length = -1 THEN c.max_length
                 WHEN sys.name = ''nvarchar'' THEN c.max_length / 2
                 WHEN sys.name = ''nchar'' THEN c.max_length / 2
                 ELSE c.max_length
               END
             AS NVARCHAR(100)) AS max_length ,
             c.precision ,
             c.scale ,
             c.is_nullable
    FROM   ' + QUOTENAME(@DatabaseName) + '.sys.tables  t
    JOIN   ' + QUOTENAME(@DatabaseName) + '.sys.columns c   ON  t.object_id = c.object_id
    JOIN   ' + QUOTENAME(@DatabaseName) + '.sys.types   typ ON  c.system_type_id = typ.system_type_id
                                                            AND c.user_type_id = typ.user_type_id
    JOIN   ' + QUOTENAME(@DatabaseName) + '.sys.types   sys ON  typ.system_type_id = sys.system_type_id
                                                            AND sys.user_type_id = sys.system_type_id
    JOIN   ' + QUOTENAME(@DatabaseName) + '.sys.schemas s   ON  t.schema_id = s.schema_id
                                                            AND s.name = ''' + @Schema + '''
    WHERE  t.name = ''' + @TableName + '''
    ORDER BY c.column_id;'

    IF @VERBOSE = 1
    BEGIN
      RAISERROR (N'Inserting data into #table_column_profile', 0, 1) WITH NOWAIT;
      RAISERROR (@SQLString, 0, 1) WITH NOWAIT;
    END

    IF @SQLString IS NULL 
      RAISERROR('@SQLString is null', 16, 1);

    INSERT INTO #table_column_profile (
      [object_id] ,
      [column_id] ,
      [name] ,
      [system_type] ,
      [user_type] ,
      [collation] ,
      [length] ,
      [precision] ,
      [scale] ,
      [is_nullable]
    ) 
    EXEC sp_executesql @SQLString;
  
    /* Update actual row count  */     
    SET @SQLString = N'
      UPDATE #table_column_profile  
      SET num_rows = cnt 
      FROM (SELECT COUNT_BIG(*) cnt 
            FROM ' + @FromTableName + ') tablecount ;'
    
    IF @VERBOSE = 1
    BEGIN
      RAISERROR (N'Updating data in #table_column_profile for table row counts', 0, 1) WITH NOWAIT;
      RAISERROR (@SQLString, 0, 1) WITH NOWAIT;
    END
    
    IF @SQLString IS NULL 
      RAISERROR('@SQLString is null', 16, 1);

    EXEC sp_executesql @SQLString;
      
    SELECT TOP 1 @RowCount = num_rows FROM #table_column_profile;
    
    /* Insert FK data into #table_relationship */
    IF @ShowForeignKeys = 1
    BEGIN

      SET @SQLString = N'
        SELECT      relationship_type = ''Outgoing'',
                    fk_name = fk.name ,
                    parent_table = tp.name ,
                    parent_column_name = cp.name , 
                    parent_column_id = cp.column_id ,
                    referrenced_table = tr.name ,
                    referrenced_column_name = cr.name , 
                    referenced_column_id = cr.column_id
        FROM        ' + QUOTENAME(@DatabaseName) + '.sys.foreign_keys        fk
        JOIN        ' + QUOTENAME(@DatabaseName) + '.sys.tables              tp  ON  fk.parent_object_id = tp.object_id
        LEFT JOIN   ' + QUOTENAME(@DatabaseName) + '.sys.tables              tr  ON  fk.referenced_object_id = tr.object_id
        JOIN        ' + QUOTENAME(@DatabaseName) + '.sys.foreign_key_columns fkc ON  fkc.constraint_object_id = fk.object_id
        JOIN        ' + QUOTENAME(@DatabaseName) + '.sys.columns             cp  ON  fkc.parent_column_id = cp.column_id 
                                                AND fkc.parent_object_id = cp.object_id
        JOIN        ' + QUOTENAME(@DatabaseName) + '.sys.columns             cr  ON  fkc.referenced_column_id = cr.column_id 
                                                AND fkc.referenced_object_id = cr.object_id
        JOIN        ' + QUOTENAME(@DatabaseName) + '.sys.schemas             s   ON  tr.schema_id = s.schema_id
                                                                                 AND s.name = ''' + @Schema + '''
        WHERE       tr.name = ''' + @TableName + '''
        
        UNION ALL
        
        SELECT      RelationshipType = ''Incoming'',
                    FKName = fk.name ,
                    ParentTable = tp.name ,
                    ParentColumnName = cp.name , 
                    ParentColumnID = cp.column_id ,
                    ReferencedTable = tr.name ,
                    ReferencedColumnName = cr.name , 
                    ReferencedColumnID = cr.column_id
        FROM        ' + QUOTENAME(@DatabaseName) + '.sys.foreign_keys        fk
        JOIN        ' + QUOTENAME(@DatabaseName) + '.sys.tables              tp  ON  fk.parent_object_id = tp.object_id
        LEFT JOIN   ' + QUOTENAME(@DatabaseName) + '.sys.tables              tr  ON  fk.referenced_object_id = tr.object_id
        JOIN        ' + QUOTENAME(@DatabaseName) + '.sys.foreign_key_columns fkc ON  fkc.constraint_object_id = fk.object_id
        JOIN        ' + QUOTENAME(@DatabaseName) + '.sys.columns             cp  ON  fkc.parent_column_id = cp.column_id AND fkc.parent_object_id = cp.object_id
        JOIN        ' + QUOTENAME(@DatabaseName) + '.sys.columns             cr  ON  fkc.referenced_column_id = cr.column_id AND fkc.referenced_object_id = cr.object_id
        JOIN        ' + QUOTENAME(@DatabaseName) + '.sys.schemas             s   ON  tp.schema_id = s.schema_id
                                                                                 AND s.name = ''' + @Schema + '''
        WHERE       tp.name = ''' + @TableName + ''''
    
      IF @VERBOSE = 1
      BEGIN
        RAISERROR (N'Insert FK data into #table_relationship', 0, 1) WITH NOWAIT;
        RAISERROR (@SQLString, 0, 1) WITH NOWAIT;
      END
    
      IF @SQLString IS NULL 
        RAISERROR('@SQLString is null', 16, 1);

      INSERT INTO #table_relationship (
        [relationship_type] ,
        [fk_name] ,
        [parent_table] ,
        [parent_column_name] ,
        [parent_column_id] ,
        [referrenced_table] ,
        [referrenced_column_name] ,
        [referenced_column_id]
      )
      EXEC sp_executesql @SQLString;

      SET @SQLStringFK = N'
        SELECT    [relationship_type] ,
                  [fk_name] ,
                  [parent_table] ,
                  [parent_column_name] ,
                  [parent_column_id] ,
                  [referrenced_table] ,
                  [referrenced_column_name] ,
                  [referenced_column_id]
        FROM      #table_relationship
        ORDER BY  relationship_type ,
                  parent_table ,
                  fk_name ;'

    END

    /* Insert Index data into #table_indexes */
    IF @ShowIndexes = 1
    BEGIN

      SET @SQLString = N'
        SELECT     i.name , 
                   i.index_id ,
                   i.type_desc ,
                   i.is_primary_key ,
                   i.is_unique ,
                   i.is_unique_constraint ,
                   i.is_disabled ,
                   i.fill_factor ,
                   index_columns = 
                    (SELECT STUFF(
                      (SELECT '', '' +  c.name + CASE WHEN ic.is_descending_key = 1 THEN '' DESC'' ELSE '' ASC'' END 
                       FROM   ' + QUOTENAME(@DatabaseName) + '.sys.index_columns ic
                       JOIN   ' + QUOTENAME(@DatabaseName) + '.sys.columns       c   ON  ic.object_id = c.object_id
                                                    AND ic.column_id = c.column_id
                       WHERE  i.object_id = ic.object_id
                       AND    i.index_id = ic.index_id
                       AND    ic.is_included_column = 0
                       ORDER BY ic.index_column_id
                       FOR XML PATH (''''))
                     , 1, 1, '''') ) ,
                   included_columns = 
                    (SELECT STUFF(
                      (SELECT '', '' +  c.name 
                      FROM   ' + QUOTENAME(@DatabaseName) + '.sys.index_columns ic
                      JOIN   ' + QUOTENAME(@DatabaseName) + '.sys.columns       c   ON  ic.object_id = c.object_id
                                                   AND ic.column_id = c.column_id
                      WHERE  i.object_id = ic.object_id
                      AND    i.index_id = ic.index_id
                      AND    ic.is_included_column = 1
                      ORDER BY ic.index_column_id
                      FOR XML PATH (''''))
                    , 1, 1, '''') ) ,
                   i.filter_definition
          FROM     ' + QUOTENAME(@DatabaseName) + '.sys.indexes       i
          WHERE    i.object_id = OBJECT_ID(''' + @FromTableName + ''')
          ORDER BY i.index_id'
    
      IF @VERBOSE = 1
      BEGIN
        RAISERROR (N'Insert index data into #table_indexes', 0, 1) WITH NOWAIT;
        RAISERROR (@SQLString, 0, 1) WITH NOWAIT;
      END
    
      INSERT INTO #table_indexes (
        [name] ,
        [index_id] ,
        [type_desc] ,
        [is_primary_key] , 
        [is_unique] ,
        [is_unique_constraint] ,
        [is_disabled] ,
        [fill_factor] ,
        [index_columns] ,
        [included_columns] ,
        [filter_definition]
      )        
      EXEC sp_executesql @SQLString;

      IF @SQLString IS NULL 
        RAISERROR('@SQLString is null', 16, 1);

      SET @SQLStringIndexes = N'
        SELECT    [name] ,
                  [index_id] ,
                  [type_desc] ,
                  [is_primary_key] , 
                  [is_unique] ,
                  [is_unique_constraint] ,
                  [is_disabled] ,
                  [fill_factor] ,
                  [index_columns] ,
                  [included_columns] ,
                  [filter_definition]
        FROM      #table_indexes
        ORDER BY  index_id ;'        
    END

    IF @Mode = 1 /* Table Detail */
    BEGIN         
      -- Determine unique values for each column with a valid type.
      DECLARE @uniq_col_name NVARCHAR(500) ,
              @uniq_col_id  INTEGER;
      
      DECLARE uniq_cur CURSOR
        LOCAL STATIC FORWARD_ONLY READ_ONLY FOR
          SELECT p.name,
                 p.column_id
          FROM   #table_column_profile p
          WHERE  system_type IN ('uniqueidentifier', 'date', 'time', 'datetime2', 'datetimeoffset', 'tinyint', 'smallint', 'int', 'smalldatetime', 'real', 'money', 'datetime', 'float', 'sql_variant', 'bit', 'decimal', 'numeric', 'smallmoney' ,'bigint', 'hierarchyid', 'geometry', 'geography', 'varbinary', 'varchar', 'binary', 'char', 'timestamp', 'nvarchar', 'nchar') ;
    
      OPEN uniq_cur;
      
      FETCH NEXT FROM uniq_cur INTO @uniq_col_name, @uniq_col_id;
  
      WHILE @@FETCH_STATUS = 0
      BEGIN      
        SELECT @SQLString = N'
          UPDATE #table_column_profile 
          SET num_unique_values = val 
          FROM (
            SELECT COUNT(DISTINCT ' + QUOTENAME(@uniq_col_name) + ') val 
            FROM ' + @FromTableName + ') uniq 
          WHERE column_id = ' + CAST(@uniq_col_id AS NVARCHAR(10)) 
      
        IF @VERBOSE = 1
        BEGIN
          RAISERROR (N'Determine unique values for each column with a valid type.', 0, 1) WITH NOWAIT;
          RAISERROR (@SQLString, 0, 1) WITH NOWAIT;
        END

        IF @SQLString IS NULL 
          RAISERROR('@SQLString is null', 16, 1);
  
        EXECUTE sp_executesql @SQLString;
    
        FETCH NEXT FROM uniq_cur INTO @uniq_col_name, @uniq_col_id;
      END
        
      -- Determine null values for each column   
      DECLARE @null_col_name NVARCHAR(500) ,
              @null_col_num  INTEGER;
    
      DECLARE null_cur CURSOR
        LOCAL STATIC FORWARD_ONLY READ_ONLY FOR
          SELECT p.name,
                 p.column_id
          FROM   #table_column_profile p
          WHERE  p.is_nullable = 1;
    
      OPEN null_cur;
      
      FETCH NEXT FROM null_cur INTO @null_col_name, @null_col_num;
      
      WHILE @@FETCH_STATUS = 0
      BEGIN
    
        SELECT @SQLString = 
          N'UPDATE #table_column_profile ' +
           'SET num_nulls = val ' + 
           'FROM (' +
           '  SELECT COUNT(*) val ' +
           '  FROM ' + @FromTableName + ' ' +
           '  WHERE ' + QUOTENAME(@null_col_name) + ' IS NULL ' +
           ') uniq ' +
           'WHERE column_id = ' + CAST(@null_col_num AS NVARCHAR(10))

        IF @VERBOSE = 1
        BEGIN
          RAISERROR (N'Updating data in #table_column_profile for column null row counts.', 0, 1) WITH NOWAIT;
          RAISERROR (@SQLString, 0, 1) WITH NOWAIT;
        END
    
        IF @SQLString IS NULL 
          RAISERROR('@SQLString is null', 16, 1);
    
        EXECUTE sp_executesql @SQLString;
        
        FETCH NEXT FROM null_cur INTO @null_col_name, @null_col_num;
      END
      
      CLOSE null_cur;
      DEALLOCATE null_cur;
    
      /* Determine min/max length values */
      DECLARE @len_col_name NVARCHAR(500) ,
              @len_col_num  INTEGER;
    
      DECLARE len_cur CURSOR
  
       LOCAL STATIC FORWARD_ONLY READ_ONLY FOR
          SELECT p.name,
                 p.column_id
          FROM   #table_column_profile p
          WHERE  p.system_type IN ('varchar', 'char', 'nvarchar', 'nchar');
    
      OPEN len_cur;
      
      FETCH NEXT FROM len_cur INTO @len_col_name, @len_col_num;
      
      WHILE @@FETCH_STATUS = 0
      BEGIN
        SELECT @SQLString = 
          N'UPDATE #table_column_profile ' +
           'SET max_length = val ' + 
           'FROM (' +
           '  SELECT MAX(LEN(' + QUOTENAME(@len_col_name) + ')) val ' +
           '  FROM ' + @FromTableName + ' ' +
           ') uniq ' +
           'WHERE column_id = ' + CAST(@len_col_num AS NVARCHAR(10));
    
        IF @Verbose = 1
        BEGIN
          RAISERROR (N'Updating data in #table_column_profile for column max length', 0, 1) WITH NOWAIT;
          RAISERROR (@SQLString, 0, 1) WITH NOWAIT;;
        END

        IF @SQLString IS NULL 
          RAISERROR('@SQLString is null', 16, 1);
    
        EXECUTE sp_executesql @SQLString;
      
        SELECT @SQLString = 
          N'UPDATE #table_column_profile ' +
           'SET min_length = val ' + 
           'FROM (' +
           '  SELECT MIN(LEN(' + QUOTENAME(@len_col_name) + ')) val ' +
           '  FROM ' + @FromTableName + ' ' +
           ') uniq ' +
           'WHERE column_id = ' + CAST(@len_col_num AS NVARCHAR(10));

        IF @Verbose = 1
        BEGIN
          RAISERROR (N'Updating data in #table_column_profile for column min length', 0, 1) WITH NOWAIT;
          RAISERROR (@SQLString, 0, 1) WITH NOWAIT;;
        END
    
        IF @SQLString IS NULL 
          RAISERROR('@SQLString is null', 16, 1);

        EXECUTE sp_executesql @SQLString;

        FETCH NEXT FROM len_cur INTO @len_col_name, @len_col_num;
      END
      
      CLOSE len_cur;
      DEALLOCATE len_cur; 
  
    END /* Table Detail */
  
    IF @Mode = 2 /* Column Statistics */
    BEGIN
  
      /* Determine Column Statistics */
      IF @Verbose = 1
        RAISERROR (N'Updating data in #table_column_profile for column statistics', 0, 1) WITH NOWAIT;
     
      DECLARE @stats_col_name NVARCHAR(500) ,
              @stats_col_num  INTEGER ,
              @stats_col_type NVARCHAR(50);
    
      DECLARE stats_cur CURSOR LOCAL STATIC FORWARD_ONLY READ_ONLY FOR
      SELECT p.name,
             p.column_id,
             p.system_type
      FROM   #table_column_profile p
      WHERE  p.system_type IN ('bigint', 'bit', 'decimal', 'int', 'money', 'numeric', 'smallint', 'smallmoney', 'tinyint', 'float', 'real', 'date', 'datetime2', 'datetime', 'datetimeoffset', 'smalldatetime', 'time');
    
      OPEN stats_cur;
      
      FETCH NEXT FROM stats_cur INTO @stats_col_name, @stats_col_num, @stats_col_type;
      
      WHILE @@FETCH_STATUS = 0
      BEGIN
        SELECT @SQLString = N'  
          UPDATE #table_column_profile 
          SET max_value = max_val ,
              min_value = min_val 
          FROM (
            SELECT CAST(MAX(' + QUOTENAME(@stats_col_name) + ') AS NVARCHAR(100)) max_val  ,
                   CAST(MIN(' + QUOTENAME(@stats_col_name) + ') AS NVARCHAR(100)) min_val  
            FROM ' + @FromTableName + ' 
           ) stats 
          WHERE column_id = ' + CAST(@stats_col_num AS NVARCHAR(10))

        IF @Verbose = 1
        BEGIN
          RAISERROR (N'Updating data in #table_column_profile for column max length', 0, 1) WITH NOWAIT;
          RAISERROR (@SQLString, 0, 1) WITH NOWAIT;;
        END
  
        IF @SQLString IS NULL
          RAISERROR('@SQLString is null', 16, 1);
  
        IF @stats_col_type != 'bit'
          EXECUTE sp_executesql @SQLString;
  
        /* Update mean, standard deviation */
        DECLARE @col_name NVARCHAR(100) = QUOTENAME(@stats_col_name);
      
        IF @stats_col_type = 'int'
          SET @col_name = 'CAST(' + QUOTENAME(@stats_col_name) + ' AS BIGINT)';
  
        SELECT @SQLString = N'
          UPDATE #table_column_profile 
          SET mean = mean_val ,
              std_dev = std_dev_val
          FROM (
            SELECT mean_val = CAST(AVG(' + @col_name + ') AS NVARCHAR(100)) ,
                   std_dev_val = CAST(CAST(STDEV(' + QUOTENAME(@stats_col_name) + ') AS NUMERIC(18,4)) AS NVARCHAR(100)) 
            FROM ' + @FromTableName + ' 
          ) stats WHERE column_id = ' + CAST(@stats_col_num AS NVARCHAR(10))

        IF @Verbose = 1
        BEGIN
          RAISERROR (N'Update mean, standard deviation', 0, 1) WITH NOWAIT;
          RAISERROR (@SQLString, 0, 1) WITH NOWAIT;;
        END
        
        IF @SQLString IS NULL
          RAISERROR('@SQLString is null', 16, 1);
  
        IF @stats_col_type IN ('bigint', 'decimal', 'int', 'money', 'numeric', 'smallint', 'smallmoney', 'tinyint', 'float', 'real')
          EXECUTE sp_executesql @SQLString;
       
        /* Update median */
        IF @SQLCompatLevel >= 110
        BEGIN
        
          SELECT @SQLString = N'
            UPDATE #table_column_profile 
            SET median = median_val
            FROM (
              SELECT DISTINCT median_val = PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY ' + @stats_col_name + ') OVER ()
              FROM ' + @FromTableName + ' 
            ) stats 
            WHERE column_id = ' + CAST(@stats_col_num AS NVARCHAR(10))

          IF @Verbose = 1
          BEGIN
            RAISERROR (N'Update median', 0, 1) WITH NOWAIT;
            RAISERROR (@SQLString, 0, 1) WITH NOWAIT;;
          END
  
          IF @SQLString IS NULL
            RAISERROR('@SQLString is null', 16, 1);
  
          IF @stats_col_type IN ('bigint', 'decimal', 'int', 'money', 'numeric', 'smallint', 'smallmoney', 'tinyint', 'float', 'real')
            EXECUTE sp_executesql @SQLString;
       
        END /* End Median Update */
  
        FETCH NEXT FROM stats_cur INTO @stats_col_name, @stats_col_num, @stats_col_type;
    
      END /* Column Statistics Loop */
      
      CLOSE stats_cur;
      DEALLOCATE stats_cur; 
  
    END /* 2 - Column Statistics */

    IF @Mode = 3 /* 3 - Candidate Key Check */
    BEGIN

      DECLARE @WhereString NVARCHAR(MAX)
      DECLARE @WhereCtr INT;

      IF OBJECT_ID ('tempdb..#ColumnName') IS NOT NULL
        DROP TABLE #ColumnName;

      CREATE TABLE #ColumnName (
        column_name NVARCHAR(500),
        column_type NVARCHAR(100)
      );

      SET @WhereString = ' WHERE ';
      SET @WhereCtr = 0;

      SET @SQLString = N'
        SELECT c.name ,
               type = TYPE_NAME(c.system_type_id)
        FROM   sys.tables t
        JOIN   sys.columns c ON  c.object_id = t.object_id
        WHERE  t.name = ''' + @TableName + '''
        AND    t.schema_id = SCHEMA_ID(''' + @Schema + ''')
        AND    c.name IN (' + @ColumnListString + ');'

      IF @Verbose = 1
      BEGIN
        RAISERROR (N'Find data types for columns for Where clause Candidate Key Check', 0, 1) WITH NOWAIT;
        RAISERROR (@SQLString, 0, 1) WITH NOWAIT;;
      END

      IF @SQLString IS NULL
        RAISERROR('@SQLString is null', 16, 1);

      INSERT INTO #ColumnName
      EXECUTE sp_executesql @SQLString

      -- Determine unique values for each column with a valid type.
      DECLARE @where_col_name   NVARCHAR(500) ,
              @where_type_name  NVARCHAR(100) ,
              @where_col_value  NVARCHAR(500) ;
      
      DECLARE where_type_cur CURSOR
        LOCAL STATIC FORWARD_ONLY READ_ONLY FOR
           SELECT column_name ,
                  column_type
           FROM   #ColumnName
    
      OPEN where_type_cur;
      
      FETCH NEXT FROM where_type_cur INTO @where_col_name, @where_type_name;

      WHILE @@FETCH_STATUS = 0
      BEGIN      

        SET @WhereCtr = @WhereCtr + 1;
        IF @WhereCtr > 1
          SET @WhereString = @WhereString + ' AND ';

        IF @where_type_name IN ('datetime', 'datetime2', 'date', 'time', 'datetimeoffset', 'smalldatetime')
        BEGIN
          SET @where_col_value = 'CONVERT(NVARCHAR, ' + @where_col_name + ', 127)'
        END
        ELSE
          SET @where_col_value = 'CONVERT(NVARCHAR(MAX), ' + @where_col_name + ')'

        IF @where_type_name IN ('uniqueidentifier', 'date', 'time', 'datetime2', 'datetimeoffset', 'smalldatetime', 'datetime', 'sql_variant', 'varchar', 'char', 'timestamp', 'nvarchar', 'nchar') 
        BEGIN
          SET @WhereString = @WhereString + @where_col_name + ''' + COALESCE('' = '''''' + ' + @where_col_value + ' + '''''''', '' IS NULL'') + ''';
        END
        ELSE
        BEGIN
          SET @WhereString = @WhereString + @where_col_name + ''' + COALESCE('' = '' + ' + @where_col_value + ' + '''', '' IS NULL'') + ''';
        END

        FETCH NEXT FROM where_type_cur INTO @where_col_name, @where_type_name;
      END

      CLOSE where_type_cur;
      DEALLOCATE where_type_cur; 
  
      IF @Verbose = 1
      BEGIN
        SET @msg = N'@WhereString: ' + @WhereString;
        RAISERROR (@msg, 0, 1) WITH NOWAIT;
      END

    END /* 3 - Candidate Key Check */

    IF @Mode = 4 /* 4 - Column Value Distribution */
    BEGIN

      DECLARE @RowCountDistinct BIGINT;

      IF OBJECT_ID ('tempdb..#table_distinct_count') IS NOT NULL
        DROP TABLE #table_distinct_count;

      CREATE TABLE #table_distinct_count (
          [column_count] BIGINT NULL);

      /* Only process the first column identified */
      IF CHARINDEX(',', @ColumnList) > 0
        SET @ColumnNameFirst = LEFT(@ColumnList, CHARINDEX(',', @ColumnList) - 1)
      ELSE 
        SET @ColumnNameFirst = RTRIM(LTRIM(@ColumnList))

      IF RTRIM(LTRIM(@ColumnNameFirst)) <> RTRIM(LTRIM(@ColumnList))
      BEGIN
        RAISERROR(N'More than one column was supplied. Only the first column will be used in determining the column value distribution.', 0, 1);
      END 
      
      SELECT @SQLString = N'
        INSERT INTO #table_distinct_count (column_count)
        SELECT COUNT(DISTINCT ' + QUOTENAME(@ColumnNameFirst) + ') val 
        FROM ' + @FromTableName + ' 
      ';

      IF @Verbose = 1
      BEGIN
        RAISERROR (N'Insert distinct count for Column Value Distribution.', 0, 1) WITH NOWAIT;
        RAISERROR (@SQLString, 0, 1) WITH NOWAIT;;
      END
  
      IF @SQLString IS NULL 
        RAISERROR('@SQLString is null', 16, 1);
  
      EXEC sp_executesql @SQLString;

    END /* 4 - Column Value Distribution */

    /* Table schema output */  
    IF @Mode = 0
    BEGIN

      IF @Verbose = 1
        RAISERROR (N'Ouputting data for table schema output.', 0, 1) WITH NOWAIT;

      /* Table output */
      SELECT [object_id] = OBJECT_ID(QUOTENAME(@Schema) + '.' + QUOTENAME(@TableName)) ,
             [schema_name] = @Schema ,
             [table_name] = @TableName ,
             [row_count] = @RowCount ,
             [is_sample] = CASE @IsSample WHEN 1 THEN 'True' ELSE 'False' END;

      SELECT   [column_id] ,
               [name] ,
               [user_type] ,
               [system_type] ,
               [length] = 
                 CASE 
                   WHEN [length] = -1 AND [system_type] = 'xml' THEN NULL
                   WHEN [length] = -1 THEN 'max'
                   ELSE CAST([length] AS VARCHAR(50)) 
                 END,
               [precision] ,
               [scale] ,
               [is_nullable] ,
               [collation] 
      FROM #table_column_profile;

      IF @ShowForeignKeys = 1
      BEGIN
        IF @Verbose = 1
        BEGIN
          RAISERROR (N'Displaying Foreign Keys', 0, 1) WITH NOWAIT;
          RAISERROR (@SQLStringFK, 0, 1) WITH NOWAIT;
        END

        IF @SQLStringFK IS NULL 
          RAISERROR('@SQLStringFK is null', 16, 1);
  
        EXEC sp_executesql @SQLStringFK;
      END

      IF @ShowIndexes = 1
      BEGIN
        IF @Verbose = 1
        BEGIN
          RAISERROR (N'Displaying Indexes', 0, 1) WITH NOWAIT;
          RAISERROR (@SQLStringIndexes, 0, 1) WITH NOWAIT;
        END

        IF @SQLStringIndexes IS NULL 
          RAISERROR('@SQLStringIndexes is null', 16, 1);
  
        EXEC sp_executesql @SQLStringIndexes;
      END
    END /* Mode 0: Table schema output */
    
    /* Table detail output */  
    IF @Mode = 1
    BEGIN
  
      IF @Verbose = 1
        RAISERROR (N'Ouputting data for table detail output.', 0, 1) WITH NOWAIT;

      /* Table output */
      SELECT   [object_id] = OBJECT_ID(QUOTENAME(@Schema) + '.' + QUOTENAME(@TableName)) ,
               [schema_name] = @Schema ,
               [table_name] = @TableName ,
               [row_count] = @RowCount ,
               [is_sample] = CASE @IsSample WHEN 1 THEN 'True' ELSE 'False' END;

      SELECT   [column_id] ,
               [name] ,
               [user_type] ,
               [system_type] ,
               [length] = 
                 CASE 
                   WHEN [length] = -1 AND [system_type] = 'xml' THEN NULL
                   WHEN [length] = -1 THEN 'max'
                   ELSE CAST([length] AS VARCHAR(50)) 
                 END,
               [precision] ,
               [scale] ,
               [is_nullable] ,
               [num_unique_values] ,
               [unique_ratio] , 
               [num_nulls] , 
               [nulls_ratio] ,
               [min_length] ,
               [max_length]
      FROM #table_column_profile;

      IF @ShowForeignKeys = 1
      BEGIN
        IF @Verbose = 1
        BEGIN
          RAISERROR (N'Displaying Foreign Keys', 0, 1) WITH NOWAIT;
          RAISERROR (@SQLStringFK, 0, 1) WITH NOWAIT;
        END

        IF @SQLStringFK IS NULL 
          RAISERROR('@SQLStringFK is null', 16, 1);
  
        EXEC sp_executesql @SQLStringFK;
      END

      IF @ShowIndexes = 1
      BEGIN
        IF @Verbose = 1
        BEGIN
          RAISERROR (N'Displaying Indexes', 0, 1) WITH NOWAIT;
          RAISERROR (@SQLStringIndexes, 0, 1) WITH NOWAIT;
        END

        IF @SQLStringIndexes IS NULL 
          RAISERROR('@SQLStringIndexes is null', 16, 1);
  
        EXEC sp_executesql @SQLStringIndexes;
      END
             
    END /* Mode 1: Table detail output */
  
    /* Column statistics output */
    IF @Mode = 2
    BEGIN
  
      IF @Verbose = 1
        RAISERROR (N'Ouputting data for column statistics output.', 0, 1) WITH NOWAIT;

      /* Table output */
      SELECT [object_id] = OBJECT_ID(QUOTENAME(@Schema) + '.' + QUOTENAME(@TableName)) ,
             [schema_name] = @Schema ,
             [table_name] = @TableName ,
             [row_count] = @RowCount ,
             [is_sample] = CASE @IsSample WHEN 1 THEN 'True' ELSE 'False' END;

      SET @SQLString = N'
          SELECT [column_id] ,
                 [name] ,
                 [user_type] ,
                 [system_type] ,
                 [length] = 
                   CASE 
                     WHEN [length] = -1 AND [system_type] = ''xml'' THEN NULL
                     WHEN [length] = -1 THEN ''max''
                     ELSE CAST([length] AS VARCHAR(50)) 
                   END,
                 [precision] ,
                 [scale] ,
                 [is_nullable] ,
                 [min_value] ,
                 [max_value] ,
                 [mean] ,'
  
      IF @SQLCompatLevel >= 110
        SET @SQLString = @SQLString + N'
                 [median] ,'
  
      SET @SQLString = @SQLString + N'             
                 [std_dev]
          FROM #table_column_profile;'
  
      IF @SQLString IS NULL 
        RAISERROR('@SQLString is null', 16, 1);
  
      EXEC sp_executesql @SQLString;

      IF @ShowForeignKeys = 1
      BEGIN
        IF @Verbose = 1
        BEGIN
          RAISERROR (N'Displaying Foreign Keys', 0, 1) WITH NOWAIT;
          RAISERROR (@SQLStringFK, 0, 1) WITH NOWAIT;
        END

        IF @SQLStringFK IS NULL 
          RAISERROR('@SQLStringFK is null', 16, 1);
  
        EXEC sp_executesql @SQLStringFK;
      END

      IF @ShowIndexes = 1
      BEGIN
        IF @Verbose = 1
        BEGIN
          RAISERROR (N'Displaying Indexes', 0, 1) WITH NOWAIT;
          RAISERROR (@SQLStringIndexes, 0, 1) WITH NOWAIT;
        END

        IF @SQLStringIndexes IS NULL 
          RAISERROR('@SQLStringIndexes is null', 16, 1);
  
        EXEC sp_executesql @SQLStringIndexes;
      END

    END /* Mode 2: Column statistics output */
  
    /* Candidate Key Check */
    IF @Mode = 3
    BEGIN
 
      /* Table output */
      SELECT [object_id] = OBJECT_ID(QUOTENAME(@Schema) + '.' + QUOTENAME(@TableName)) ,
             [schema_name] = @Schema ,
             [table_name] = @TableName ,
             [row_count] = @RowCount ,
             [is_sample] = CASE @IsSample WHEN 1 THEN 'True' ELSE 'False' END;

      SET @SQLString = N'
        SELECT    COUNT(*) AS row_count ,
                  ' + @ColumnList + ' ,
                  view_data_sql = ''SELECT * FROM ' + @FromTableName + @WhereString + '''
        FROM      ' + @FromTableName + '
        GROUP BY  ' + @ColumnList + '
        HAVING    COUNT(*) > 1
        ORDER BY  1 DESC
       ';

      IF @Verbose = 1
      BEGIN
        RAISERROR (N'Ouputting data for candidate key check.', 0, 1) WITH NOWAIT;
        RAISERROR (@SQLString, 0, 1) WITH NOWAIT;;
      END

      IF @SQLString IS NULL 
        RAISERROR('@SQLString is null', 16, 1);
  
      EXEC sp_executesql @SQLString;

      IF @ShowForeignKeys = 1
      BEGIN
        IF @Verbose = 1
        BEGIN
          RAISERROR (N'Displaying Foreign Keys', 0, 1) WITH NOWAIT;
          RAISERROR (@SQLStringFK, 0, 1) WITH NOWAIT;
        END

        IF @SQLStringFK IS NULL 
          RAISERROR('@SQLStringFK is null', 16, 1);
  
        EXEC sp_executesql @SQLStringFK;
      END

      IF @ShowIndexes = 1
      BEGIN
        IF @Verbose = 1
        BEGIN
          RAISERROR (N'Displaying Indexes', 0, 1) WITH NOWAIT;
          RAISERROR (@SQLStringIndexes, 0, 1) WITH NOWAIT;
        END

        IF @SQLStringIndexes IS NULL 
          RAISERROR('@SQLStringIndexes is null', 16, 1);
  
        EXEC sp_executesql @SQLStringIndexes;
      END

    END /* 3 - Candidate Key Check */

    /* 4 - Column Value Distribution */
    IF @Mode = 4 
    BEGIN

      /* Table output */
      SELECT [object_id] = OBJECT_ID(QUOTENAME(@Schema) + '.' + QUOTENAME(@TableName)) ,
             [schema_name] = @Schema ,
             [table_name] = @TableName ,
             [row_count] = @RowCount ,
             [column_name] = @ColumnNameFirst ,
             [distinct_row_count] = (SELECT column_count FROM #table_distinct_count) ,
             [is_sample] = CASE @IsSample WHEN 1 THEN 'True' ELSE 'False' END ;

      SELECT @SQLString = N'
        SELECT ' + @ColumnNameFirst + ' ,
                Count = COUNT(*) ,
                Percentage = CAST((CAST(COUNT(*)AS DECIMAL(18,4)) / ' + CAST(@RowCount AS NVARCHAR(25)) + ') * 100 AS DECIMAL(18,4))
        FROM   ' + @FromTableName + '
        GROUP BY ' + @ColumnNameFirst + '
        ORDER BY 2 DESC, 1
      ';

      IF @Verbose = 1
      BEGIN
        RAISERROR (N'Ouputting data for column value distribution', 0, 1) WITH NOWAIT;
        RAISERROR (@SQLString, 0, 1) WITH NOWAIT;;
      END

      IF @SQLString IS NULL 
        RAISERROR('@SQLString is null', 16, 1);
  
      EXEC sp_executesql @SQLString;

      IF @ShowForeignKeys = 1
      BEGIN
        IF @Verbose = 1
        BEGIN
          RAISERROR (N'Displaying Foreign Keys', 0, 1) WITH NOWAIT;
          RAISERROR (@SQLStringFK, 0, 1) WITH NOWAIT;
        END

        IF @SQLStringFK IS NULL 
          RAISERROR('@SQLStringFK is null', 16, 1);
  
        EXEC sp_executesql @SQLStringFK;
      END

      IF @ShowIndexes = 1
      BEGIN
        IF @Verbose = 1
        BEGIN
          RAISERROR (N'Displaying Indexes', 0, 1) WITH NOWAIT;
          RAISERROR (@SQLStringIndexes, 0, 1) WITH NOWAIT;
        END

        IF @SQLStringIndexes IS NULL 
          RAISERROR('@SQLStringIndexes is null', 16, 1);
  
        EXEC sp_executesql @SQLStringIndexes;
      END

    END /* 4 - Column Value Distribution */

    DROP TABLE #table_column_profile;
    DROP TABLE #table_relationship;
    DROP TABLE #table_indexes
  
    SET NOCOUNT OFF;
  
  END TRY
  
  BEGIN CATCH
    RAISERROR (N'Uh oh. Something bad happend.', 0,1) WITH NOWAIT;
  
    SELECT  @msg = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();
  
    RAISERROR (@msg, @ErrorSeverity, @ErrorState);
    
    WHILE @@trancount > 0 
      ROLLBACK;
  
    RETURN;
  END CATCH;

END

GO
