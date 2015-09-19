USE Master
GO
ALTER LOGIN test_must_change WITH PASSWORD = ‘samepassword’
GO
ALTER LOGIN test_must_change WITH
      CHECK_POLICY = OFF,
      CHECK_EXPIRATION = OFF;