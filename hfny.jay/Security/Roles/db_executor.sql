CREATE ROLE [db_executor]
AUTHORIZATION [dbo]
EXEC sp_addrolemember N'db_executor', N'CHSRAdmin'
GRANT EXECUTE TO [db_executor]

GO
EXEC sp_addrolemember N'db_executor', N'CHSRUser'
GO
