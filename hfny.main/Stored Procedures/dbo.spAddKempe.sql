SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddKempe](@DadBondingArea char(2)=NULL,
@DadChildHistoryArea char(2)=NULL,
@DadCPSArea char(2)=NULL,
@DadDisciplineArea char(2)=NULL,
@DadExpectationArea char(2)=NULL,
@DadPerceptionArea char(2)=NULL,
@DadSAMICHArea char(2)=NULL,
@DadScore char(3)=NULL,
@DadSelfEsteemArea char(2)=NULL,
@DadStressorArea char(2)=NULL,
@DadViolentArea char(2)=NULL,
@FAWFK int=NULL,
@FOBPartnerPresent bit=NULL,
@FOBPresent bit=NULL,
@GrandParentPresent bit=NULL,
@HVCaseFK int=NULL,
@KempeCreator char(10)=NULL,
@KempeDate datetime=NULL,
@KempeResult bit=NULL,
@MOBPartnerPresent bit=NULL,
@MOBPresent bit=NULL,
@MomBondingArea char(2)=NULL,
@MomChildHistoryArea char(2)=NULL,
@MomCPSArea char(2)=NULL,
@MomDisciplineArea char(2)=NULL,
@MomExpectationArea char(2)=NULL,
@MomPerceptionArea char(2)=NULL,
@MomSAMICHArea char(2)=NULL,
@MomScore char(3)=NULL,
@MomSelfEsteemArea char(2)=NULL,
@MomStressorArea char(2)=NULL,
@MomViolentArea char(2)=NULL,
@NegativeReferral bit=NULL,
@OtherPresent bit=NULL,
@PartnerBondingArea char(2)=NULL,
@PartnerChildHistoryArea char(2)=NULL,
@PartnerCPSArea char(2)=NULL,
@PartnerDisciplineArea char(2)=NULL,
@PartnerExpectationArea char(2)=NULL,
@PartnerInHome bit=NULL,
@PartnerPerceptionArea char(2)=NULL,
@PartnerSAMICHArea char(2)=NULL,
@PartnerScore char(3)=NULL,
@PartnerSelfEsteemArea char(2)=NULL,
@PartnerStressorArea char(2)=NULL,
@PartnerViolentArea char(2)=NULL,
@PC1ABadChild char(1)=NULL,
@PC1ADifficultChild char(1)=NULL,
@PC1AEmotionalNeeds char(1)=NULL,
@PC1AHarsh char(1)=NULL,
@PC1ATemper char(1)=NULL,
@PC1AUnrealistic char(1)=NULL,
@PC1AUnwanted char(1)=NULL,
@PC1CANer char(1)=NULL,
@PC1Criminal char(1)=NULL,
@PC1FosterChild char(1)=NULL,
@PC1IssuesFK int=NULL,
@PC1MentallyIll char(1)=NULL,
@PC1Neglected char(1)=NULL,
@PC1ParentSubAbuse char(1)=NULL,
@PC1PhysicallyAbused char(1)=NULL,
@PC1SexuallyAbused char(1)=NULL,
@PC1SubAbuse char(1)=NULL,
@PC1SuspectCANer char(1)=NULL,
@PresentSpecify varchar(500)=NULL,
@ProgramFK int=NULL,
@SupervisorObservation bit=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) KempePK
FROM Kempe lastRow
WHERE 
@DadBondingArea = lastRow.DadBondingArea AND
@DadChildHistoryArea = lastRow.DadChildHistoryArea AND
@DadCPSArea = lastRow.DadCPSArea AND
@DadDisciplineArea = lastRow.DadDisciplineArea AND
@DadExpectationArea = lastRow.DadExpectationArea AND
@DadPerceptionArea = lastRow.DadPerceptionArea AND
@DadSAMICHArea = lastRow.DadSAMICHArea AND
@DadScore = lastRow.DadScore AND
@DadSelfEsteemArea = lastRow.DadSelfEsteemArea AND
@DadStressorArea = lastRow.DadStressorArea AND
@DadViolentArea = lastRow.DadViolentArea AND
@FAWFK = lastRow.FAWFK AND
@FOBPartnerPresent = lastRow.FOBPartnerPresent AND
@FOBPresent = lastRow.FOBPresent AND
@GrandParentPresent = lastRow.GrandParentPresent AND
@HVCaseFK = lastRow.HVCaseFK AND
@KempeCreator = lastRow.KempeCreator AND
@KempeDate = lastRow.KempeDate AND
@KempeResult = lastRow.KempeResult AND
@MOBPartnerPresent = lastRow.MOBPartnerPresent AND
@MOBPresent = lastRow.MOBPresent AND
@MomBondingArea = lastRow.MomBondingArea AND
@MomChildHistoryArea = lastRow.MomChildHistoryArea AND
@MomCPSArea = lastRow.MomCPSArea AND
@MomDisciplineArea = lastRow.MomDisciplineArea AND
@MomExpectationArea = lastRow.MomExpectationArea AND
@MomPerceptionArea = lastRow.MomPerceptionArea AND
@MomSAMICHArea = lastRow.MomSAMICHArea AND
@MomScore = lastRow.MomScore AND
@MomSelfEsteemArea = lastRow.MomSelfEsteemArea AND
@MomStressorArea = lastRow.MomStressorArea AND
@MomViolentArea = lastRow.MomViolentArea AND
@NegativeReferral = lastRow.NegativeReferral AND
@OtherPresent = lastRow.OtherPresent AND
@PartnerBondingArea = lastRow.PartnerBondingArea AND
@PartnerChildHistoryArea = lastRow.PartnerChildHistoryArea AND
@PartnerCPSArea = lastRow.PartnerCPSArea AND
@PartnerDisciplineArea = lastRow.PartnerDisciplineArea AND
@PartnerExpectationArea = lastRow.PartnerExpectationArea AND
@PartnerInHome = lastRow.PartnerInHome AND
@PartnerPerceptionArea = lastRow.PartnerPerceptionArea AND
@PartnerSAMICHArea = lastRow.PartnerSAMICHArea AND
@PartnerScore = lastRow.PartnerScore AND
@PartnerSelfEsteemArea = lastRow.PartnerSelfEsteemArea AND
@PartnerStressorArea = lastRow.PartnerStressorArea AND
@PartnerViolentArea = lastRow.PartnerViolentArea AND
@PC1ABadChild = lastRow.PC1ABadChild AND
@PC1ADifficultChild = lastRow.PC1ADifficultChild AND
@PC1AEmotionalNeeds = lastRow.PC1AEmotionalNeeds AND
@PC1AHarsh = lastRow.PC1AHarsh AND
@PC1ATemper = lastRow.PC1ATemper AND
@PC1AUnrealistic = lastRow.PC1AUnrealistic AND
@PC1AUnwanted = lastRow.PC1AUnwanted AND
@PC1CANer = lastRow.PC1CANer AND
@PC1Criminal = lastRow.PC1Criminal AND
@PC1FosterChild = lastRow.PC1FosterChild AND
@PC1IssuesFK = lastRow.PC1IssuesFK AND
@PC1MentallyIll = lastRow.PC1MentallyIll AND
@PC1Neglected = lastRow.PC1Neglected AND
@PC1ParentSubAbuse = lastRow.PC1ParentSubAbuse AND
@PC1PhysicallyAbused = lastRow.PC1PhysicallyAbused AND
@PC1SexuallyAbused = lastRow.PC1SexuallyAbused AND
@PC1SubAbuse = lastRow.PC1SubAbuse AND
@PC1SuspectCANer = lastRow.PC1SuspectCANer AND
@PresentSpecify = lastRow.PresentSpecify AND
@ProgramFK = lastRow.ProgramFK AND
@SupervisorObservation = lastRow.SupervisorObservation
ORDER BY KempePK DESC) 
BEGIN
INSERT INTO Kempe(
DadBondingArea,
DadChildHistoryArea,
DadCPSArea,
DadDisciplineArea,
DadExpectationArea,
DadPerceptionArea,
DadSAMICHArea,
DadScore,
DadSelfEsteemArea,
DadStressorArea,
DadViolentArea,
FAWFK,
FOBPartnerPresent,
FOBPresent,
GrandParentPresent,
HVCaseFK,
KempeCreator,
KempeDate,
KempeResult,
MOBPartnerPresent,
MOBPresent,
MomBondingArea,
MomChildHistoryArea,
MomCPSArea,
MomDisciplineArea,
MomExpectationArea,
MomPerceptionArea,
MomSAMICHArea,
MomScore,
MomSelfEsteemArea,
MomStressorArea,
MomViolentArea,
NegativeReferral,
OtherPresent,
PartnerBondingArea,
PartnerChildHistoryArea,
PartnerCPSArea,
PartnerDisciplineArea,
PartnerExpectationArea,
PartnerInHome,
PartnerPerceptionArea,
PartnerSAMICHArea,
PartnerScore,
PartnerSelfEsteemArea,
PartnerStressorArea,
PartnerViolentArea,
PC1ABadChild,
PC1ADifficultChild,
PC1AEmotionalNeeds,
PC1AHarsh,
PC1ATemper,
PC1AUnrealistic,
PC1AUnwanted,
PC1CANer,
PC1Criminal,
PC1FosterChild,
PC1IssuesFK,
PC1MentallyIll,
PC1Neglected,
PC1ParentSubAbuse,
PC1PhysicallyAbused,
PC1SexuallyAbused,
PC1SubAbuse,
PC1SuspectCANer,
PresentSpecify,
ProgramFK,
SupervisorObservation
)
VALUES(
@DadBondingArea,
@DadChildHistoryArea,
@DadCPSArea,
@DadDisciplineArea,
@DadExpectationArea,
@DadPerceptionArea,
@DadSAMICHArea,
@DadScore,
@DadSelfEsteemArea,
@DadStressorArea,
@DadViolentArea,
@FAWFK,
@FOBPartnerPresent,
@FOBPresent,
@GrandParentPresent,
@HVCaseFK,
@KempeCreator,
@KempeDate,
@KempeResult,
@MOBPartnerPresent,
@MOBPresent,
@MomBondingArea,
@MomChildHistoryArea,
@MomCPSArea,
@MomDisciplineArea,
@MomExpectationArea,
@MomPerceptionArea,
@MomSAMICHArea,
@MomScore,
@MomSelfEsteemArea,
@MomStressorArea,
@MomViolentArea,
@NegativeReferral,
@OtherPresent,
@PartnerBondingArea,
@PartnerChildHistoryArea,
@PartnerCPSArea,
@PartnerDisciplineArea,
@PartnerExpectationArea,
@PartnerInHome,
@PartnerPerceptionArea,
@PartnerSAMICHArea,
@PartnerScore,
@PartnerSelfEsteemArea,
@PartnerStressorArea,
@PartnerViolentArea,
@PC1ABadChild,
@PC1ADifficultChild,
@PC1AEmotionalNeeds,
@PC1AHarsh,
@PC1ATemper,
@PC1AUnrealistic,
@PC1AUnwanted,
@PC1CANer,
@PC1Criminal,
@PC1FosterChild,
@PC1IssuesFK,
@PC1MentallyIll,
@PC1Neglected,
@PC1ParentSubAbuse,
@PC1PhysicallyAbused,
@PC1SexuallyAbused,
@PC1SubAbuse,
@PC1SuspectCANer,
@PresentSpecify,
@ProgramFK,
@SupervisorObservation
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
