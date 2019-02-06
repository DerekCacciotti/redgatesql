CREATE TABLE [dbo].[SupervisionHomeVisitCase]
(
[SupervisionHomeVisitCasePK] [int] NOT NULL IDENTITY(1, 1),
[CaseComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChallengingIssues] [bit] NULL,
[ChallengingIssuesComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChallengingIssuesStatus] [bit] NULL,
[CHEERSFeedback] [bit] NULL,
[CHEERSFeedbackComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CHEERSFeedbackStatus] [bit] NULL,
[FGPProgress] [bit] NULL,
[FGPProgressComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FGPProgressStatus] [bit] NULL,
[FollowUpHVCase] [bit] NULL,
[HVCaseFK] [int] NOT NULL,
[HVReferrals] [bit] NULL,
[HVReferralsComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HVReferralsStatus] [bit] NULL,
[LevelChange] [bit] NULL,
[LevelChangeComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LevelChangeStatus] [bit] NULL,
[Medical] [bit] NULL,
[MedicalComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MedicalStatus] [bit] NULL,
[ProgramFK] [int] NOT NULL,
[ServicePlan] [bit] NULL,
[ServicePlanComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ServicePlanStatus] [bit] NULL,
[SupervisionFK] [int] NOT NULL,
[SupervisionHomeVisitCaseCreateDate] [datetime] NULL CONSTRAINT [DF_SupervisionHomeVisitCase_SupervisionHomeVisitCaseCreateDate] DEFAULT (getdate()),
[SupervisionHomeVisitCaseCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SupervisionHomeVisitCaseEditDate] [datetime] NULL,
[SupervisionHomeVisitCaseEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Tools] [bit] NULL,
[ToolsComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ToolsStatus] [bit] NULL,
[TransitionPlanning] [bit] NULL,
[TransitionPlanningComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TransitionPlanningStatus] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SupervisionHomeVisitCase] ADD CONSTRAINT [PK_SupervisionHomeVisitCase] PRIMARY KEY CLUSTERED  ([SupervisionHomeVisitCasePK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SupervisionHomeVisitCase] ADD CONSTRAINT [FK_SupervisionHomeVisitCase_SupervisionFK] FOREIGN KEY ([SupervisionFK]) REFERENCES [dbo].[Supervision] ([SupervisionPK])
GO
