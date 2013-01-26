
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditCaseProgram](@CaseProgramPK int=NULL,
@CaseProgramEditor char(10)=NULL,
@CaseStartDate datetime=NULL,
@CurrentFAFK int=NULL,
@CurrentFAWFK int=NULL,
@CurrentFSWFK int=NULL,
@CurrentLevelDate datetime=NULL,
@CurrentLevelFK int=NULL,
@DischargeDate datetime=NULL,
@DischargeReason char(2)=NULL,
@DischargeReasonSpecify varchar(500)=NULL,
@ExtraField1 char(30)=NULL,
@ExtraField2 char(30)=NULL,
@ExtraField3 char(30)=NULL,
@ExtraField4 char(30)=NULL,
@ExtraField5 char(30)=NULL,
@ExtraField6 char(30)=NULL,
@ExtraField7 char(30)=NULL,
@ExtraField8 char(30)=NULL,
@ExtraField9 char(30)=NULL,
@HVCaseFK int=NULL,
@HVCaseFK_old int=NULL,
@OldID char(23)=NULL,
@PC1ID char(13)=NULL,
@ProgramFK int=NULL,
@TransferredtoProgram varchar(50)=NULL,
@TransferredtoProgramFK int=NULL)
AS
UPDATE CaseProgram
SET 
CaseProgramEditor = @CaseProgramEditor, 
CaseStartDate = @CaseStartDate, 
CurrentFAFK = @CurrentFAFK, 
CurrentFAWFK = @CurrentFAWFK, 
CurrentFSWFK = @CurrentFSWFK, 
CurrentLevelDate = @CurrentLevelDate, 
CurrentLevelFK = @CurrentLevelFK, 
DischargeDate = @DischargeDate, 
DischargeReason = @DischargeReason, 
DischargeReasonSpecify = @DischargeReasonSpecify, 
ExtraField1 = @ExtraField1, 
ExtraField2 = @ExtraField2, 
ExtraField3 = @ExtraField3, 
ExtraField4 = @ExtraField4, 
ExtraField5 = @ExtraField5, 
ExtraField6 = @ExtraField6, 
ExtraField7 = @ExtraField7, 
ExtraField8 = @ExtraField8, 
ExtraField9 = @ExtraField9, 
HVCaseFK = @HVCaseFK, 
HVCaseFK_old = @HVCaseFK_old, 
OldID = @OldID, 
PC1ID = @PC1ID, 
ProgramFK = @ProgramFK, 
TransferredtoProgram = @TransferredtoProgram, 
TransferredtoProgramFK = @TransferredtoProgramFK
WHERE CaseProgramPK = @CaseProgramPK
GO
