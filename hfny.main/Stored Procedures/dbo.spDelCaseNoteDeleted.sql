SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelCaseNoteDeleted](@CaseNoteDeletedPK int)

AS


DELETE 
FROM CaseNoteDeleted
WHERE CaseNoteDeletedPK = @CaseNoteDeletedPK
GO
