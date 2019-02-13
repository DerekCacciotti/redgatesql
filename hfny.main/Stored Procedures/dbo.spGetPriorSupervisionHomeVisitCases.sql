SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		jayrobot
-- Create date: 10/10/18
-- Description:	This stored procedure gets the list of prior home visit
--				supervision cases for the passed Supervision FK and their
--				follow-up status
-- =============================================
CREATE procedure [dbo].[spGetPriorSupervisionHomeVisitCases]
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
	select s.SupervisionPK
				, s.ProgramFK
				, s.WorkerFK
				, shvc.CaseComments
				, shvc.ChallengingIssuesComments
				, shvc.ChallengingIssuesStatus
				, shvc.CHEERSFeedbackComments
				, shvc.CHEERSFeedbackStatus
				, shvc.FGPProgressComments
				, shvc.FGPProgressStatus
				, shvc.FollowUpHVCase
				, shvc.HVCaseFK
				, shvc.HVCPSComments
				, shvc.HVCPSStatus
				, shvc.HVReferralsComments
				, shvc.HVReferralsStatus
				, shvc.LevelChangeComments
				, shvc.LevelChangeStatus
				, shvc.MedicalComments
				, shvc.MedicalStatus
				, shvc.ProgramFK
				, shvc.ServicePlanComments
				, shvc.ServicePlanStatus
				, shvc.SupervisionFK
				, shvc.ToolsComments
				, shvc.ToolsStatus
				, shvc.TransitionPlanningComments
				, shvc.TransitionPlanningStatus
				, PC1ID
	from Supervision s
	inner join cteLastSupervision ls on ls.SupervisionDate = s.SupervisionDate
	inner join SupervisionHomeVisitCase shvc on shvc.SupervisionFK = s.SupervisionPK
	left outer join CaseProgram cp on cp.HVCaseFK = shvc.HVCaseFK 
	where s.WorkerFK = @WorkerFK;
	
end

GO
