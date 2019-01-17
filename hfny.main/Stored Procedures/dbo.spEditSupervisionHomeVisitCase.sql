SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditSupervisionHomeVisitCase](@SupervisionHomeVisitCasePK int=NULL,
@ActivitiesOther bit=NULL,
@ActivitiesOtherSpecify varchar(500)=NULL,
@ActivitiesOtherStatus bit=NULL,
@CaseComments varchar(max)=NULL,
@ChallengingIssues bit=NULL,
@ChallengingIssuesComments varchar(max)=NULL,
@ChallengingIssuesStatus bit=NULL,
@CHEERSFeedback bit=NULL,
@CHEERSFeedbackComments varchar(max)=NULL,
@CHEERSFeedbackStatus bit=NULL,
@Concerns bit=NULL,
@ConcernsComments varchar(max)=NULL,
@ConcernsStatus bit=NULL,
@Curriculum bit=NULL,
@CurriculumComments varchar(max)=NULL,
@CurriculumStatus bit=NULL,
@FamilyGrievance bit=NULL,
@FamilyGrievanceComments varchar(max)=NULL,
@FamilyGrievanceStatus bit=NULL,
@FGPProgress bit=NULL,
@FGPProgressComments varchar(max)=NULL,
@FGPProgressStatus bit=NULL,
@FollowUpHVCase bit=NULL,
@HVCaseFK int=NULL,
@HVCulturalSensitivity bit=NULL,
@HVCulturalSensitivityComments varchar(max)=NULL,
@HVCulturalSensitivityStatus bit=NULL,
@HVHomeVisitRate bit=NULL,
@HVHomeVisitRateComments varchar(max)=NULL,
@HVHomeVisitRateStatus bit=NULL,
@HVReferralSources bit=NULL,
@HVReferralSourcesComments varchar(max)=NULL,
@HVReferralSourcesStatus bit=NULL,
@LevelChange bit=NULL,
@LevelChangeComments varchar(max)=NULL,
@LevelChangeStatus bit=NULL,
@Medical bit=NULL,
@MedicalComments varchar(max)=NULL,
@MedicalStatus bit=NULL,
@ProgramFK int=NULL,
@Successes bit=NULL,
@SuccessesComments varchar(max)=NULL,
@SuccessesStatus bit=NULL,
@SupervisionFK int=NULL,
@Tools bit=NULL,
@ToolsComments varchar(max)=NULL,
@ToolsStatus bit=NULL,
@TransitionPlanning bit=NULL,
@TransitionPlanningComments varchar(max)=NULL,
@TransitionPlanningStatus bit=NULL)
AS
UPDATE SupervisionHomeVisitCase
SET 
ActivitiesOther = @ActivitiesOther, 
ActivitiesOtherSpecify = @ActivitiesOtherSpecify, 
ActivitiesOtherStatus = @ActivitiesOtherStatus, 
CaseComments = @CaseComments, 
ChallengingIssues = @ChallengingIssues, 
ChallengingIssuesComments = @ChallengingIssuesComments, 
ChallengingIssuesStatus = @ChallengingIssuesStatus, 
CHEERSFeedback = @CHEERSFeedback, 
CHEERSFeedbackComments = @CHEERSFeedbackComments, 
CHEERSFeedbackStatus = @CHEERSFeedbackStatus, 
Concerns = @Concerns, 
ConcernsComments = @ConcernsComments, 
ConcernsStatus = @ConcernsStatus, 
Curriculum = @Curriculum, 
CurriculumComments = @CurriculumComments, 
CurriculumStatus = @CurriculumStatus, 
FamilyGrievance = @FamilyGrievance, 
FamilyGrievanceComments = @FamilyGrievanceComments, 
FamilyGrievanceStatus = @FamilyGrievanceStatus, 
FGPProgress = @FGPProgress, 
FGPProgressComments = @FGPProgressComments, 
FGPProgressStatus = @FGPProgressStatus, 
FollowUpHVCase = @FollowUpHVCase, 
HVCaseFK = @HVCaseFK, 
HVCulturalSensitivity = @HVCulturalSensitivity, 
HVCulturalSensitivityComments = @HVCulturalSensitivityComments, 
HVCulturalSensitivityStatus = @HVCulturalSensitivityStatus, 
HVHomeVisitRate = @HVHomeVisitRate, 
HVHomeVisitRateComments = @HVHomeVisitRateComments, 
HVHomeVisitRateStatus = @HVHomeVisitRateStatus, 
HVReferralSources = @HVReferralSources, 
HVReferralSourcesComments = @HVReferralSourcesComments, 
HVReferralSourcesStatus = @HVReferralSourcesStatus, 
LevelChange = @LevelChange, 
LevelChangeComments = @LevelChangeComments, 
LevelChangeStatus = @LevelChangeStatus, 
Medical = @Medical, 
MedicalComments = @MedicalComments, 
MedicalStatus = @MedicalStatus, 
ProgramFK = @ProgramFK, 
Successes = @Successes, 
SuccessesComments = @SuccessesComments, 
SuccessesStatus = @SuccessesStatus, 
SupervisionFK = @SupervisionFK, 
Tools = @Tools, 
ToolsComments = @ToolsComments, 
ToolsStatus = @ToolsStatus, 
TransitionPlanning = @TransitionPlanning, 
TransitionPlanningComments = @TransitionPlanningComments, 
TransitionPlanningStatus = @TransitionPlanningStatus
WHERE SupervisionHomeVisitCasePK = @SupervisionHomeVisitCasePK
GO