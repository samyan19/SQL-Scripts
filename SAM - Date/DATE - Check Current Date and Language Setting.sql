-- Check system setting
dbcc useroptions

-- Check current language from syslanguages

   select name ,alias, dateformat
   from syslanguages
      where langid =
      (select value from master..sysconfigures
         where comment = 'default language')