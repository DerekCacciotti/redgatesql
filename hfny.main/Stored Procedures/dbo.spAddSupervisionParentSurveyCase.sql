SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddSupervisionParentSurveyCase](@AssessmentIssues bit=NULL,
@AssessmentIssuesComments varchar(max)=NULL,
@AssessmentIssuesStatus bit=NULL,
@AssessmentScreens bit=NULL,
@AssessmentScreensComments varchar(max)=NULL,
@AssessmentScreensStatus bit=NULL,
@CaseComments varchar(max)=NULL,
@CommunityResources bit=NULL,
@CommunityResourcesComments varchar(max)=NULL,
@CommunityResourcesStatus bit=NULL,
@CulturalSensitivity bit=NULL,
@CulturalSensitivityComments varchar(max)=NULL,
@CulturalSensitivityStatus bit=NULL,
@HVCaseFK int=NULL,
@InterRaterReliability bit=NULL,
@InterRaterReliabilityComments varchar(max)=NULL,
@InterRaterReliabilityStatus bit=NULL,
@ProgramFK int=NULL,
@ProtectiveFactors bit=NULL,
@ProtectiveFactorsComments varchar(max)=NULL,
@ProtectiveFactorsStatus bit=NULL,
@Referrals bit=NULL,
@ReferralsComments varchar(max)=NULL,
@ReferralsStatus bit=NULL,
@Reflection bit=NULL,
@ReflectionComments varchar(max)=NULL,
@ReflectionStatus bit=NULL,
@RiskFactors bit=NULL,
@RiskFactorsComments varchar(max)=NULL,
@RiskFactorsStatus bit=NULL,
@SupervisionFK int=NULL,
@TrackingData bit=NULL,
@TrackingDataComments varchar(max)=NULL,
@TrackingDataStatus bit=NULL)
AS
INSERT INTO SupervisionParentSurveyCase(
AssessmentIssues,
AssessmentIssuesComments,
AssessmentIssuesStatus,
AssessmentScreens,
AssessmentScreensComments,
AssessmentScreensStatus,
CaseComments,
CommunityResources,
CommunityResourcesComments,
CommunityResourcesStatus,
CulturalSensitivity,
CulturalSensitivityComments,
CulturalSensitivityStatus,
HVCaseFK,
InterRaterReliability,
InterRaterReliabilityComments,
InterRaterReliabilityStatus,
ProgramFK,
ProtectiveFactors,
ProtectiveFactorsComments,
ProtectiveFactorsStatus,
Referrals,
ReferralsComments,
ReferralsStatus,
Reflection,
ReflectionComments,
ReflectionStatus,
RiskFactors,
RiskFactorsComments,
RiskFactorsStatus,
SupervisionFK,
TrackingData,
TrackingDataComments,
TrackingDataStatus
)
VALUES(
@AssessmentIssues,
@AssessmentIssuesComments,
@AssessmentIssuesStatus,
@AssessmentScreens,
@AssessmentScreensComments,
@AssessmentScreensStatus,
@CaseComments,
@CommunityResources,
@CommunityResourcesComments,
@CommunityResourcesStatus,
@CulturalSensitivity,
@CulturalSensitivityComments,
@CulturalSensitivityStatus,
@HVCaseFK,
@InterRaterReliability,
@InterRaterReliabilityComments,
@InterRaterReliabilityStatus,
@ProgramFK,
@ProtectiveFactors,
@ProtectiveFactorsComments,
@ProtectiveFactorsStatus,
@Referrals,
@ReferralsComments,
@ReferralsStatus,
@Reflection,
@ReflectionComments,
@ReflectionStatus,
@RiskFactors,
@RiskFactorsComments,
@RiskFactorsStatus,
@SupervisionFK,
@TrackingData,
@TrackingDataComments,
@TrackingDataStatus
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
