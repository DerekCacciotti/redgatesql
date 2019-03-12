SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddHVLevelDeleted](@HVLevelPK int=NULL,
@HVCaseFK int=NULL,
@HVLevelCreator varchar(max)=NULL,
@LevelAssignDate datetime=NULL,
@LevelFK int=NULL,
@ProgramFK int=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) HVLevelDeletedPK
FROM HVLevelDeleted lastRow
WHERE 
@HVLevelPK = lastRow.HVLevelPK AND
@HVCaseFK = lastRow.HVCaseFK AND
@HVLevelCreator = lastRow.HVLevelCreator AND
@LevelAssignDate = lastRow.LevelAssignDate AND
@LevelFK = lastRow.LevelFK AND
@ProgramFK = lastRow.ProgramFK
ORDER BY HVLevelDeletedPK DESC) 
BEGIN
INSERT INTO HVLevelDeleted(
HVLevelPK,
HVCaseFK,
HVLevelCreator,
LevelAssignDate,
LevelFK,
ProgramFK
)
VALUES(
@HVLevelPK,
@HVCaseFK,
@HVLevelCreator,
@LevelAssignDate,
@LevelFK,
@ProgramFK
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
