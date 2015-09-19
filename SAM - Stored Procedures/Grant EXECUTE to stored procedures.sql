USE RTP_BARCLAYSLTO_STG01
GO
SELECT
  -- p.Name,
   GrantCmd = 'GRANT EXECUTE ON OBJECT::' + p.name + ' TO [RTP_BARCLAYSLTO_STG01_User]'
FROM sys.procedures p
WHERE p.Name LIKE 'usp%'