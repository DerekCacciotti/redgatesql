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
IF NOT EXISTS (SELECT TOP(1) SupervisionHomeVisitCaseDeletedPK
FROM SupervisionHomeVisitCaseDeleted lastRow
WHERE 
@SupervisionHomeVisitCasePK = lastRow.SupervisionHomeVisitCasePK AND
@CaseComments = lastRow.CaseComments AND
@ChallengingIssues = lastRow.ChallengingIssues AND
@ChallengingIssuesComments = lastRow.ChallengingIssuesComments AND
@ChallengingIssuesStatus = lastRow.ChallengingIssuesStatus AND
@CHEERSFeedback = lastRow.CHEERSFeedback AND
@CHEERSFeedbackComments = lastRow.CHEERSFeedbackComments AND
@CHEERSFeedbackStatus = lastRow.CHEERSFeedbackStatus AND
@FGPProgress = lastRow.FGPProgress AND
@FGPProgressComments = lastRow.FGPProgressComments AND
@FGPProgressStatus = lastRow.FGPProgressStatus AND
@FollowUpHVCase = lastRow.FollowUpHVCase AND
@HVCaseFK = lastRow.HVCaseFK AND
@HVCPS = lastRow.HVCPS AND
@HVCPSComments = lastRow.HVCPSComments AND
@HVCPSStatus = lastRow.HVCPSStatus AND
@HVReferrals = lastRow.HVReferrals AND
@HVReferralsComments = lastRow.HVReferralsComments AND
@HVReferralsStatus = lastRow.HVReferralsStatus AND
@LevelChange = lastRow.LevelChange AND
@LevelChangeComments = lastRow.LevelChangeComments AND
@LevelChangeStatus = lastRow.LevelChangeStatus AND
@Medical = lastRow.Medical AND
@MedicalComments = lastRow.MedicalComments AND
@MedicalStatus = lastRow.MedicalStatus AND
@ProgramFK = lastRow.ProgramFK AND
@ServicePlan = lastRow.ServicePlan AND
@ServicePlanComments = lastRow.ServicePlanComments AND
@ServicePlanStatus = lastRow.ServicePlanStatus AND
@SupervisionFK = lastRow.SupervisionFK AND
@SupervisionHomeVisitCaseCreator = lastRow.SupervisionHomeVisitCaseCreator AND
@Tools = lastRow.Tools AND
@ToolsComments = lastRow.ToolsComments AND
@ToolsStatus = lastRow.ToolsStatus AND
@TransitionPlanning = lastRow.TransitionPlanning AND
@TransitionPlanningComments = lastRow.TransitionPlanningComments AND
@TransitionPlanningStatus = lastRow.TransitionPlanningStatus AND
@SupervisionHomeVisitCaseDeleteDate = lastRow.SupervisionHomeVisitCaseDeleteDate AND
@SupervisionHomeVisitCaseDeleter = lastRow.SupervisionHomeVisitCaseDeleter
ORDER BY SupervisionHomeVisitCaseDeletedPK DESC) 
BEGIN
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

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
