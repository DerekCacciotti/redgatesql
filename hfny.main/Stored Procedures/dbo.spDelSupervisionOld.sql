SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelSupervisionOld](@SupervisionOldPK int)

AS


DELETE 
FROM SupervisionOld
WHERE SupervisionOldPK = @SupervisionOldPK
GO
