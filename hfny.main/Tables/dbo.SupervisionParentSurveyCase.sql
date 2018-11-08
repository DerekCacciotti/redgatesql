CREATE TABLE [dbo].[SupervisionParentSurveyCase]
(
[SupervisionParentSurveyCasePK] [int] NOT NULL IDENTITY(1, 1),
[AssessmentIssues] [bit] NULL,
[AssessmentIssuesComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AssessmentIssuesStatus] [bit] NULL,
[AssessmentRate] [bit] NULL,
[AssessmentRateComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AssessmentRateStatus] [bit] NULL,
[AssessmentScreens] [bit] NULL,
[AssessmentScreensComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AssessmentScreensStatus] [bit] NULL,
[CaseComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CommunityResources] [bit] NULL,
[CommunityResourcesComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CommunityResourcesStatus] [bit] NULL,
[CulturalSensitivity] [bit] NULL,
[CulturalSensitivityComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CulturalSensitivityStatus] [bit] NULL,
[FollowUpPSCase] [bit] NULL,
[HVCaseFK] [int] NOT NULL,
[InterRaterReliability] [bit] NULL,
[InterRaterReliabilityComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InterRaterReliabilityStatus] [bit] NULL,
[ProgramFK] [int] NOT NULL,
[ProtectiveFactors] [bit] NULL,
[ProtectiveFactorsComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProtectiveFactorsStatus] [bit] NULL,
[Referrals] [bit] NULL,
[ReferralsComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReferralsStatus] [bit] NULL,
[Reflection] [bit] NULL,
[ReflectionComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReflectionStatus] [bit] NULL,
[RiskFactors] [bit] NULL,
[RiskFactorsComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RiskFactorsStatus] [bit] NULL,
[SupervisionFK] [int] NOT NULL,
[TrackingData] [bit] NULL,
[TrackingDataComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrackingDataStatus] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SupervisionParentSurveyCase] ADD CONSTRAINT [PK_SupervisionParentSurveyCase] PRIMARY KEY CLUSTERED  ([SupervisionParentSurveyCasePK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SupervisionParentSurveyCase] WITH NOCHECK ADD CONSTRAINT [FK_SupervisionParentSurveyCase_SupervisionFK] FOREIGN KEY ([SupervisionFK]) REFERENCES [dbo].[Supervision] ([SupervisionPK])
GO
