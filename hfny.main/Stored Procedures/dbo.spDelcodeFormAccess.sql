SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelcodeFormAccess](@codeFormAccessPK int)

AS


DELETE 
FROM codeFormAccess
WHERE codeFormAccessPK = @codeFormAccessPK
GO
