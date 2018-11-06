SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		jayrobot
-- Create date: 09/10/18
-- Description:	This stored procedure gets the list of home visit
--				supervision cases for the passed Supervision FK
-- =============================================
CREATE procedure [dbo].[spGetSupervisionHomeVisitCaseList]
( 
	@SupervisionFK int
)
as begin
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	set noCount on ;

	select	SupervisionHomeVisitCasePK
		, ActivitiesOther
		, ActivitiesOtherSpecify
		, ActivitiesOtherStatus
		, CaseComments
		, ChallengingIssues
		, ChallengingIssuesComments
		, ChallengingIssuesStatus
		, CHEERSFeedback
		, CHEERSFeedbackComments
		, CHEERSFeedbackStatus
		, Concerns
		, ConcernsComments
		, ConcernsStatus
		, Curriculum
		, CurriculumComments
		, CurriculumStatus
		, FamilyGrievance
		, FamilyGrievanceComments
		, FamilyGrievanceStatus
		, FGPProgress
		, FGPProgressComments
		, FGPProgressStatus
		, sc.HVCaseFK
		, HVCulturalSensitivity
		, HVCulturalSensitivityComments
		, HVCulturalSensitivityStatus
		, HVHomeVisitRate
		, HVHomeVisitRateComments
		, HVHomeVisitRateStatus
		, HVReferralSources
		, HVReferralSourcesComments
		, HVReferralSourcesStatus
		, LevelChange
		, LevelChangeComments
		, LevelChangeStatus
		, Medical
		, MedicalComments
		, MedicalStatus
		, cp.PC1ID
		, sc.ProgramFK
		, Successes
		, SuccessesComments
		, SuccessesStatus
		, SupervisionFK
		, Tools
		, ToolsComments
		, ToolsStatus
		, TransitionPlanning
		, TransitionPlanningComments
		, TransitionPlanningStatus
	from	SupervisionHomeVisitCase sc
	inner join CaseProgram cp on cp.HVCaseFK = sc.HVCaseFK
	where	sc.SupervisionFK = @SupervisionFK ;
end ;
GO
