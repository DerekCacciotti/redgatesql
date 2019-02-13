SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditSupervisionParentSurveyCaseDeleted](@SupervisionParentSurveyCaseDeletedPK int=NULL,
@SupervisionParentSurveyCasePK int=NULL,
@AssessmentIssues bit=NULL,
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
@SupervisionParentSurveyCaseEditor char(10)=NULL,
@SupervisionParentSurveyCaseDeleteDate datetime=NULL,
@SupervisionParentSurveyCaseDeleter char(10)=NULL)
AS
UPDATE SupervisionParentSurveyCaseDeleted
SET 
SupervisionParentSurveyCasePK = @SupervisionParentSurveyCasePK, 
AssessmentIssues = @AssessmentIssues, 
AssessmentIssuesComments = @AssessmentIssuesComments, 
AssessmentIssuesStatus = @AssessmentIssuesStatus, 
CaseComments = @CaseComments, 
FollowUpPSCase = @FollowUpPSCase, 
HVCaseFK = @HVCaseFK, 
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
SupervisionParentSurveyCaseEditor = @SupervisionParentSurveyCaseEditor, 
SupervisionParentSurveyCaseDeleteDate = @SupervisionParentSurveyCaseDeleteDate, 
SupervisionParentSurveyCaseDeleter = @SupervisionParentSurveyCaseDeleter
WHERE SupervisionParentSurveyCaseDeletedPK = @SupervisionParentSurveyCaseDeletedPK
GO
