INSERT INTO MyTable  (PriKey, Description)
       SELECT ForeignKey, Description
       FROM SomeView;