CREATE ROLE [db_executor]
AUTHORIZATION [dbo]
GO
EXEC sp_addrolemember N'db_executor', N'CHSRUser'
GO
GRANT EXECUTE TO [db_executor]
