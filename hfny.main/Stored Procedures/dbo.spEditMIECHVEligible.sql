SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditMIECHVEligible](@MIECHVEligiblePK int=NULL,
@PC1ID char(13)=NULL,
@HVCaseFK int=NULL,
@ProgramFK int=NULL,
@CaseStartDate datetime=NULL,
@DischargeDate datetime=NULL)
AS
UPDATE MIECHVEligible
SET 
PC1ID = @PC1ID, 
HVCaseFK = @HVCaseFK, 
ProgramFK = @ProgramFK, 
CaseStartDate = @CaseStartDate, 
DischargeDate = @DischargeDate
WHERE MIECHVEligiblePK = @MIECHVEligiblePK
GO
