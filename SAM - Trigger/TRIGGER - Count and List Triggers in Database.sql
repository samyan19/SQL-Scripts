/*
Count and list triggers in a databases
*/


SELECT      Tables.Name TableName,
      Triggers.name TriggerName,       
         S.Name as Schemaname
FROM      sysobjects Triggers
      Inner Join sysobjects Tables On Triggers.parent_obj = Tables.id
         join sys.tables T on T.Object_ID = Tables.id
         Inner JOin sys.Schemas S on S.Schema_ID = T.Schema_ID
      Inner Join syscomments Comments On Triggers.id = Comments.id
WHERE      Triggers.xtype = 'TR'
      And Tables.xtype = 'U' --and  Comments.Text like '%formatter%'  
         and S.name = 'REF'
ORDER BY Tables.Name, Triggers.name
