DECLARE @stmt nvarchar(max);
DECLARE @params nvarchar(max);
EXEC sp_get_query_template 
    N'SELECT TOP (100) * FROM [view_Notifications] WHERE SeqId  >= 2478736 ORDER BY SeqId ASC;',
    @stmt OUTPUT, 
    @params OUTPUT
EXEC sp_create_plan_guide N'TemplateGuide1', 
    @stmt, 
    N'TEMPLATE', 
    NULL, 
    @params, 
    N'OPTION(PARAMETERIZATION FORCED)';
    
    
SELECT * FROM sys.plan_guides

EXEC sp_control_plan_guide N'DROP', N'TemplateGuide1'; 