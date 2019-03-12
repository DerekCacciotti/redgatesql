SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditHVLevelDeleted](@HVLevelDeletedPK int=NULL,
@HVLevelPK int=NULL,
@HVCaseFK int=NULL,
@HVLevelEditor varchar(max)=NULL,
@LevelAssignDate datetime=NULL,
@LevelFK int=NULL,
@ProgramFK int=NULL)
AS
UPDATE HVLevelDeleted
SET 
HVLevelPK = @HVLevelPK, 
HVCaseFK = @HVCaseFK, 
HVLevelEditor = @HVLevelEditor, 
LevelAssignDate = @LevelAssignDate, 
LevelFK = @LevelFK, 
ProgramFK = @ProgramFK
WHERE HVLevelDeletedPK = @HVLevelDeletedPK
GO
