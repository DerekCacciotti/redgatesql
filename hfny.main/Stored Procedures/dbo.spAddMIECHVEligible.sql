SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddMIECHVEligible](@PC1ID char(13)=NULL,
@HVCaseFK int=NULL,
@ProgramFK int=NULL,
@CaseStartDate datetime=NULL,
@DischargeDate datetime=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) MIECHVEligiblePK
FROM MIECHVEligible lastRow
WHERE 
@PC1ID = lastRow.PC1ID AND
@HVCaseFK = lastRow.HVCaseFK AND
@ProgramFK = lastRow.ProgramFK AND
@CaseStartDate = lastRow.CaseStartDate AND
@DischargeDate = lastRow.DischargeDate
ORDER BY MIECHVEligiblePK DESC) 
BEGIN
INSERT INTO MIECHVEligible(
PC1ID,
HVCaseFK,
ProgramFK,
CaseStartDate,
DischargeDate
)
VALUES(
@PC1ID,
@HVCaseFK,
@ProgramFK,
@CaseStartDate,
@DischargeDate
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
