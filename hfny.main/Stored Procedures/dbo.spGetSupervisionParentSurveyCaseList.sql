SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		jayrobot
-- Create date: 10/10/18
-- Description:	This stored procedure gets the list of parent survey 
--				supervision cases for the passed Supervision FK
-- =============================================
CREATE procedure [dbo].[spGetSupervisionParentSurveyCaseList] (@SupervisionFK int)
as begin
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	set noCount on ;

	select	SupervisionParentSurveyCasePK
		, AssessmentIssues
		, AssessmentIssuesComments
		, AssessmentIssuesStatus
		, CaseComments
		, sc.HVCaseFK
		, InDepthDiscussion
		, cp.PC1ID
		, sc.ProgramFK
		, ProtectiveFactors
		, ProtectiveFactorsComments
		, ProtectiveFactorsStatus
		, Referrals
		, ReferralsComments
		, ReferralsStatus
		, RiskFactors
		, RiskFactorsComments
		, RiskFactorsStatus
		, SupervisionFK
	from	SupervisionParentSurveyCase sc
	inner join CaseProgram cp on cp.HVCaseFK = sc.HVCaseFK
	where	sc.SupervisionFK = @SupervisionFK and
			cp.CaseProgramPK = (select top 1 cp.CaseProgramPK
								from CaseProgram cp 
								where cp.HVCaseFK = sc.HVCaseFK
										and cp.ProgramFK = sc.ProgramFK
								order by cp.CaseProgramCreateDate desc)
	order by upper(cp.PC1ID)
end ;
GO
