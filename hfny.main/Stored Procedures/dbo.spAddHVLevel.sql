SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddHVLevel](@HVCaseFK int=NULL,
@HVLevelCreator char(10)=NULL,
@LevelAssignDate datetime=NULL,
@LevelFK int=NULL,
@ProgramFK int=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) HVLevelPK
FROM HVLevel lastRow
WHERE 
@HVCaseFK = lastRow.HVCaseFK AND
@HVLevelCreator = lastRow.HVLevelCreator AND
@LevelAssignDate = lastRow.LevelAssignDate AND
@LevelFK = lastRow.LevelFK AND
@ProgramFK = lastRow.ProgramFK
ORDER BY HVLevelPK DESC) 
BEGIN
INSERT INTO HVLevel(
HVCaseFK,
HVLevelCreator,
LevelAssignDate,
LevelFK,
ProgramFK
)
VALUES(
@HVCaseFK,
@HVLevelCreator,
@LevelAssignDate,
@LevelFK,
@ProgramFK
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
