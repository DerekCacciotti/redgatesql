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
CREATE procedure [dbo].[spGetPriorSupervision] 
	(
		@SupervisionPK int, 
		@WorkerFK int, 
		@SupervisorFK int
	) 
as
begin
	with cteLastSupervision
		as (
			select	max(SupervisionPK) as SupervisionPK
			from	Supervision s
			where	s.WorkerFK = @WorkerFK
					and SupervisionPK < @SupervisionPK
		)
	select			s.SupervisionPK
				, s.AreasGrowthStatus
				, s.AssessmentRateStatus
				, s.BoundariesStatus
				, s.CaseloadStatus
				, s.CoachingStatus
				, s.CPSStatus
				, s.FamilyProgressStatus
				, s.HomeVisitLogActivitiesStatus
				, s.HomeVisitRateStatus
				, s.IFSPStatus
				, s.ImpactOfWorkStatus
				, s.ImplementTrainingStatus
				, s.OutreachStatus
				, s.PersonalGrowthStatus
				, s.PersonnelStatus
				, s.PIPStatus
				, s.ProfessionalGrowthStatus
				, s.ProgramFK
				, s.RecordDocumentationStatus
				, s.RetentionStatus
				, s.RolePlayingStatus
				, s.SafetyStatus
				, s.SiteDocumentationStatus
				, s.ShadowStatus
				, s.StrengthBasedApproachStatus
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
				, s.SupervisorObservationAssessmentStatus
				, s.SupervisorObservationHomeVisitStatus
				, s.TakePlace
				, s.TeamDevelopmentStatus
				, s.TechniquesApproachesStatus
				, s.TrainingNeedsStatus
				, s.WorkerFK
				, s.ParticipantEmergency
				, s.ReasonOther
				, s.ReasonOtherSpecify
				, s.ShortWeek
				, s.StaffCourt
				, s.StaffFamilyEmergency
				, s.StaffForgot
				, s.StaffIll
				, s.StaffOnLeave
				, s.StaffTraining
				, s.StaffVacation
				, s.StaffOutAllWeek
				, s.SupervisorFamilyEmergency
				, s.SupervisorForgot
				, s.SupervisorHoliday
				, s.SupervisorIll
				, s.SupervisorTraining
				, s.SupervisorVacation
				, s.Weather
				, shvc.ActivitiesOtherStatus
				, shvc.CaseComments
				, shvc.ChallengingIssuesStatus
				, shvc.CHEERSFeedbackStatus
				, shvc.ConcernsStatus
				, shvc.CurriculumStatus
				, shvc.FamilyGrievanceStatus
				, shvc.FGPProgressStatus
				, shvc.FollowUpHVCase
				, shvc.HVCaseFK
				, shvc.HVCulturalSensitivityStatus
				, shvc.HVHomeVisitRateStatus
				, shvc.HVReferralSourcesStatus
				, shvc.LevelChangeStatus
				, shvc.MedicalStatus
				, shvc.ProgramFK
				, shvc.SuccessesStatus
				, shvc.SupervisionFK
				, shvc.ToolsStatus
				, shvc.TransitionPlanningStatus
				, cphv.PC1ID as HVPC1ID
				, spsc.AssessmentIssuesStatus
				, spsc.AssessmentScreensStatus
				, spsc.CaseComments
				, spsc.CommunityResourcesStatus
				, spsc.CulturalSensitivityStatus
				, spsc.HVCaseFK
				, spsc.InterRaterReliabilityStatus
				, spsc.ProgramFK
				, spsc.ProtectiveFactorsStatus
				, spsc.ReferralsStatus
				, spsc.ReflectionStatus
				, spsc.RiskFactorsStatus
				, spsc.TrackingDataStatus
				, cpps.PC1ID as PSPC1ID
	from			Supervision s
	inner join		cteLastSupervision ls on s.SupervisionPK = ls.SupervisionPK
	left outer join SupervisionHomeVisitCase shvc on shvc.SupervisionFK = s.SupervisionPK
	left outer join CaseProgram cphv on cphv.HVCaseFK = shvc.HVCaseFK
	left outer join SupervisionParentSurveyCase spsc on spsc.SupervisionFK = s.SupervisionPK
	left outer join CaseProgram cpps on cpps.HVCaseFK = spsc.HVCaseFK ;
end
GO
