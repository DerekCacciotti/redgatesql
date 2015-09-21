SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddCaseNote](@CaseNote varchar(max)=NULL,
@CaseNoteCreator char(10)=NULL,
@HVCaseFK int=NULL,
@ProgramFK int=NULL)
AS
INSERT INTO CaseNote(
CaseNote,
CaseNoteCreator,
HVCaseFK,
ProgramFK
)
VALUES(
@CaseNote,
@CaseNoteCreator,
@HVCaseFK,
@ProgramFK
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
