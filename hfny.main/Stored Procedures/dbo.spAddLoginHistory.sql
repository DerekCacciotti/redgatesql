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

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
