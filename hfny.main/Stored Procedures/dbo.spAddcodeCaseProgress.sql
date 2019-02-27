SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddcodeCaseProgress](@CaseProgressCode numeric(3, 1)=NULL,
@CaseProgressBrief varchar(10)=NULL,
@CaseProgressDescription varchar(100)=NULL,
@CaseProgressNote varchar(100)=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) codeCaseProgressPK
FROM codeCaseProgress lastRow
WHERE 
@CaseProgressCode = lastRow.CaseProgressCode AND
@CaseProgressBrief = lastRow.CaseProgressBrief AND
@CaseProgressDescription = lastRow.CaseProgressDescription AND
@CaseProgressNote = lastRow.CaseProgressNote
ORDER BY codeCaseProgressPK DESC) 
BEGIN
INSERT INTO codeCaseProgress(
CaseProgressCode,
CaseProgressBrief,
CaseProgressDescription,
CaseProgressNote
)
VALUES(
@CaseProgressCode,
@CaseProgressBrief,
@CaseProgressDescription,
@CaseProgressNote
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
