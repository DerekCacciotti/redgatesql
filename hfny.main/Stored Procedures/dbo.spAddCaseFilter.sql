SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddCaseFilter](@CaseFilterNameFK int=NULL,
@CaseFilterCreator varchar(max)=NULL,
@CaseFilterNameChoice bit=NULL,
@CaseFilterNameDate date=NULL,
@CaseFilterNameOptionFK int=NULL,
@CaseFilterValue varchar(50)=NULL,
@HVCaseFK int=NULL,
@ProgramFK int=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) CaseFilterPK
FROM CaseFilter lastRow
WHERE 
@CaseFilterNameFK = lastRow.CaseFilterNameFK AND
@CaseFilterCreator = lastRow.CaseFilterCreator AND
@CaseFilterNameChoice = lastRow.CaseFilterNameChoice AND
@CaseFilterNameDate = lastRow.CaseFilterNameDate AND
@CaseFilterNameOptionFK = lastRow.CaseFilterNameOptionFK AND
@CaseFilterValue = lastRow.CaseFilterValue AND
@HVCaseFK = lastRow.HVCaseFK AND
@ProgramFK = lastRow.ProgramFK
ORDER BY CaseFilterPK DESC) 
BEGIN
INSERT INTO CaseFilter(
CaseFilterNameFK,
CaseFilterCreator,
CaseFilterNameChoice,
CaseFilterNameDate,
CaseFilterNameOptionFK,
CaseFilterValue,
HVCaseFK,
ProgramFK
)
VALUES(
@CaseFilterNameFK,
@CaseFilterCreator,
@CaseFilterNameChoice,
@CaseFilterNameDate,
@CaseFilterNameOptionFK,
@CaseFilterValue,
@HVCaseFK,
@ProgramFK
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
