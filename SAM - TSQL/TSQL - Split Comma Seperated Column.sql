USE [dbDealing]
GO

/****** Object:  UserDefinedFunction [dbo].[SPLIT]    Script Date: 03/07/2013 11:43:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[SPLIT]
(
 @s nvarchar(max),
 @splitChar nchar(1)
)
returns @t table (id int identity(1,1), val nvarchar(max))
as
begin

declare @i int, @j int
select @i = 0, @j = (len(@s) - len(replace(@s,@splitChar,'')))

;with cte 
as
(
 select
  i = @i + 1,
  s = @s, 
  n = substring(@s, 0, charindex(@splitChar, @s)),
  m = substring(@s, charindex(@splitChar, @s)+1, len(@s) - charindex(@splitChar, @s))

 union all

 select 
  i = cte.i + 1,
  s = cte.m, 
  n = substring(cte.m, 0, charindex(@splitChar, cte.m)),
  m = substring(
   cte.m,
   charindex(@splitChar, cte.m) + 1,
   len(cte.m)-charindex(@splitChar, cte.m)
 )
 from cte
 where i <= @j
)
insert into @t (val)
select pieces
from 
(
 select 
 ltrim(rtrim(case when i <= @j then n else m end)) pieces
 from cte
) t
where
 len(pieces) >= 0
option (maxrecursion 0)

return

end


GO


