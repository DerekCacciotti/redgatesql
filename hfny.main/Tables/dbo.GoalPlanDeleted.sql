CREATE TABLE [dbo].[GoalPlanDeleted]
(
[GoalPlanDeletedPK] [int] NOT NULL IDENTITY(1, 1),
[GoalPlanPK] [int] NOT NULL,
[AnticipatedAchievementDate] [datetime] NOT NULL,
[Deleted] [bit] NULL CONSTRAINT [DF_GoalPlanDeleted_Deleted] DEFAULT ((0)),
[GoalArea] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GoalCreationDiscussion] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GoalName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GoalPlanActive] [bit] NOT NULL,
[GoalPlanCreateDate] [datetime] NOT NULL,
[GoalPlanCreator] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GoalPlanDeleteDate] [datetime] NULL CONSTRAINT [DF_GoalPlanDeleted_GoalPlanDeleteDate] DEFAULT (getdate()),
[GoalPlanDeleter] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GoalPlanEditDate] [datetime] NULL,
[GoalPlanEditor] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GoalPertainsTo] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GoalPertainsToSpecify] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GoalProblemSolvingAndPlan] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GoalStatement] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GoalStatus] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GoalStatusDate] [datetime] NULL,
[NextStep] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProtectiveFactors] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StartDate] [datetime] NOT NULL,
[HVCaseFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GoalPlanDeleted] ADD CONSTRAINT [PK_GoalPlanDeleted] PRIMARY KEY CLUSTERED  ([GoalPlanDeletedPK]) ON [PRIMARY]
GO
