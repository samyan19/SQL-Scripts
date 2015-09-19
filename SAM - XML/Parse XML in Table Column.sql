DECLARE @xmltable table (data xml)
--DECLARE @MyXML XML
--SET @MyXML = 

insert into @xmltable values (
'<SampleXML>
<Colors>
<Color1>White</Color1>
<Color2>Blue</Color2>
<Color3>Black</Color3>
<Color4 Special="Light">Green</Color4>
<Color5>Red</Color5>
</Colors>
<Fruits>
<Fruits1>Apple</Fruits1>
<Fruits2>Pineapple</Fruits2>
<Fruits3>Grapes</Fruits3>
<Fruits4>Melon</Fruits4>
</Fruits>
</SampleXML>')

insert into @xmltable values (
'<SampleXML>
<Colors>
<Color1>White</Color1>
<Color2>Blue</Color2>
<Color3>Black</Color3>
<Color4 Special="Light">Green</Color4>
<Color5>Red</Color5>
</Colors>
<Fruits>
<Fruits1>Apple</Fruits1>
<Fruits2>Pineapple</Fruits2>
<Fruits3>Grapes</Fruits3>
<Fruits4>Melon</Fruits4>
</Fruits>
</SampleXML>')


SELECT * from @xmltable;

--select @MyXML

SELECT
a.b.value('Colors[1]/Color1[1]','varchar(10)') AS Color1,
a.b.value('Colors[1]/Color2[1]','varchar(10)') AS Color2,
a.b.value('Colors[1]/Color3[1]','varchar(10)') AS Color3,
a.b.value('Colors[1]/Color4[1]/@Special','varchar(10)')+' '+
+a.b.value('Colors[1]/Color4[1]','varchar(10)') AS Color4,
a.b.value('Colors[1]/Color5[1]','varchar(10)') AS Color5,
a.b.value('Fruits[1]/Fruits1[1]','varchar(10)') AS Fruits1,
a.b.value('Fruits[1]/Fruits2[1]','varchar(10)') AS Fruits2,
a.b.value('Fruits[1]/Fruits3[1]','varchar(10)') AS Fruits3,
a.b.value('Fruits[1]/Fruits4[1]','varchar(10)') AS Fruits4
from @xmltable
cross apply data.nodes('SampleXML') a(b)