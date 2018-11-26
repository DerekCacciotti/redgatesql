SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		jayrobot
-- Create date: 10/10/18
-- Description:	This stored procedure gets the list of prior parent survey 
--				supervision cases for the passed Supervision FK and thier
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
			select	max(SupervisionPK) as SupervisionPK
			from	Supervision s
			where	s.WorkerFK = @WorkerFK
					and s.SupervisionDate < @SupervisionDate
		)
	select 			s.SupervisionPK
				, s.ProgramFK
				, s.WorkerFK
				, spsc.AssessmentIssuesComments
				, spsc.AssessmentIssuesStatus
				, spsc.AssessmentRateComments
				, spsc.AssessmentRateStatus
				, spsc.AssessmentScreensComments
				, spsc.AssessmentScreensStatus
				, spsc.CaseComments
				, spsc.CommunityResourcesComments
				, spsc.CommunityResourcesStatus
				, spsc.CulturalSensitivityComments
				, spsc.CulturalSensitivityStatus
				, spsc.HVCaseFK
				, spsc.InterRaterReliabilityComments
				, spsc.InterRaterReliabilityStatus
				, spsc.ProgramFK
				, spsc.ProtectiveFactorsComments
				, spsc.ProtectiveFactorsStatus
				, spsc.ReferralsComments
				, spsc.ReferralsStatus
				, spsc.ReflectionComments
				, spsc.ReflectionStatus
				, spsc.RiskFactorsComments
				, spsc.RiskFactorsStatus
				, spsc.TrackingDataComments
				, spsc.TrackingDataStatus
				, PC1ID
		from			Supervision s
	inner join		cteLastSupervision ls on s.SupervisionPK = ls.SupervisionPK
	inner join SupervisionParentSurveyCase spsc on spsc.SupervisionFK = s.SupervisionPK
	left outer join CaseProgram cp on cp.HVCaseFK = spsc.HVCaseFK ;
end

GO
