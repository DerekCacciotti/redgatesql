SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelHVLogOld](@HVLogOldPK int)

AS


DELETE 
FROM HVLogOld
WHERE HVLogOldPK = @HVLogOldPK
GO
