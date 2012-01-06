
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditKempe](@KempePK int=NULL,
@DadBondingArea char(2)=NULL,
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
@KempeDate datetime=NULL,
@KempeEditor char(10)=NULL,
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
UPDATE Kempe
SET 
DadBondingArea = @DadBondingArea, 
DadChildHistoryArea = @DadChildHistoryArea, 
DadCPSArea = @DadCPSArea, 
DadDisciplineArea = @DadDisciplineArea, 
DadExpectationArea = @DadExpectationArea, 
DadPerceptionArea = @DadPerceptionArea, 
DadSAMICHArea = @DadSAMICHArea, 
DadScore = @DadScore, 
DadSelfEsteemArea = @DadSelfEsteemArea, 
DadStressorArea = @DadStressorArea, 
DadViolentArea = @DadViolentArea, 
FAWFK = @FAWFK, 
FOBPartnerPresent = @FOBPartnerPresent, 
FOBPresent = @FOBPresent, 
GrandParentPresent = @GrandParentPresent, 
HVCaseFK = @HVCaseFK, 
KempeDate = @KempeDate, 
KempeEditor = @KempeEditor, 
KempeResult = @KempeResult, 
MOBPartnerPresent = @MOBPartnerPresent, 
MOBPresent = @MOBPresent, 
MomBondingArea = @MomBondingArea, 
MomChildHistoryArea = @MomChildHistoryArea, 
MomCPSArea = @MomCPSArea, 
MomDisciplineArea = @MomDisciplineArea, 
MomExpectationArea = @MomExpectationArea, 
MomPerceptionArea = @MomPerceptionArea, 
MomSAMICHArea = @MomSAMICHArea, 
MomScore = @MomScore, 
MomSelfEsteemArea = @MomSelfEsteemArea, 
MomStressorArea = @MomStressorArea, 
MomViolentArea = @MomViolentArea, 
NegativeReferral = @NegativeReferral, 
OtherPresent = @OtherPresent, 
PartnerBondingArea = @PartnerBondingArea, 
PartnerChildHistoryArea = @PartnerChildHistoryArea, 
PartnerCPSArea = @PartnerCPSArea, 
PartnerDisciplineArea = @PartnerDisciplineArea, 
PartnerExpectationArea = @PartnerExpectationArea, 
PartnerInHome = @PartnerInHome, 
PartnerPerceptionArea = @PartnerPerceptionArea, 
PartnerSAMICHArea = @PartnerSAMICHArea, 
PartnerScore = @PartnerScore, 
PartnerSelfEsteemArea = @PartnerSelfEsteemArea, 
PartnerStressorArea = @PartnerStressorArea, 
PartnerViolentArea = @PartnerViolentArea, 
PC1ABadChild = @PC1ABadChild, 
PC1ADifficultChild = @PC1ADifficultChild, 
PC1AEmotionalNeeds = @PC1AEmotionalNeeds, 
PC1AHarsh = @PC1AHarsh, 
PC1ATemper = @PC1ATemper, 
PC1AUnrealistic = @PC1AUnrealistic, 
PC1AUnwanted = @PC1AUnwanted, 
PC1CANer = @PC1CANer, 
PC1Criminal = @PC1Criminal, 
PC1FosterChild = @PC1FosterChild, 
PC1IssuesFK = @PC1IssuesFK, 
PC1MentallyIll = @PC1MentallyIll, 
PC1Neglected = @PC1Neglected, 
PC1ParentSubAbuse = @PC1ParentSubAbuse, 
PC1PhysicallyAbused = @PC1PhysicallyAbused, 
PC1SexuallyAbused = @PC1SexuallyAbused, 
PC1SubAbuse = @PC1SubAbuse, 
PC1SuspectCANer = @PC1SuspectCANer, 
PresentSpecify = @PresentSpecify, 
ProgramFK = @ProgramFK, 
SupervisorObservation = @SupervisorObservation
WHERE KempePK = @KempePK
GO
