SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[spGetLastPreintakeByHVCaseFK]
	@HVCaseFK INT,
	@ProgramFK INT = NULL

AS

SELECT TOP 1 *
FROM preintake
WHERE hvcasefk = @HVCaseFK
AND programfk = ISNULL(@ProgramFK, programfk)
ORDER BY pidate DESC




GO
