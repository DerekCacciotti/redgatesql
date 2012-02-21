SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



create PROCEDURE [dbo].[spGetEmploymentByPCType]
	@PCType AS VARCHAR(3),
	@HVCaseFK INT,
	@ProgramFK INT = NULL

AS

SELECT *
FROM employment
WHERE hvcasefk = @HVCaseFK
AND programfk = ISNULL(@ProgramFK, ProgramFK)
AND PCType = @PCType





GO
