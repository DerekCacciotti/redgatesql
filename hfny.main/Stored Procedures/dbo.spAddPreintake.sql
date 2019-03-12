SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddPreintake](@CaseStatus char(2)=NULL,
@DischargeReason char(2)=NULL,
@DischargeReasonSpecify varchar(500)=NULL,
@DischargeSafetyReason char(2)=NULL,
@DischargeSafetyReasonDV bit=NULL,
@DischargeSafetyReasonMH bit=NULL,
@DischargeSafetyReasonOther bit=NULL,
@DischargeSafetyReasonSA bit=NULL,
@DischargeSafetyReasonSpecify varchar(500)=NULL,
@HVCaseFK int=NULL,
@KempeFK int=NULL,
@PIActivitySpecify varchar(500)=NULL,
@PICall2Parent int=NULL,
@PICallFromParent int=NULL,
@PICaseReview int=NULL,
@PICreator varchar(max)=NULL,
@PIDate datetime=NULL,
@PIFSWFK int=NULL,
@PIGift int=NULL,
@PIOtherActivity int=NULL,
@PIOtherHVProgram int=NULL,
@PIParent2Office int=NULL,
@PIParentLetter int=NULL,
@PIProgramMaterial int=NULL,
@PIVisitAttempt int=NULL,
@PIVisitMade int=NULL,
@ProgramFK int=NULL,
@TransferredtoProgram varchar(50)=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) PreintakePK
FROM Preintake lastRow
WHERE 
@CaseStatus = lastRow.CaseStatus AND
@DischargeReason = lastRow.DischargeReason AND
@DischargeReasonSpecify = lastRow.DischargeReasonSpecify AND
@DischargeSafetyReason = lastRow.DischargeSafetyReason AND
@DischargeSafetyReasonDV = lastRow.DischargeSafetyReasonDV AND
@DischargeSafetyReasonMH = lastRow.DischargeSafetyReasonMH AND
@DischargeSafetyReasonOther = lastRow.DischargeSafetyReasonOther AND
@DischargeSafetyReasonSA = lastRow.DischargeSafetyReasonSA AND
@DischargeSafetyReasonSpecify = lastRow.DischargeSafetyReasonSpecify AND
@HVCaseFK = lastRow.HVCaseFK AND
@KempeFK = lastRow.KempeFK AND
@PIActivitySpecify = lastRow.PIActivitySpecify AND
@PICall2Parent = lastRow.PICall2Parent AND
@PICallFromParent = lastRow.PICallFromParent AND
@PICaseReview = lastRow.PICaseReview AND
@PICreator = lastRow.PICreator AND
@PIDate = lastRow.PIDate AND
@PIFSWFK = lastRow.PIFSWFK AND
@PIGift = lastRow.PIGift AND
@PIOtherActivity = lastRow.PIOtherActivity AND
@PIOtherHVProgram = lastRow.PIOtherHVProgram AND
@PIParent2Office = lastRow.PIParent2Office AND
@PIParentLetter = lastRow.PIParentLetter AND
@PIProgramMaterial = lastRow.PIProgramMaterial AND
@PIVisitAttempt = lastRow.PIVisitAttempt AND
@PIVisitMade = lastRow.PIVisitMade AND
@ProgramFK = lastRow.ProgramFK AND
@TransferredtoProgram = lastRow.TransferredtoProgram
ORDER BY PreintakePK DESC) 
BEGIN
INSERT INTO Preintake(
CaseStatus,
DischargeReason,
DischargeReasonSpecify,
DischargeSafetyReason,
DischargeSafetyReasonDV,
DischargeSafetyReasonMH,
DischargeSafetyReasonOther,
DischargeSafetyReasonSA,
DischargeSafetyReasonSpecify,
HVCaseFK,
KempeFK,
PIActivitySpecify,
PICall2Parent,
PICallFromParent,
PICaseReview,
PICreator,
PIDate,
PIFSWFK,
PIGift,
PIOtherActivity,
PIOtherHVProgram,
PIParent2Office,
PIParentLetter,
PIProgramMaterial,
PIVisitAttempt,
PIVisitMade,
ProgramFK,
TransferredtoProgram
)
VALUES(
@CaseStatus,
@DischargeReason,
@DischargeReasonSpecify,
@DischargeSafetyReason,
@DischargeSafetyReasonDV,
@DischargeSafetyReasonMH,
@DischargeSafetyReasonOther,
@DischargeSafetyReasonSA,
@DischargeSafetyReasonSpecify,
@HVCaseFK,
@KempeFK,
@PIActivitySpecify,
@PICall2Parent,
@PICallFromParent,
@PICaseReview,
@PICreator,
@PIDate,
@PIFSWFK,
@PIGift,
@PIOtherActivity,
@PIOtherHVProgram,
@PIParent2Office,
@PIParentLetter,
@PIProgramMaterial,
@PIVisitAttempt,
@PIVisitMade,
@ProgramFK,
@TransferredtoProgram
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
