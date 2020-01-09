SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditcodeFormAccess](@codeFormAccessPK int=NULL,
@AllowedAccess bit=NULL,
@codeFormFK int=NULL,
@StateFK int=NULL)
AS
UPDATE codeFormAccess
SET 
AllowedAccess = @AllowedAccess, 
codeFormFK = @codeFormFK, 
StateFK = @StateFK
WHERE codeFormAccessPK = @codeFormAccessPK
GO
