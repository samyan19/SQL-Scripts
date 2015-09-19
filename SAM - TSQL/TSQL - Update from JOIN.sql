UPDATE ASSET.Asset 
SET MidPrice=f.BIDMIDPRICE
from ASSET.Asset a
join [_fundpriceids] f on a.FundPriceID=f.assetid