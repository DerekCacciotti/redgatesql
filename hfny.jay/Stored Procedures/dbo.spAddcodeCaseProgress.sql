SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddcodeCaseProgress](@CaseProgressCode numeric(3, 1)=NULL,
@CaseProgressDescription varchar(100)=NULL,
@CaseProgressNote varchar(100)=NULL)
AS
INSERT INTO codeCaseProgress(
CaseProgressCode,
CaseProgressDescription,
CaseProgressNote
)
VALUES(
@CaseProgressCode,
@CaseProgressDescription,
@CaseProgressNote
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
