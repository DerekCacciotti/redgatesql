SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetCaseNoteDeletedbyPK]

(@CaseNoteDeletedPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM CaseNoteDeleted
WHERE CaseNoteDeletedPK = @CaseNoteDeletedPK
GO
