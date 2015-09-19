/*Rename column*/
sp_RENAME 'TableName.OldColumnName' , 'NewColumnName', 'COLUMN'

/*Rename table name*/
sp_RENAME 'OldTableName' , 'NewTableName'

