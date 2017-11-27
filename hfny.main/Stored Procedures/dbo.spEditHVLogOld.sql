SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditHVLogOld](@HVLogOldPK int=NULL,
@CAChildSupport char(2)=NULL,
@CAAdvocacy char(2)=NULL,
@CAGoods char(2)=NULL,
@CAHousing char(2)=NULL,
@CALaborSupport char(2)=NULL,
@CALegal char(2)=NULL,
@CAOther char(2)=NULL,
@CAParentRights char(2)=NULL,
@CASpecify varchar(500)=NULL,
@CATranslation char(2)=NULL,
@CATransportation char(2)=NULL,
@CAVisitation char(2)=NULL,
@CDChildDevelopment char(2)=NULL,
@CDOther char(2)=NULL,
@CDParentConcerned char(2)=NULL,
@CDSpecify varchar(500)=NULL,
@CDToys char(2)=NULL,
@CIProblems char(2)=NULL,
@CIOther char(2)=NULL,
@CIOtherSpecify varchar(500)=NULL,
@Curriculum247Dads bit=NULL,
@CurriculumBoyz2Dads bit=NULL,
@CurriculumGrowingGreatKids bit=NULL,
@CurriculumHelpingBabiesLearn bit=NULL,
@CurriculumInsideOutDads bit=NULL,
@CurriculumMomGateway bit=NULL,
@CurriculumOther bit=NULL,
@CurriculumOtherSpecify varchar(500)=NULL,
@CurriculumParentsForLearning bit=NULL,
@CurriculumPartnersHealthyBaby bit=NULL,
@CurriculumPAT bit=NULL,
@CurriculumPATFocusFathers bit=NULL,
@CurriculumSanAngelo bit=NULL,
@FamilyMemberReads char(2)=NULL,
@FatherAdvocateFK int=NULL,
@FatherAdvocateParticipated bit=NULL,
@FatherFigureParticipated bit=NULL,
@FFCommunication char(2)=NULL,
@FFDomesticViolence char(2)=NULL,
@FFFamilyRelations char(2)=NULL,
@FFMentalHealth char(2)=NULL,
@FFOther char(2)=NULL,
@FFSpecify varchar(500)=NULL,
@FFSubstanceAbuse char(2)=NULL,
@FSWFK int=NULL,
@GrandParentParticipated bit=NULL,
@HCBreastFeeding char(2)=NULL,
@HCChild char(2)=NULL,
@HCDental char(2)=NULL,
@HCFamilyPlanning char(2)=NULL,
@HCFASD char(2)=NULL,
@HCFeeding char(2)=NULL,
@HCGeneral char(2)=NULL,
@HCMedicalAdvocacy char(2)=NULL,
@HCNutrition char(2)=NULL,
@HCOther char(2)=NULL,
@HCPrenatalCare char(2)=NULL,
@HCProviders char(2)=NULL,
@HCSafety char(2)=NULL,
@HCSexEducation char(2)=NULL,
@HCSIDS char(2)=NULL,
@HCSmoking char(2)=NULL,
@HCSpecify varchar(500)=NULL,
@HVCaseFK int=NULL,
@HVLogEditor char(10)=NULL,
@HVSupervisorParticipated bit=NULL,
@NonPrimaryFSWParticipated bit=NULL,
@NonPrimaryFSWFK int=NULL,
@OBPParticipated bit=NULL,
@OtherLocationSpecify varchar(500)=NULL,
@OtherParticipated bit=NULL,
@PAAssessmentIssues bit=NULL,
@PAForms char(2)=NULL,
@PAGroups char(2)=NULL,
@PAIFSP char(2)=NULL,
@PAOther char(2)=NULL,
@PARecreation char(2)=NULL,
@PASpecify varchar(500)=NULL,
@PAVideo char(2)=NULL,
@ParentCompletedActivity bit=NULL,
@ParentObservationsDiscussed bit=NULL,
@ParticipatedSpecify varchar(500)=NULL,
@PC1Participated bit=NULL,
@PC2Participated bit=NULL,
@PCBasicNeeds char(2)=NULL,
@PCChildInteraction char(2)=NULL,
@PCChildManagement char(2)=NULL,
@PCFeelings char(2)=NULL,
@PCOther char(2)=NULL,
@PCShakenBaby char(2)=NULL,
@PCShakenBabyVideo char(2)=NULL,
@PCSpecify varchar(500)=NULL,
@PCStress char(2)=NULL,
@ProgramFK int=NULL,
@ReviewAssessmentIssues varchar(500)=NULL,
@SiblingParticipated bit=NULL,
@SSCalendar char(2)=NULL,
@SSChildCare char(2)=NULL,
@SSEducation char(2)=NULL,
@SSEmployment char(2)=NULL,
@SSHousekeeping char(2)=NULL,
@SSJob char(2)=NULL,
@SSMoneyManagement char(2)=NULL,
@SSOther char(2)=NULL,
@SSProblemSolving char(2)=NULL,
@SSSpecify varchar(500)=NULL,
@SSTransportation char(2)=NULL,
@SupervisorObservation bit=NULL,
@TCAlwaysOnBack bit=NULL,
@TCAlwaysWithoutSharing bit=NULL,
@TCParticipated bit=NULL,
@TotalPercentageSpent int=NULL,
@UpcomingProgramEvents bit=NULL,
@VisitLengthHour int=NULL,
@VisitLengthMinute int=NULL,
@VisitLocation char(5)=NULL,
@VisitStartTime datetime=NULL,
@VisitType char(4)=NULL)
AS
UPDATE HVLogOld
SET 
CAChildSupport = @CAChildSupport, 
CAAdvocacy = @CAAdvocacy, 
CAGoods = @CAGoods, 
CAHousing = @CAHousing, 
CALaborSupport = @CALaborSupport, 
CALegal = @CALegal, 
CAOther = @CAOther, 
CAParentRights = @CAParentRights, 
CASpecify = @CASpecify, 
CATranslation = @CATranslation, 
CATransportation = @CATransportation, 
CAVisitation = @CAVisitation, 
CDChildDevelopment = @CDChildDevelopment, 
CDOther = @CDOther, 
CDParentConcerned = @CDParentConcerned, 
CDSpecify = @CDSpecify, 
CDToys = @CDToys, 
CIProblems = @CIProblems, 
CIOther = @CIOther, 
CIOtherSpecify = @CIOtherSpecify, 
Curriculum247Dads = @Curriculum247Dads, 
CurriculumBoyz2Dads = @CurriculumBoyz2Dads, 
CurriculumGrowingGreatKids = @CurriculumGrowingGreatKids, 
CurriculumHelpingBabiesLearn = @CurriculumHelpingBabiesLearn, 
CurriculumInsideOutDads = @CurriculumInsideOutDads, 
CurriculumMomGateway = @CurriculumMomGateway, 
CurriculumOther = @CurriculumOther, 
CurriculumOtherSpecify = @CurriculumOtherSpecify, 
CurriculumParentsForLearning = @CurriculumParentsForLearning, 
CurriculumPartnersHealthyBaby = @CurriculumPartnersHealthyBaby, 
CurriculumPAT = @CurriculumPAT, 
CurriculumPATFocusFathers = @CurriculumPATFocusFathers, 
CurriculumSanAngelo = @CurriculumSanAngelo, 
FamilyMemberReads = @FamilyMemberReads, 
FatherAdvocateFK = @FatherAdvocateFK, 
FatherAdvocateParticipated = @FatherAdvocateParticipated, 
FatherFigureParticipated = @FatherFigureParticipated, 
FFCommunication = @FFCommunication, 
FFDomesticViolence = @FFDomesticViolence, 
FFFamilyRelations = @FFFamilyRelations, 
FFMentalHealth = @FFMentalHealth, 
FFOther = @FFOther, 
FFSpecify = @FFSpecify, 
FFSubstanceAbuse = @FFSubstanceAbuse, 
FSWFK = @FSWFK, 
GrandParentParticipated = @GrandParentParticipated, 
HCBreastFeeding = @HCBreastFeeding, 
HCChild = @HCChild, 
HCDental = @HCDental, 
HCFamilyPlanning = @HCFamilyPlanning, 
HCFASD = @HCFASD, 
HCFeeding = @HCFeeding, 
HCGeneral = @HCGeneral, 
HCMedicalAdvocacy = @HCMedicalAdvocacy, 
HCNutrition = @HCNutrition, 
HCOther = @HCOther, 
HCPrenatalCare = @HCPrenatalCare, 
HCProviders = @HCProviders, 
HCSafety = @HCSafety, 
HCSexEducation = @HCSexEducation, 
HCSIDS = @HCSIDS, 
HCSmoking = @HCSmoking, 
HCSpecify = @HCSpecify, 
HVCaseFK = @HVCaseFK, 
HVLogEditor = @HVLogEditor, 
HVSupervisorParticipated = @HVSupervisorParticipated, 
NonPrimaryFSWParticipated = @NonPrimaryFSWParticipated, 
NonPrimaryFSWFK = @NonPrimaryFSWFK, 
OBPParticipated = @OBPParticipated, 
OtherLocationSpecify = @OtherLocationSpecify, 
OtherParticipated = @OtherParticipated, 
PAAssessmentIssues = @PAAssessmentIssues, 
PAForms = @PAForms, 
PAGroups = @PAGroups, 
PAIFSP = @PAIFSP, 
PAOther = @PAOther, 
PARecreation = @PARecreation, 
PASpecify = @PASpecify, 
PAVideo = @PAVideo, 
ParentCompletedActivity = @ParentCompletedActivity, 
ParentObservationsDiscussed = @ParentObservationsDiscussed, 
ParticipatedSpecify = @ParticipatedSpecify, 
PC1Participated = @PC1Participated, 
PC2Participated = @PC2Participated, 
PCBasicNeeds = @PCBasicNeeds, 
PCChildInteraction = @PCChildInteraction, 
PCChildManagement = @PCChildManagement, 
PCFeelings = @PCFeelings, 
PCOther = @PCOther, 
PCShakenBaby = @PCShakenBaby, 
PCShakenBabyVideo = @PCShakenBabyVideo, 
PCSpecify = @PCSpecify, 
PCStress = @PCStress, 
ProgramFK = @ProgramFK, 
ReviewAssessmentIssues = @ReviewAssessmentIssues, 
SiblingParticipated = @SiblingParticipated, 
SSCalendar = @SSCalendar, 
SSChildCare = @SSChildCare, 
SSEducation = @SSEducation, 
SSEmployment = @SSEmployment, 
SSHousekeeping = @SSHousekeeping, 
SSJob = @SSJob, 
SSMoneyManagement = @SSMoneyManagement, 
SSOther = @SSOther, 
SSProblemSolving = @SSProblemSolving, 
SSSpecify = @SSSpecify, 
SSTransportation = @SSTransportation, 
SupervisorObservation = @SupervisorObservation, 
TCAlwaysOnBack = @TCAlwaysOnBack, 
TCAlwaysWithoutSharing = @TCAlwaysWithoutSharing, 
TCParticipated = @TCParticipated, 
TotalPercentageSpent = @TotalPercentageSpent, 
UpcomingProgramEvents = @UpcomingProgramEvents, 
VisitLengthHour = @VisitLengthHour, 
VisitLengthMinute = @VisitLengthMinute, 
VisitLocation = @VisitLocation, 
VisitStartTime = @VisitStartTime, 
VisitType = @VisitType
WHERE HVLogOldPK = @HVLogOldPK
GO
