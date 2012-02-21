SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



create PROCEDURE [dbo].[spGetEducationByPCType]
	@PCType AS VARCHAR(3),
	@HVCaseFK INT,
	@ProgramFK INT = NULL

AS

SELECT *
FROM education
WHERE hvcasefk = @HVCaseFK
AND programfk = ISNULL(@ProgramFK, ProgramFK)
AND PCType = @PCType



GO
