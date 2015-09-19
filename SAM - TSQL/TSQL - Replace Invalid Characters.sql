--Leave only numbers
WHILE PATINDEX('%[^0-9]%',@string) > 0
 BEGIN

    SET @pos = PATINDEX('%[^0-9]%',@string)
    SET @string = REPLACE(@string,SUBSTRING(@string,@pos,1),'')

 END

--Leave only characters
WHILE PATINDEX('%[^a-z]%',@string) > 0
 BEGIN

    SET @pos = PATINDEX('%[^a-z]%',@string)
    SET @string = REPLACE(@string,SUBSTRING(@string,@pos,1),'')

 END