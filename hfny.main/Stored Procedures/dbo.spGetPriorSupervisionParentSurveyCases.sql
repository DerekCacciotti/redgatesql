SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		jayrobot
-- Create date: 10/10/18
-- Description:	This stored procedure gets the list of prior parent survey 
--				supervision cases for the passed Supervision FK and their
--				follow-up status
-- =============================================
CREATE procedure [dbo].[spGetPriorSupervisionParentSurveyCases]
	(
		@WorkerFK int, 
		@SupervisorFK int, 
		@SupervisionDate datetime
	) 
as
begin
	with cteLastSupervision
		as (
			select	max(SupervisionDate) as SupervisionDate
			from	Supervision s
			where	s.WorkerFK = @WorkerFK
					and s.SupervisionDate < @SupervisionDate
					and s.SupervisionSessionType in ('1', '2')
		)
	select 			s.SupervisionPK
				, s.ProgramFK
				, s.WorkerFK
				, spsc.AssessmentIssuesComments
				, spsc.AssessmentIssuesStatus
				, spsc.CaseComments
				, spsc.HVCaseFK
				, spsc.ProgramFK
				, spsc.ProtectiveFactorsComments
				, spsc.ProtectiveFactorsStatus
				, spsc.PSServicePlanComments
				, spsc.PSServicePlanStatus
				, spsc.ReferralsComments
				, spsc.ReferralsStatus
				, spsc.RiskFactorsComments
				, spsc.RiskFactorsStatus
				, PC1ID
	from Supervision s
	inner join cteLastSupervision ls on ls.SupervisionDate = s.SupervisionDate
	inner join SupervisionParentSurveyCase spsc on spsc.SupervisionFK = s.SupervisionPK
	left outer join CaseProgram cp on cp.HVCaseFK = spsc.HVCaseFK 
	where s.WorkerFK = @WorkerFK;

end

GO
