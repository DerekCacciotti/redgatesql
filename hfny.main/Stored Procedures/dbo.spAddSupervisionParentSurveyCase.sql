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
INSERT INTO SupervisionParentSurveyCase(
AssessmentIssues,
AssessmentIssuesComments,
AssessmentIssuesStatus,
CaseComments,
FollowUpPSCase,
HVCaseFK,
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

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
