CREATE TABLE [dbo].[SupervisionParentSurveyCaseDeleted]
(
[SupervisionParentSurveyCaseDeletedPK] [int] NOT NULL IDENTITY(1, 1),
[SupervisionParentSurveyCasePK] [int] NOT NULL,
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
[SupervisionParentSurveyCaseCreateDate] [datetime] NULL,
[SupervisionParentSurveyCaseCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SupervisionParentSurveyCaseEditDate] [datetime] NULL,
[SupervisionParentSurveyCaseEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SupervisionParentSurveyCaseDeleted] ADD CONSTRAINT [PK_SupervisionParentSurveyCaseDeleted] PRIMARY KEY CLUSTERED  ([SupervisionParentSurveyCaseDeletedPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_SupervisionParentSurveyCaseDeleted_1] ON [dbo].[SupervisionParentSurveyCaseDeleted] ([HVCaseFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_SupervisionParentSurveyCaseDeleted] ON [dbo].[SupervisionParentSurveyCaseDeleted] ([SupervisionFK]) ON [PRIMARY]
GO
