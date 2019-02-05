SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		jayrobot
-- Create date: 10/10/18
-- Description:	This stored procedure gets the list of prior 
--				supervision variables' follow-up status
-- =============================================
CREATE procedure [dbo].[spGetPriorSupervisionInfo]
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
					and s.SupervisionSessionType = '1'
		)
	select			s.SupervisionPK
				, s.BoundariesComments
				, s.BoundariesStatus
				, s.CaseloadComments
				, s.CaseloadStatus
				, s.CoachingComments
				, s.CoachingStatus
				, s.CPSComments
				, s.CPSStatus
				, s.CurriculumComments
				, s.CurriculumStatus
				, s.FamilyReviewComments
				, s.FamilyReviewStatus
				, s.ImpactOfWorkComments
				, s.ImpactOfWorkStatus
				, s.ImplementTrainingComments
				, s.ImplementTrainingStatus
				, s.OutreachComments
				, s.OutreachStatus
				, s.PersonnelComments
				, s.PersonnelStatus
				, s.PIPComments
				, s.PIPStatus
				, s.ProfessionalGrowthComments
				, s.ProfessionalGrowthStatus
				, s.ProgramFK
				, s.RecordDocumentationComments
				, s.RecordDocumentationStatus
				, s.RetentionComments
				, s.RetentionStatus
				, s.RolePlayingComments
				, s.RolePlayingStatus
				, s.SafetyComments
				, s.SafetyStatus
				, s.SiteDocumentationComments
				, s.SiteDocumentationStatus
				, s.StrengthsComments
				, s.StrengthsStatus
				, s.SupervisionCreateDate
				, s.SupervisionCreator
				, s.SupervisionDate
				, s.SupervisionEditDate
				, s.SupervisionEditor
				, s.SupervisionEndTime
				, s.SupervisionHours
				, s.SupervisionMinutes
				, s.SupervisionNotes
				, s.SupervisionSessionType
				, s.SupervisionStartTime
				, s.SupervisorFK
				, s.SupervisorObservationAssessmentComments
				, s.SupervisorObservationAssessmentStatus
				, s.SupervisorObservationHomeVisitComments
				, s.SupervisorObservationHomeVisitStatus
				, s.SupervisorObservationSupervisionComments
				, s.SupervisorObservationSupervisionStatus
				, s.SupportHFAModelComments
				, s.SupportHFAModelStatus
				, s.TeamDevelopmentComments
				, s.TeamDevelopmentStatus
				, s.WorkerFK
				, s.WorkplaceEnvironment
				, s.WorkplaceEnvironmentComments
				, s.WorkplaceEnvironmentStatus
	from			Supervision s
	inner join		cteLastSupervision ls on s.SupervisionDate = ls.SupervisionDate
	where s.WorkerFK = @WorkerFK

end

GO
