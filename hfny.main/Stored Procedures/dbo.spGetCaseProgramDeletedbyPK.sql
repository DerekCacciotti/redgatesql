SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetCaseProgramDeletedbyPK]

(@CaseProgramDeletedPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM CaseProgramDeleted
WHERE CaseProgramDeletedPK = @CaseProgramDeletedPK
GO
