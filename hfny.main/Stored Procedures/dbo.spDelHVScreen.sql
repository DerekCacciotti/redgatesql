SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelHVScreen](@HVScreenPK int)

AS


DELETE 
FROM HVScreen
WHERE HVScreenPK = @HVScreenPK
GO
