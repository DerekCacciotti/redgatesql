SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetcodeFormAccessbyPK]

(@codeFormAccessPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM codeFormAccess
WHERE codeFormAccessPK = @codeFormAccessPK
GO
