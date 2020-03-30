SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddHVLog](@AdditionalComments varchar(max)=NULL,
@CAAdvocacy bit=NULL,
@CAChildSupport bit=NULL,
@CAComments varchar(max)=NULL,
@CAGoods bit=NULL,
@CAHousing bit=NULL,
@CALaborSupport bit=NULL,
@CALegal bit=NULL,
@CAOther bit=NULL,
@CAParentRights bit=NULL,
@CASpecify varchar(500)=NULL,
@CATranslation bit=NULL,
@CATransportation bit=NULL,
@CAVisitation bit=NULL,
@CDChildDevelopment bit=NULL,
@CDComments varchar(max)=NULL,
@CDFollowUpEIServices bit=NULL,
@CDOther bit=NULL,
@CDParentConcerned bit=NULL,
@CDSocialEmotionalDevelopment bit=NULL,
@CDSpecify varchar(500)=NULL,
@CDToys bit=NULL,
@CHEERSCues varchar(max)=NULL,
@CHEERSHolding varchar(max)=NULL,
@CHEERSExpression varchar(max)=NULL,
@CHEERSEmpathy varchar(max)=NULL,
@CHEERSRhythmReciprocity varchar(max)=NULL,
@CHEERSSmiles varchar(max)=NULL,
@CHEERSOverallStrengths varchar(max)=NULL,
@CHEERSAreasToFocus varchar(max)=NULL,
@CIComments varchar(max)=NULL,
@CIProblems bit=NULL,
@CIOther bit=NULL,
@CIOtherSpecify varchar(500)=NULL,
@Curriculum247Dads bit=NULL,
@CurriculumBoyz2Dads bit=NULL,
@CurriculumComments varchar(max)=NULL,
@CurriculumGreatBeginnings bit=NULL,
@CurriculumGrowingGreatKids bit=NULL,
@CurriculumHelpingBabiesLearn bit=NULL,
@CurriculumInsideOutDads bit=NULL,
@CurriculumMomGateway bit=NULL,
@CurriculumOtherSupplementalInformation bit=NULL,
@CurriculumOtherSupplementalInformationComments varchar(max)=NULL,
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
@FFChildProtectiveIssues bit=NULL,
@FFComments varchar(max)=NULL,
@FFCommunication bit=NULL,
@FFDevelopmentalDisabilities bit=NULL,
@FFDomesticViolence bit=NULL,
@FFFamilyRelations bit=NULL,
@FFImmigration bit=NULL,
@FFMentalHealth bit=NULL,
@FFOther bit=NULL,
@FFSpecify varchar(500)=NULL,
@FFSubstanceAbuse bit=NULL,
@FGPComments varchar(max)=NULL,
@FGPDevelopActivities bit=NULL,
@FGPDiscuss bit=NULL,
@FGPGoalsCompleted bit=NULL,
@FGPNewGoal bit=NULL,
@FGPNoDiscussion bit=NULL,
@FGPProgress bit=NULL,
@FGPRevisions bit=NULL,
@FormComplete bit=NULL,
@FSWFK int=NULL,
@GrandParentParticipated bit=NULL,
@HCBreastFeeding bit=NULL,
@HCChild bit=NULL,
@HCComments varchar(max)=NULL,
@HCDental bit=NULL,
@HCFamilyPlanning bit=NULL,
@HCFASD bit=NULL,
@HCFeeding bit=NULL,
@HCGeneral bit=NULL,
@HCLaborDelivery bit=NULL,
@HCMedicalAdvocacy bit=NULL,
@HCNutrition bit=NULL,
@HCOther bit=NULL,
@HCPrenatalCare bit=NULL,
@HCProviders bit=NULL,
@HCSafety bit=NULL,
@HCSexEducation bit=NULL,
@HCSIDS bit=NULL,
@HCSmoking bit=NULL,
@HCSpecify varchar(500)=NULL,
@HealthPC1AppearsHealthy bit=NULL,
@HealthPC1Asleep bit=NULL,
@HealthPC1CommentsGeneral varchar(max)=NULL,
@HealthPC1CommentsMedical varchar(max)=NULL,
@HealthPC1ERVisits bit=NULL,
@HealthPC1HealthConcern bit=NULL,
@HealthPC1MedicalPrenatalAppointments bit=NULL,
@HealthPC1PhysicalNeedsAppearUnmet bit=NULL,
@HealthPC1TiredIrritable bit=NULL,
@HealthPC1WithdrawnUnresponsive bit=NULL,
@HealthTCAppearsHealthy bit=NULL,
@HealthTCAsleep bit=NULL,
@HealthTCCommentsGeneral varchar(max)=NULL,
@HealthTCCommentsMedical varchar(max)=NULL,
@HealthTCERVisits bit=NULL,
@HealthTCHealthConcern bit=NULL,
@HealthTCImmunizations bit=NULL,
@HealthTCMedicalWellBabyAppointments bit=NULL,
@HealthTCPhysicalNeedsAppearUnmet bit=NULL,
@HealthTCTiredIrritable bit=NULL,
@HealthTCWithdrawnUnresponsive bit=NULL,
@HouseholdChangesComments varchar(max)=NULL,
@HouseholdChangesLeft bit=NULL,
@HouseholdChangesNew bit=NULL,
@HVCaseFK int=NULL,
@HVLogCreator varchar(max)=NULL,
@HVSupervisorParticipated bit=NULL,
@NextScheduledVisit datetime=NULL,
@NextVisitNotes varchar(max)=NULL,
@NonPrimaryFSWParticipated bit=NULL,
@NonPrimaryFSWFK int=NULL,
@OBPParticipated bit=NULL,
@OtherLocationSpecify varchar(500)=NULL,
@OtherParticipated bit=NULL,
@PAAssessmentIssues bit=NULL,
@PAComments varchar(max)=NULL,
@PAForms bit=NULL,
@PAGroups bit=NULL,
@PAIFSP bit=NULL,
@PAIntroduceProgram bit=NULL,
@PALevelChange bit=NULL,
@PAOther bit=NULL,
@PARecreation bit=NULL,
@PASpecify varchar(500)=NULL,
@PAVideo bit=NULL,
@ParentCompletedActivity bit=NULL,
@ParentObservationsDiscussed bit=NULL,
@ParticipatedSpecify varchar(500)=NULL,
@PC1Participated bit=NULL,
@PC2Participated bit=NULL,
@PCBasicNeeds bit=NULL,
@PCChildInteraction bit=NULL,
@PCChildManagement bit=NULL,
@PCComments varchar(max)=NULL,
@PCFeelings bit=NULL,
@PCOther bit=NULL,
@PCShakenBaby bit=NULL,
@PCShakenBabyVideo bit=NULL,
@PCSpecify varchar(500)=NULL,
@PCStress bit=NULL,
@PCTechnologyEffects bit=NULL,
@POCRAskedQuestions bit=NULL,
@POCRComments varchar(max)=NULL,
@POCRContributed bit=NULL,
@POCRInterested bit=NULL,
@POCRNotInterested bit=NULL,
@POCRWantedInformation bit=NULL,
@ProgramFK int=NULL,
@PSCComments varchar(max)=NULL,
@PSCEmergingIssues bit=NULL,
@PSCInitialDiscussion bit=NULL,
@PSCImplement bit=NULL,
@PSCOngoingDiscussion bit=NULL,
@ReferralsComments varchar(max)=NULL,
@ReferralsFollowUp bit=NULL,
@ReferralsMade bit=NULL,
@ReviewAssessmentIssues varchar(500)=NULL,
@RSATP bit=NULL,
@RSATPComments varchar(max)=NULL,
@RSSATP bit=NULL,
@RSSATPComments varchar(max)=NULL,
@RSFFF bit=NULL,
@RSFFFComments varchar(max)=NULL,
@RSEW bit=NULL,
@RSEWComments varchar(max)=NULL,
@RSNormalizing bit=NULL,
@RSNormalizingComments varchar(max)=NULL,
@RSSFT bit=NULL,
@RSSFTComments varchar(max)=NULL,
@SiblingParticipated bit=NULL,
@SiblingsObservation varchar(max)=NULL,
@SSCalendar bit=NULL,
@SSChildCare bit=NULL,
@SSChildWelfareServices bit=NULL,
@SSComments varchar(max)=NULL,
@SSEducation bit=NULL,
@SSEmployment bit=NULL,
@SSHomeEnvironment bit=NULL,
@SSHousekeeping bit=NULL,
@SSJob bit=NULL,
@SSMoneyManagement bit=NULL,
@SSOther bit=NULL,
@SSProblemSolving bit=NULL,
@SSSpecify varchar(500)=NULL,
@SSTransportation bit=NULL,
@STASQ bit=NULL,
@STASQSE bit=NULL,
@STComments varchar(max)=NULL,
@STPHQ9 bit=NULL,
@STPSI bit=NULL,
@STOther bit=NULL,
@SupervisorObservation bit=NULL,
@TCAlwaysOnBack bit=NULL,
@TCAlwaysWithoutSharing bit=NULL,
@TCParticipated bit=NULL,
@TotalPercentageSpent int=NULL,
@TPComments varchar(max)=NULL,
@TPDateInitiated date=NULL,
@TPInitiated bit=NULL,
@TPNotApplicable int=NULL,
@TPOngoingDiscussion bit=NULL,
@TPParentDeclined bit=NULL,
@TPPlanFinalized bit=NULL,
@TPTransitionCompleted bit=NULL,
@UpcomingProgramEvents bit=NULL,
@VisitLengthHour int=NULL,
@VisitLengthMinute int=NULL,
@VisitLocation char(5)=NULL,
@VisitStartTime datetime=NULL,
@VisitType char(6)=NULL,
@VisitTypeComments varchar(max)=NULL,
@CHEERSCuesFrequency char(1)=NULL,
@CHEERSHoldingFrequency char(1)=NULL,
@CHEERSExpressionFrequency char(1)=NULL,
@CHEERSEmpathyFrequency char(1)=NULL,
@CHEERSRhythmReciprocityFrequency char(1)=NULL,
@CHEERSSmilesFrequency char(1)=NULL)
AS
INSERT INTO HVLog(
AdditionalComments,
CAAdvocacy,
CAChildSupport,
CAComments,
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
CDComments,
CDFollowUpEIServices,
CDOther,
CDParentConcerned,
CDSocialEmotionalDevelopment,
CDSpecify,
CDToys,
CHEERSCues,
CHEERSHolding,
CHEERSExpression,
CHEERSEmpathy,
CHEERSRhythmReciprocity,
CHEERSSmiles,
CHEERSOverallStrengths,
CHEERSAreasToFocus,
CIComments,
CIProblems,
CIOther,
CIOtherSpecify,
Curriculum247Dads,
CurriculumBoyz2Dads,
CurriculumComments,
CurriculumGreatBeginnings,
CurriculumGrowingGreatKids,
CurriculumHelpingBabiesLearn,
CurriculumInsideOutDads,
CurriculumMomGateway,
CurriculumOtherSupplementalInformation,
CurriculumOtherSupplementalInformationComments,
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
FFChildProtectiveIssues,
FFComments,
FFCommunication,
FFDevelopmentalDisabilities,
FFDomesticViolence,
FFFamilyRelations,
FFImmigration,
FFMentalHealth,
FFOther,
FFSpecify,
FFSubstanceAbuse,
FGPComments,
FGPDevelopActivities,
FGPDiscuss,
FGPGoalsCompleted,
FGPNewGoal,
FGPNoDiscussion,
FGPProgress,
FGPRevisions,
FormComplete,
FSWFK,
GrandParentParticipated,
HCBreastFeeding,
HCChild,
HCComments,
HCDental,
HCFamilyPlanning,
HCFASD,
HCFeeding,
HCGeneral,
HCLaborDelivery,
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
HealthPC1AppearsHealthy,
HealthPC1Asleep,
HealthPC1CommentsGeneral,
HealthPC1CommentsMedical,
HealthPC1ERVisits,
HealthPC1HealthConcern,
HealthPC1MedicalPrenatalAppointments,
HealthPC1PhysicalNeedsAppearUnmet,
HealthPC1TiredIrritable,
HealthPC1WithdrawnUnresponsive,
HealthTCAppearsHealthy,
HealthTCAsleep,
HealthTCCommentsGeneral,
HealthTCCommentsMedical,
HealthTCERVisits,
HealthTCHealthConcern,
HealthTCImmunizations,
HealthTCMedicalWellBabyAppointments,
HealthTCPhysicalNeedsAppearUnmet,
HealthTCTiredIrritable,
HealthTCWithdrawnUnresponsive,
HouseholdChangesComments,
HouseholdChangesLeft,
HouseholdChangesNew,
HVCaseFK,
HVLogCreator,
HVSupervisorParticipated,
NextScheduledVisit,
NextVisitNotes,
NonPrimaryFSWParticipated,
NonPrimaryFSWFK,
OBPParticipated,
OtherLocationSpecify,
OtherParticipated,
PAAssessmentIssues,
PAComments,
PAForms,
PAGroups,
PAIFSP,
PAIntroduceProgram,
PALevelChange,
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
PCComments,
PCFeelings,
PCOther,
PCShakenBaby,
PCShakenBabyVideo,
PCSpecify,
PCStress,
PCTechnologyEffects,
POCRAskedQuestions,
POCRComments,
POCRContributed,
POCRInterested,
POCRNotInterested,
POCRWantedInformation,
ProgramFK,
PSCComments,
PSCEmergingIssues,
PSCInitialDiscussion,
PSCImplement,
PSCOngoingDiscussion,
ReferralsComments,
ReferralsFollowUp,
ReferralsMade,
ReviewAssessmentIssues,
RSATP,
RSATPComments,
RSSATP,
RSSATPComments,
RSFFF,
RSFFFComments,
RSEW,
RSEWComments,
RSNormalizing,
RSNormalizingComments,
RSSFT,
RSSFTComments,
SiblingParticipated,
SiblingsObservation,
SSCalendar,
SSChildCare,
SSChildWelfareServices,
SSComments,
SSEducation,
SSEmployment,
SSHomeEnvironment,
SSHousekeeping,
SSJob,
SSMoneyManagement,
SSOther,
SSProblemSolving,
SSSpecify,
SSTransportation,
STASQ,
STASQSE,
STComments,
STPHQ9,
STPSI,
STOther,
SupervisorObservation,
TCAlwaysOnBack,
TCAlwaysWithoutSharing,
TCParticipated,
TotalPercentageSpent,
TPComments,
TPDateInitiated,
TPInitiated,
TPNotApplicable,
TPOngoingDiscussion,
TPParentDeclined,
TPPlanFinalized,
TPTransitionCompleted,
UpcomingProgramEvents,
VisitLengthHour,
VisitLengthMinute,
VisitLocation,
VisitStartTime,
VisitType,
VisitTypeComments,
CHEERSCuesFrequency,
CHEERSHoldingFrequency,
CHEERSExpressionFrequency,
CHEERSEmpathyFrequency,
CHEERSRhythmReciprocityFrequency,
CHEERSSmilesFrequency
)
VALUES(
@AdditionalComments,
@CAAdvocacy,
@CAChildSupport,
@CAComments,
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
@CDComments,
@CDFollowUpEIServices,
@CDOther,
@CDParentConcerned,
@CDSocialEmotionalDevelopment,
@CDSpecify,
@CDToys,
@CHEERSCues,
@CHEERSHolding,
@CHEERSExpression,
@CHEERSEmpathy,
@CHEERSRhythmReciprocity,
@CHEERSSmiles,
@CHEERSOverallStrengths,
@CHEERSAreasToFocus,
@CIComments,
@CIProblems,
@CIOther,
@CIOtherSpecify,
@Curriculum247Dads,
@CurriculumBoyz2Dads,
@CurriculumComments,
@CurriculumGreatBeginnings,
@CurriculumGrowingGreatKids,
@CurriculumHelpingBabiesLearn,
@CurriculumInsideOutDads,
@CurriculumMomGateway,
@CurriculumOtherSupplementalInformation,
@CurriculumOtherSupplementalInformationComments,
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
@FFChildProtectiveIssues,
@FFComments,
@FFCommunication,
@FFDevelopmentalDisabilities,
@FFDomesticViolence,
@FFFamilyRelations,
@FFImmigration,
@FFMentalHealth,
@FFOther,
@FFSpecify,
@FFSubstanceAbuse,
@FGPComments,
@FGPDevelopActivities,
@FGPDiscuss,
@FGPGoalsCompleted,
@FGPNewGoal,
@FGPNoDiscussion,
@FGPProgress,
@FGPRevisions,
@FormComplete,
@FSWFK,
@GrandParentParticipated,
@HCBreastFeeding,
@HCChild,
@HCComments,
@HCDental,
@HCFamilyPlanning,
@HCFASD,
@HCFeeding,
@HCGeneral,
@HCLaborDelivery,
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
@HealthPC1AppearsHealthy,
@HealthPC1Asleep,
@HealthPC1CommentsGeneral,
@HealthPC1CommentsMedical,
@HealthPC1ERVisits,
@HealthPC1HealthConcern,
@HealthPC1MedicalPrenatalAppointments,
@HealthPC1PhysicalNeedsAppearUnmet,
@HealthPC1TiredIrritable,
@HealthPC1WithdrawnUnresponsive,
@HealthTCAppearsHealthy,
@HealthTCAsleep,
@HealthTCCommentsGeneral,
@HealthTCCommentsMedical,
@HealthTCERVisits,
@HealthTCHealthConcern,
@HealthTCImmunizations,
@HealthTCMedicalWellBabyAppointments,
@HealthTCPhysicalNeedsAppearUnmet,
@HealthTCTiredIrritable,
@HealthTCWithdrawnUnresponsive,
@HouseholdChangesComments,
@HouseholdChangesLeft,
@HouseholdChangesNew,
@HVCaseFK,
@HVLogCreator,
@HVSupervisorParticipated,
@NextScheduledVisit,
@NextVisitNotes,
@NonPrimaryFSWParticipated,
@NonPrimaryFSWFK,
@OBPParticipated,
@OtherLocationSpecify,
@OtherParticipated,
@PAAssessmentIssues,
@PAComments,
@PAForms,
@PAGroups,
@PAIFSP,
@PAIntroduceProgram,
@PALevelChange,
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
@PCComments,
@PCFeelings,
@PCOther,
@PCShakenBaby,
@PCShakenBabyVideo,
@PCSpecify,
@PCStress,
@PCTechnologyEffects,
@POCRAskedQuestions,
@POCRComments,
@POCRContributed,
@POCRInterested,
@POCRNotInterested,
@POCRWantedInformation,
@ProgramFK,
@PSCComments,
@PSCEmergingIssues,
@PSCInitialDiscussion,
@PSCImplement,
@PSCOngoingDiscussion,
@ReferralsComments,
@ReferralsFollowUp,
@ReferralsMade,
@ReviewAssessmentIssues,
@RSATP,
@RSATPComments,
@RSSATP,
@RSSATPComments,
@RSFFF,
@RSFFFComments,
@RSEW,
@RSEWComments,
@RSNormalizing,
@RSNormalizingComments,
@RSSFT,
@RSSFTComments,
@SiblingParticipated,
@SiblingsObservation,
@SSCalendar,
@SSChildCare,
@SSChildWelfareServices,
@SSComments,
@SSEducation,
@SSEmployment,
@SSHomeEnvironment,
@SSHousekeeping,
@SSJob,
@SSMoneyManagement,
@SSOther,
@SSProblemSolving,
@SSSpecify,
@SSTransportation,
@STASQ,
@STASQSE,
@STComments,
@STPHQ9,
@STPSI,
@STOther,
@SupervisorObservation,
@TCAlwaysOnBack,
@TCAlwaysWithoutSharing,
@TCParticipated,
@TotalPercentageSpent,
@TPComments,
@TPDateInitiated,
@TPInitiated,
@TPNotApplicable,
@TPOngoingDiscussion,
@TPParentDeclined,
@TPPlanFinalized,
@TPTransitionCompleted,
@UpcomingProgramEvents,
@VisitLengthHour,
@VisitLengthMinute,
@VisitLocation,
@VisitStartTime,
@VisitType,
@VisitTypeComments,
@CHEERSCuesFrequency,
@CHEERSHoldingFrequency,
@CHEERSExpressionFrequency,
@CHEERSEmpathyFrequency,
@CHEERSRhythmReciprocityFrequency,
@CHEERSSmilesFrequency
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
