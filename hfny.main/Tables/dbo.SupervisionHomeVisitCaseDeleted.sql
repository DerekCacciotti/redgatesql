CREATE TABLE [dbo].[SupervisionHomeVisitCaseDeleted]
(
[SupervisionHomeVisitCaseDeletedPK] [int] NOT NULL IDENTITY(1, 1),
[SupervisionHomeVisitCasePK] [int] NOT NULL,
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
[SupervisionHomeVisitCaseCreateDate] [datetime] NULL,
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
ALTER TABLE [dbo].[SupervisionHomeVisitCaseDeleted] ADD CONSTRAINT [PK_SupervisionHomeVisitCaseDeleted] PRIMARY KEY CLUSTERED  ([SupervisionHomeVisitCaseDeletedPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_SupervisionHomeVisitCaseDeleted_1] ON [dbo].[SupervisionHomeVisitCaseDeleted] ([HVCaseFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_SupervisionHomeVisitCaseDeleted] ON [dbo].[SupervisionHomeVisitCaseDeleted] ([SupervisionFK]) ON [PRIMARY]
GO
