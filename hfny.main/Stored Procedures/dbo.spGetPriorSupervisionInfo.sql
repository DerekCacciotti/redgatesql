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
			select	max(SupervisionPK) as SupervisionPK
			from	Supervision s
			where	s.WorkerFK = @WorkerFK
					and s.SupervisionDate < @SupervisionDate
					and s.TakePlace = 1
		)
	select			s.SupervisionPK
				, s.AreasGrowthComments
				, s.AreasGrowthStatus
				, s.BoundariesComments
				, s.BoundariesStatus
				, s.CPSComments
				, s.CPSStatus
				, s.CaseloadComments
				, s.CaseloadStatus
				, s.CoachingComments
				, s.CoachingStatus
				, s.FamilyProgressComments
				, s.FamilyProgressStatus
				, s.HomeVisitLogActivitiesComments
				, s.HomeVisitLogActivitiesStatus
				, s.HomeVisitRateComments
				, s.HomeVisitRateStatus
				, s.IFSPComments
				, s.IFSPStatus
				, s.ImpactOfWorkComments
				, s.ImpactOfWorkStatus
				, s.ImplementTrainingComments
				, s.ImplementTrainingStatus
				, s.OutreachComments
				, s.OutreachStatus
				, s.PIPComments
				, s.PIPStatus
				, s.PersonalGrowthComments
				, s.PersonalGrowthStatus
				, s.PersonnelComments
				, s.PersonnelStatus
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
				, s.ShadowComments
				, s.ShadowStatus
				, s.SiteDocumentationComments
				, s.SiteDocumentationStatus
				, s.StrengthBasedApproachComments
				, s.StrengthBasedApproachStatus
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
				, s.SupervisionStartTime
				, s.SupervisorFK
				, s.SupervisorObservationAssessmentComments
				, s.SupervisorObservationAssessmentStatus
				, s.SupervisorObservationHomeVisitComments
				, s.SupervisorObservationHomeVisitStatus
				, s.TakePlace
				, s.TeamDevelopmentComments
				, s.TeamDevelopmentStatus
				, s.TechniquesApproachesComments
				, s.TechniquesApproachesStatus
				, s.TrainingNeedsComments
				, s.TrainingNeedsStatus
				, s.WorkerFK
	from			Supervision s
	inner join		cteLastSupervision ls on s.SupervisionPK = ls.SupervisionPK

end

GO
