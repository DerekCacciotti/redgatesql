SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		jayrobot
-- Create date: 10/10/18
-- Description:	This stored procedure gets the list of prior home visit
--				supervision cases for the passed Supervision FK and thier
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
			select	max(SupervisionPK) as SupervisionPK
			from	Supervision s
			where	s.WorkerFK = @WorkerFK
					and s.SupervisionDate < @SupervisionDate
		)
	select s.SupervisionPK
				, s.ProgramFK
				, s.WorkerFK
				, shvc.ActivitiesOtherStatus
				, shvc.CHEERSFeedbackComments
				, shvc.CHEERSFeedbackStatus
				, shvc.CaseComments
				, shvc.ChallengingIssuesComments
				, shvc.ChallengingIssuesStatus
				, shvc.ConcernsComments
				, shvc.ConcernsStatus
				, shvc.CurriculumComments
				, shvc.CurriculumStatus
				, shvc.FGPProgressComments
				, shvc.FGPProgressStatus
				, shvc.FamilyGrievanceComments
				, shvc.FamilyGrievanceStatus
				, shvc.FollowUpHVCase
				, shvc.FollowUpHVCase
				, shvc.HVCaseFK
				, shvc.HVCulturalSensitivityComments
				, shvc.HVCulturalSensitivityStatus
				, shvc.HVHomeVisitRateComments
				, shvc.HVHomeVisitRateStatus
				, shvc.HVReferralSourcesComments
				, shvc.HVReferralSourcesStatus
				, shvc.LevelChangeComments
				, shvc.LevelChangeStatus
				, shvc.MedicalComments
				, shvc.MedicalStatus
				, shvc.ProgramFK
				, shvc.SuccessesComments
				, shvc.SuccessesStatus
				, shvc.SupervisionFK
				, shvc.ToolsComments
				, shvc.ToolsStatus
				, shvc.TransitionPlanningComments
				, shvc.TransitionPlanningStatus
				, PC1ID
	from Supervision s
	inner join cteLastSupervision ls on s.SupervisionPK = ls.SupervisionPK
	inner join SupervisionHomeVisitCase shvc on shvc.SupervisionFK = s.SupervisionPK
	left outer join CaseProgram cp on cp.HVCaseFK = shvc.HVCaseFK ;

end

GO
