SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelCaseProgramDeleted](@CaseProgramDeletedPK int)

AS


DELETE 
FROM CaseProgramDeleted
WHERE CaseProgramDeletedPK = @CaseProgramDeletedPK
GO
