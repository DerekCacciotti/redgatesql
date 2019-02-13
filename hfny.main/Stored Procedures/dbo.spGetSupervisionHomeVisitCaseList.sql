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
		, CaseComments
		, ChallengingIssues
		, ChallengingIssuesComments
		, ChallengingIssuesStatus
		, CHEERSFeedback
		, CHEERSFeedbackComments
		, CHEERSFeedbackStatus
		, FGPProgress
		, FGPProgressComments
		, FGPProgressStatus
		, sc.HVCaseFK
		, HVCPS
		, HVCPSComments
		, HVCPSStatus
		, HVReferrals
		, HVReferralsComments
		, HVReferralsStatus
		, LevelChange
		, LevelChangeComments
		, LevelChangeStatus
		, Medical
		, MedicalComments
		, MedicalStatus
		, cp.PC1ID
		, sc.ProgramFK
		, ServicePlan
		, ServicePlanComments
		, ServicePlanStatus
		, SupervisionFK
		, Tools
		, ToolsComments
		, ToolsStatus
		, TransitionPlanning
		, TransitionPlanningComments
		, TransitionPlanningStatus
	from	SupervisionHomeVisitCase sc
	inner join CaseProgram cp on cp.HVCaseFK = sc.HVCaseFK
	where	sc.SupervisionFK = @SupervisionFK and 
			cp.CaseProgramPK = (select top 1 cp.CaseProgramPK
								from CaseProgram cp 
								where cp.HVCaseFK = sc.HVCaseFK
										and cp.ProgramFK = sc.ProgramFK
								order by cp.CaseProgramCreateDate desc)
	order by cp.PC1ID
end ;
GO
