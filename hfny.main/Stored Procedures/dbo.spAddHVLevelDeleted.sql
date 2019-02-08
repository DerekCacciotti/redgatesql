SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddHVLevelDeleted](@HVLevelPK int=NULL,
@HVCaseFK int=NULL,
@HVLevelCreator char(10)=NULL,
@LevelAssignDate datetime=NULL,
@LevelFK int=NULL,
@ProgramFK int=NULL)
AS
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

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
