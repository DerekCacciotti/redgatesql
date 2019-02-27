SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddCaseNote](@CaseNoteContents varchar(max)=NULL,
@CaseNoteCreator char(10)=NULL,
@CaseNoteDate date=NULL,
@HVCaseFK int=NULL,
@ProgramFK int=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) CaseNotePK
FROM CaseNote lastRow
WHERE 
@CaseNoteContents = lastRow.CaseNoteContents AND
@CaseNoteCreator = lastRow.CaseNoteCreator AND
@CaseNoteDate = lastRow.CaseNoteDate AND
@HVCaseFK = lastRow.HVCaseFK AND
@ProgramFK = lastRow.ProgramFK
ORDER BY CaseNotePK DESC) 
BEGIN
INSERT INTO CaseNote(
CaseNoteContents,
CaseNoteCreator,
CaseNoteDate,
HVCaseFK,
ProgramFK
)
VALUES(
@CaseNoteContents,
@CaseNoteCreator,
@CaseNoteDate,
@HVCaseFK,
@ProgramFK
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
