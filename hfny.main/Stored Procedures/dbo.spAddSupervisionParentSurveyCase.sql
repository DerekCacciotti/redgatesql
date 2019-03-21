SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddSupervisionParentSurveyCase](@AssessmentIssues bit=NULL,
@AssessmentIssuesComments varchar(max)=NULL,
@AssessmentIssuesStatus bit=NULL,
@CaseComments varchar(max)=NULL,
@FollowUpPSCase bit=NULL,
@HVCaseFK int=NULL,
@InDepthDiscussion bit=NULL,
@ProgramFK int=NULL,
@ProtectiveFactors bit=NULL,
@ProtectiveFactorsComments varchar(max)=NULL,
@ProtectiveFactorsStatus bit=NULL,
@PSServicePlan bit=NULL,
@PSServicePlanComments varchar(max)=NULL,
@PSServicePlanStatus bit=NULL,
@Referrals bit=NULL,
@ReferralsComments varchar(max)=NULL,
@ReferralsStatus bit=NULL,
@RiskFactors bit=NULL,
@RiskFactorsComments varchar(max)=NULL,
@RiskFactorsStatus bit=NULL,
@SupervisionFK int=NULL,
@SupervisionParentSurveyCaseCreator varchar(max)=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) SupervisionParentSurveyCasePK
FROM SupervisionParentSurveyCase lastRow
WHERE 
@AssessmentIssues = lastRow.AssessmentIssues AND
@AssessmentIssuesComments = lastRow.AssessmentIssuesComments AND
@AssessmentIssuesStatus = lastRow.AssessmentIssuesStatus AND
@CaseComments = lastRow.CaseComments AND
@FollowUpPSCase = lastRow.FollowUpPSCase AND
@HVCaseFK = lastRow.HVCaseFK AND
@InDepthDiscussion = lastRow.InDepthDiscussion AND
@ProgramFK = lastRow.ProgramFK AND
@ProtectiveFactors = lastRow.ProtectiveFactors AND
@ProtectiveFactorsComments = lastRow.ProtectiveFactorsComments AND
@ProtectiveFactorsStatus = lastRow.ProtectiveFactorsStatus AND
@PSServicePlan = lastRow.PSServicePlan AND
@PSServicePlanComments = lastRow.PSServicePlanComments AND
@PSServicePlanStatus = lastRow.PSServicePlanStatus AND
@Referrals = lastRow.Referrals AND
@ReferralsComments = lastRow.ReferralsComments AND
@ReferralsStatus = lastRow.ReferralsStatus AND
@RiskFactors = lastRow.RiskFactors AND
@RiskFactorsComments = lastRow.RiskFactorsComments AND
@RiskFactorsStatus = lastRow.RiskFactorsStatus AND
@SupervisionFK = lastRow.SupervisionFK AND
@SupervisionParentSurveyCaseCreator = lastRow.SupervisionParentSurveyCaseCreator
ORDER BY SupervisionParentSurveyCasePK DESC) 
BEGIN
INSERT INTO SupervisionParentSurveyCase(
AssessmentIssues,
AssessmentIssuesComments,
AssessmentIssuesStatus,
CaseComments,
FollowUpPSCase,
HVCaseFK,
InDepthDiscussion,
ProgramFK,
ProtectiveFactors,
ProtectiveFactorsComments,
ProtectiveFactorsStatus,
PSServicePlan,
PSServicePlanComments,
PSServicePlanStatus,
Referrals,
ReferralsComments,
ReferralsStatus,
RiskFactors,
RiskFactorsComments,
RiskFactorsStatus,
SupervisionFK,
SupervisionParentSurveyCaseCreator
)
VALUES(
@AssessmentIssues,
@AssessmentIssuesComments,
@AssessmentIssuesStatus,
@CaseComments,
@FollowUpPSCase,
@HVCaseFK,
@InDepthDiscussion,
@ProgramFK,
@ProtectiveFactors,
@ProtectiveFactorsComments,
@ProtectiveFactorsStatus,
@PSServicePlan,
@PSServicePlanComments,
@PSServicePlanStatus,
@Referrals,
@ReferralsComments,
@ReferralsStatus,
@RiskFactors,
@RiskFactorsComments,
@RiskFactorsStatus,
@SupervisionFK,
@SupervisionParentSurveyCaseCreator
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
