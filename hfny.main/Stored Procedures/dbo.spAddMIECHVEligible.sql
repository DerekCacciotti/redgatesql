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

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
