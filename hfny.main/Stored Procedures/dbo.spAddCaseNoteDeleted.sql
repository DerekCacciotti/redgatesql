SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddCaseNoteDeleted](@CaseNotePK int=NULL,
@CaseNoteContents varchar(max)=NULL,
@CaseNoteCreator varchar(max)=NULL,
@CaseNoteDeleteDate datetime=NULL,
@CaseNotesDeleter varchar(max)=NULL,
@CaseNoteDate date=NULL,
@HVCaseFK int=NULL,
@ProgramFK int=NULL)
AS
INSERT INTO CaseNoteDeleted(
CaseNotePK,
CaseNoteContents,
CaseNoteCreator,
CaseNoteDeleteDate,
CaseNotesDeleter,
CaseNoteDate,
HVCaseFK,
ProgramFK
)
VALUES(
@CaseNotePK,
@CaseNoteContents,
@CaseNoteCreator,
@CaseNoteDeleteDate,
@CaseNotesDeleter,
@CaseNoteDate,
@HVCaseFK,
@ProgramFK
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
