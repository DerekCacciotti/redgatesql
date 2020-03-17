SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 01/10/2020
-- Description:	Get all the HVLevel rows for a specific case
-- =============================================
CREATE PROC [dbo].[spGetAllLevelsByHVCaseFK] 
	@HVCaseFK INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    --Get all the HVLevel rows
    SELECT hl.HVLevelPK,
           hl.HVCaseFK,
           hl.HVLevelCreateDate,
           hl.HVLevelCreator,
           hl.HVLevelEditDate,
           hl.HVLevelEditor,
           hl.LevelAssignDate,
           hl.LevelFK,
           hl.ProgramFK
    FROM dbo.HVLevel hl
    WHERE hl.HVCaseFK = @HVCaseFK
    ORDER BY hl.LevelAssignDate ASC;

END;
GO
