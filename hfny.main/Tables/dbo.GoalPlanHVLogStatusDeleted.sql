CREATE TABLE [dbo].[GoalPlanHVLogStatusDeleted]
(
[GoalPlanHVLogStatusDeletedPK] [int] NOT NULL IDENTITY(1, 1),
[GoalPlanHVLogStatusPK] [int] NOT NULL,
[Deleted] [bit] NULL CONSTRAINT [DF_GoalPlanHVLogStatusDeleted_Deleted] DEFAULT ((0)),
[DevelopmentSinceLastVisit] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GoalPlanHVLogStatusCreateDate] [datetime] NOT NULL,
[GoalPlanHVLogStatusCreator] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GoalPlanHVLogStatusDeleteDate] [datetime] NULL CONSTRAINT [DF_GoalPlanHVLogStatusDeleted_GoalPlanHVLogStatusDeleteDate] DEFAULT (getdate()),
[GoalPlanHVLogStatusDeleter] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GoalPlanHVLogStatusEditDate] [datetime] NULL,
[GoalPlanHVLogStatusEditor] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GoalProblemSolvingAndPlanEdit] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NextStepEdit] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GoalPlanFK] [int] NOT NULL,
[HVLogFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GoalPlanHVLogStatusDeleted] ADD CONSTRAINT [PK_GoalPlanHVLogStatusDeleted] PRIMARY KEY CLUSTERED  ([GoalPlanHVLogStatusDeletedPK]) ON [PRIMARY]
GO
