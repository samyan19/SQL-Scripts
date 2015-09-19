Must get round to writing this as an articel some time. 

This document assumes that the SERVER is at the correct collation and that the DATABASE is a different collation to the server. These steps will bring the Database into alignment. It is for SQL 2005 ONLY and make sure you have a backup of the database before you start.

1. load the script called Generate Change Column Collation 
Ensure that the Collation setting at the top is correct
Run it against the Database
Save the results as 01_Change_Column_Collation.SQL

2. Load the Script called Generate Primary Key Constraints
Run it against the database
Save the results as 02_Create_PK.SQL

3. Load the Script called Generate Alternate Key Indexes
Run it against the database
Save the results as 03_Create_AK.SQL

4. Load the Script called Generate Foreign Key Constraints
Run it against the database
Save the results as 04_Create_FK.SQL

5. Load the Script called Generate Check Constraints
Run it against the database
Save the results as 05_Create_CK.SQL

6. Load the Script called Drop Check Constraints
Run it against the database

7. Load the Script called Drop Foreign Key Constraints
Run it against the database

8. Load the Script called Drop Alternate Key Indexes
Run it against the database

9. Load the Script called Drop Primary Key Constraints
Run it against the database

10. enter the following commands
USE MASTER
ALTER DATABASE xxxxx COLLATE xxxxxxxxxxx

11. Load the Script called 01_Change_Column_Collation.SQL 
Run it against the database

12. Load the Script called 02_Create_PK.SQL
Run it against the database

13. Load the Script called 03_Create_AK.SQL 
Run it against the database

14. Load the Script called 04_Create_FK.SQL 
Run it against the database

15. Load the Script called 05_Create_CK.SQL 
Run it against the database


AND NOW THE SCRIPTS

Generate Change Column Collation 
declare @toCollation sysname 

SET @toCollation = 'Latin1_General_CI_AS' -- Database default collate

SELECT 'ALTER TABLE ' + INFORMATION_SCHEMA.COLUMNS.TABLE_NAME +
' ALTER COLUMN ' + COLUMN_NAME + ' ' + DATA_TYPE +
CASE WHEN CHARACTER_MAXIMUM_LENGTH = -1 then '(max)'
WHEN DATA_TYPE in ('text','ntext') then ''
WHEN CHARACTER_MAXIMUM_LENGTH IS NOT NULL 
THEN '('+(CONVERT(VARCHAR,CHARACTER_MAXIMUM_LENGTH)+')' )
ELSE isnull(CONVERT(VARCHAR,CHARACTER_MAXIMUM_LENGTH),' ') END
+' COLLATE ' + @toCollation+ ' ' + CASE IS_NULLABLE
WHEN 'YES' THEN 'NULL'
WHEN 'No' THEN 'NOT NULL' 

END
FROM INFORMATION_SCHEMA.COLUMNS INNER JOIN INFORMATION_SCHEMA.TABLES
ON INFORMATION_SCHEMA.COLUMNS.TABLE_NAME = INFORMATION_SCHEMA.TABLES.TABLE_NAME
AND INFORMATION_SCHEMA.COLUMNS.TABLE_SCHEMA = INFORMATION_SCHEMA.TABLES.TABLE_SCHEMA
WHERE DATA_TYPE IN ('varchar' ,'char','nvarchar','nchar','text','ntext')
AND TABLE_TYPE = 'BASE TABLE'
and COLLATION_NAME <> @toCollation 

Generate_Primary_Key_Contraints

BEGIN TRAN

-- Get all existing primary keys
DECLARE cPK CURSOR FOR
SELECT so.name,si.name,si.type_desc
from sys.indexes si
join sys.objects so
on si.object_id = so.object_id
and so.type = 'U'
where si.type_desc <> 'HEAP'
and si.is_Primary_Key = 1
ORDER BY so.Name

DECLARE @PkTable SYSNAME
DECLARE @PkName SYSNAME
Declare @KeyType nvarchar(50)

-- Loop through all the primary keys
OPEN cPK
FETCH NEXT FROM cPK INTO @PkTable, @PkName,@KeyType
WHILE (@@FETCH_STATUS = 0)
BEGIN
DECLARE @PKSQL NVARCHAR(4000) SET @PKSQL = ''
SET @PKSQL = 'ALTER TABLE ' + @PkTable + ' ADD CONSTRAINT ' + @PkName + ' PRIMARY KEY ' + @KeyType + ' ('

-- Get all columns for the current primary key
DECLARE cPKColumn CURSOR FOR
SELECT COLUMN_NAME 
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_NAME = @PkTable AND CONSTRAINT_NAME = @PkName
ORDER BY ORDINAL_POSITION
OPEN cPKColumn

DECLARE @PkColumn SYSNAME
DECLARE @PkFirstColumn BIT SET @PkFirstColumn = 1
-- Loop through all columns and append the sql statement
FETCH NEXT FROM cPKColumn INTO @PkColumn
WHILE (@@FETCH_STATUS = 0)
BEGIN
IF (@PkFirstColumn = 1)
SET @PkFirstColumn = 0
ELSE
SET @PKSQL = @PKSQL + ', '

SET @PKSQL = @PKSQL + @PkColumn

FETCH NEXT FROM cPKColumn INTO @PkColumn
END
CLOSE cPKColumn
DEALLOCATE cPKColumn

SET @PKSQL = @PKSQL + ')'
-- Print the primary key statement
PRINT @PKSQL

FETCH NEXT FROM cPK INTO @PkTable, @PkName, @KeyType
END
CLOSE cPK
DEALLOCATE cPK


ROLLBACK

Generate_Alternate_Key_Indexes
BEGIN TRAN

-- Get all existing primary keys
DECLARE cPK CURSOR FOR
select si.Object_id,si.Index_Id,so.name,si.name,si.type_desc,si.is_unique from sys.indexes si
join sys.objects so
on so.object_id = si.object_id
and so.type = 'U'
and si.is_Primary_key = 0
and si.type_desc <> 'HEAP'
order by so.name

Declare @ObjectID int
Declare @IndexID int
Declare @TableName nvarchar(50)
Declare @IndexName nvarchar(50)
declare @IndexType nvarchar(50)
declare @IndexUnique bit

-- Loop through all the primary keys
OPEN cPK
FETCH NEXT FROM cPK INTO @ObjectID,@IndexId,@TableName,@IndexName,@indexType,@IndexUnique
WHILE (@@FETCH_STATUS = 0)
BEGIN
DECLARE @PKSQL NVARCHAR(4000) SET @PKSQL = ''
Declare @KeyUnique nvarchar(10) set @KeyUnique = ''
if @IndexUnique = 1 set @KeyUnique = 'Unique'
SET @PKSQL = 'Create ' + @KeyUnique + ' ' + @IndexType + ' INDEX ' + @IndexName + ' ON ' + @TableName + ' ('

-- Get all columns for the current key
DECLARE cPKColumn CURSOR FOR
select sc.name
from sys.index_Columns sic
join sys.columns sc
on sc.object_id = sic.object_id
and sc.column_id = sic.column_id
where sic.object_id = @ObjectID
and sic.Index_id = @IndexID

OPEN cPKColumn

DECLARE @PkColumn SYSNAME
DECLARE @PkFirstColumn BIT SET @PkFirstColumn = 1
-- Loop through all columns and append the sql statement
FETCH NEXT FROM cPKColumn INTO @PkColumn
WHILE (@@FETCH_STATUS = 0)
BEGIN
IF (@PkFirstColumn = 1)
SET @PkFirstColumn = 0
ELSE
Begin
SET @PKSQL = @PKSQL + ', '
end

SET @PKSQL = @PKSQL + @PkColumn

FETCH NEXT FROM cPKColumn INTO @PkColumn
END
CLOSE cPKColumn
DEALLOCATE cPKColumn

SET @PKSQL = @PKSQL + ')'
-- Print the primary key statement
PRINT @PKSQL

FETCH NEXT FROM cPK INTO @ObjectID,@IndexId,@TableName,@IndexName,@indexType,@IndexUnique
END
CLOSE cPK
DEALLOCATE cPK


ROLLBACK

Generate Foreign Key Constraints
BEGIN TRAN

-- Get all existing primary keys
DECLARE cPK CURSOR FOR
select sf.object_id,sf.name,so.name,sor.name from sys.foreign_keys sf 
join sys.objects so 
on so.object_id = sf.parent_object_id
join sys.objects sor 
on sor.object_id = sf.referenced_object_id
ORDER BY sf.Name

DECLARE @PkTable SYSNAME
DECLARE @PkName SYSNAME
Declare @RefName nvarchar(50)
declare @objectid bigint

-- Loop through all the primary keys
OPEN cPK
FETCH NEXT FROM cPK INTO @objectid,@PkName,@PkTable, @refName
WHILE (@@FETCH_STATUS = 0)
BEGIN
DECLARE @PKSQL NVARCHAR(4000) SET @PKSQL = ''
Declare @FKSQL Nvarchar(4000) set @fkSQL = ''
SET @PKSQL = 'ALTER TABLE ' + @PkTable + ' WITH NOCHECK ADD CONSTRAINT ' + @PkName + ' Foreign KEY ' + ' ('
Set @FKSQL = ' REFERENCES ' + @RefName + ' ('

-- Get all columns for the current primary key
DECLARE cPKColumn CURSOR FOR
select so.name,sor.name from sys.foreign_key_columns sfc
join sys.columns so 
on so.column_id = sfc.parent_column_id
and so.object_Id = sfc.parent_object_id
join sys.columns sor 
on sor.column_id = sfc.referenced_column_id
and sor.object_id = sfc.referenced_object_id
where sfc.Constraint_object_id = @ObjectID
OPEN cPKColumn

DECLARE @PkColumn SYSNAME
Declare @fkColumn sysname
DECLARE @PkFirstColumn BIT SET @PkFirstColumn = 1
-- Loop through all columns and append the sql statement
FETCH NEXT FROM cPKColumn INTO @PkColumn,@fkColumn
WHILE (@@FETCH_STATUS = 0)
BEGIN
IF (@PkFirstColumn = 1)
SET @PkFirstColumn = 0
ELSE
Begin
SET @PKSQL = @PKSQL + ', '
set @FkSQL = @FKSQL + ', '
end

SET @PKSQL = @PKSQL + @PkColumn
set @FkSql = @FKSQL + @FKColumn

FETCH NEXT FROM cPKColumn INTO @PkColumn,@FKColumn
END
CLOSE cPKColumn
DEALLOCATE cPKColumn

SET @PKSQL = @PKSQL + ')'
set @FKSql = @FKSQL + ')'
-- Print the primary key statement
PRINT @PKSQL
Print @FKSQL

FETCH NEXT FROM cPK INTO @objectid,@PkName,@PkTable, @refName
END
CLOSE cPK
DEALLOCATE cPK


ROLLBACK

Generate Check Constraints
select 'Alter Table ' + st.name + ' With Nocheck ' + 'Add Constraint ' + scc.name + ' check ' + scc.definition
from sys.tables st
join sys.check_constraints scc
on st.object_id = scc.parent_object_id
order by st.name

Drop Check Constraints
declare ca Cursor
for select st.name,scc.name
from sys.tables st
join sys.check_constraints scc
on st.object_id = scc.parent_object_id
order by st.name

declare @TableName nvarchar(50)
declare @ConstraintName nvarchar(50)
declare @DbName nvarchar(50)
Declare @Sql nvarchar(4000)

set @dbName = db_name()
open ca
fetch from ca into @TableName,@ConstraintName
While @@Fetch_Status = 0
Begin
set @SQL = 'use ' + db_name() +' Alter Table ' + @TableName + ' Drop Constraint ' + @ConstraintName + ';'
print @sql
exec (@Sql)
fetch from ca into @TableName,@ConstraintName
end

close ca
deallocate ca
Drop Foreign Key Constraints
-- Get all existing Foreign keys
DECLARE cPK CURSOR FOR
select sf.object_id,sf.name,so.name,sor.name from sys.foreign_keys sf 
join sys.objects so 
on so.object_id = sf.parent_object_id
join sys.objects sor 
on sor.object_id = sf.referenced_object_id
ORDER BY sf.Name

DECLARE @PkTable SYSNAME
DECLARE @PkName SYSNAME
Declare @RefName nvarchar(50)
declare @objectid bigint

-- Loop through all the primary keys
OPEN cPK
FETCH NEXT FROM cPK INTO @objectid,@PkName,@PkTable, @refName
WHILE (@@FETCH_STATUS = 0)
BEGIN
DECLARE @PKSQL NVARCHAR(4000) SET @PKSQL = ''
Declare @FKSQL Nvarchar(4000) set @fkSQL = ''
SET @PKSQL = 'ALTER TABLE ' + @PkTable + ' Drop CONSTRAINT ' + @PkName 

-- Print the Drop key statement
PRINT @PKSQL
Exec(@pksql)

FETCH NEXT FROM cPK INTO @objectid,@PkName,@PkTable, @refName
END
CLOSE cPK
DEALLOCATE cPK


Drop Alternate Key Indexes

-- Get all existing Alternate keys
DECLARE cPK CURSOR FOR
select si.Object_id,si.Index_Id,so.name,si.name,si.type_desc,si.is_unique from sys.indexes si
join sys.objects so
on so.object_id = si.object_id
and so.type = 'U'
and si.is_Primary_key = 0
and si.type_desc <> 'HEAP'
order by so.name

Declare @ObjectID int
Declare @IndexID int
Declare @TableName nvarchar(50)
Declare @IndexName nvarchar(50)
declare @IndexType nvarchar(50)
declare @IndexUnique bit

-- Loop through all the primary keys
OPEN cPK
FETCH NEXT FROM cPK INTO @ObjectID,@IndexId,@TableName,@IndexName,@indexType,@IndexUnique
WHILE (@@FETCH_STATUS = 0)
BEGIN
DECLARE @PKSQL NVARCHAR(4000) SET @PKSQL = ''
Declare @KeyUnique nvarchar(10) set @KeyUnique = ''
if @IndexUnique = 1 set @KeyUnique = 'Unique'
SET @PKSQL = 'DROP INDEX ' + @IndexName + ' ON ' + @TableName 

-- Print the Alternate key statement
PRINT @PKSQL
exec (@pksql)
FETCH NEXT FROM cPK INTO @ObjectID,@IndexId,@TableName,@IndexName,@indexType,@IndexUnique
END
CLOSE cPK
DEALLOCATE cPK




Drop Primary Key Constraints

-- Get all existing primary keys
DECLARE cPK CURSOR FOR
SELECT TABLE_NAME, CONSTRAINT_NAME 
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
Where Constraint_Type = 'Primary Key'
ORDER BY TABLE_NAME

DECLARE @PkTable SYSNAME
DECLARE @PkName SYSNAME

-- Loop through all the primary keys
OPEN cPK
FETCH NEXT FROM cPK INTO @PkTable, @PkName
WHILE (@@FETCH_STATUS = 0)
BEGIN
DECLARE @PKSQL NVARCHAR(4000) SET @PKSQL = ''
SET @PKSQL = 'use ' + db_name() + ' ALTER TABLE ' + @PkTable + ' drop CONSTRAINT ' + @PkName

print @PKSQL
exec(@PKSQL)

FETCH NEXT FROM cPK INTO @PkTable, @PkName
END
CLOSE cPK
DEALLOCATE cPK
