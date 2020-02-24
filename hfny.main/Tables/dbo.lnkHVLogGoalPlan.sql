CREATE TABLE [dbo].[lnkHVLogGoalPlan]
(
[lnkHVLogGoalPlanPK] [int] NOT NULL IDENTITY(1, 1),
[HVLogFK] [int] NOT NULL,
[GoalPlanFK] [int] NOT NULL,
[NotDiscussed] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[lnkHVLogGoalPlan] ADD CONSTRAINT [PK_lnkHVLogGoalPlan] PRIMARY KEY CLUSTERED  ([lnkHVLogGoalPlanPK]) ON [PRIMARY]
GO
