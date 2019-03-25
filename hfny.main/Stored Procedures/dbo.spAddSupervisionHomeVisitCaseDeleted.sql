SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddSupervisionHomeVisitCaseDeleted](@SupervisionHomeVisitCasePK int=NULL,
@CaseComments varchar(max)=NULL,
@ChallengingIssues bit=NULL,
@ChallengingIssuesComments varchar(max)=NULL,
@ChallengingIssuesStatus bit=NULL,
@CHEERSFeedback bit=NULL,
@CHEERSFeedbackComments varchar(max)=NULL,
@CHEERSFeedbackStatus bit=NULL,
@FGPProgress bit=NULL,
@FGPProgressComments varchar(max)=NULL,
@FGPProgressStatus bit=NULL,
@FollowUpHVCase bit=NULL,
@HVCaseFK int=NULL,
@HVCPS bit=NULL,
@HVCPSComments varchar(max)=NULL,
@HVCPSStatus bit=NULL,
@HVReferrals bit=NULL,
@HVReferralsComments varchar(max)=NULL,
@HVReferralsStatus bit=NULL,
@LevelChange bit=NULL,
@LevelChangeComments varchar(max)=NULL,
@LevelChangeStatus bit=NULL,
@Medical bit=NULL,
@MedicalComments varchar(max)=NULL,
@MedicalStatus bit=NULL,
@ProgramFK int=NULL,
@ServicePlan bit=NULL,
@ServicePlanComments varchar(max)=NULL,
@ServicePlanStatus bit=NULL,
@SupervisionFK int=NULL,
@SupervisionHomeVisitCaseCreator varchar(max)=NULL,
@Tools bit=NULL,
@ToolsComments varchar(max)=NULL,
@ToolsStatus bit=NULL,
@TransitionPlanning bit=NULL,
@TransitionPlanningComments varchar(max)=NULL,
@TransitionPlanningStatus bit=NULL,
@SupervisionHomeVisitCaseDeleteDate datetime=NULL,
@SupervisionHomeVisitCaseDeleter varchar(max)=NULL)
AS
INSERT INTO SupervisionHomeVisitCaseDeleted(
SupervisionHomeVisitCasePK,
CaseComments,
ChallengingIssues,
ChallengingIssuesComments,
ChallengingIssuesStatus,
CHEERSFeedback,
CHEERSFeedbackComments,
CHEERSFeedbackStatus,
FGPProgress,
FGPProgressComments,
FGPProgressStatus,
FollowUpHVCase,
HVCaseFK,
HVCPS,
HVCPSComments,
HVCPSStatus,
HVReferrals,
HVReferralsComments,
HVReferralsStatus,
LevelChange,
LevelChangeComments,
LevelChangeStatus,
Medical,
MedicalComments,
MedicalStatus,
ProgramFK,
ServicePlan,
ServicePlanComments,
ServicePlanStatus,
SupervisionFK,
SupervisionHomeVisitCaseCreator,
Tools,
ToolsComments,
ToolsStatus,
TransitionPlanning,
TransitionPlanningComments,
TransitionPlanningStatus,
SupervisionHomeVisitCaseDeleteDate,
SupervisionHomeVisitCaseDeleter
)
VALUES(
@SupervisionHomeVisitCasePK,
@CaseComments,
@ChallengingIssues,
@ChallengingIssuesComments,
@ChallengingIssuesStatus,
@CHEERSFeedback,
@CHEERSFeedbackComments,
@CHEERSFeedbackStatus,
@FGPProgress,
@FGPProgressComments,
@FGPProgressStatus,
@FollowUpHVCase,
@HVCaseFK,
@HVCPS,
@HVCPSComments,
@HVCPSStatus,
@HVReferrals,
@HVReferralsComments,
@HVReferralsStatus,
@LevelChange,
@LevelChangeComments,
@LevelChangeStatus,
@Medical,
@MedicalComments,
@MedicalStatus,
@ProgramFK,
@ServicePlan,
@ServicePlanComments,
@ServicePlanStatus,
@SupervisionFK,
@SupervisionHomeVisitCaseCreator,
@Tools,
@ToolsComments,
@ToolsStatus,
@TransitionPlanning,
@TransitionPlanningComments,
@TransitionPlanningStatus,
@SupervisionHomeVisitCaseDeleteDate,
@SupervisionHomeVisitCaseDeleter
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
