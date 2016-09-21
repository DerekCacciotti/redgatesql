SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddHVLog](@CAChildSupport char(2)=NULL,
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
@CDSpecify varchar(500)=NULL,
@CDToys char(2)=NULL,
@CDParentConcerned char(2)=NULL,
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
@HVLogCreator char(10)=NULL,
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
INSERT INTO HVLog(
CAChildSupport,
CAAdvocacy,
CAGoods,
CAHousing,
CALaborSupport,
CALegal,
CAOther,
CAParentRights,
CASpecify,
CATranslation,
CATransportation,
CAVisitation,
CDChildDevelopment,
CDOther,
CDSpecify,
CDToys,
CDParentConcerned,
CIProblems,
CIOther,
CIOtherSpecify,
Curriculum247Dads,
CurriculumBoyz2Dads,
CurriculumGrowingGreatKids,
CurriculumHelpingBabiesLearn,
CurriculumInsideOutDads,
CurriculumMomGateway,
CurriculumOther,
CurriculumOtherSpecify,
CurriculumParentsForLearning,
CurriculumPartnersHealthyBaby,
CurriculumPAT,
CurriculumPATFocusFathers,
CurriculumSanAngelo,
FamilyMemberReads,
FatherAdvocateFK,
FatherAdvocateParticipated,
FatherFigureParticipated,
FFCommunication,
FFDomesticViolence,
FFFamilyRelations,
FFMentalHealth,
FFOther,
FFSpecify,
FFSubstanceAbuse,
FSWFK,
GrandParentParticipated,
HCBreastFeeding,
HCChild,
HCDental,
HCFamilyPlanning,
HCFASD,
HCFeeding,
HCGeneral,
HCMedicalAdvocacy,
HCNutrition,
HCOther,
HCPrenatalCare,
HCProviders,
HCSafety,
HCSexEducation,
HCSIDS,
HCSmoking,
HCSpecify,
HVCaseFK,
HVLogCreator,
HVSupervisorParticipated,
NonPrimaryFSWParticipated,
NonPrimaryFSWFK,
OBPParticipated,
OtherLocationSpecify,
OtherParticipated,
PAAssessmentIssues,
PAForms,
PAGroups,
PAIFSP,
PAOther,
PARecreation,
PASpecify,
PAVideo,
ParentCompletedActivity,
ParentObservationsDiscussed,
ParticipatedSpecify,
PC1Participated,
PC2Participated,
PCBasicNeeds,
PCChildInteraction,
PCChildManagement,
PCFeelings,
PCOther,
PCShakenBaby,
PCShakenBabyVideo,
PCSpecify,
PCStress,
ProgramFK,
ReviewAssessmentIssues,
SiblingParticipated,
SSCalendar,
SSChildCare,
SSEducation,
SSEmployment,
SSHousekeeping,
SSJob,
SSMoneyManagement,
SSOther,
SSProblemSolving,
SSSpecify,
SSTransportation,
SupervisorObservation,
TCAlwaysOnBack,
TCAlwaysWithoutSharing,
TCParticipated,
TotalPercentageSpent,
UpcomingProgramEvents,
VisitLengthHour,
VisitLengthMinute,
VisitLocation,
VisitStartTime,
VisitType
)
VALUES(
@CAChildSupport,
@CAAdvocacy,
@CAGoods,
@CAHousing,
@CALaborSupport,
@CALegal,
@CAOther,
@CAParentRights,
@CASpecify,
@CATranslation,
@CATransportation,
@CAVisitation,
@CDChildDevelopment,
@CDOther,
@CDSpecify,
@CDToys,
@CDParentConcerned,
@CIProblems,
@CIOther,
@CIOtherSpecify,
@Curriculum247Dads,
@CurriculumBoyz2Dads,
@CurriculumGrowingGreatKids,
@CurriculumHelpingBabiesLearn,
@CurriculumInsideOutDads,
@CurriculumMomGateway,
@CurriculumOther,
@CurriculumOtherSpecify,
@CurriculumParentsForLearning,
@CurriculumPartnersHealthyBaby,
@CurriculumPAT,
@CurriculumPATFocusFathers,
@CurriculumSanAngelo,
@FamilyMemberReads,
@FatherAdvocateFK,
@FatherAdvocateParticipated,
@FatherFigureParticipated,
@FFCommunication,
@FFDomesticViolence,
@FFFamilyRelations,
@FFMentalHealth,
@FFOther,
@FFSpecify,
@FFSubstanceAbuse,
@FSWFK,
@GrandParentParticipated,
@HCBreastFeeding,
@HCChild,
@HCDental,
@HCFamilyPlanning,
@HCFASD,
@HCFeeding,
@HCGeneral,
@HCMedicalAdvocacy,
@HCNutrition,
@HCOther,
@HCPrenatalCare,
@HCProviders,
@HCSafety,
@HCSexEducation,
@HCSIDS,
@HCSmoking,
@HCSpecify,
@HVCaseFK,
@HVLogCreator,
@HVSupervisorParticipated,
@NonPrimaryFSWParticipated,
@NonPrimaryFSWFK,
@OBPParticipated,
@OtherLocationSpecify,
@OtherParticipated,
@PAAssessmentIssues,
@PAForms,
@PAGroups,
@PAIFSP,
@PAOther,
@PARecreation,
@PASpecify,
@PAVideo,
@ParentCompletedActivity,
@ParentObservationsDiscussed,
@ParticipatedSpecify,
@PC1Participated,
@PC2Participated,
@PCBasicNeeds,
@PCChildInteraction,
@PCChildManagement,
@PCFeelings,
@PCOther,
@PCShakenBaby,
@PCShakenBabyVideo,
@PCSpecify,
@PCStress,
@ProgramFK,
@ReviewAssessmentIssues,
@SiblingParticipated,
@SSCalendar,
@SSChildCare,
@SSEducation,
@SSEmployment,
@SSHousekeeping,
@SSJob,
@SSMoneyManagement,
@SSOther,
@SSProblemSolving,
@SSSpecify,
@SSTransportation,
@SupervisorObservation,
@TCAlwaysOnBack,
@TCAlwaysWithoutSharing,
@TCParticipated,
@TotalPercentageSpent,
@UpcomingProgramEvents,
@VisitLengthHour,
@VisitLengthMinute,
@VisitLocation,
@VisitStartTime,
@VisitType
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
