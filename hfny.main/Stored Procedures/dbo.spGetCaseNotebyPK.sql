SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetCaseNotebyPK]

(@CaseNotePK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM CaseNote
WHERE CaseNotePK = @CaseNotePK
GO