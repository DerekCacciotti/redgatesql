SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditSupervisionParentSurveyCase](@SupervisionParentSurveyCasePK int=NULL,
@AssessmentIssues bit=NULL,
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
@SupervisionParentSurveyCaseEditor varchar(max)=NULL)
AS
UPDATE SupervisionParentSurveyCase
SET 
AssessmentIssues = @AssessmentIssues, 
AssessmentIssuesComments = @AssessmentIssuesComments, 
AssessmentIssuesStatus = @AssessmentIssuesStatus, 
CaseComments = @CaseComments, 
FollowUpPSCase = @FollowUpPSCase, 
HVCaseFK = @HVCaseFK, 
InDepthDiscussion = @InDepthDiscussion, 
ProgramFK = @ProgramFK, 
ProtectiveFactors = @ProtectiveFactors, 
ProtectiveFactorsComments = @ProtectiveFactorsComments, 
ProtectiveFactorsStatus = @ProtectiveFactorsStatus, 
PSServicePlan = @PSServicePlan, 
PSServicePlanComments = @PSServicePlanComments, 
PSServicePlanStatus = @PSServicePlanStatus, 
Referrals = @Referrals, 
ReferralsComments = @ReferralsComments, 
ReferralsStatus = @ReferralsStatus, 
RiskFactors = @RiskFactors, 
RiskFactorsComments = @RiskFactorsComments, 
RiskFactorsStatus = @RiskFactorsStatus, 
SupervisionFK = @SupervisionFK, 
SupervisionParentSurveyCaseEditor = @SupervisionParentSurveyCaseEditor
WHERE SupervisionParentSurveyCasePK = @SupervisionParentSurveyCasePK
GO
