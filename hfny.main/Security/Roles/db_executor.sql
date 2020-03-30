CREATE ROLE [db_executor]
AUTHORIZATION [dbo]
GO
ALTER ROLE [db_executor] ADD MEMBER [CHSRUser]
GO
GRANT EXECUTE TO [db_executor]
