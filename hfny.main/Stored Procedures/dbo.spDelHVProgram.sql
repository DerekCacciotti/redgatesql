SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelHVProgram](@HVProgramPK int)

AS


DELETE 
FROM HVProgram
WHERE HVProgramPK = @HVProgramPK
GO
