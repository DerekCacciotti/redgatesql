SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditLoginHistory](@LoginHistoryPK int=NULL,
@Username varchar(max)=NULL,
@LoginTime datetime=NULL,
@Role varchar(255)=NULL,
@ProgramFK int=NULL,
@LogoutTime datetime=NULL)
AS
UPDATE LoginHistory
SET 
Username = @Username, 
LoginTime = @LoginTime, 
Role = @Role, 
ProgramFK = @ProgramFK, 
LogoutTime = @LogoutTime
WHERE LoginHistoryPK = @LoginHistoryPK
GO
