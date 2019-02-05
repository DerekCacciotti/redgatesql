CREATE TABLE [dbo].[SupervisionParentSurveyCase]
(
[SupervisionParentSurveyCasePK] [int] NOT NULL IDENTITY(1, 1),
[AssessmentIssues] [bit] NULL,
[AssessmentIssuesComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AssessmentIssuesStatus] [bit] NULL,
[CaseComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FollowUpPSCase] [bit] NULL,
[HVCaseFK] [int] NOT NULL,
[ProgramFK] [int] NOT NULL,
[ProtectiveFactors] [bit] NULL,
[ProtectiveFactorsComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProtectiveFactorsStatus] [bit] NULL,
[PSServicePlan] [bit] NULL,
[PSServicePlanComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSServicePlanStatus] [bit] NULL,
[Referrals] [bit] NULL,
[ReferralsComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReferralsStatus] [bit] NULL,
[RiskFactors] [bit] NULL,
[RiskFactorsComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RiskFactorsStatus] [bit] NULL,
[SupervisionFK] [int] NOT NULL,
[SupervisionParentSurveyCaseCreateDate] [datetime] NULL CONSTRAINT [DF_SupervisionParentSurveyCase_SupervisionParentSurveyCaseCreateDate] DEFAULT (getdate()),
[SupervisionParentSurveyCaseCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SupervisionParentSurveyCaseEditDate] [datetime] NULL,
[SupervisionParentSurveyCaseEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SupervisionParentSurveyCase] ADD CONSTRAINT [PK_SupervisionParentSurveyCase] PRIMARY KEY CLUSTERED  ([SupervisionParentSurveyCasePK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SupervisionParentSurveyCase] ADD CONSTRAINT [FK_SupervisionParentSurveyCase_SupervisionFK] FOREIGN KEY ([SupervisionFK]) REFERENCES [dbo].[Supervision] ([SupervisionPK])
GO
