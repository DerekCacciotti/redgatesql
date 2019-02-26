SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddLoginHistory](@Username varchar(255)=NULL,
@LoginTime datetime=NULL,
@Role varchar(255)=NULL,
@ProgramFK int=NULL,
@LogoutTime datetime=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) LoginHistoryPK
FROM LoginHistory lastRow
WHERE 
@Username = lastRow.Username AND
@LoginTime = lastRow.LoginTime AND
@Role = lastRow.Role AND
@ProgramFK = lastRow.ProgramFK AND
@LogoutTime = lastRow.LogoutTime
ORDER BY LoginHistoryPK DESC) 
BEGIN
INSERT INTO LoginHistory(
Username,
LoginTime,
Role,
ProgramFK,
LogoutTime
)
VALUES(
@Username,
@LoginTime,
@Role,
@ProgramFK,
@LogoutTime
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
