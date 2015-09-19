--When you're trying to alternate the details, I use the following:

= iif (rownumber(Nothing) mod 2, "White", "Gainsboro")

 

--When you're going off a group band, I use this:

= iif (RunningValue( Fields!YourField.Value , CountDistinct, Nothing) mod 2, "White", "Gainsboro")