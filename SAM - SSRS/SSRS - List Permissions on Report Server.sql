select 	case when path='' 
		then 'Home'
		else path end as 'ssrs_path',D.RoleName,C.UserName
from dbo.PolicyUserRole A
   inner join dbo.Policies B on A.PolicyID = B.PolicyID
   inner join dbo.Users C on A.UserID = C.UserID
   inner join dbo.Roles D on A.RoleID = D.RoleID
   left join dbo.Catalog E on A.PolicyID = E.PolicyID
order by Path,d.RoleName,c.UserName
