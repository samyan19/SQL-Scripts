UPDATE a         
       SET a.PoolValue =b.MonthEndSum    
FROM @Rebate a   
join ( SELECT SUM(PortfolioAssetValueMonthEnd) as MonthEndSum,RebatePoolID         
                     FROM @Rebate     
                     GROUP BY RebatePoolID) b on  a.RebatePoolID= b.RebatePoolID  
join Rebate.RebatePool RP on RP.RebatePoolID = b.RebatePoolID    
where RP.Active = 1    and    b.RebatePoolID IS NOT NULL