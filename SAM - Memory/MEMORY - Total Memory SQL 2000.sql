create table #SVer(ID int,  Name  sysname, Internal_Value int, Value nvarchar(512))
insert #SVer exec master.dbo.xp_msver
                
SELECT Internal_Value
FROM #SVer
WHere Name = 'PhysicalMemory'
GO

drop table #SVer     