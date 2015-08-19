SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditProgressNotes](@ProgressNotesPK int=NULL,
@HVCaseFK int=NULL,
@ProgramFK int=NULL,
@ProgressNotes varchar(max)=NULL,
@ProgressNotesEditor char(10)=NULL)
AS
UPDATE ProgressNotes
SET 
HVCaseFK = @HVCaseFK, 
ProgramFK = @ProgramFK, 
ProgressNotes = @ProgressNotes, 
ProgressNotesEditor = @ProgressNotesEditor
WHERE ProgressNotesPK = @ProgressNotesPK
GO
