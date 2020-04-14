SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditCaseNoteDeleted](@CaseNoteDeletedPK int=NULL,
@CaseNotePK int=NULL,
@CaseNoteContents varchar(max)=NULL,
@CaseNoteDeleteDate datetime=NULL,
@CaseNotesDeleter varchar(max)=NULL,
@CaseNoteDate date=NULL,
@CaseNoteEditor varchar(max)=NULL,
@HVCaseFK int=NULL,
@ProgramFK int=NULL)
AS
UPDATE CaseNoteDeleted
SET 
CaseNotePK = @CaseNotePK, 
CaseNoteContents = @CaseNoteContents, 
CaseNoteDeleteDate = @CaseNoteDeleteDate, 
CaseNotesDeleter = @CaseNotesDeleter, 
CaseNoteDate = @CaseNoteDate, 
CaseNoteEditor = @CaseNoteEditor, 
HVCaseFK = @HVCaseFK, 
ProgramFK = @ProgramFK
WHERE CaseNoteDeletedPK = @CaseNoteDeletedPK
GO
