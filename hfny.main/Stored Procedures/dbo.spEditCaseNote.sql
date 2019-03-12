SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditCaseNote](@CaseNotePK int=NULL,
@CaseNoteContents varchar(max)=NULL,
@CaseNoteDate date=NULL,
@CaseNoteEditor varchar(max)=NULL,
@HVCaseFK int=NULL,
@ProgramFK int=NULL)
AS
UPDATE CaseNote
SET 
CaseNoteContents = @CaseNoteContents, 
CaseNoteDate = @CaseNoteDate, 
CaseNoteEditor = @CaseNoteEditor, 
HVCaseFK = @HVCaseFK, 
ProgramFK = @ProgramFK
WHERE CaseNotePK = @CaseNotePK
GO
