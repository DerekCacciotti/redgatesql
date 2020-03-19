CREATE TABLE [dbo].[GoalStepDeleted]
(
[GoalStepDeletedPK] [int] NOT NULL IDENTITY(1, 1),
[GoalStepPK] [int] NOT NULL,
[Deleted] [bit] NULL CONSTRAINT [DF_GoalStepDeleted_Deleted] DEFAULT ((0)),
[GoalStepCreateDate] [datetime] NOT NULL,
[GoalStepCreator] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GoalStepDeleteDate] [datetime] NULL CONSTRAINT [DF_GoalStepDeleted_GoalStepDeleteDate] DEFAULT (getdate()),
[GoalStepDeleter] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GoalStepEditDate] [datetime] NULL,
[GoalStepEditor] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StepAchieved] [bit] NOT NULL,
[StepAnticipatedAchievementDate] [datetime] NOT NULL,
[StepDescription] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GoalPlanFK] [int] NOT NULL,
[StepNum] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GoalStepDeleted] ADD CONSTRAINT [PK_GoalStepDeleted] PRIMARY KEY CLUSTERED  ([GoalStepDeletedPK]) ON [PRIMARY]
GO
