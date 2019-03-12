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
@VisitTypeComments varchar(max)=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) HVLogPK
FROM HVLog lastRow
WHERE 
@AdditionalComments = lastRow.AdditionalComments AND
@CAAdvocacy = lastRow.CAAdvocacy AND
@CAChildSupport = lastRow.CAChildSupport AND
@CAComments = lastRow.CAComments AND
@CAGoods = lastRow.CAGoods AND
@CAHousing = lastRow.CAHousing AND
@CALaborSupport = lastRow.CALaborSupport AND
@CALegal = lastRow.CALegal AND
@CAOther = lastRow.CAOther AND
@CAParentRights = lastRow.CAParentRights AND
@CASpecify = lastRow.CASpecify AND
@CATranslation = lastRow.CATranslation AND
@CATransportation = lastRow.CATransportation AND
@CAVisitation = lastRow.CAVisitation AND
@CDChildDevelopment = lastRow.CDChildDevelopment AND
@CDComments = lastRow.CDComments AND
@CDFollowUpEIServices = lastRow.CDFollowUpEIServices AND
@CDOther = lastRow.CDOther AND
@CDParentConcerned = lastRow.CDParentConcerned AND
@CDSocialEmotionalDevelopment = lastRow.CDSocialEmotionalDevelopment AND
@CDSpecify = lastRow.CDSpecify AND
@CDToys = lastRow.CDToys AND
@CHEERSCues = lastRow.CHEERSCues AND
@CHEERSHolding = lastRow.CHEERSHolding AND
@CHEERSExpression = lastRow.CHEERSExpression AND
@CHEERSEmpathy = lastRow.CHEERSEmpathy AND
@CHEERSRhythmReciprocity = lastRow.CHEERSRhythmReciprocity AND
@CHEERSSmiles = lastRow.CHEERSSmiles AND
@CHEERSOverallStrengths = lastRow.CHEERSOverallStrengths AND
@CHEERSAreasToFocus = lastRow.CHEERSAreasToFocus AND
@CIComments = lastRow.CIComments AND
@CIProblems = lastRow.CIProblems AND
@CIOther = lastRow.CIOther AND
@CIOtherSpecify = lastRow.CIOtherSpecify AND
@Curriculum247Dads = lastRow.Curriculum247Dads AND
@CurriculumBoyz2Dads = lastRow.CurriculumBoyz2Dads AND
@CurriculumComments = lastRow.CurriculumComments AND
@CurriculumGreatBeginnings = lastRow.CurriculumGreatBeginnings AND
@CurriculumGrowingGreatKids = lastRow.CurriculumGrowingGreatKids AND
@CurriculumHelpingBabiesLearn = lastRow.CurriculumHelpingBabiesLearn AND
@CurriculumInsideOutDads = lastRow.CurriculumInsideOutDads AND
@CurriculumMomGateway = lastRow.CurriculumMomGateway AND
@CurriculumOtherSupplementalInformation = lastRow.CurriculumOtherSupplementalInformation AND
@CurriculumOtherSupplementalInformationComments = lastRow.CurriculumOtherSupplementalInformationComments AND
@CurriculumOther = lastRow.CurriculumOther AND
@CurriculumOtherSpecify = lastRow.CurriculumOtherSpecify AND
@CurriculumParentsForLearning = lastRow.CurriculumParentsForLearning AND
@CurriculumPartnersHealthyBaby = lastRow.CurriculumPartnersHealthyBaby AND
@CurriculumPAT = lastRow.CurriculumPAT AND
@CurriculumPATFocusFathers = lastRow.CurriculumPATFocusFathers AND
@CurriculumSanAngelo = lastRow.CurriculumSanAngelo AND
@FamilyMemberReads = lastRow.FamilyMemberReads AND
@FatherAdvocateFK = lastRow.FatherAdvocateFK AND
@FatherAdvocateParticipated = lastRow.FatherAdvocateParticipated AND
@FatherFigureParticipated = lastRow.FatherFigureParticipated AND
@FFChildProtectiveIssues = lastRow.FFChildProtectiveIssues AND
@FFComments = lastRow.FFComments AND
@FFCommunication = lastRow.FFCommunication AND
@FFDevelopmentalDisabilities = lastRow.FFDevelopmentalDisabilities AND
@FFDomesticViolence = lastRow.FFDomesticViolence AND
@FFFamilyRelations = lastRow.FFFamilyRelations AND
@FFImmigration = lastRow.FFImmigration AND
@FFMentalHealth = lastRow.FFMentalHealth AND
@FFOther = lastRow.FFOther AND
@FFSpecify = lastRow.FFSpecify AND
@FFSubstanceAbuse = lastRow.FFSubstanceAbuse AND
@FGPComments = lastRow.FGPComments AND
@FGPDevelopActivities = lastRow.FGPDevelopActivities AND
@FGPDiscuss = lastRow.FGPDiscuss AND
@FGPGoalsCompleted = lastRow.FGPGoalsCompleted AND
@FGPNewGoal = lastRow.FGPNewGoal AND
@FGPNoDiscussion = lastRow.FGPNoDiscussion AND
@FGPProgress = lastRow.FGPProgress AND
@FGPRevisions = lastRow.FGPRevisions AND
@FormComplete = lastRow.FormComplete AND
@FSWFK = lastRow.FSWFK AND
@GrandParentParticipated = lastRow.GrandParentParticipated AND
@HCBreastFeeding = lastRow.HCBreastFeeding AND
@HCChild = lastRow.HCChild AND
@HCComments = lastRow.HCComments AND
@HCDental = lastRow.HCDental AND
@HCFamilyPlanning = lastRow.HCFamilyPlanning AND
@HCFASD = lastRow.HCFASD AND
@HCFeeding = lastRow.HCFeeding AND
@HCGeneral = lastRow.HCGeneral AND
@HCLaborDelivery = lastRow.HCLaborDelivery AND
@HCMedicalAdvocacy = lastRow.HCMedicalAdvocacy AND
@HCNutrition = lastRow.HCNutrition AND
@HCOther = lastRow.HCOther AND
@HCPrenatalCare = lastRow.HCPrenatalCare AND
@HCProviders = lastRow.HCProviders AND
@HCSafety = lastRow.HCSafety AND
@HCSexEducation = lastRow.HCSexEducation AND
@HCSIDS = lastRow.HCSIDS AND
@HCSmoking = lastRow.HCSmoking AND
@HCSpecify = lastRow.HCSpecify AND
@HealthPC1AppearsHealthy = lastRow.HealthPC1AppearsHealthy AND
@HealthPC1Asleep = lastRow.HealthPC1Asleep AND
@HealthPC1CommentsGeneral = lastRow.HealthPC1CommentsGeneral AND
@HealthPC1CommentsMedical = lastRow.HealthPC1CommentsMedical AND
@HealthPC1ERVisits = lastRow.HealthPC1ERVisits AND
@HealthPC1HealthConcern = lastRow.HealthPC1HealthConcern AND
@HealthPC1MedicalPrenatalAppointments = lastRow.HealthPC1MedicalPrenatalAppointments AND
@HealthPC1PhysicalNeedsAppearUnmet = lastRow.HealthPC1PhysicalNeedsAppearUnmet AND
@HealthPC1TiredIrritable = lastRow.HealthPC1TiredIrritable AND
@HealthPC1WithdrawnUnresponsive = lastRow.HealthPC1WithdrawnUnresponsive AND
@HealthTCAppearsHealthy = lastRow.HealthTCAppearsHealthy AND
@HealthTCAsleep = lastRow.HealthTCAsleep AND
@HealthTCCommentsGeneral = lastRow.HealthTCCommentsGeneral AND
@HealthTCCommentsMedical = lastRow.HealthTCCommentsMedical AND
@HealthTCERVisits = lastRow.HealthTCERVisits AND
@HealthTCHealthConcern = lastRow.HealthTCHealthConcern AND
@HealthTCImmunizations = lastRow.HealthTCImmunizations AND
@HealthTCMedicalWellBabyAppointments = lastRow.HealthTCMedicalWellBabyAppointments AND
@HealthTCPhysicalNeedsAppearUnmet = lastRow.HealthTCPhysicalNeedsAppearUnmet AND
@HealthTCTiredIrritable = lastRow.HealthTCTiredIrritable AND
@HealthTCWithdrawnUnresponsive = lastRow.HealthTCWithdrawnUnresponsive AND
@HouseholdChangesComments = lastRow.HouseholdChangesComments AND
@HouseholdChangesLeft = lastRow.HouseholdChangesLeft AND
@HouseholdChangesNew = lastRow.HouseholdChangesNew AND
@HVCaseFK = lastRow.HVCaseFK AND
@HVLogCreator = lastRow.HVLogCreator AND
@HVSupervisorParticipated = lastRow.HVSupervisorParticipated AND
@NextScheduledVisit = lastRow.NextScheduledVisit AND
@NextVisitNotes = lastRow.NextVisitNotes AND
@NonPrimaryFSWParticipated = lastRow.NonPrimaryFSWParticipated AND
@NonPrimaryFSWFK = lastRow.NonPrimaryFSWFK AND
@OBPParticipated = lastRow.OBPParticipated AND
@OtherLocationSpecify = lastRow.OtherLocationSpecify AND
@OtherParticipated = lastRow.OtherParticipated AND
@PAAssessmentIssues = lastRow.PAAssessmentIssues AND
@PAComments = lastRow.PAComments AND
@PAForms = lastRow.PAForms AND
@PAGroups = lastRow.PAGroups AND
@PAIFSP = lastRow.PAIFSP AND
@PAIntroduceProgram = lastRow.PAIntroduceProgram AND
@PALevelChange = lastRow.PALevelChange AND
@PAOther = lastRow.PAOther AND
@PARecreation = lastRow.PARecreation AND
@PASpecify = lastRow.PASpecify AND
@PAVideo = lastRow.PAVideo AND
@ParentCompletedActivity = lastRow.ParentCompletedActivity AND
@ParentObservationsDiscussed = lastRow.ParentObservationsDiscussed AND
@ParticipatedSpecify = lastRow.ParticipatedSpecify AND
@PC1Participated = lastRow.PC1Participated AND
@PC2Participated = lastRow.PC2Participated AND
@PCBasicNeeds = lastRow.PCBasicNeeds AND
@PCChildInteraction = lastRow.PCChildInteraction AND
@PCChildManagement = lastRow.PCChildManagement AND
@PCComments = lastRow.PCComments AND
@PCFeelings = lastRow.PCFeelings AND
@PCOther = lastRow.PCOther AND
@PCShakenBaby = lastRow.PCShakenBaby AND
@PCShakenBabyVideo = lastRow.PCShakenBabyVideo AND
@PCSpecify = lastRow.PCSpecify AND
@PCStress = lastRow.PCStress AND
@PCTechnologyEffects = lastRow.PCTechnologyEffects AND
@POCRAskedQuestions = lastRow.POCRAskedQuestions AND
@POCRComments = lastRow.POCRComments AND
@POCRContributed = lastRow.POCRContributed AND
@POCRInterested = lastRow.POCRInterested AND
@POCRNotInterested = lastRow.POCRNotInterested AND
@POCRWantedInformation = lastRow.POCRWantedInformation AND
@ProgramFK = lastRow.ProgramFK AND
@PSCComments = lastRow.PSCComments AND
@PSCEmergingIssues = lastRow.PSCEmergingIssues AND
@PSCInitialDiscussion = lastRow.PSCInitialDiscussion AND
@PSCImplement = lastRow.PSCImplement AND
@PSCOngoingDiscussion = lastRow.PSCOngoingDiscussion AND
@ReferralsComments = lastRow.ReferralsComments AND
@ReferralsFollowUp = lastRow.ReferralsFollowUp AND
@ReferralsMade = lastRow.ReferralsMade AND
@ReviewAssessmentIssues = lastRow.ReviewAssessmentIssues AND
@RSATP = lastRow.RSATP AND
@RSATPComments = lastRow.RSATPComments AND
@RSSATP = lastRow.RSSATP AND
@RSSATPComments = lastRow.RSSATPComments AND
@RSFFF = lastRow.RSFFF AND
@RSFFFComments = lastRow.RSFFFComments AND
@RSEW = lastRow.RSEW AND
@RSEWComments = lastRow.RSEWComments AND
@RSNormalizing = lastRow.RSNormalizing AND
@RSNormalizingComments = lastRow.RSNormalizingComments AND
@RSSFT = lastRow.RSSFT AND
@RSSFTComments = lastRow.RSSFTComments AND
@SiblingParticipated = lastRow.SiblingParticipated AND
@SiblingsObservation = lastRow.SiblingsObservation AND
@SSCalendar = lastRow.SSCalendar AND
@SSChildCare = lastRow.SSChildCare AND
@SSChildWelfareServices = lastRow.SSChildWelfareServices AND
@SSComments = lastRow.SSComments AND
@SSEducation = lastRow.SSEducation AND
@SSEmployment = lastRow.SSEmployment AND
@SSHomeEnvironment = lastRow.SSHomeEnvironment AND
@SSHousekeeping = lastRow.SSHousekeeping AND
@SSJob = lastRow.SSJob AND
@SSMoneyManagement = lastRow.SSMoneyManagement AND
@SSOther = lastRow.SSOther AND
@SSProblemSolving = lastRow.SSProblemSolving AND
@SSSpecify = lastRow.SSSpecify AND
@SSTransportation = lastRow.SSTransportation AND
@STASQ = lastRow.STASQ AND
@STASQSE = lastRow.STASQSE AND
@STComments = lastRow.STComments AND
@STPHQ9 = lastRow.STPHQ9 AND
@STPSI = lastRow.STPSI AND
@STOther = lastRow.STOther AND
@SupervisorObservation = lastRow.SupervisorObservation AND
@TCAlwaysOnBack = lastRow.TCAlwaysOnBack AND
@TCAlwaysWithoutSharing = lastRow.TCAlwaysWithoutSharing AND
@TCParticipated = lastRow.TCParticipated AND
@TotalPercentageSpent = lastRow.TotalPercentageSpent AND
@TPComments = lastRow.TPComments AND
@TPDateInitiated = lastRow.TPDateInitiated AND
@TPInitiated = lastRow.TPInitiated AND
@TPNotApplicable = lastRow.TPNotApplicable AND
@TPOngoingDiscussion = lastRow.TPOngoingDiscussion AND
@TPParentDeclined = lastRow.TPParentDeclined AND
@TPPlanFinalized = lastRow.TPPlanFinalized AND
@TPTransitionCompleted = lastRow.TPTransitionCompleted AND
@UpcomingProgramEvents = lastRow.UpcomingProgramEvents AND
@VisitLengthHour = lastRow.VisitLengthHour AND
@VisitLengthMinute = lastRow.VisitLengthMinute AND
@VisitLocation = lastRow.VisitLocation AND
@VisitStartTime = lastRow.VisitStartTime AND
@VisitType = lastRow.VisitType AND
@VisitTypeComments = lastRow.VisitTypeComments
ORDER BY HVLogPK DESC) 
BEGIN
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
VisitTypeComments
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
@VisitTypeComments
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
