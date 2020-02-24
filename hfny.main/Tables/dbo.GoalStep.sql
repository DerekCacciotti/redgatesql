CREATE TABLE [dbo].[GoalStep]
(
[GoalStepPK] [int] NOT NULL IDENTITY(1, 1),
[GoalStepCreateDate] [datetime] NOT NULL CONSTRAINT [DF_GoalStep_GoalStepCreateDate] DEFAULT (getdate()),
[GoalStepCreator] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GoalStepEditDate] [datetime] NULL,
[GoalStepEditor] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StepAchieved] [bit] NOT NULL,
[StepAnticipatedAchievementDate] [datetime] NOT NULL,
[StepDescription] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StepNum] [int] NOT NULL,
[GoalPlanFK] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Benjamin Simmons
-- Create date: 05/31/18
-- Description:	This trigger records the deletion of a goal step row
-- =============================================
CREATE TRIGGER [dbo].[fr_delete_GoalStep]
   ON  [dbo].[GoalStep]
   AFTER DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
	INSERT INTO dbo.GoalStepDeleted
	(
	    GoalStepPK,
		Deleted,
		StepAchieved,
		StepNum,
	    StepDescription,
	    StepAnticipatedAchievementDate,
	    GoalStepCreateDate,
	    GoalStepCreator,
	    GoalStepEditDate,
	    GoalStepEditor,
	    GoalPlanFK
	)
	SELECT 
	    GoalStepPK,
		1, --This was a delete
		StepAchieved,
		StepNum,
	    StepDescription,
	    StepAnticipatedAchievementDate,
	    GoalStepCreateDate,
	    GoalStepCreator,
	    GoalStepEditDate,
	    GoalStepEditor,
	    GoalPlanFK
	FROM Deleted
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 6/20/18
-- Description:	This trigger writes edits to the Deleted table
-- with the delete flag set to false as per Chris's advice
-- =============================================
CREATE TRIGGER [dbo].[TR_GoalStepEdited]
ON [dbo].[GoalStep]
AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE dbo.GoalStep Set GoalStepEditDate = GETDATE() 
	FROM dbo.GoalStep gs 
	INNER JOIN Inserted i ON i.GoalStepPK = gs.GoalStepPK

    -- Insert the edit into the deleted table
	INSERT INTO dbo.GoalStepDeleted
	(
	    GoalStepPK,
		Deleted,
		StepAchieved,
		StepNum,
	    StepDescription,
	    StepAnticipatedAchievementDate,
	    GoalStepCreateDate,
	    GoalStepCreator,
	    GoalStepEditDate,
	    GoalStepEditor,
	    GoalPlanFK
	)
	SELECT 
	    d.GoalStepPK,
		0, --This was and edit, not a delete
		d.StepAchieved,
		d.StepNum,
	    d.StepDescription,
	    d.StepAnticipatedAchievementDate,
	    d.GoalStepCreateDate,
	    d.GoalStepCreator,
	    d.GoalStepEditDate,
	    d.GoalStepEditor,
	    d.GoalPlanFK
		FROM dbo.GoalStep gs
		INNER JOIN Deleted d ON d.GoalStepPK = gs.GoalStepPK
END
GO
ALTER TABLE [dbo].[GoalStep] ADD CONSTRAINT [PK_GoalStep] PRIMARY KEY CLUSTERED  ([GoalStepPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GoalStep] ADD CONSTRAINT [FK_GoalStep_GoalPlan] FOREIGN KEY ([GoalPlanFK]) REFERENCES [dbo].[GoalPlan] ([GoalPlanPK])
GO
