SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditHVGroupParticipants](@HVGroupParticipantsPK int=NULL,
@HVGroupFK int=NULL,
@GroupFatherFigureFK int=NULL,
@HVGroupParticipantsEditor char(10)=NULL,
@ProgramFK int=NULL)
AS
UPDATE HVGroupParticipants
SET 
HVGroupFK = @HVGroupFK, 
GroupFatherFigureFK = @GroupFatherFigureFK, 
HVGroupParticipantsEditor = @HVGroupParticipantsEditor, 
ProgramFK = @ProgramFK
WHERE HVGroupParticipantsPK = @HVGroupParticipantsPK
GO
