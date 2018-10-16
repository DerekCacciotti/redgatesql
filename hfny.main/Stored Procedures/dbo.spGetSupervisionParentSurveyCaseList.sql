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
create procedure [dbo].[spGetSupervisionParentSurveyCaseList] (@SupervisionFK int)
as begin
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	set noCount on ;

	select	SupervisionParentSurveyCasePK
		, AssessmentIssues
		, AssessmentIssuesComments
		, AssessmentIssuesStatus
		, AssessmentScreens
		, AssessmentScreensComments
		, AssessmentScreensStatus
		, CaseComments
		, CommunityResources
		, CommunityResourcesComments
		, CommunityResourcesStatus
		, CulturalSensitivity
		, CulturalSensitivityComments
		, CulturalSensitivityStatus
		, HVCaseFK
		, InterRaterReliability
		, InterRaterReliabilityComments
		, InterRaterReliabilityStatus
		, ProgramFK
		, ProtectiveFactors
		, ProtectiveFactorsComments
		, ProtectiveFactorsStatus
		, Referrals
		, ReferralsComments
		, ReferralsStatus
		, Reflection
		, ReflectionComments
		, ReflectionStatus
		, RiskFactors
		, RiskFactorsComments
		, RiskFactorsStatus
		, SupervisionFK
		, TrackingData
		, TrackingDataComments
		, TrackingDataStatus
	from	SupervisionParentSurveyCase sc
	where	sc.SupervisionFK = @SupervisionFK ;
end ;
GO
