SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditCaseNote](@CaseNotePK int=NULL,
@CaseNote varchar(max)=NULL,
@CaseNoteEditor char(10)=NULL,
@HVCaseFK int=NULL,
@ProgramFK int=NULL)
AS
UPDATE CaseNote
SET 
CaseNote = @CaseNote, 
CaseNoteEditor = @CaseNoteEditor, 
HVCaseFK = @HVCaseFK, 
ProgramFK = @ProgramFK
WHERE CaseNotePK = @CaseNotePK
GO
