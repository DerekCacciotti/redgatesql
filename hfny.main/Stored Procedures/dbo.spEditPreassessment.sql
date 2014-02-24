
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditPreassessment](@PreassessmentPK int=NULL,
@CaseStatus char(2)=NULL,
@DischargeReason char(2)=NULL,
@DischargeReasonSpecify varchar(500)=NULL,
@DischargeSafetyReason char(2)=NULL,
@DischargeSafetyReasonDV bit=NULL,
@DischargeSafetyReasonMH bit=NULL,
@DischargeSafetyReasonOther bit=NULL,
@DischargeSafetyReasonSA bit=NULL,
@DischargeSafetyReasonSpecify varchar(500)=NULL,
@FSWAssignDate datetime=NULL,
@HVCaseFK int=NULL,
@KempeDate datetime=NULL,
@KempeResult bit=NULL,
@PAActivitySpecify varchar(500)=NULL,
@PACall2Parent int=NULL,
@PACallFromParent int=NULL,
@PACaseReview int=NULL,
@PADate datetime=NULL,
@PAEditor char(10)=NULL,
@PAFAWFK int=NULL,
@PAFSWFK int=NULL,
@PAGift int=NULL,
@PAOtherActivity int=NULL,
@PAOtherHVProgram int=NULL,
@PAParent2Office int=NULL,
@PAParentLetter int=NULL,
@PAProgramMaterial int=NULL,
@PAVisitAttempt int=NULL,
@PAVisitMade int=NULL,
@ProgramFK int=NULL,
@TransferredtoProgram varchar(50)=NULL)
AS
UPDATE Preassessment
SET 
CaseStatus = @CaseStatus, 
DischargeReason = @DischargeReason, 
DischargeReasonSpecify = @DischargeReasonSpecify, 
DischargeSafetyReason = @DischargeSafetyReason, 
DischargeSafetyReasonDV = @DischargeSafetyReasonDV, 
DischargeSafetyReasonMH = @DischargeSafetyReasonMH, 
DischargeSafetyReasonOther = @DischargeSafetyReasonOther, 
DischargeSafetyReasonSA = @DischargeSafetyReasonSA, 
DischargeSafetyReasonSpecify = @DischargeSafetyReasonSpecify, 
FSWAssignDate = @FSWAssignDate, 
HVCaseFK = @HVCaseFK, 
KempeDate = @KempeDate, 
KempeResult = @KempeResult, 
PAActivitySpecify = @PAActivitySpecify, 
PACall2Parent = @PACall2Parent, 
PACallFromParent = @PACallFromParent, 
PACaseReview = @PACaseReview, 
PADate = @PADate, 
PAEditor = @PAEditor, 
PAFAWFK = @PAFAWFK, 
PAFSWFK = @PAFSWFK, 
PAGift = @PAGift, 
PAOtherActivity = @PAOtherActivity, 
PAOtherHVProgram = @PAOtherHVProgram, 
PAParent2Office = @PAParent2Office, 
PAParentLetter = @PAParentLetter, 
PAProgramMaterial = @PAProgramMaterial, 
PAVisitAttempt = @PAVisitAttempt, 
PAVisitMade = @PAVisitMade, 
ProgramFK = @ProgramFK, 
TransferredtoProgram = @TransferredtoProgram
WHERE PreassessmentPK = @PreassessmentPK
GO