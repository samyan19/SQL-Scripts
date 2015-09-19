USE reportServer
go

Select   [Name],
               [Description],
               SubString([Path],1,Len([Path]) - (CharIndex('/',Reverse([Path]))-1)) As [Path],
               Case
                        When [Hidden] = 1
                        Then  'Yes'
                        Else    'No'
               End As [Hidden]
From    [Catalog]
Where  [Type] = 2
Order By SubString([Path],1,Len([Path]) - (CharIndex('/',Reverse([Path]))-1)),
               [Name]